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
namespace Countdown {
    public class Event : Object, Json.Serializable {
        public string id { get; set; default = Uuid.string_random (); }
        public string title { get; set; }
        public DateTime date { get; set; }
        public bool passed { get; set; }

        public static Event from_json (Json.Node node) requires (node.get_node_type () == OBJECT) {
            return (Event) Json.gobject_deserialize (typeof (Event), node);
        }

        public static List<Event> list_from_json (Json.Node node) requires (node.get_node_type () == ARRAY) {
            var result = new List<Event> ();

            var json_array = node.get_array ();
            json_array.foreach_element ((_, __, element_node) => {
                result.append (Event.from_json (element_node));
            });

            return (owned) result;
        }

        public Json.Node to_json () {
            return Json.gobject_serialize (this);
        }

        bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
            if (property_name == "date") {
                if (property_node.get_string ().length == 0) return false;

                string[] d = property_node.get_string ().split ("-", 2);
                var date = new DateTime.from_iso8601 ("%04d-%s".printf (int.parse (d[0]), d[1]), null);
                if (date == null) return false;

                var vout = Value (typeof (DateTime));
                vout.set_boxed (date);
                @value = vout;

                return true;
            } else {
                return default_deserialize_property (property_name, out @value, pspec, property_node);
            }
        }

        Json.Node serialize_property (string property_name, Value @value, ParamSpec pspec) {
            if (property_name == "date") {
                var dt = @value as DateTime;
                var node = new Json.Node (VALUE);
                var date = "";
                if (dt != null) date = dt.to_string();
                node.set_string (date);

                return node;
            } else {
                return default_serialize_property (property_name, @value, pspec);
            }
        }
    }
}
