"use client";
import { useState } from "react";
import {
  Plus,
  Search,
  ArrowRight,
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  Leaf,
  Check,
  UserRound,
  Globe2,
  MapPin,
} from "lucide-react";
import {
  DIVISIONS,
  entry,
  num,
  money,
  shortName,
  translations,
} from "../lib/estate";
import { Modal, Field, DatePicker, Pill, Empty } from "./UI";
export function FieldEntry({ data, date, initialId, close, commit }) {
  const [worker, setWorker] = useState(
      initialId || data.workers.find((w) => w.active)?.id || "",
    ),
    [day, setDay] = useState(date),
    [lang, setLang] = useState(data.language);
  const t = translations[lang],
    workers = data.workers.filter((w) => w.active),
    person = workers.find((w) => w.id === worker);
  return (
    <Modal title="Record field entry" close={close}>
      <div className="lang">
        <Globe2 size={15} />
        <select
          aria-label="Field entry language"
          value={lang}
          onChange={(e) => setLang(e.target.value)}
        >
          {Object.keys(translations).map((k) => (
            <option key={k}>{k}</option>
          ))}
        </select>
      </div>
      <div className="form-grid">
        <Field label={t.date}>
          <input
            type="date"
            required
            value={day}
            onChange={(e) => e.target.value && setDay(e.target.value)}
          />
        </Field>
        <Field label={t.worker}>
          <select value={worker} onChange={(e) => setWorker(e.target.value)}>
            {workers.map((w) => (
              <option value={w.id} key={w.id}>
                {w.name} · {w.id}
              </option>
            ))}
          </select>
        </Field>
      </div>
      {person ? (
        <EntryValues
          key={worker + day}
          initial={entry(person, day, data.changes)}
          t={t}
          person={person}
          onSubmit={(value) => {
            commit(
              (s) => ({
                ...s,
                language: lang,
                changes: { ...s.changes, [day + "/" + worker]: value },
              }),
              "Field entry saved",
              person.name + " · " + day,
              "Attendance",
            );
            close();
          }}
        />
      ) : (
        <Empty
          title="No active workers"
          detail="Add a worker to start a field register."
        />
      )}
    </Modal>
  );
}
function EntryValues({ initial, t, person, onSubmit }) {
  const [status, setStatus] = useState(
    initial.status === "Unmarked" ? "Present" : initial.status,
  );
  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        const f = new FormData(e.currentTarget);
        onSubmit({
          status,
          kg: status === "Absent" ? 0 : Number(f.get("kg")),
          block: String(f.get("block") || "").trim(),
        });
      }}
    >
      <p className="field-note">
        <MapPin size={14} />
        {person.division}
      </p>
      <fieldset>
        <legend>{t.status}</legend>
        <div className="segments">
          {["Present", "Half-day", "Absent"].map((s) => (
            <button
              key={s}
              type="button"
              aria-pressed={s === status}
              className={s === status ? "chosen" : ""}
              onClick={() => setStatus(s)}
            >
              {s === status && <Check size={14} />} {t[s]}
            </button>
          ))}
        </div>
      </fieldset>
      <div className="form-grid">
        <Field label={t.kg}>
          <input
            name="kg"
            type="number"
            step=".1"
            min="0"
            max="500"
            required
            disabled={status === "Absent"}
            defaultValue={initial.kg}
          />
        </Field>
        <Field label={t.block}>
          <input
            name="block"
            maxLength={40}
            defaultValue={initial.block}
            placeholder="Block 1"
            required={status !== "Absent"}
          />
        </Field>
      </div>
      <p className="muted">Entries are saved on this device for the demo.</p>
      <button className="btn primary full">
        <Check size={16} />
        {t.save}
      </button>
    </form>
  );
}
function WorkerForm({ worker, close, commit }) {
  return (
    <Modal title={worker ? "Edit worker" : "Add worker"} close={close}>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          const f = new FormData(e.currentTarget);
          let updated = {
            ...worker,
            id:
              worker?.id ||
              "ET-" + crypto.randomUUID().slice(0, 6).toUpperCase(),
            name: String(f.get("name")).trim(),
            division: f.get("division"),
            rate: Number(f.get("rate")),
            nic: f.get("nic"),
            epf: f.get("epf"),
            etf: f.get("etf"),
            active: f.get("active") === "Active",
          };
          if (!updated.name) return;
          commit(
            (s) => ({
              ...s,
              workers: worker
                ? s.workers.map((w) => (w.id === worker.id ? updated : w))
                : [updated, ...s.workers],
            }),
            worker ? "Worker updated" : "Worker added",
            updated.name,
            "Workers",
          );
          close();
        }}
      >
        <Field label="Full name">
          <input
            name="name"
            required
            pattern=".*\S.*"
            defaultValue={worker?.name}
            maxLength={80}
          />
        </Field>
        <div className="form-grid">
          <Field label="Division">
            <select name="division" defaultValue={worker?.division}>
              {DIVISIONS.map((d) => (
                <option key={d}>{d}</option>
              ))}
            </select>
          </Field>
          <Field label="Daily base pay (LKR)">
            <input
              type="number"
              name="rate"
              min="1"
              max="100000"
              step=".01"
              defaultValue={worker?.rate || 1500}
              required
            />
          </Field>
          <Field label="EPF number">
            <input name="epf" defaultValue={worker?.epf} />
          </Field>
          <Field label="ETF number">
            <input name="etf" defaultValue={worker?.etf} />
          </Field>
          <Field label="NIC reference">
            <input name="nic" defaultValue={worker?.nic} />
          </Field>
          <Field label="Worker status">
            <select
              name="active"
              defaultValue={worker?.active === false ? "Inactive" : "Active"}
            >
              <option>Active</option>
              <option>Inactive</option>
            </select>
          </Field>
        </div>
        <p className="muted">
          Use fictional identifiers in this demo workspace.
        </p>
        <button className="btn primary full">Save worker</button>
      </form>
    </Modal>
  );
}
export default function Fieldwork({
  view,
  data,
  date,
  setDate,
  commit,
  openEntry,
  canEditStaff,
  canEnter,
}) {
  const [query, setQuery] = useState(""),
    [div, setDiv] = useState("All divisions"),
    [pg, setPg] = useState(0),
    [modal, setModal] = useState(null),
    [status, setStatus] = useState("All statuses");
  const directory = view === "Workers",
    harvest = view === "Harvest logs";
  const rows = data.workers.filter(
    (w) =>
      (directory || w.active) &&
      (div === "All divisions" || div === w.division) &&
      (w.name + " " + w.id).toLowerCase().includes(query.toLowerCase()) &&
      (status === "All statuses" ||
        (directory
          ? w.active
            ? "Active"
            : "Inactive"
          : entry(w, date, data.changes).status) === status),
  );
  const pages = Math.max(1, Math.ceil(rows.length / 12)),
    page = Math.min(pg, pages - 1);
  const sub = directory
    ? "Manage worker profiles, divisions, and daily pay rates."
    : harvest
      ? "Review green leaf collection by worker and field block."
      : "Review the daily muster and record attendance by division.";
  return (
    <>
      <div className="page-title">
        <div>
          <h1>{view}</h1>
          <p>{sub}</p>
        </div>
        {directory ? (
          canEditStaff && (
            <button className="btn primary" onClick={() => setModal({})}>
              <Plus size={16} />
              Add worker
            </button>
          )
        ) : (
          <DatePicker date={date} onChange={setDate} />
        )}
      </div>
      <section className="panel register">
        <div className="panel-head">
          <div className="headed-icon">
            {directory ? <UserRound /> : harvest ? <Leaf /> : <ClipboardList />}
            <h2>
              {directory
                ? "Worker directory"
                : harvest
                  ? "Collection register"
                  : "Attendance register"}
            </h2>
          </div>
          {!directory && canEnter && (
            <button className="btn primary" onClick={() => openEntry()}>
              <Plus size={15} />
              Field entry
            </button>
          )}
        </div>
        <div className="filters">
          <label className="search-input">
            <Search size={16} />
            <input
              aria-label="Search workers"
              placeholder="Search name or ID"
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setPg(0);
              }}
            />
          </label>
          <select
            aria-label="Division"
            value={div}
            onChange={(e) => {
              setDiv(e.target.value);
              setPg(0);
            }}
          >
            {["All divisions", ...DIVISIONS].map((v) => (
              <option key={v}>{v}</option>
            ))}
          </select>
          <select
            aria-label="Status"
            value={status}
            onChange={(e) => {
              setStatus(e.target.value);
              setPg(0);
            }}
          >
            {[
              "All statuses",
              ...(directory
                ? ["Active", "Inactive"]
                : ["Present", "Half-day", "Absent", "Unmarked"]),
            ].map((v) => (
              <option key={v}>{v}</option>
            ))}
          </select>
        </div>
        {rows.length ? (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  {[
                    "Worker",
                    "Division",
                    ...(directory
                      ? ["Daily pay", "Status"]
                      : harvest
                        ? ["Field block", "Harvest"]
                        : ["Attendance", "Harvest"]),
                    "Action",
                  ].map((k) => (
                    <th key={k}>{k}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.slice(page * 12, page * 12 + 12).map((w) => {
                  const e = entry(w, date, data.changes);
                  return (
                    <tr key={w.id}>
                      <td>
                        <div className="person">
                          <span className={"avatar a" + ((w.seed || 0) % 4)}>
                            {shortName(w.name)}
                          </span>
                          <div>
                            <b>{w.name}</b>
                            <small>{w.id}</small>
                          </div>
                        </div>
                      </td>
                      <td>{w.division}</td>
                      <td>
                        {directory ? (
                          money(w.rate)
                        ) : harvest ? (
                          e.block || "—"
                        ) : (
                          <Pill value={e.status} />
                        )}
                      </td>
                      <td>
                        {directory ? (
                          <Pill value={w.active ? "Active" : "Inactive"} />
                        ) : (
                          num(e.kg, 1) + " kg"
                        )}
                      </td>
                      <td>
                        {(directory ? canEditStaff : canEnter) ? (
                          <button
                            className="table-action"
                            onClick={() =>
                              directory
                                ? setModal({ worker: w })
                                : openEntry(w.id)
                            }
                          >
                            Edit <ArrowRight size={13} />
                          </button>
                        ) : (
                          "—"
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        ) : (
          <Empty />
        )}
        <div className="pagination">
          <span>
            {rows.length
              ? page * 12 +
                1 +
                "–" +
                Math.min((page + 1) * 12, rows.length) +
                " of " +
                rows.length +
                " workers"
              : "0 workers"}
          </span>
          <div>
            <button
              aria-label="Previous page"
              disabled={!page}
              onClick={() => setPg(page - 1)}
            >
              <ChevronLeft size={16} />
            </button>
            <button
              aria-label="Next page"
              disabled={page + 1 >= pages}
              onClick={() => setPg(page + 1)}
            >
              <ChevronRight size={16} />
            </button>
          </div>
        </div>
      </section>
      {modal && (
        <WorkerForm
          worker={modal.worker}
          close={() => setModal(null)}
          commit={commit}
        />
      )}
    </>
  );
}
