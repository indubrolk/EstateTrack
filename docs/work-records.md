# Fact-based work records

The mobile app now saves observed facts before any network request. Attendance
opens a form for whether a worker came, their task, unit, and total quantity.
The date picker permits corrections to earlier days. Workers and Home use the
same local roster; Home's attendance totals count the observed attendance fact,
not an overridden day classification.

## Rules and assumptions to confirm with the estate

No monetary or quantity defaults are installed. Add each task/unit rule in the
Settings tab. The current, explicitly displayed policy is:

- Did not attend: absent, with no task or quantity.
- Quantity at or above the norm: full day.
- Quantity at or above the half-day cut-off but below the norm: half day.
- Quantity below the cut-off: needs review, not an automatic unpaid day.
- No matching task rule: facts saved, result awaiting rules.
- Extra amount: max(quantity − norm, 0) × extra rate, rounded half up to
  two decimal places. The rate is expressed in the estate's currency per unit.
- Quantity at or above the incentive threshold: incentive eligible. No incentive
  payment amount or base wage is inferred or calculated.

These boundaries are an implementation assumption pending estate confirmation.
Quantities use integer thousandths; rates and amounts use integer hundredths.
Rules apply per task and unit; kilograms are never combined with other units.
The current form records one daily task and its total quantity per worker/date.
Multiple tasks or multiple shifts per worker/day need a separate aggregation
policy and are not silently combined.

Saving an edited rule appends a new version. Historical entries retain their
rule snapshot, calculated result, extra amount and incentive eligibility.
An explicit correction uses current rules and requires a reason. For facts that
were saved before rules existed, open Correct facts and save a reason such as
“Apply approved task rule” to produce a calculated revision.

An override appends a new entry with the original facts and calculation,
the requested final classification, supervisor ID, timestamp and required reason.
It does not change extra-quantity or incentive calculations. Subsequent facts
corrections recalculate and replace the override as the current result, while
the override remains in History.

## Storage and migration

SQLite schema v2 adds `record_events` and `record_outbox`. The event insert and
outbox insert commit together. UPDATE and DELETE triggers protect the event
ledger. Each revision links to its parent; a stale form is rejected rather than
silently overwriting a later correction. Sync acknowledgements update only the
outbox metadata.

Existing v1 attendance rows are retained in a read-only table and copied to
explicit `legacy_import` events. Missing historical quantities, reasons and
rules are not invented. The old app replaced rows, so records already lost
before this migration cannot be recovered. Legacy rows remain visible in
History and can be followed by a new facts correction.

The browser is a read-only preview. Recording is enabled in native apps, where
SQLite provides durable local storage.

## Development sync server

The repository had no backend or authentication service. `backend/server.mjs`
is a dependency-free Node 24 development receiver, with a durable SQLite ledger,
bearer-token authentication, transactional batch receipt, idempotent retry and
immutable event IDs. It binds only to loopback. It is not deployed.

PowerShell, from `backend`:

```powershell
$env:ESTATE_SYNC_TOKEN = '<random development token of at least 24 characters>'
node server.mjs
```

Start the Windows client from `apps/mobile` with the same development token:

```powershell
flutter run -d windows --dart-define=ESTATE_SYNC_URL=http://127.0.0.1:8787/sync --dart-define=ESTATE_SYNC_TOKEN=<same-development-token>
```

Android emulators reach the host through `http://10.0.2.2:8787/sync`. Real phones
require an HTTPS deployment reachable by the phone. Use a local debug-only
Android network-security configuration if testing emulator cleartext HTTP;
release transport security has not been relaxed. Unconfigured clients keep
records queued and explicitly display “Sync server not configured”. They never
claim successful delivery based on Wi-Fi presence alone.

The client retries after a local save, on app resume, and every 30 seconds while
running. Android also queues network-constrained one-off work and a 15-minute
periodic background retry. iOS is configured for Workmanager periodic refresh;
the OS controls when background work runs. Force-stopping an app, battery policy
and iOS scheduling can delay delivery. Foreground reopening retries immediately.
Background behavior needs validation on actual Android/iOS devices; Windows
tests validate the queue and transport logic, not mobile OS scheduling.

Only server-acknowledged event IDs leave the pending queue. A lost response
resends the same immutable IDs, and the receiver returns the same receipts.
Events are uploaded oldest first, including rules and correction parents.
Conflicting branches from separate devices are preserved by the receiver for
review, not destructively reconciled.

This first backend receives records; it does not yet distribute task rules or
worker assignments between devices. Estate-wide administration, authenticated
supervisor/administrator roles, conflict-review UI, TLS hosting, server-side
policy verification and credential provisioning remain deployment integration
work. Do not ship the development shared token in a production app: build-time
defines are configuration, not secure credential storage.

## Verification

```powershell
flutter analyze
flutter test test/work_records_test.dart test/attendance_database_test.dart
cd ../../backend
node --test server.test.mjs
```

Coverage includes exact threshold boundaries, decimal precision, absent and
unconfigured facts, reason-required overrides/corrections, stale writes,
historical rule snapshots, restart persistence, lost acknowledgement retry,
v1 migration, immutable server records and HTTP authentication.
