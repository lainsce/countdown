namespace Countdown {
    [GtkTemplate (ui = "/io/github/lainsce/Countdown/dialog.ui")]
    public class Widgets.Dialog : Adw.Window {
        [GtkChild]
        public unowned Gtk.Button new_button;
        [GtkChild]
        public unowned Gtk.Entry event_name_entry;
        [GtkChild]
        public unowned Gtk.Entry event_date_day_entry;
        [GtkChild]
        public unowned Gtk.Entry event_date_month_entry;
        [GtkChild]
        public unowned Gtk.Entry event_date_year_entry;

        public EventViewModel vm { get; construct; }
        public PastEventViewModel pvm { get; construct; }

        public Dialog (EventViewModel vm, PastEventViewModel pvm) {
            Object (
                vm: vm,
                pvm: pvm
            );
        }

        construct {
            event_name_entry.notify["text"].connect (() => {
                event_date_year_entry.notify["text"].connect (() => {
                    if (event_name_entry.get_text () != "") {
                        new_button.sensitive = true;
                    } else {
                        new_button.sensitive = false;
                    }
                });
            });
        }

        [GtkCallback]
        public void on_new_event_requested () {
            var event = new Event ();
            event.title = event_name_entry.get_text ();
            event.date = event_date_day_entry.get_text () + "/" + event_date_month_entry.get_text () + "/" + event_date_year_entry.get_text ();
            
            GLib.TimeSpan res = 0;
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

                    res = d.difference(e) / 86400000000;
                }
            } catch (GLib.RegexError re) {
                warning ("%s".printf(re.message));
            }
            
            if (res < 0) {
                pvm.create_new_event (event);
            } else {
                vm.create_new_event (event);
            }
            this.dispose ();
        }

        [GtkCallback]
        public void on_cancel_requested () {
            this.dispose ();
        }
    }
}
