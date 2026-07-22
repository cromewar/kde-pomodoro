pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.notification
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property int focusMinutes: Math.max(1, Plasmoid.configuration.focusMinutes)
    readonly property int shortBreakMinutes: Math.max(1, Plasmoid.configuration.shortBreakMinutes)
    readonly property int longBreakMinutes: Math.max(1, Plasmoid.configuration.longBreakMinutes)
    readonly property int sessionsUntilLongBreak: Math.max(1, Plasmoid.configuration.sessionsUntilLongBreak)
    readonly property string focusDescription: Plasmoid.configuration.focusDescription

    property string phase: "focus"
    property bool isRunning: false
    property int remainingSeconds: 1500
    property int phaseTotalSeconds: 1500
    property double deadlineMs: 0
    property int focusesSinceLongBreak: 0
    property int completedFocusSessions: 0
    property int completedFocusSessionsToday: 0
    property string dailyCounterDate: ""
    property string pendingNotificationPhase: ""
    property bool initialized: false

    readonly property real progress: phaseTotalSeconds > 0
        ? Math.max(0, Math.min(1, 1 - remainingSeconds / phaseTotalSeconds))
        : 0
    readonly property string formattedTime: formatTime(remainingSeconds)
    readonly property string phaseName: phase === "focus"
        ? i18n("Focus")
        : (phase === "longBreak" ? i18n("Long break") : i18n("Short break"))
    readonly property color accentColor: phase === "focus"
        ? "#e85d5d"
        : (phase === "longBreak" ? "#7765d8" : "#2f9e78")
    readonly property string notificationActionLabel: pendingNotificationPhase === "focus"
        ? i18n("Start focus")
        : (pendingNotificationPhase === "longBreak"
            ? i18n("Start long break")
            : i18n("Start break"))

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.icon: "chronometer"
    Plasmoid.status: isRunning ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.title: i18n("Pomodoro Focus")

    toolTipMainText: focusDescription.length > 0 ? focusDescription : phaseName
    toolTipSubText: i18nc("Timer phase, remaining time, state and daily count", "%1 · %2 · %3 · %4 today",
        phaseName,
        formattedTime,
        isRunning ? i18n("Running") : i18n("Paused"),
        completedFocusSessionsToday)
    toolTipTextFormat: Text.PlainText

    preferredRepresentation: Qt.application.name === "plasmawindowed"
        ? fullRepresentation
        : compactRepresentation
    compactRepresentation: CompactRepresentation {
        controller: root
    }
    fullRepresentation: FullRepresentation {
        controller: root
    }

    property PlasmaCore.Action toggleAction: PlasmaCore.Action {
        text: root.isRunning ? i18n("Pause") : i18n("Start")
        icon.name: root.isRunning ? "media-playback-pause" : "media-playback-start"
        onTriggered: root.toggleTimer()
    }

    property PlasmaCore.Action skipAction: PlasmaCore.Action {
        text: i18n("Skip interval")
        icon.name: "media-skip-forward"
        onTriggered: root.skipInterval()
    }

    property PlasmaCore.Action resetAction: PlasmaCore.Action {
        text: i18n("Restart interval")
        icon.name: "view-refresh"
        onTriggered: root.resetCurrentInterval()
    }

    Plasmoid.contextualActions: [toggleAction, skipAction, resetAction]

    function durationSecondsForPhase(targetPhase) {
        if (targetPhase === "longBreak") {
            return longBreakMinutes * 60;
        }
        if (targetPhase === "shortBreak") {
            return shortBreakMinutes * 60;
        }
        return focusMinutes * 60;
    }

    function formatTime(seconds) {
        const safeSeconds = Math.max(0, Math.floor(seconds));
        const minutes = Math.floor(safeSeconds / 60);
        const remainder = safeSeconds % 60;
        return String(minutes).padStart(2, "0") + ":" + String(remainder).padStart(2, "0");
    }

    function persistRuntime() {
        if (!initialized) {
            return;
        }
        Plasmoid.configuration.currentPhase = phase;
        Plasmoid.configuration.timerRunning = isRunning;
        Plasmoid.configuration.remainingSeconds = remainingSeconds;
        Plasmoid.configuration.phaseTotalSeconds = phaseTotalSeconds;
        Plasmoid.configuration.deadlineEpochMs = String(Math.round(deadlineMs));
        Plasmoid.configuration.focusesSinceLongBreak = focusesSinceLongBreak;
        Plasmoid.configuration.completedFocusSessions = completedFocusSessions;
        Plasmoid.configuration.completedFocusSessionsToday = completedFocusSessionsToday;
        Plasmoid.configuration.dailyCounterDate = dailyCounterDate;
        Plasmoid.configuration.writeConfig();
    }

    function localDateKey(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        return year + "-" + month + "-" + day;
    }

    function ensureDailyCounterCurrent() {
        const today = localDateKey(new Date());
        if (dailyCounterDate === today) {
            return false;
        }
        dailyCounterDate = today;
        completedFocusSessionsToday = 0;
        persistRuntime();
        return true;
    }

    function resetDailyCount() {
        dailyCounterDate = localDateKey(new Date());
        completedFocusSessionsToday = 0;
        persistRuntime();
    }

    function toggleTimer() {
        if (isRunning) {
            pauseTimer();
        } else {
            startTimer();
        }
    }

    function startTimer() {
        ensureDailyCounterCurrent();
        if (remainingSeconds <= 0 || remainingSeconds > phaseTotalSeconds) {
            phaseTotalSeconds = durationSecondsForPhase(phase);
            remainingSeconds = phaseTotalSeconds;
        }
        deadlineMs = Date.now() + remainingSeconds * 1000;
        isRunning = true;
        persistRuntime();
    }

    function pauseTimer() {
        if (!isRunning) {
            return;
        }
        remainingSeconds = Math.max(0, Math.ceil((deadlineMs - Date.now()) / 1000));
        isRunning = false;
        deadlineMs = 0;
        persistRuntime();
    }

    function resetCurrentInterval() {
        isRunning = false;
        deadlineMs = 0;
        phaseTotalSeconds = durationSecondsForPhase(phase);
        remainingSeconds = phaseTotalSeconds;
        persistRuntime();
    }

    function skipInterval() {
        moveToNextPhase(false);
    }

    function moveToNextPhase(countCompletedFocus) {
        const finishedPhase = phase;

        if (finishedPhase === "focus") {
            if (countCompletedFocus) {
                ensureDailyCounterCurrent();
                focusesSinceLongBreak += 1;
                completedFocusSessions += 1;
                completedFocusSessionsToday += 1;
            }
            phase = focusesSinceLongBreak >= sessionsUntilLongBreak ? "longBreak" : "shortBreak";
        } else {
            if (finishedPhase === "longBreak") {
                focusesSinceLongBreak = 0;
            }
            phase = "focus";
        }

        isRunning = false;
        deadlineMs = 0;
        phaseTotalSeconds = durationSecondsForPhase(phase);
        remainingSeconds = phaseTotalSeconds;
        persistRuntime();

        if (countCompletedFocus) {
            showCompletionNotification(finishedPhase);
        }
    }

    function showCompletionNotification(finishedPhase) {
        pendingNotificationPhase = phase;

        if (finishedPhase === "focus") {
            completionNotification.title = focusDescription.length > 0
                ? i18n("Focus complete: %1", focusDescription)
                : i18n("Focus complete");
            completionNotification.text = phase === "longBreak"
                ? i18n("Pomodoro %1 for today is complete. Time for a %2-minute long break.",
                    completedFocusSessionsToday, longBreakMinutes)
                : i18n("Pomodoro %1 for today is complete. Time for a %2-minute break.",
                    completedFocusSessionsToday, shortBreakMinutes);
        } else {
            completionNotification.title = i18n("Break complete");
            completionNotification.text = i18n("Your next %1-minute focus interval is ready.", focusMinutes);
        }

        completionNotification.sendEvent();
    }

    function startIntervalFromNotification(expectedPhase) {
        if (phase === expectedPhase && !isRunning) {
            startTimer();
        } else {
            expanded = true;
        }
    }

    function settingChanged(affectedPhase) {
        if (!initialized || isRunning || phase !== affectedPhase) {
            return;
        }
        phaseTotalSeconds = durationSecondsForPhase(phase);
        remainingSeconds = phaseTotalSeconds;
        deadlineMs = 0;
        persistRuntime();
    }

    function setFocusMinutes(value) {
        Plasmoid.configuration.focusMinutes = Math.max(1, value);
        Plasmoid.configuration.writeConfig();
    }

    function setShortBreakMinutes(value) {
        Plasmoid.configuration.shortBreakMinutes = Math.max(1, value);
        Plasmoid.configuration.writeConfig();
    }

    function setLongBreakMinutes(value) {
        Plasmoid.configuration.longBreakMinutes = Math.max(1, value);
        Plasmoid.configuration.writeConfig();
    }

    function setSessionsUntilLongBreak(value) {
        Plasmoid.configuration.sessionsUntilLongBreak = Math.max(1, value);
        Plasmoid.configuration.writeConfig();
    }

    function setFocusDescription(value) {
        Plasmoid.configuration.focusDescription = value.trim();
        Plasmoid.configuration.writeConfig();
    }

    onFocusMinutesChanged: settingChanged("focus")
    onShortBreakMinutesChanged: settingChanged("shortBreak")
    onLongBreakMinutesChanged: settingChanged("longBreak")

    Timer {
        interval: 250
        repeat: true
        running: root.isRunning
        onTriggered: {
            const nextRemaining = Math.max(0, Math.ceil((root.deadlineMs - Date.now()) / 1000));
            if (nextRemaining !== root.remainingSeconds) {
                root.remainingSeconds = nextRemaining;
            }
            if (nextRemaining <= 0) {
                root.moveToNextPhase(true);
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: root.ensureDailyCounterCurrent()
    }

    Notification {
        id: completionNotification

        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "chronometer"
        flags: Notification.Persistent | Notification.SkipGrouping
        urgency: Notification.HighUrgency

        defaultAction: NotificationAction {
            label: i18n("Open Pomodoro")
            onActivated: root.expanded = true
        }

        actions: [
            NotificationAction {
                label: root.notificationActionLabel
                onActivated: root.startIntervalFromNotification(root.pendingNotificationPhase)
            }
        ]
    }

    Component.onCompleted: {
        const savedPhase = Plasmoid.configuration.currentPhase;
        phase = savedPhase === "shortBreak" || savedPhase === "longBreak" ? savedPhase : "focus";
        focusesSinceLongBreak = Math.max(0, Plasmoid.configuration.focusesSinceLongBreak);
        completedFocusSessions = Math.max(0, Plasmoid.configuration.completedFocusSessions);

        const today = localDateKey(new Date());
        if (Plasmoid.configuration.dailyCounterDate === today) {
            dailyCounterDate = today;
            completedFocusSessionsToday = Math.max(0, Plasmoid.configuration.completedFocusSessionsToday);
        } else {
            dailyCounterDate = today;
            completedFocusSessionsToday = 0;
        }

        const savedPhaseTotal = Plasmoid.configuration.phaseTotalSeconds;
        phaseTotalSeconds = savedPhaseTotal > 0
            ? savedPhaseTotal
            : durationSecondsForPhase(phase);
        const savedRemaining = Plasmoid.configuration.remainingSeconds;
        remainingSeconds = savedRemaining > 0 && savedRemaining <= phaseTotalSeconds
            ? savedRemaining
            : phaseTotalSeconds;

        deadlineMs = Number(Plasmoid.configuration.deadlineEpochMs) || 0;
        initialized = true;

        if (Plasmoid.configuration.timerRunning && deadlineMs > Date.now()) {
            remainingSeconds = Math.max(1, Math.ceil((deadlineMs - Date.now()) / 1000));
            isRunning = true;
            persistRuntime();
        } else if (Plasmoid.configuration.timerRunning && deadlineMs > 0) {
            remainingSeconds = 0;
            moveToNextPhase(true);
        } else {
            isRunning = false;
            deadlineMs = 0;
            persistRuntime();
        }
    }
}
