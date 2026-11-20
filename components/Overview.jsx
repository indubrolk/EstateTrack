"use client";
import { useState } from "react";
import {
  MapPin,
  Plus,
  ArrowUpRight,
  ArrowDownRight,
  Minus,
  Users,
  Leaf,
  Wallet,
  ChevronDown,
  ArrowRight,
  Sprout,
  Layers3,
  CalendarCheck,
} from "lucide-react";
import { DIVISIONS, tally, num, pretty, shift, sheetRows } from "../lib/estate";
import { DatePicker } from "./UI";
const colors = ["#286a4f", "#c4d98c", "#e9bfa8", "#daddd7"];
function Kpi({ icon: Icon, tone, label, value, unit, delta, foot, onClick }) {
  let Trend = delta > 0 ? ArrowUpRight : delta < 0 ? ArrowDownRight : Minus;
  return (
    <button className="metric" onClick={onClick}>
      <div className="metric-top">
        <span className={"metric-icon " + tone}>
          <Icon size={18} />
        </span>
        <span>{label}</span>
      </div>
      <div className="metric-value">
        {value} <small>{unit}</small>
      </div>
      <div className="metric-foot">
        {Number.isFinite(delta) && (
          <span className={"delta " + (delta < 0 ? "down" : "")}>
            <Trend size={12} />
            {Math.abs(delta).toFixed(1)}%
          </span>
        )}
        {foot}
      </div>
    </button>
  );
}
function pathFor(points) {
  return points.reduce((s, p, i) => {
    if (!i) return "M" + p.join(" ");
    let prev = points[i - 1],
      x = (prev[0] + p[0]) / 2;
    return (
      s +
      " C" +
      x +
      " " +
      prev[1] +
      " " +
      x +
      " " +
      p[1] +
      " " +
      p[0] +
      " " +
      p[1]
    );
  }, "");
}
function HarvestChart({ workers, changes, date }) {
  const [period, setPeriod] = useState(7),
    [hover, setHover] = useState(null);
  const days = Array.from({ length: period }, (_, i) =>
      shift(date, i - period + 1),
    ),
    series = days.map((d) => tally(workers, d, changes).kg),
    prior = days.map((d) => tally(workers, shift(d, -period), changes).kg);
  const max = Math.max(
      1000,
      Math.ceil(Math.max(...series, ...prior) / 1000) * 1000,
    ),
    left = 45,
    right = 600,
    top = 16,
    bottom = 156;
  const coords = (a) =>
    a.map((v, i) => [
      left + (i * (right - left)) / (a.length - 1),
      bottom - (v / max) * (bottom - top),
    ]);
  const pts = coords(series),
    path = pathFor(pts),
    idx = hover === null ? null : Math.min(period - 1, hover);
  return (
    <section className="panel chart-panel">
      <div className="panel-head">
        <div>
          <h2>Harvest overview</h2>
          <p>Daily green leaf collection</p>
        </div>
        <label className="small-select">
          <select
            aria-label="Harvest chart period"
            value={period}
            onChange={(e) => {
              setPeriod(+e.target.value);
              setHover(null);
            }}
          >
            <option value="7">Last 7 days</option>
            <option value="14">Last 14 days</option>
          </select>
          <ChevronDown size={12} />
        </label>
      </div>
      <div className="legend">
        <span>
          <i style={{ background: colors[0] }} />
          This period
        </span>
        <span>
          <i className="past" />
          Previous period
        </span>
      </div>
      <div
        className="plot"
        tabIndex="0"
        aria-label="Daily harvest chart. Use left and right arrows to explore."
        onKeyDown={(e) => {
          if (["ArrowLeft", "ArrowRight"].includes(e.key)) {
            e.preventDefault();
            setHover(
              Math.max(
                0,
                Math.min(
                  period - 1,
                  (idx ?? 0) + (e.key === "ArrowLeft" ? -1 : 1),
                ),
              ),
            );
          }
        }}
        onBlur={() => setHover(null)}
        onPointerLeave={() => setHover(null)}
      >
        <svg
          viewBox="0 0 615 188"
          role="img"
          aria-label={
            "Harvest over " +
            period +
            " days. Total " +
            num(series.reduce((a, b) => a + b, 0)) +
            " kilograms."
          }
          onPointerMove={(e) => {
            const rect = e.currentTarget.getBoundingClientRect();
            setHover(
              Math.max(
                0,
                Math.min(
                  period - 1,
                  Math.round(
                    ((((e.clientX - rect.left) / rect.width) * 615 - left) /
                      (right - left)) *
                      (period - 1),
                  ),
                ),
              ),
            );
          }}
        >
          <defs>
            <linearGradient id="area" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0%" stopColor="#89b985" stopOpacity=".38" />
              <stop offset="100%" stopColor="#b4ce9e" stopOpacity=".07" />
            </linearGradient>
          </defs>
          {[0, 1, 2, 3, 4].map((i) => {
            let y = bottom - (i * (bottom - top)) / 4;
            return (
              <g key={i}>
                <line
                  x1={left}
                  x2={right}
                  y1={y}
                  y2={y}
                  stroke="#e3e9e3"
                  strokeDasharray="3 4"
                />
                <text x={left - 9} y={y + 4} textAnchor="end">
                  {num((max * i) / 4)}
                </text>
              </g>
            );
          })}
          <path
            d={
              path +
              " L" +
              right +
              " " +
              bottom +
              " L" +
              left +
              " " +
              bottom +
              " Z"
            }
            fill="url(#area)"
          />
          <path
            d={pathFor(coords(prior))}
            fill="none"
            stroke="#a4b5a5"
            strokeWidth="2"
            strokeDasharray="5 5"
          />
          <path
            className="curve"
            d={path}
            fill="none"
            stroke={colors[0]}
            strokeWidth="3"
          />
          {days.map(
            (d, i) =>
              (period === 7 || i % 2 === 0 || i === period - 1) && (
                <text
                  key={d}
                  y="181"
                  x={pts[i][0]}
                  textAnchor={
                    i === period - 1 ? "end" : i === 0 ? "start" : "middle"
                  }
                >
                  {pretty(d, { month: "short", day: "numeric" })}
                </text>
              ),
          )}
          {idx !== null && (
            <g>
              <line
                x1={pts[idx][0]}
                x2={pts[idx][0]}
                y1={top}
                y2={bottom}
                stroke="#64896b"
                strokeDasharray="3 3"
              />
              <circle
                cx={pts[idx][0]}
                cy={pts[idx][1]}
                r="5"
                fill="#215d43"
                stroke="white"
                strokeWidth="2"
              />
            </g>
          )}
        </svg>
        {idx !== null && (
          <span className="plot-tip">
            {pretty(days[idx], { day: "numeric", month: "short" })} ·{" "}
            {num(series[idx])} kg
          </span>
        )}
      </div>
    </section>
  );
}
function AttendanceChart({ stats, total, go }) {
  let progress = 0;
  const parts = ["Present", "Half-day", "Absent", "Unmarked"].filter(
    (k) => k !== "Unmarked" || stats[k] > 0,
  );
  return (
    <section className="panel attendance-panel">
      <div className="panel-head">
        <div>
          <h2>Attendance mix</h2>
          <p>Workforce breakdown</p>
        </div>
        <button
          className="icon-btn small"
          aria-label="Open attendance"
          onClick={() => go("Attendance")}
        >
          <ArrowUpRight size={17} />
        </button>
      </div>
      <div className="donut-slot">
        <svg viewBox="0 0 156 156" aria-label="Attendance breakdown">
          <circle
            cx="78"
            cy="78"
            r="62"
            fill="none"
            stroke="#e9ede8"
            strokeWidth="15"
          />
          {parts.map((k, i) => {
            let start = progress,
              pct = total ? (stats[k] / total) * 100 : 0;
            progress += pct;
            return (
              <circle
                key={k}
                cx="78"
                cy="78"
                r="62"
                fill="none"
                pathLength="100"
                stroke={colors[i]}
                strokeWidth="15"
                strokeDasharray={
                  Math.max(0, pct - 0.8) + " " + (100 - Math.max(0, pct - 0.8))
                }
                strokeDashoffset={-start}
                transform="rotate(-90 78 78)"
              />
            );
          })}
        </svg>
        <div>
          <strong>{total}</strong>
          <span>Total workers</span>
        </div>
      </div>
      <div className="attendance-legend">
        {parts.map((k, i) => (
          <div key={k}>
            <i style={{ background: colors[i] }} />
            {k}
            <b>{stats[k]}</b>
          </div>
        ))}
      </div>
    </section>
  );
}
export default function Overview({ data, date, setDate, go, openEntry }) {
  const workers = data.workers.filter((w) => w.active),
    stats = tally(workers, date, data.changes),
    before = tally(workers, shift(date, -1), data.changes);
  const pct = (now, old) => (old ? ((now - old) / old) * 100 : null);
  const rate = workers.length
    ? ((stats.Present + stats["Half-day"]) / workers.length) * 100
    : 0;
  const wages = sheetRows(workers, data.changes, date, date, data.rates).reduce(
    (a, b) => a + b.net,
    0,
  );
  return (
    <>
      <div className="page-title">
        <div>
          <h1>Estate overview</h1>
          <p>A daily snapshot of your estate operations.</p>
        </div>
        <DatePicker date={date} onChange={setDate} />
      </div>
      <section className="estate-banner">
        <div className="hero-photo" />
        <div className="hero-content">
          <div className="hero-tag">
            <span /> ESTATE WORKSPACE
          </div>
          <h2>Kelani Valley Estate</h2>
          <p>
            <MapPin size={14} /> Nuwara Eliya, Sri Lanka
          </p>
          <button className="btn hero-btn" onClick={openEntry}>
            <Plus size={15} /> Record field entry
          </button>
        </div>
        <div className="hero-caption">
          <Layers3 size={14} /> 3 divisions
        </div>
      </section>
      <div className="metrics">
        <Kpi
          icon={Users}
          tone="mint"
          label="Total workforce"
          value={num(workers.length)}
          unit=""
          foot="Across 3 divisions"
          onClick={() => go("Workers")}
        />
        <Kpi
          icon={CalendarCheck}
          tone="lilac"
          label="Attendance rate"
          value={num(rate, 1)}
          unit="%"
          foot="vs. yesterday"
          delta={pct(
            stats.Present + stats["Half-day"],
            before.Present + before["Half-day"],
          )}
          onClick={() => go("Attendance")}
        />
        <Kpi
          icon={Leaf}
          tone="lime"
          label="Green leaf harvest"
          value={num(stats.kg, 1)}
          unit="kg"
          delta={pct(stats.kg, before.kg)}
          foot="vs. yesterday"
          onClick={() => go("Harvest logs")}
        />
        <Kpi
          icon={Wallet}
          tone="peach"
          label="Estimated wages"
          value={num(wages / 1000, 1) + "k"}
          unit="LKR"
          foot="Daily net wages"
          onClick={() =>
            go(data.role === "Field Supervisor" ? "Reports" : "Payroll")
          }
        />
      </div>
      <div className="insight-grid">
        <HarvestChart workers={workers} changes={data.changes} date={date} />
        <AttendanceChart stats={stats} total={workers.length} go={go} />
      </div>
      <section className="panel">
        <div className="panel-head">
          <div>
            <h2>Division summary</h2>
            <p>Field performance across the estate</p>
          </div>
          <button className="text-btn" onClick={() => go("Reports")}>
            View reports <ArrowRight size={15} />
          </button>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                {[
                  "Division",
                  "Workforce",
                  "On duty",
                  "Harvest",
                  "Attendance",
                ].map((x) => (
                  <th key={x}>{x}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {DIVISIONS.map((d, i) => {
                const ws = workers.filter((w) => w.division === d),
                  s = tally(ws, date, data.changes),
                  r = ws.length
                    ? ((s.Present + s["Half-day"]) / ws.length) * 100
                    : 0;
                return (
                  <tr key={d}>
                    <td>
                      <span className="division-name">
                        <span className={"division-mark v" + i}>
                          <Sprout size={16} />
                        </span>
                        {d}
                      </span>
                    </td>
                    <td>{ws.length}</td>
                    <td>{s.Present + s["Half-day"]}</td>
                    <td>{num(s.kg)} kg</td>
                    <td>
                      <span className="mini-bar">
                        <i style={{ width: r + "%" }} />
                      </span>
                      {num(r, 1)}%
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>
    </>
  );
}
