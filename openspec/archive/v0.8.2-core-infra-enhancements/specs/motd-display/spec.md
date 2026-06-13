# Delta for motd-display

## ADDED Requirements

### Requirement: Update notification line

After displaying the random tip and before MOTD completion, the system MUST check for an update marker file. If `logs/update-available.txt` exists, a single notification line SHALL be displayed: `>> Actualizacion disponible: vX.Y.Z <<`.

#### Scenario: Update available shows notification

- GIVEN `logs/update-available.txt` contains `v0.5.0`
- WHEN the MOTD finishes displaying the random tip
- THEN a line MUST show `>> Actualizacion disponible: v0.5.0 <<`
- AND it MUST appear after the tip and before MOTD ends

#### Scenario: No marker, no notification

- GIVEN `logs/update-available.txt` does NOT exist
- WHEN the MOTD runs
- THEN no update notification line SHALL be shown
- AND the MOTD MUST complete as normal

#### Scenario: Empty marker file handled

- GIVEN `logs/update-available.txt` exists but is empty
- WHEN the MOTD runs
- THEN the notification line SHALL NOT be shown
- AND MOTD MUST NOT error
