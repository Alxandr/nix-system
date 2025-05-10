import { App } from "astal/gtk4";
import style from "./style.scss";
import Bar from "./widget/Bar";
import perMonitor from "./monitor-manager";

App.start({
	css: style,
	main() {
		perMonitor(Bar);
	},
});
