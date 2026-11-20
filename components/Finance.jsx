"use client";
import { useState } from "react";
import {
  Plus,
  ArrowRight,
  Printer,
  Download,
  Check,
  X,
  FileText,
  Users,
  Leaf,
  Wallet,
  MessageSquare,
} from "lucide-react";
import {
  DIVISIONS,
  dates,
  entry,
  sheetRows,
  shift,
  num,
  money,
  pretty,
  csv,
} from "../lib/estate";
import { Modal, Field, Pill, Empty } from "./UI";
const sum = (rows, k) => rows.reduce((a, b) => a + b[k], 0);
function PeriodFields({ from, to, setFrom, setTo }) {
  return (
    <div className="form-grid">
      <Field label="From">
        <input
          type="date"
          required
          value={from}
          max={to}
          onChange={(e) => e.target.value && setFrom(e.target.value)}
        />
      </Field>
      <Field label="Through">
        <input
          type="date"
          required
          value={to}
          min={from}
          max={shift(from, 365)}
          onChange={(e) => e.target.value && setTo(e.target.value)}
        />
      </Field>
    </div>
  );
}
function Generate({ data, date, close, commit, select }) {
  const [from, setFrom] = useState(date),
    [to, setTo] = useState(date),
    [division, setDivision] = useState(DIVISIONS[0]),
    [err, setErr] = useState("");
  function generate(e) {
    e.preventDefault();
    if (to < from || to > shift(from, 365)) {
      setErr("Choose a pay period of up to one year.");
      return;
    }
    if (
      data.sheets.some(
        (s) =>
          s.status !== "Rejected" &&
          s.division === division &&
          s.start <= to &&
          s.end >= from,
      )
    ) {
      setErr("An existing wage sheet covers this division and pay period.");
      return;
    }
    const rows = sheetRows(
      data.workers.filter((w) => w.division === division),
      data.changes,
      from,
      to,
      data.rates,
    );
    if (!rows.length) {
      setErr(
        "Record attendance for this division before generating a wage sheet.",
      );
      return;
    }
    const sheet = {
      id: "WS-" + crypto.randomUUID().slice(0, 6).toUpperCase(),
      division,
      start: from,
      end: to,
      rows,
      status: "Pending review",
    };
    commit(
      (s) => ({ ...s, sheets: [sheet, ...s.sheets] }),
      "Wage sheet ready for review",
      division + " · " + pretty(to),
      "Payroll",
    );
    select(sheet.id);
    close();
  }
  return (
    <Modal title="Generate wage sheet" close={close}>
      <form onSubmit={generate}>
        <Field label="Division">
          <select
            value={division}
            onChange={(e) => setDivision(e.target.value)}
          >
            {DIVISIONS.map((d) => (
              <option key={d}>{d}</option>
            ))}
          </select>
        </Field>
        <PeriodFields {...{ from, to, setFrom, setTo }} />
        <p className="muted">
          The wage sheet captures attendance, harvest incentives, and
          contributions for this period.
        </p>
        {err && (
          <p role="alert" className="error">
            {err}
          </p>
        )}
        <button className="btn primary full">
          <FileText size={16} />
          Generate for review
        </button>
      </form>
    </Modal>
  );
}
function Sheet({ s, canApprove, close, commit }) {
  const [worker, setWorker] = useState(s.rows[0]?.id),
    [slip, setSlip] = useState(false);
  const row = s.rows.find((r) => r.id === worker);
  const decide = (status) =>
    commit(
      (prev) => ({
        ...prev,
        sheets: prev.sheets.map((item) =>
          item.id === s.id ? { ...item, status } : item,
        ),
      }),
      "Wage sheet " + status.toLowerCase(),
      s.division + " · " + s.id,
      "Payroll",
    );
  return (
    <Modal
      title={slip ? "Worker wage slip" : "Wage sheet details"}
      wide
      close={close}
    >
      <div className="sheet-summary">
        <div>
          <b>{s.division}</b>
          <p>
            {s.id} · {pretty(s.start)} – {pretty(s.end)}
          </p>
        </div>
        <Pill value={s.status} />
      </div>
      {slip && row ? (
        <>
          <label className="field no-print">
            <span>Worker</span>
            <select value={worker} onChange={(e) => setWorker(e.target.value)}>
              {s.rows.map((r) => (
                <option value={r.id} key={r.id}>
                  {r.name}
                </option>
              ))}
            </select>
          </label>
          <article className="slip">
            <p>Kelani Valley Estate · Wage statement</p>
            <h2>{row.name}</h2>
            <p>
              {row.id} · {s.division}
            </p>
            {[
              ["Days worked", num(row.days, 1)],
              ["Base pay", money(row.base)],
              ["Over-kilo incentive", money(row.incentive)],
              ["Employee EPF", money(row.employee)],
              ["Net pay", money(row.net)],
            ].map(([k, v]) => (
              <div key={k}>
                <span>{k}</span>
                <b>{v}</b>
              </div>
            ))}
          </article>
          <div className="receipt-preview no-print">
            <MessageSquare size={17} />
            <div>
              <b>SMS receipt preview</b>
              <p>
                {row.name}, your net pay for {pretty(s.start)} to{" "}
                {pretty(s.end)} is {money(row.net)}. Kelani Valley Estate.
              </p>
            </div>
          </div>
          <div className="actions no-print">
            <button className="btn" onClick={() => setSlip(false)}>
              Back to sheet
            </button>
            <button className="btn primary" onClick={() => window.print()}>
              <Printer size={15} />
              Print slip
            </button>
          </div>
        </>
      ) : (
        <>
          <div className="summary-tiles">
            {[
              ["Workers", s.rows.length],
              ["Gross wages", money(sum(s.rows, "gross"))],
              ["Net wages", money(sum(s.rows, "net"))],
            ].map(([k, v]) => (
              <div key={k}>
                <small>{k}</small>
                <strong>{v}</strong>
              </div>
            ))}
          </div>
          <div className="table-wrap capped">
            <table>
              <thead>
                <tr>
                  {["Worker", "Days", "Gross", "Employee EPF", "Net (LKR)"].map(
                    (x) => (
                      <th key={x}>{x}</th>
                    ),
                  )}
                </tr>
              </thead>
              <tbody>
                {s.rows.map((r) => (
                  <tr key={r.id}>
                    <td>{r.name}</td>
                    <td>{r.days}</td>
                    <td>{num(r.gross, 2)}</td>
                    <td>{num(r.employee, 2)}</td>
                    <td>{num(r.net, 2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="actions">
            <button
              className="btn"
              onClick={() =>
                csv(
                  s.id,
                  [
                    "Worker ID",
                    "Worker",
                    "Base",
                    "Incentive",
                    "Employee EPF",
                    "Employer EPF",
                    "Employer ETF",
                    "Net pay",
                  ],
                  s.rows.map((r) => [
                    r.id,
                    r.name,
                    r.base,
                    r.incentive,
                    r.employee,
                    r.employer,
                    r.etf,
                    r.net,
                  ]),
                )
              }
            >
              <Download size={15} />
              Export CSV
            </button>
            {s.status === "Pending review" && canApprove && (
              <>
                <button
                  className="btn reject"
                  onClick={() => decide("Rejected")}
                >
                  <X size={15} />
                  Reject
                </button>
                <button
                  className="btn primary"
                  onClick={() => decide("Approved")}
                >
                  <Check size={15} />
                  Approve
                </button>
              </>
            )}
            {s.status === "Approved" && (
              <button className="btn primary" onClick={() => setSlip(true)}>
                <Printer size={15} />
                Wage slips
              </button>
            )}
          </div>
        </>
      )}
    </Modal>
  );
}
export function Payroll({ data, date, commit }) {
  const [create, setCreate] = useState(false),
    [id, setId] = useState(null),
    [filter, setFilter] = useState("All statuses");
  const selected = data.sheets.find((s) => s.id === id),
    sheets = data.sheets.filter(
      (s) => filter === "All statuses" || s.status === filter,
    );
  return (
    <>
      <div className="page-title">
        <div>
          <h1>Payroll</h1>
          <p>Generate check-rolls, review wages, and issue pay slips.</p>
        </div>
        <button className="btn primary" onClick={() => setCreate(true)}>
          <Plus size={16} />
          Generate wage sheet
        </button>
      </div>
      <section className="panel">
        <div className="panel-head">
          <h2>Wage sheets</h2>
          <select
            aria-label="Filter wage sheets"
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
          >
            {["All statuses", "Pending review", "Approved", "Rejected"].map(
              (k) => (
                <option key={k}>{k}</option>
              ),
            )}
          </select>
        </div>
        {!sheets.length ? (
          <Empty />
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  {[
                    "Division",
                    "Pay period",
                    "Workers",
                    "Net wages",
                    "Status",
                    "",
                  ].map((k) => (
                    <th key={k}>{k}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {sheets.map((s) => (
                  <tr key={s.id}>
                    <td>
                      <b>{s.division}</b>
                      <small>{s.id}</small>
                    </td>
                    <td>
                      {pretty(s.start)} – {pretty(s.end)}
                    </td>
                    <td>{s.rows.length}</td>
                    <td>{money(sum(s.rows, "net"))}</td>
                    <td>
                      <Pill value={s.status} />
                    </td>
                    <td>
                      <button
                        className="table-action"
                        onClick={() => setId(s.id)}
                      >
                        Open <ArrowRight size={14} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
      {create && (
        <Generate
          {...{ data, date, commit }}
          close={() => setCreate(false)}
          select={setId}
        />
      )}
      {selected && (
        <Sheet
          s={selected}
          canApprove={["Administrator", "Estate Manager"].includes(data.role)}
          close={() => setId(null)}
          commit={commit}
        />
      )}
    </>
  );
}
export function Reports({ data, date }) {
  const [report, setReport] = useState("Productivity"),
    [from, setFrom] = useState(shift(date, -6)),
    [to, setTo] = useState(date),
    [division, setDivision] = useState("All divisions"),
    [worker, setWorker] = useState("All workers"),
    [page, setPage] = useState(0);
  const workers = data.workers.filter(
      (w) => division === "All divisions" || w.division === division,
    ),
    selected = workers.filter(
      (w) => worker === "All workers" || w.id === worker,
    ),
    valid = to >= from && to <= shift(from, 365);
  const approved = data.sheets.filter(
    (s) =>
      s.status === "Approved" &&
      s.start >= from &&
      s.end <= to &&
      (division === "All divisions" || s.division === division),
  );
  let headers, rows;
  if (report === "EPF / ETF") {
    headers = [
      "Worker",
      "EPF number",
      "ETF number",
      "Employee EPF",
      "Employer EPF",
      "Employer ETF",
      "Wage sheet",
    ];
    rows = approved.flatMap((s) =>
      s.rows
        .filter((r) => worker === "All workers" || r.id === worker)
        .map((r) => [
          r.name,
          r.epfNo,
          r.etfNo,
          +r.employee.toFixed(2),
          +r.employer.toFixed(2),
          +r.etf.toFixed(2),
          s.id,
        ]),
    );
  } else if (report === "Wages") {
    headers = [
      "Worker",
      "Division",
      "Base pay",
      "Incentive",
      "Employee EPF",
      "Net pay",
    ];
    rows = valid
      ? sheetRows(selected, data.changes, from, to, data.rates).map((r) => [
          r.name,
          r.division,
          r.base,
          r.incentive,
          +r.employee.toFixed(2),
          +r.net.toFixed(2),
        ])
      : [];
  } else {
    headers = [
      "Worker",
      "Division",
      "Full days",
      "Half days",
      "Absent days",
      "Harvest (kg)",
    ];
    const period = valid ? dates(from, to) : [];
    rows = selected
      .map((w) => {
        const entries = period.map((d) => entry(w, d, data.changes));
        return [
          w.name,
          w.division,
          ...["Present", "Half-day", "Absent"].map(
            (k) => entries.filter((e) => e.status === k).length,
          ),
          entries.reduce((a, e) => a + e.kg, 0),
        ];
      })
      .filter((r) => r.slice(2).some(Boolean));
  }
  const visible = valid ? rows : [],
    last = Math.max(0, Math.ceil(visible.length / 20) - 1),
    p = Math.min(page, last);
  return (
    <>
      <div className="page-title">
        <div>
          <h1>Reports</h1>
          <p>
            Explore attendance, harvest, wages, and statutory contributions.
          </p>
        </div>
        <button
          disabled={!visible.length}
          className="btn"
          onClick={() =>
            csv(
              report.replaceAll("/", "-") + "-" + from + "-" + to,
              headers,
              visible,
            )
          }
        >
          <Download size={16} />
          Export CSV
        </button>
      </div>
      <div className="tabs">
        {["Productivity", "Wages", "EPF / ETF"].map((k) => (
          <button
            key={k}
            className={k === report ? "selected" : ""}
            onClick={() => {
              setReport(k);
              setPage(0);
            }}
          >
            {k}
          </button>
        ))}
      </div>
      <section className="panel">
        <div className="report-filters">
          <PeriodFields {...{ from, to, setFrom, setTo }} />
          <Field label="Division">
            <select
              value={division}
              onChange={(e) => {
                setDivision(e.target.value);
                setWorker("All workers");
              }}
            >
              {["All divisions", ...DIVISIONS].map((v) => (
                <option key={v}>{v}</option>
              ))}
            </select>
          </Field>
          <Field label="Worker">
            <select value={worker} onChange={(e) => setWorker(e.target.value)}>
              <option>All workers</option>
              {workers.map((w) => (
                <option key={w.id} value={w.id}>
                  {w.name}
                </option>
              ))}
            </select>
          </Field>
        </div>
        <div className="panel-head">
          <div>
            <h2>{report} report</h2>
            <p>
              {report === "EPF / ETF"
                ? "Approved wage sheets fully within this period"
                : report === "Wages"
                  ? "Estimated wages at the current demo rates"
                  : "Recorded attendance and green leaf collection"}
            </p>
          </div>
        </div>
        {visible.length ? (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  {headers.map((x) => (
                    <th key={x}>{x}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {visible.slice(p * 20, p * 20 + 20).map((r, i) => (
                  <tr key={i}>
                    {r.map((v, j) => (
                      <td key={j}>{typeof v === "number" ? num(v, 2) : v}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <Empty
            detail={
              valid
                ? "No records match this period and selection."
                : "Select a valid period of up to one year."
            }
          />
        )}
        <div className="pagination">
          {visible.length} records
          <div>
            <button disabled={p === 0} onClick={() => setPage(p - 1)}>
              Previous
            </button>
            <button disabled={p === last} onClick={() => setPage(p + 1)}>
              Next
            </button>
          </div>
        </div>
      </section>
    </>
  );
}
