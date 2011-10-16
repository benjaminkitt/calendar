//
//  Copyright (C) 2011 Jaap Broekhuizen
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Gtk;
using Gdk;
using GLib;

using Granite;
using Granite.Services;

using Maya;
using Maya.Services;

namespace Maya.Widgets {

	public class ContractorButtonWithMenu : Granite.Widgets.ToolButtonWithMenu {

		private MayaWindow window;

		private Maya.Services.Contractor contract;
		private HashTable<string,string>[] services;

		public ContractorButtonWithMenu (MayaWindow window) {

		    base (new Image.from_icon_name ("document-export", IconSize.MENU), "Share", new Menu());
			this.window = window;

			// try to connect
			try {
                contract = Bus.get_proxy_sync (BusType.SESSION,
                                               "org.elementary.contractor",
                                               "/org/elementary/contractor");

		        // get the list and parse it into the menu
		        services = contract.GetServicesByLocation ("file:///usr/share/contractor/");

                foreach (HashTable<string,string> service in services) {
                    MenuItem item = new MenuItem.with_label(service.lookup ("Description"));
                    item.activate.connect (activate_contract);
                    menu.append (item);
                }
            } catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }

		}

		private void activate_contract () {

		    MenuItem menuitem = (MenuItem) menu.get_active();
            string app_menu = menuitem.get_label();

		    foreach (HashTable<string,string> service in services) {
                if (app_menu == service.lookup ("Description")) {
                    try {
                        GLib.Process.spawn_command_line_async (service.lookup ("Exec"));
                    } catch (SpawnError e) {
                        stderr.printf ("%s\n", e.message);
                    }

                    break;
                }
            }
		}

	}

}

