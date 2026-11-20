export const TODAY = "2026-11-18";
export const DIVISIONS = [
  "Upper Division",
  "Middle Division",
  "Lower Division",
];
export const ROLES = [
  "Estate Manager",
  "Estate Clerk",
  "Field Supervisor",
  "Administrator",
];
export const PEOPLE = {
  "Estate Manager": "Anjali Perera",
  "Estate Clerk": "Nimal Silva",
  "Field Supervisor": "Kavitha Rajan",
  Administrator: "Dev Fernando",
};
export const DEFAULT_RATES = {
  norm: 18,
  bonus: 65,
  employee: 8,
  employer: 12,
  etf: 3,
};
const names = [
  "Kavitha",
  "Nimal",
  "Selvi",
  "Arun",
  "Malini",
  "Suresh",
  "Rani",
  "Sunil",
  "Lakshmi",
  "Kumar",
  "Amara",
  "Nalini",
  "Vijay",
  "Shanthi",
  "Ravi",
  "Meena",
];
const families = [
  "Perera",
  "Rajendran",
  "Fernando",
  "Kumarasamy",
  "Silva",
  "Sundaram",
  "Mendis",
  "Nadarajah",
];
export function seedWorkers() {
  return Array.from({ length: 128 }, (_, i) => ({
    id: "ET-" + String(1001 + i),
    name: names[i % 16] + " " + families[(Math.floor(i / 16) + i) % 8],
    division: DIVISIONS[i % 3],
    rate: 1500,
    active: true,
    seed: i,
    nic: "DEMO-" + (2001 + i),
    epf: "E-" + (4500 + i),
    etf: "T-" + (6100 + i),
  }));
}
export function shift(date, days) {
  let d = new Date(date + "T12:00:00Z");
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}
export function dates(start, end) {
  let a = [];
  for (let d = start; d <= end; d = shift(d, 1)) a.push(d);
  return a;
}
export function pretty(
  date,
  opts = { day: "numeric", month: "short", year: "numeric" },
) {
  return new Intl.DateTimeFormat("en-GB", { ...opts, timeZone: "UTC" }).format(
    new Date(date + "T12:00:00Z"),
  );
}
export const num = (value, max = 0) =>
  Number(value).toLocaleString("en-GB", { maximumFractionDigits: max });
export const money = (n) => "Rs. " + num(n, 2);
export function entry(worker, date, changes) {
  const saved = changes[date + "/" + worker.id];
  if (saved) return saved;
  if (worker.seed == null || date < shift(TODAY, -40) || date > TODAY)
    return { status: "Unmarked", kg: 0, block: "" };
  const day = Math.round((Date.parse(date) - Date.parse(TODAY)) / 86400000);
  const roll = (((worker.seed * 37 + day * 7) % 128) + 128) % 128;
  const full = 114 - (Math.abs(day * 3) % 8),
    half = 6 + (Math.abs(day) % 2);
  const status =
    roll < full ? "Present" : roll < full + half ? "Half-day" : "Absent";
  const wave = [
    1.14, 0.97, 0.86, 0.94, 1.04, 0.9, 1.02, 0.78, 0.94, 0.87, 1.08, 1.02, 0.99,
    1.07,
  ];
  const kg =
    status === "Absent"
      ? 0
      : Math.round(
          (18 + ((worker.seed * 19 + Math.abs(day) * 3) % 12)) *
            wave[((day % wave.length) + wave.length) % wave.length] *
            (status === "Half-day" ? 0.5 : 1),
        );
  return { status, kg, block: "Block " + (1 + (worker.seed % 6)) };
}
export function tally(workers, date, changes) {
  let result = { Present: 0, "Half-day": 0, Absent: 0, Unmarked: 0, kg: 0 };
  for (const w of workers) {
    const e = entry(w, date, changes);
    result[e.status]++;
    result.kg += e.kg;
  }
  return result;
}
export function sheetRows(workers, changes, start, end, rates) {
  const period = dates(start, end);
  return workers
    .map((w) => {
      let days = 0,
        kg = 0,
        extra = 0;
      for (const date of period) {
        let e = entry(w, date, changes);
        const fraction =
          e.status === "Present" ? 1 : e.status === "Half-day" ? 0.5 : 0;
        days += fraction;
        kg += e.kg;
        extra += fraction ? Math.max(0, e.kg - rates.norm * fraction) : 0;
      }
      const base = days * w.rate,
        incentive = extra * rates.bonus,
        gross = base + incentive;
      return {
        id: w.id,
        name: w.name,
        division: w.division,
        epfNo: w.epf,
        etfNo: w.etf,
        days,
        kg,
        base,
        incentive,
        gross,
        employee: (gross * rates.employee) / 100,
        employer: (gross * rates.employer) / 100,
        etf: (gross * rates.etf) / 100,
        net: gross * (1 - rates.employee / 100),
      };
    })
    .filter((r) => r.days > 0);
}
export function csv(filename, headers, rows) {
  const quote = (v) => {
    let s = String(v ?? "");
    if (/^[=+@-]/.test(s)) s = "'" + s;
    return '"' + s.replaceAll('"', '""') + '"';
  };
  const blob = new Blob(
    [
      "\ufeff" +
        [headers, ...rows].map((row) => row.map(quote).join(",")).join("\r\n"),
    ],
    { type: "text/csv;charset=utf-8" },
  );
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename + ".csv";
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 5000);
}
export function initialState() {
  const workers = seedWorkers(),
    end = shift(TODAY, -1),
    start = shift(end, -6);
  const sheets = DIVISIONS.slice(0, 2).map((division, i) => ({
    id: "WS-" + (1002 - i),
    division,
    start,
    end,
    status: i ? "Approved" : "Pending review",
    rows: sheetRows(
      workers.filter((w) => w.division === division),
      {},
      start,
      end,
      DEFAULT_RATES,
    ),
  }));
  return {
    workers,
    changes: {},
    rates: DEFAULT_RATES,
    sheets,
    role: "Estate Manager",
    language: "English",
    activity: [
      {
        id: "sample-2",
        title: "Wage sheet ready for review",
        detail: "Upper Division · " + pretty(end),
        view: "Payroll",
        date: TODAY,
      },
      {
        id: "sample-1",
        title: "Wage sheet approved",
        detail: "Middle Division · " + pretty(end),
        view: "Payroll",
        date: end,
      },
    ],
  };
}
export const shortName = (s) =>
  s
    .split(" ")
    .map((x) => x[0])
    .join("")
    .slice(0, 2);
export const translations = {
  English: {
    worker: "Worker",
    date: "Date",
    status: "Attendance",
    kg: "Harvest weight (kg)",
    block: "Field / block",
    save: "Save entry",
    Present: "Present",
    Absent: "Absent",
    "Half-day": "Half-day",
  },
  සිංහල: {
    worker: "සේවකයා",
    date: "දිනය",
    status: "පැමිණීම",
    kg: "අස්වැන්න (කි.ග්‍රෑ.)",
    block: "ක්ෂේත්‍රය / කොටස",
    save: "සටහන සුරකින්න",
    Present: "පැමිණ ඇත",
    Absent: "නොපැමිණි",
    "Half-day": "අර්ධ දිනය",
  },
  தமிழ்: {
    worker: "தொழிலாளர்",
    date: "தேதி",
    status: "வருகை",
    kg: "அறுவடை எடை (கிலோ)",
    block: "புலம் / பிரிவு",
    save: "பதிவைச் சேமி",
    Present: "வருகை",
    Absent: "வரவில்லை",
    "Half-day": "அரை நாள்",
  },
};
