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
class Countdown.EventSorter : Gtk.Sorter {
  protected override Gtk.Ordering compare (Object? item1, Object? item2) {
    var event1 = item1 as Event;
    var event2 = item2 as Event;

    var d = new DateTime.local (int.parse(event1.date.substring (6,4)),
                                int.parse(event1.date.substring (3,2)),
                                int.parse(event1.date.substring (0,2)),
                                0,
                                0,
                                0.0);
    var f = new DateTime.local (int.parse(event2.date.substring (6,4)),
                                int.parse(event2.date.substring (3,2)),
                                int.parse(event2.date.substring (0,2)),
                                0,
                                0,
                                0.0);

    var df = d.difference(f) / 86400000000;
    var fd = f.difference(d) / 86400000000;

    if (df > fd) {
        return LARGER;
    } else if (df < fd) {
        return SMALLER;
    } else {
        return Gtk.Ordering.from_cmpfunc (event1.date.collate (event2.date));
    }
  }

  protected override Gtk.SorterOrder get_order () {
    return TOTAL;
  }
}
