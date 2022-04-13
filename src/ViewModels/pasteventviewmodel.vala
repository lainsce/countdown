/*
* Copyright (C) 2017-2022 Lains
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
public class Countdown.PastEventViewModel : Object {
    uint timeout_id = 0;

    public ObservableList<Event> events { get; default = new ObservableList<Event> (); }
    public PastEventRepository? repository { private get; construct; }

    public PastEventViewModel (PastEventRepository repository) {
        Object (repository: repository);
    }

    construct {
        populate_events.begin ();
    }

    public void create_new_event (Event? event) {
        events.add (event);
        repository.insert_event (event);
        save_events ();
    }

    public void update_event (Event event) {
        repository.update_event (event);

        save_events ();
    }

    public void delete_event (Event event) {
        events.remove (event);

        repository.delete_event (event.id);
        save_events ();
    }

    async void populate_events () {
        var events = yield repository.get_events ();
        this.events.add_all (events);
    }

    void save_events () {
        if (timeout_id != 0)
            Source.remove (timeout_id);

        timeout_id = Timeout.add (500, () => {
            timeout_id = 0;

            repository.save.begin ();

            return Source.REMOVE;
        });
    }
}
