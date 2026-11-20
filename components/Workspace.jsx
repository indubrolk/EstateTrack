"use client";
import { useCallback, useEffect, useRef, useState } from "react";
import {
  LayoutDashboard,
  UsersRound,
  CalendarCheck2,
  Sprout,
  WalletCards,
  ChartNoAxesCombined,
  Bell,
  Settings,
  HelpCircle,
  Menu,
  Search,
  ChevronRight,
  PanelLeft,
  ArrowUpRight,
  ChevronsUpDown,
  Check,
  House,
  FileText,
  MapPin,
  Leaf,
  HardDrive,
  Command,
  X,
  ClipboardList,
  ShieldCheck,
} from "lucide-react";
import {
  initialState,
  TODAY,
  ROLES,
  PEOPLE,
  shortName,
  num,
  translations,
} from "../lib/estate";
import Overview from "./Overview";
import Fieldwork, { FieldEntry } from "./Fieldwork";
import { Payroll, Reports } from "./Finance";
import { Modal, Field, Empty } from "./UI";
const KEY = "estatetrack.workspace.v1";
const groups = [
  [
    "Workspace",
    [
      ["Overview", LayoutDashboard],
      ["Workers", UsersRound],
      ["Attendance", CalendarCheck2],
      ["Harvest logs", Sprout],
    ],
  ],
  [
    "Management",
    [
      ["Payroll", WalletCards],
      ["Reports", ChartNoAxesCombined],
      ["Notifications", Bell],
    ],
  ],
  ["Preferences", [["Settings", Settings]]],
];
const pages = groups.flatMap((g) => g[1]);
const slug = (s) => s.toLowerCase().replaceAll(" ", "-");
function pageFromHash() {
  return (
    pages.find(([s]) => slug(s) === window.location.hash.slice(1))?.[0] ||
    "Overview"
  );
}
function Brand() {
  return (
    <div className="brand">
      <img src="/icon.svg" width="36" height="36" alt="" />
      <strong>
        Estate<span>Track</span>
      </strong>
    </div>
  );
}
function DemoSignIn({ signIn }) {
  const [role, setRole] = useState(ROLES[0]);
  const [error, setError] = useState("");
  return (
    <main className="sign-in">
      <section className="sign-in-image">
        <Brand />
        <div>
          <MapPin size={18} />
          <h2>Kelani Valley Estate</h2>
          <p>Nuwara Eliya, Sri Lanka</p>
        </div>
      </section>
      <section className="sign-in-form">
        <h1>Welcome back</h1>
        <p>Sign in to the estate demo workspace.</p>
        <form
          onSubmit={(event) => {
            event.preventDefault();
            if (new FormData(event.currentTarget).get("pin") !== "2026") {
              setError("Enter the sample PIN shown below.");
              return;
            }
            signIn(role);
          }}
        >
          <Field label="Demo account">
            <select value={role} onChange={(e) => setRole(e.target.value)}>
              {ROLES.map((r) => (
                <option key={r} value={r}>
                  {PEOPLE[r]} · {r}
                </option>
              ))}
            </select>
          </Field>
          <Field label="Sample PIN">
            <input
              name="pin"
              inputMode="numeric"
              type="password"
              pattern="[0-9]{4}"
              required
              maxLength={4}
              autoComplete="off"
            />
          </Field>
          <p className="muted">
            Use <b>2026</b> for any demo account.
          </p>
          {error && (
            <p className="error" role="alert">
              {error}
            </p>
          )}
          <button className="btn primary full">
            Open workspace <ChevronRight size={16} />
          </button>
        </form>
      </section>
    </main>
  );
}
function SettingsView({ data, commit, switchRole }) {
  const edit = ["Administrator", "Estate Manager"].includes(data.role);
  return (
    <>
      <div className="page-title">
        <div>
          <h1>Settings</h1>
          <p>Manage your workspace, field language, and estate pay rules.</p>
        </div>
      </div>
      <div className="settings-grid">
        <section className="panel settings-card">
          <div className="headed-icon">
            <ShieldCheck />
            <h2>Workspace profile</h2>
          </div>
          <p className="muted">
            Switch demo roles to explore the estate workflow.
          </p>
          <Field label="Preview role">
            <select
              value={data.role}
              onChange={(e) => switchRole(e.target.value)}
            >
              {ROLES.map((r) => (
                <option key={r}>{r}</option>
              ))}
            </select>
          </Field>
          <Field label="Field entry language">
            <select
              value={data.language}
              onChange={(e) => {
                const language = e.target.value;
                commit(
                  (s) => ({ ...s, language }),
                  "Language preference saved",
                  language,
                  "Settings",
                );
              }}
            >
              {Object.keys(translations).map((l) => (
                <option key={l}>{l}</option>
              ))}
            </select>
          </Field>
          <div className="settings-info">
            <HardDrive size={18} />
            <p>
              Demo records and edits are stored in this browser. Use sample
              worker information.
            </p>
          </div>
        </section>
        <section className="panel settings-card">
          <div className="headed-icon">
            <WalletCards />
            <h2>Pay rules</h2>
          </div>
          <p className="muted">
            Illustrative estate rates for wage estimates and new sheets.
          </p>
          <form
            key={data.role}
            onSubmit={(e) => {
              e.preventDefault();
              const f = new FormData(e.currentTarget);
              const rates = Object.fromEntries(
                Object.keys(data.rates).map((k) => [k, Number(f.get(k))]),
              );
              commit(
                (s) => ({ ...s, rates }),
                "Pay rules saved",
                "New sheets use the updated rates",
                "Settings",
              );
            }}
          >
            <div className="form-grid">
              {[
                ["norm", "Daily plucking norm (kg)"],
                ["bonus", "Over-kilo rate (LKR)"],
                ["employee", "Employee EPF (%)"],
                ["employer", "Employer EPF (%)"],
                ["etf", "Employer ETF (%)"],
              ].map(([key, label]) => (
                <Field key={key} label={label}>
                  <input
                    type="number"
                    name={key}
                    required
                    step=".01"
                    min="0"
                    max={key === "bonus" ? 10000 : key === "norm" ? 500 : 100}
                    disabled={!edit}
                    defaultValue={data.rates[key]}
                  />
                </Field>
              ))}
            </div>
            {edit && (
              <button className="btn primary">
                <Check size={15} />
                Save pay rules
              </button>
            )}
          </form>
        </section>
      </div>
    </>
  );
}
function Activity({ data, go }) {
  return (
    <>
      <div className="page-title">
        <div>
          <h1>Notifications</h1>
          <p>
            Review field updates, payroll decisions, and workspace activity.
          </p>
        </div>
      </div>
      <section className="panel">
        <div className="panel-head">
          <h2>Activity log</h2>
          <span className="counter">{data.activity.length} updates</span>
        </div>
        {data.activity.map((a) => (
          <div key={a.id} className="activity-row">
            <span className="metric-icon mint">
              {a.view === "Payroll" ? (
                <WalletCards size={18} />
              ) : (
                <ClipboardList size={18} />
              )}
            </span>
            <div>
              <b>{a.title}</b>
              <p>{a.detail}</p>
              <small>{a.date}</small>
            </div>
            {!(data.role === "Field Supervisor" && a.view === "Payroll") && (
              <button
                className="icon-btn"
                aria-label={"View " + a.view}
                onClick={() => go(a.view)}
              >
                <ArrowUpRight size={17} />
              </button>
            )}
          </div>
        ))}
      </section>
    </>
  );
}
export default function Workspace() {
  const [data, setData] = useState(initialState),
    [loaded, ready] = useState(false),
    [view, setView] = useState("Overview"),
    [date, setDate] = useState(TODAY),
    [modal, setModal] = useState(""),
    [worker, setWorker] = useState(""),
    [mobile, setMobile] = useState(false),
    [compact, setCompact] = useState(false),
    [query, setQuery] = useState(""),
    [toast, setToast] = useState(""),
    [online, setOnline] = useState(true);
  const timer = useRef(null),
    latest = useRef(data);
  const announce = useCallback((msg) => {
    setToast(msg);
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setToast(""), 3500);
  }, []);
  useEffect(() => {
    try {
      const raw = localStorage.getItem(KEY);
      if (raw) {
        const saved = JSON.parse(raw);
        if (
          Array.isArray(saved.workers) &&
          saved.rates &&
          Array.isArray(saved.sheets) &&
          saved.changes &&
          ROLES.includes(saved.role)
        ) {
          setData(saved);
          latest.current = saved;
        }
      }
    } catch {
      announce("Saved workspace could not be read. Showing the demo estate.");
    }
    const hash = () => {
      setView(pageFromHash());
      setMobile(false);
      setModal("");
      window.scrollTo(0, 0);
    };
    hash();
    ready(true);
    const net = () => setOnline(navigator.onLine);
    net();
    const key = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setQuery("");
        setModal((v) => (v === "search" ? "" : "search"));
      }
      if (e.key === "Escape") setMobile(false);
    };
    window.addEventListener("hashchange", hash);
    window.addEventListener("keydown", key);
    window.addEventListener("online", net);
    window.addEventListener("offline", net);
    if (process.env.NODE_ENV === "production" && "serviceWorker" in navigator) {
      navigator.serviceWorker
        .register("/sw.js")
        .then(async () => {
          let reg = await navigator.serviceWorker.ready;
          reg.active?.postMessage({
            assets: performance
              .getEntriesByType("resource")
              .map((r) => r.name)
              .filter((s) => s.startsWith(location.origin + "/_next/static/")),
          });
        })
        .catch(() => {});
    }
    return () => {
      window.removeEventListener("hashchange", hash);
      window.removeEventListener("keydown", key);
      window.removeEventListener("online", net);
      window.removeEventListener("offline", net);
      clearTimeout(timer.current);
    };
  }, [announce]);
  useEffect(() => {
    document.title = view + " · EstateTrack";
  }, [view]);
  function go(v) {
    setView(v);
    setModal("");
    setMobile(false);
    if (window.location.hash !== "#" + slug(v)) window.location.hash = slug(v);
    window.scrollTo(0, 0);
  }
  function commit(update, title, detail, target) {
    const updated = update(latest.current);
    const next = {
      ...updated,
      activity: [
        {
          id: crypto.randomUUID(),
          title,
          detail,
          view: target,
          date: new Date().toLocaleDateString("en-CA", {
            timeZone: "Asia/Colombo",
          }),
        },
        ...updated.activity,
      ],
    };
    try {
      localStorage.setItem(KEY, JSON.stringify(next));
      latest.current = next;
      setData(next);
      announce(title);
    } catch {
      announce(
        "Device storage is unavailable. Your change could not be saved.",
      );
    }
  }
  function switchRole(role) {
    commit((s) => ({ ...s, role }), "Demo role changed", role, "Settings");
    setModal("");
    if (role === "Field Supervisor" && view === "Payroll") go("Overview");
  }
  function openEntry(id) {
    setWorker(typeof id === "string" ? id : "");
    setModal("entry");
  }
  const allowed = (v) => v !== "Payroll" || data.role !== "Field Supervisor",
    page = allowed(view) ? view : "Overview",
    canEditStaff = ["Estate Clerk", "Estate Manager", "Administrator"].includes(
      data.role,
    );
  const close = () => setModal(""),
    pending = data.sheets.filter((s) => s.status === "Pending review").length,
    who = PEOPLE[data.role];
  if (data.signedOut)
    return (
      <DemoSignIn
        signIn={(role) => {
          commit(
            (s) => ({ ...s, role, signedOut: false }),
            "Demo session started",
            role,
            "Settings",
          );
          go(role === "Field Supervisor" ? "Attendance" : "Overview");
        }}
      />
    );
  return (
    <div
      className={
        "app " + (compact ? "compact " : "") + (mobile ? "mobile-open" : "")
      }
    >
      <a
        className="skip"
        href="#main-content"
        onClick={(e) => {
          e.preventDefault();
          document.getElementById("main-content").focus();
        }}
      >
        Skip to content
      </a>
      {mobile && (
        <button
          className="scrim"
          aria-label="Close navigation"
          onClick={() => setMobile(false)}
        />
      )}
      <aside className="sidebar">
        <a
          className="brand-link"
          href="#overview"
          aria-label="EstateTrack overview"
        >
          <Brand />
        </a>
        <div className="workspace-id">
          <div className="estate-icon">
            <Sprout size={19} />
          </div>
          <div>
            <b>Kelani Valley</b>
            <small>Tea estate</small>
          </div>
        </div>
        <nav aria-label="Main navigation">
          {groups.map(([g, items]) => (
            <div className="nav-group" key={g}>
              <div className="nav-label">{g}</div>
              {items
                .filter(([v]) => allowed(v))
                .map(([v, Icon]) => (
                  <a
                    href={"#" + slug(v)}
                    key={v}
                    aria-current={page === v ? "page" : undefined}
                    title={v}
                    className={"nav-link " + (page === v ? "active" : "")}
                    onClick={() => {
                      setMobile(false);
                      setModal("");
                    }}
                  >
                    <Icon size={18} />
                    <span>{v}</span>
                    {v === "Payroll" && pending > 0 && <small>{pending}</small>}
                  </a>
                ))}
            </div>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <button className="help" onClick={() => setModal("help")}>
            <HelpCircle size={17} /> <span>Help & support</span>
          </button>
          <button className="profile" onClick={() => setModal("profile")}>
            <span className="profile-avatar">{shortName(who)}</span>
            <span className="profile-meta">
              <b>{who}</b>
              <small>{data.role}</small>
            </span>
            <ChevronsUpDown size={14} />
          </button>
        </div>
      </aside>
      <div className="workspace">
        <header className="topbar">
          <div className="breadcrumbs">
            <button
              className="icon-btn desktop-toggle"
              aria-label="Toggle sidebar"
              onClick={() => setCompact(!compact)}
            >
              <PanelLeft size={17} />
            </button>
            <button
              className="icon-btn mobile-toggle"
              aria-label="Open navigation"
              onClick={() => setMobile(true)}
            >
              <Menu size={21} />
            </button>
            <span className="divider" />
            <span>Workspace</span>
            <ChevronRight size={13} />
            <b>{page}</b>
          </div>
          <div className="top-actions">
            <button
              className="search-button"
              aria-label="Search workspace"
              onClick={() => {
                setQuery("");
                setModal("search");
              }}
            >
              <Search size={15} />
              <span>Search workspace...</span>
              <kbd>Ctrl K</kbd>
            </button>
            <button
              className="bell-btn"
              aria-label="View notifications"
              onClick={() => go("Notifications")}
            >
              <Bell size={18} />
              {data.activity.length > 0 && <i />}
            </button>
          </div>
        </header>
        <main id="main-content" tabIndex="-1" key={page} className="main">
          {page === "Overview" ? (
            <Overview {...{ data, date, setDate, go, openEntry }} />
          ) : ["Workers", "Attendance", "Harvest logs"].includes(page) ? (
            <Fieldwork
              view={page}
              {...{ data, date, setDate, commit, openEntry, canEditStaff }}
              canEnter={true}
            />
          ) : page === "Payroll" ? (
            <Payroll {...{ data, date, commit }} />
          ) : page === "Reports" ? (
            <Reports {...{ data, date }} />
          ) : page === "Settings" ? (
            <SettingsView {...{ data, commit, switchRole }} />
          ) : (
            <Activity {...{ data, go }} />
          )}
          <footer>
            <span>
              <Leaf size={12} /> EstateTrack
            </span>
            <span>
              <i className="status-dot" />
              {online
                ? "Local demo workspace"
                : "Offline · saved on this device"}
            </span>
          </footer>
        </main>
      </div>
      {loaded && modal === "entry" && (
        <FieldEntry {...{ data, date, commit, close }} initialId={worker} />
      )}
      {modal === "search" && (
        <Modal title="Search workspace" close={close}>
          <label className="search-input big">
            <Search size={18} />
            <input
              autoFocus
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              aria-label="Search pages"
              placeholder="Find a page or tool…"
            />
          </label>
          <div className="search-results">
            {pages
              .filter(
                ([v]) =>
                  allowed(v) && v.toLowerCase().includes(query.toLowerCase()),
              )
              .map(([v, Icon]) => (
                <button key={v} onClick={() => go(v)}>
                  <Icon size={17} />
                  {v}
                  <ChevronRight size={15} />
                </button>
              ))}
            {!pages.some(
              ([v]) =>
                allowed(v) && v.toLowerCase().includes(query.toLowerCase()),
            ) && (
              <Empty
                title="No matching pages"
                detail="Try searching for attendance, reports, or payroll."
              />
            )}
          </div>
        </Modal>
      )}
      {modal === "profile" && (
        <Modal title="Workspace profile" close={close}>
          <div className="profile-card">
            <span className="profile-avatar">{shortName(who)}</span>
            <div>
              <b>{who}</b>
              <p>{data.role} · Kelani Valley Estate</p>
            </div>
          </div>
          <Field label="Preview a demo role">
            <select
              value={data.role}
              onChange={(e) => switchRole(e.target.value)}
            >
              {ROLES.map((r) => (
                <option key={r}>{r}</option>
              ))}
            </select>
          </Field>
          <p className="muted">
            Role previews use fictional staff and records on this device.
          </p>
          <button
            className="btn full"
            onClick={() => {
              close();
              commit(
                (s) => ({ ...s, signedOut: true }),
                "Demo session ended",
                who,
                "Settings",
              );
            }}
          >
            Sign out of demo
          </button>
        </Modal>
      )}
      {modal === "help" && (
        <Modal title="Workspace guide" close={close}>
          {[
            [
              "Record the day",
              "Open Record field entry, choose the worker and date, mark attendance, and enter the leaf weight and field block.",
            ],
            [
              "Prepare wages",
              "In Payroll, generate a sheet for one division and pay period. A manager can approve or reject the sheet and print individual slips.",
            ],
            [
              "Work in the field",
              "Choose Sinhala or Tamil in the entry form. This demo saves your changes in this browser, including when the network drops.",
            ],
            [
              "Review contributions",
              "Choose EPF / ETF in Reports and select a date range containing an approved pay period to export its figures.",
            ],
          ].map(([k, v]) => (
            <div className="guide" key={k}>
              <h3>{k}</h3>
              <p>{v}</p>
            </div>
          ))}
        </Modal>
      )}
      {toast && (
        <div role="status" className="toast">
          <Check size={16} />
          {toast}
        </div>
      )}
    </div>
  );
}
