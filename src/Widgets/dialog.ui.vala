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
            event_date_day_entry.max_length = 2;
            event_date_month_entry.max_length = 2;
            event_date_year_entry.max_length = 4;
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
            var d = new DateTime.local (int.parse(event_date_year_entry.get_text ()),
                                        int.parse(event_date_month_entry.get_text ()),
                                        int.parse(event_date_day_entry.get_text ()),
                                        0,
                                        0,
                                        0.0);
            if (d == null) return;

            var event = new Event ();
            event.title = event_name_entry.get_text ();
            event.date = d;

            GLib.TimeSpan res = 0;
            var e = new GLib.DateTime.now_local ();

            res = d.difference(e) / 86400000000;
            
            if (res <= 0) {
                event.passed = true;
                pvm.create_new_event (event);
            } else {
                event.passed = false;
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
