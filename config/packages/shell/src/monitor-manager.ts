import { Gio } from "astal";
import { App, Gdk, Gtk } from "astal/gtk4";

export interface PerMonitorOptions {
	filter?: (monitor: Gdk.Monitor) => boolean;
}

interface MonitorState {
	name: string;
	monitor: Gdk.Monitor;
	window: Gtk.Window | null;
}

export default function perMonitor(
	factory: (monitor: Gdk.Monitor) => Gtk.Window,
	opts: PerMonitorOptions = {}
) {
	const filter = opts.filter || (() => true);
	const monitorList = App.get_monitors()[0]
		.get_display()
		.get_monitors() as Gio.ListModel<Gdk.Monitor>;
	const states: MonitorState[] = [];

	const newMonitor = (monitor: Gdk.Monitor): MonitorState => {
		const name =
			[monitor.get_connector(), monitor.get_manufacturer(), monitor.get_model()]
				.filter(Boolean)
				.join(" ") || "Unknown";

		const enabled = filter(monitor);
		if (!enabled) {
			console.log(`Monitor ${name} is disabled by filter`);
			return { name, monitor, window: null };
		}

		console.log(`Creating window for monitor ${name}`);
		const window = factory(monitor);
		const state: MonitorState = { name, monitor, window };

		return state;
	};

	monitorList.connect(
		"items-changed",
		(
			list: Gio.ListModel<Gdk.Monitor>,
			position: number,
			removed: number,
			added: number
		) => {
			console.log(
				`monitor position: ${position}, removed: ${removed}, added: ${added}`
			);

			/* Items are added and removed from the same position, so the removals
			 * must be handled first.
			 *
			 * NOTE: remember that the items have already changed in the model when this
			 *       signal is emitted, so you can not query removed objects.
			 */
			while (removed--) {
				const removedState = states[position];
				console.log(`Monitor ${removedState.name} removed`);

				if (removedState.window) {
					removedState.window.destroy();
					removedState.window = null;
				}

				states.splice(position, 1);
			}

			/* Once the removals have been processed, the additions must be inserted
			 * at the same position.
			 */
			for (let i = 0; i < added; i++) {
				const monitor = list.get_item(position + i)!;
				const state = newMonitor(monitor);

				states.splice(position + i, 0, state);
			}
		}
	);

	for (let i = 0, l = monitorList.get_n_items(); i < l; i++) {
		const monitor = monitorList.get_item(i)!;
		const state = newMonitor(monitor);
		states.push(state);
	}
}
