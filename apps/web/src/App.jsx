import { Component } from 'react'
import Workspace from '../components/Workspace'
import Overview from '../components/Overview'
import Fieldwork, { FieldEntry } from '../components/Fieldwork'
import { Payroll, Reports } from '../components/Finance'
import {
  DatePicker,
  Modal,
  Field,
  Pill,
  Empty,
  DownloadButton,
} from '../components/UI'

class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }
  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }
  componentDidCatch(error, errorInfo) {
    console.error("App error boundary caught:", error, errorInfo)
  }
  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '40px', fontFamily: 'sans-serif', maxWidth: '640px', margin: '40px auto', background: '#fff', border: '1px solid #dee3da', borderRadius: '12px' }}>
          <h2 style={{ color: '#222d26', marginBottom: '8px' }}>Something went wrong loading EstateTrack</h2>
          <p style={{ color: '#69736c', fontSize: '13px', marginBottom: '16px' }}>An error occurred while rendering the workspace.</p>
          <pre style={{ background: '#fbf4f2', padding: '12px', borderRadius: '6px', color: '#97492f', fontSize: '12px', overflow: 'auto' }}>
            {this.state.error?.message || String(this.state.error)}
          </pre>
          <button
            onClick={() => {
              try {
                localStorage.clear()
              } catch {
                // ignore
              }
              window.location.reload()
            }}
            style={{ marginTop: '16px', padding: '10px 18px', background: '#205e43', color: '#fff', border: 0, borderRadius: '7px', cursor: 'pointer', fontWeight: 600 }}
          >
            Reset Workspace Data & Reload
          </button>
        </div>
      )
    }
    return this.props.children
  }
}

function App() {
  return (
    <ErrorBoundary>
      <Workspace />
    </ErrorBoundary>
  )
}

export {
  Workspace,
  Overview,
  Fieldwork,
  FieldEntry,
  Payroll,
  Reports,
  DatePicker,
  Modal,
  Field,
  Pill,
  Empty,
  DownloadButton,
}

export default App
