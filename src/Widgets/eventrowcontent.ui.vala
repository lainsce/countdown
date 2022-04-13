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
    [GtkChild]
	unowned Gtk.Button delete_button;

	public EventViewModel vm { get; set; }
    public PastEventViewModel pvm { get; set; }

    Event? _event;
    public Event? event {
        get { return _event; }
        set {
            if (value == _event)
                return;

            _event = value;

            delete_button.clicked.connect (() => {
                print ("Deleted event!\n");
                if (_event.passed == true) {
                    var dialog = new Gtk.MessageDialog (((MainWindow)MiscUtils.find_ancestor_of_type<MainWindow>(this)), 0, 0, 0, null);
                    dialog.modal = true;

                    dialog.set_title (_("Delete Past Event?"));
                    dialog.text = (_("Deleting this past event will not save it in the past log and will stop tracking the days since the event happened."));

                    dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
                    var no_button = dialog.add_button (_("Delete"), Gtk.ResponseType.OK);
                    no_button.get_style_context ().add_class ("destructive-action");

                    dialog.response.connect ((response_id) => {
                        switch (response_id) {
                            case Gtk.ResponseType.OK:
                                ((MainWindow)MiscUtils.find_ancestor_of_type<MainWindow>(this)).past_view_model.delete_event (_event);;
                                dialog.close ();
                                break;
                            case Gtk.ResponseType.NO:
                                dialog.close ();
                                break;
                            case Gtk.ResponseType.CANCEL:
                            case Gtk.ResponseType.CLOSE:
                            case Gtk.ResponseType.DELETE_EVENT:
                            default:
                                dialog.close ();
                                return;
                        }
                    });

                    if (dialog != null) {
                        dialog.present ();
                        return;
                    } else {
                        dialog.show ();
                    }
                } else {
                    var dialog = new Gtk.MessageDialog (((MainWindow)MiscUtils.find_ancestor_of_type<MainWindow>(this)), 0, 0, 0, null);
                    dialog.modal = true;

                    dialog.set_title (_("Delete Upcoming Event?"));
                    dialog.text = (_("Deleting this upcoming event will not save it in the upcoming log and will stop tracking the days until the event happens."));

                    dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
                    var no_button = dialog.add_button (_("Delete"), Gtk.ResponseType.OK);
                    no_button.get_style_context ().add_class ("destructive-action");

                    dialog.response.connect ((response_id) => {
                        switch (response_id) {
                            case Gtk.ResponseType.OK:
                                ((MainWindow)MiscUtils.find_ancestor_of_type<MainWindow>(this)).view_model.delete_event (_event);;
                                dialog.close ();
                                break;
                            case Gtk.ResponseType.NO:
                                dialog.close ();
                                break;
                            case Gtk.ResponseType.CANCEL:
                            case Gtk.ResponseType.CLOSE:
                            case Gtk.ResponseType.DELETE_EVENT:
                            default:
                                dialog.close ();
                                return;
                        }
                    });

                    if (dialog != null) {
                        dialog.present ();
                        return;
                    } else {
                        dialog.show ();
                    }
                }
            });
        }
    }

    public EventRowContent (Event event) {
        Object(
            event: event
        );
    }

    construct {
        Timeout.add_seconds (86399, () => {
            update_date_line (event.date);
        });
    }

    [GtkCallback]
    string get_date_line () {
        return update_date_line (event.date);
    }

    public string update_date_line (string date) {
        print ("Updated event!\n");
        var res = "";
        try {
            var reg = new Regex("""(?m)(?<day>\d{2})/(?<month>\d{2})/(?<year>\d{4})""");
            GLib.MatchInfo match;

            if (reg.match (date, 0, out match)) {
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
            return (int.parse(res) * -1).to_string();
        } else {
            return res;
        }
    }
}
