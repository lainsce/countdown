/*
* Copyright (C) 2022 Lains
*
* This program is free software; you can redistribute it &&/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
public class Countdown.PastEventRepository : Object {
    const string FILENAME = "saved_events_past.json";

    Queue<Event> insert_queue = new Queue<Event> ();
    public Queue<Event> update_queue = new Queue<Event> ();
    Queue<string> delete_queue = new Queue<string> ();

    public async List<Event> get_events () {
        try {
            var contents = yield FileUtils.read_text_file (FILENAME);

            if (contents == null)
                return new List<Event> ();

            var json = Json.from_string (contents);

            if (json.get_node_type () != ARRAY)
                return new List<Event> ();

            return Event.list_from_json (json);
        } catch (Error err) {
            critical ("Error: %s", err.message);
            return new List<Event> ();
        }
    }

    public void insert_event (Event event) {
        insert_queue.push_tail (event);
    }

    public void update_event (Event event) {
        update_queue.push_tail (event);
    }

    public void delete_event (string id) {
        delete_queue.push_tail (id);
    }

    public async bool save () {
        var events = yield get_events ();

        Event? event = null;
        while ((event = update_queue.pop_head ()) != null) {
            var current_event = search_event_by_id (events, event.id);

            if (current_event == null) {
                insert_queue.push_tail (event);
                continue;
            }
            current_event.title = event.title;
            current_event.date = event.date;
        }

        string? event_id = null;
        while ((event_id = delete_queue.pop_head ()) != null) {
            event = search_event_by_id (events, event_id);

            if (event == null)
                continue;

            events.remove (event);
        }

        event = null;
        while ((event = insert_queue.pop_head ()) != null)
            events.append (event);

        var json_array = new Json.Array ();
        foreach (var item in events)
            json_array.add_element (item.to_json ());

        var node = new Json.Node (ARRAY);
        node.set_array (json_array);

        var str = Json.to_string (node, false);

        try {
            return yield FileUtils.create_text_file (FILENAME, str);
        } catch (Error err) {
              critical ("Error: %s", err.message);
              return false;
        }
    }

    public inline Event? search_event_by_id (List<Event> events, string id) {
        unowned var link = events.search<string> (id, (event, id) => strcmp (event.id, id));
        return link?.data;
    }
}
