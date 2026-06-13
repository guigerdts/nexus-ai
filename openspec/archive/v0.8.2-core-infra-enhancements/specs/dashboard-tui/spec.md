# Delta for dashboard-tui

## ADDED Requirements

### Requirement: Update marker in MonitorPanel

The MonitorPanel MUST read `logs/update-available.txt` during its refresh cycle. If the file exists and contains a version string, a notification line SHALL be displayed at the top of the panel: `Actualizacion disponible: vX.Y.Z`. The panel SHALL check the file on each refresh.

#### Scenario: Marker present shows notification

- GIVEN `logs/update-available.txt` contains `v0.5.0`
- WHEN the MonitorPanel refreshes
- THEN it MUST display `Actualizacion disponible: v0.5.0`
- AND the notification MUST appear at the top of the panel
- AND the rest of the system stats MUST remain visible below

#### Scenario: No marker, no notification

- GIVEN `logs/update-available.txt` does NOT exist
- WHEN the MonitorPanel refreshes
- THEN it MUST NOT show any update notification
- AND continue displaying system stats normally

#### Scenario: Marker file read error handled

- GIVEN `logs/update-available.txt` exists but is unreadable (permission error)
- WHEN the MonitorPanel refreshes
- THEN it MUST silently skip the notification
- AND NOT crash or show an error trace
