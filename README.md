# Pomodoro Focus for KDE Plasma

A native Plasma 6 panel widget that keeps your current focus and live Pomodoro countdown one click away.

### Compact panel

<p align="center">
  <img src="screenshots/pomodoro-panel.png" alt="Pomodoro Focus compact horizontal panel layout showing progress, countdown, daily count, and focus description" width="480">
</p>

### Popup controls

<p align="center">
  <img src="screenshots/pomodoro-focus.png" alt="Pomodoro Focus popup showing the timer, current focus, session progress, and controls" width="520">
</p>

## Quick install

Requires KDE Plasma 6, `curl`, and `kpackagetool6`.

```sh
curl -fsSL https://raw.githubusercontent.com/cromewar/kde-pomodoro/main/install.sh | bash
```

Then right-click your panel, choose **Enter Edit Mode** → **Add Widgets**, search for **Pomodoro Focus**, and drag it onto any panel. Run the same command again whenever you want to update the widget.

## Features

- Live countdown and circular progress indicator directly on horizontal or vertical panels
- Focus, short-break, and long-break phases
- Estimated finish time for the running interval, shown in the popup and the tooltip in your local 12- or 24-hour format
- Editable current-focus description in the popup, tooltip, and horizontal panel
- Focus, short-break, and long-break durations set in the widget settings dialog
- Configurable number of focus sessions before a long break
- Built-in interval presets — Classic (25/5/15), Deep work (50/10/30), and Long haul (90/20/30) — switchable from the right-click menu or the settings dialog
- Start, pause, restart, and skip controls in the popup, mirrored in the right-click menu
- Optional auto-start of breaks and of focus intervals, toggled independently in the settings dialog
- Daily Pomodoro count with automatic midnight reset, plus a manual reset in the right-click menu
- Lifetime focus total alongside today's count in the tooltip
- Audible Plasma notifications with an action to start the next interval
- Timer deadline and cycle state preserved across Plasma shell restarts
- Native Plasma styling that follows your color scheme

## Manual install

Clone the repository and install the package:

```sh
git clone https://github.com/cromewar/kde-pomodoro.git
cd kde-pomodoro
kpackagetool6 --type Plasma/Applet --install .
```

To upgrade a manual installation:

```sh
kpackagetool6 --type Plasma/Applet --upgrade .
```

To uninstall:

```sh
kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.pomodoro
```

## Development

Preview the installed widget in a standalone Plasma window:

```sh
plasmawindowed org.kde.plasma.pomodoro
```

The package targets Plasma 6 (`X-Plasma-API-Minimum-Version: 6.0`) and uses only QML and standard KDE Frameworks components.

## Inspiration

The focus-naming workflow takes inspiration from [Session](https://www.stayinsession.com/), while the minimal recurring timer flow takes inspiration from [Flow](https://www.flow.app/). This project is independent and includes no source code or assets from either application.

## License

[MIT](LICENSE)
