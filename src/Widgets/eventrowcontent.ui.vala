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
[GtkTemplate (ui = "/io/github/lainsce/Countdown/eventrowcontent.ui")]
public class Countdown.EventRowContent : Adw.Bin {
    Event? _event;
    public Event? event {
        get { return _event; }
        set {
            if (value == _event)
                return;

            _event = value;
        }
    }

    public EventRowContent (Event event) {
        Object(
            event: event
        );
    }

    [GtkCallback]
    string get_date_line () {
        var res = "";
        try {
            var reg = new Regex("""(?m)(?<day>\d{2})/(?<month>\d{2})/(?<year>\d{4})""");
            GLib.MatchInfo match;

            if (reg.match (event.date, 0, out match)) {
                var e = new GLib.DateTime.now_local ();
                var d = new DateTime.local (int.parse(match.fetch_named ("year")),
                                            int.parse(match.fetch_named ("month")),
                                            int.parse(match.fetch_named ("day")),
                                            0,
                                            0,
                                            0.0);

                res = "%s".printf(((d.difference(e) / 86400000000).to_string()));
            }
        } catch (GLib.RegexError re) {
            warning ("%s".printf(re.message));
        }
        
        if (int.parse(res) < 0) {
            return (int.parse(res) * -1).to_string() + "\ndays"; 
        } else {
            return res + "\ndays";
        }
    }
}
