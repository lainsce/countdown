namespace Countdown {
    [GtkTemplate (ui = "/io/github/lainsce/Countdown/dialog.ui")]
    public class Widgets.Dialog : Adw.Window {
        [GtkChild]
        public unowned Gtk.Button new_button;
        [GtkChild]
        public unowned Gtk.Entry event_name_entry;
        [GtkChild]
        public unowned Gtk.Entry event_date_entry;

        public EventViewModel vm { get; construct; }

        public Dialog (EventViewModel vm) {
            Object (
                vm: vm
            );
        }

        construct {
            event_name_entry.notify["text"].connect (() => {
                event_date_entry.notify["text"].connect (() => {
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
            event.date = event_date_entry.get_text ();

            vm.create_new_event (event);
            this.dispose ();
        }

        [GtkCallback]
        public void on_cancel_requested () {
            this.dispose ();
        }
    }
}
