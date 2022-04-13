public class Countdown.Application : Adw.Application {
    private const GLib.ActionEntry app_entries[] = {
        { "quit", quit },
    };

    public Application () {
        Object (application_id: Config.APP_ID);
    }
    public static int main (string[] args) {
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        var app = new Countdown.Application ();
        return app.run (args);
    }
    protected override void startup () {
        resource_base_path = "/io/github/lainsce/Countdown";

        base.startup ();

        add_action_entries (app_entries, this);

        typeof (UpcomingListView).ensure ();

        var repo = new EventRepository ();
        var view_model = new EventViewModel (repo);
        
        var prepo = new PastEventRepository ();
        var pview_model = new PastEventViewModel (prepo);

        new MainWindow (this, view_model, pview_model);
    }
    protected override void activate () {
        active_window?.present ();
    }
}
