"use client";
import { useEffect, useRef } from "react";
import { CalendarDays, ChevronDown, X, Inbox } from "lucide-react";
import { pretty } from "../lib/estate";
export function DatePicker({ date, onChange }) {
  return (
    <label className="date-picker">
      <CalendarDays size={16} />
      <span>
        {pretty(date, {
          weekday: "short",
          day: "numeric",
          month: "short",
          year: "numeric",
        })}
      </span>
      <ChevronDown size={14} />
      <input
        aria-label="Workspace date"
        type="date"
        value={date}
        onChange={(e) => e.target.value && onChange(e.target.value)}
      />
    </label>
  );
}
export function Modal({ title, children, close, wide = false }) {
  const ref = useRef(null);
  useEffect(() => {
    const el = ref.current;
    el.showModal();
    return () => el.close();
  }, []);
  return (
    <dialog
      ref={ref}
      className={wide ? "modal wide" : "modal"}
      aria-label={title}
      onCancel={(e) => {
        e.preventDefault();
        close();
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) close();
      }}
    >
      <div className="modal-body">
        <div className="modal-head">
          <h2>{title}</h2>
          <button
            aria-label="Close dialog"
            className="icon-btn"
            onClick={close}
          >
            <X size={20} />
          </button>
        </div>
        {children}
      </div>
    </dialog>
  );
}
export function Pill({ value }) {
  return (
    <span className={"pill " + value.toLowerCase().replaceAll(" ", "-")}>
      {value}
    </span>
  );
}
export function Empty({
  title = "No matching records",
  detail = "Try another date, division, or worker.",
}) {
  return (
    <div className="empty">
      <Inbox size={28} />
      <strong>{title}</strong>
      <span>{detail}</span>
    </div>
  );
}
export function DownloadButton({ children, onClick }) {
  return (
    <button className="btn" onClick={onClick}>
      {children}
    </button>
  );
}
export function Field({ label, children }) {
  return (
    <label className="field">
      <span>{label}</span>
      {children}
    </label>
  );
}
