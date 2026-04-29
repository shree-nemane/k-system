import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sqlalchemy import create_engine, text
import time
from datetime import datetime, timedelta, timezone
import json
import os
import httpx

# Page Config
st.set_page_config(
    page_title="MahaKumbh 2027 Surveillance Hub",
    page_icon="🕉️",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Constants & Settings
# Use standard psycopg2 driver for Streamlit compatibility
DB_URL = "postgresql://postgres:kumbh_pass@localhost:5432/kumbh_db"
# Path to snapshots relative to this file
SNAPSHOT_DIR = os.path.join(os.path.dirname(__file__), "..", "app", "static", "snapshots")
REFRESH_INTERVAL = 3  # Seconds

# Database Connection
@st.cache_resource
def get_engine():
    return create_engine(DB_URL)

def get_latest_status():
    """Fetch the most recent crowd event per camera."""
    engine = get_engine()
    # Use distinct on camera_id, order by timestamp desc
    query = text("""
        SELECT DISTINCT ON (camera_id) camera_id, person_count, density_level, panic_score, is_panic, timestamp
        FROM crowd_events
        ORDER BY camera_id, timestamp DESC;
    """)
    try:
        with engine.connect() as conn:
            return pd.read_sql(query, conn)
    except Exception:
        # Return empty df if table doesn't exist yet
        return pd.DataFrame()

def load_camera_config():
    """Load camera definitions from cameras.json."""
    config_path = os.path.join(os.path.dirname(__file__), "..", "cameras.json")
    try:
        with open(config_path, 'r') as f:
            data = json.load(f)
            return data.get('cameras', [])
    except Exception as e:
        st.error(f"Config Load Error: {e}")
        return []

def get_history(camera_id, hours=24):
    """Fetch 5-minute aggregated metrics for trends (D-34)."""
    engine = get_engine()
    # 5-minute bucket SQL logic from Implementation Plan
    # NOTE: We use :camera_id and :interval_hours to avoid placeholder collisions with '%'
    query = text("""
        SELECT 
            date_trunc('minute', timestamp) - (CAST(extract(minute FROM timestamp) AS integer) % 5) * interval '1 minute' AS bucket,
            AVG(person_count) as avg_count,
            MAX(person_count) as max_count,
            COUNT(id) FILTER (WHERE is_panic = TRUE) as panic_events
        FROM crowd_events
        WHERE camera_id = :camera_id 
          AND timestamp > NOW() - CAST(:interval_hours || ' hours' AS interval)
        GROUP BY bucket
        ORDER BY bucket ASC;
    """)
    try:
        with engine.connect() as conn:
            return pd.read_sql(query, conn, params={"camera_id": camera_id, "interval_hours": str(hours)})
    except Exception as e:
        st.error(f"History Search Error: {e}")
        return pd.DataFrame()

def get_active_sos():
    """Fetch recent SOS requests from users."""
    engine = get_engine()
    query = text("""
        SELECT id, device_id, latitude, longitude, category, status, created_at, responder_name
        FROM sos_requests
        WHERE status != 'resolved'
        ORDER BY created_at DESC
        LIMIT 10;
    """)
    try:
        with engine.connect() as conn:
            return pd.read_sql(query, conn)
    except Exception as e:
        # Table might not exist yet if migrations haven't run, but we assume it does based on models
        return pd.DataFrame()

def get_recent_alerts(limit=5):
    """Fetch most recent critical alerts from the alerts table."""
    engine = get_engine()
    query = text("""
        SELECT event_type, camera_id, severity, message, recommendation, fired_at
        FROM alerts
        ORDER BY fired_at DESC
        LIMIT :limit;
    """)
    try:
        with engine.connect() as conn:
            return pd.read_sql(query, conn, params={"limit": limit})
    except Exception:
        return pd.DataFrame()

# --- UI Components ---

def draw_custom_css():
    """Inject CSS to remove the fade effect during updates (D-99)."""
    st.markdown("""
        <style>
        /* Maintain full opacity during computation to prevent 'fade' */
        [data-testid="stAppViewContainer"] {
            opacity: 1 !important;
        }
        /* Optional: hide the spinner if it's distracting */
        div[data-testid="stStatusWidget"] {
            visibility: hidden;
        }
        </style>
    """, unsafe_allow_html=True)

def draw_header():
    st.title("🕉️ MahaKumbh 2027 | Surveillance & Panic Detection Hub")
    st.info("💡 Pro-Tip: Dashboard refreshes every 3 seconds to reflect real-time AI worker snapshots.")
    st.markdown("---")

def draw_camera_card(camera_id, status_row):
    """Draw a single camera card with snapshot and metrics (D-30)."""
    # 1. Health & Color Logic (D-26)
    last_ts = pd.to_datetime(status_row['timestamp'])
    
    # Calculate staleness
    now_utc = datetime.now(timezone.utc)
    if last_ts.tzinfo is None:
        last_ts = last_ts.replace(tzinfo=timezone.utc)
        
    staleness_sec = (now_utc - last_ts).total_seconds()
    is_frozen = staleness_sec > 15
    
    density = status_row['density_level']
    is_panic = status_row['is_panic']
    
    # Color mapping (D-26 refinement)
    if is_panic:
        color = "🔴"
        status_text = f"🆘 CRITICAL: PANIC (Score: {status_row['panic_score']:.1f})"
        bg_css = "background-color: #ffe6e6; border: 2px solid red;"
    elif density == "high":
        color = "🟡"
        status_text = "⚠️ WARNING: HIGH DENSITY"
        bg_css = "background-color: #fff9e6; border: 2px solid orange;"
    elif is_frozen:
        color = "⚪"
        status_text = f"OFFLINE (Stale for {int(staleness_sec)}s)"
        bg_css = "background-color: #f2f2f2; border: 1px solid gray;"
    else:
        color = "🟢"
        status_text = f"NORMAL (Density: {status_row['person_count']})"
        bg_css = "background-color: #e6ffef; border: 1px solid green;"

    with st.container():
        # Metric Overlay (Simple Title)
        st.write(f"### {color} Cam: {camera_id}")
        
        # Snapshot Display (D-24: Reading the atomic file)
        img_path = os.path.join(SNAPSHOT_DIR, f"{camera_id}_last.jpg")
        if os.path.exists(img_path):
            st.image(img_path, width='stretch', caption=status_text)
        else:
            # Placeholder or info if image not found (first run)
            st.warning(f"🕒 Snapshot pending for {camera_id}. Ensure the AI Worker (processor.py) is running to generate live frames.")
            
        m1, m2, m3 = st.columns(3)
        m1.metric("Density", f"{status_row['person_count']} pax")
        m2.metric("Level", density.upper())
        m3.metric("Updated", f"{int(staleness_sec)}s ago")

# --- Main Application Loop ---

draw_custom_css()
draw_header()

# Sidebar for controls
with st.sidebar:
    st.header("⚙️ Settings")
    auto_refresh = st.checkbox("Live Polling (3s)", value=True)
    history_hours = st.slider("Trend History (Hours)", 1, 48, 24)
    st.divider()
    st.write("📊 Surveillance Stats")
    # Quick health summary
    st.info("System healthy. AI Workers connected.")
    
    # 2. Add API health check
    try:
        resp = httpx.get("http://127.0.0.1:8000/health", timeout=1.0)
        if resp.status_code == 200:
            st.success("✅ Backend API: ONLINE")
        else:
            st.error(f"❌ Backend API: ERROR {resp.status_code}")
    except Exception:
        st.error("❌ Backend API: OFFLINE")
        st.caption("Ensure the backend is running.")

@st.fragment(run_every=3 if auto_refresh else None)
def dashboard_content_fragment(h_hours):
    # 1. Main Dashboard Content
    try:
        # Fetch data
        camera_configs = load_camera_config()
        sos_df = get_active_sos()
        status_df = get_latest_status()
    
        # --- Emergency Alert Hub ---
        st.subheader("🚨 Emergency Response Control")
        a1, a2 = st.columns([2, 1])
        
        with a1:
            st.write("#### Active User SOS Alerts")
            if sos_df.empty:
                st.success("No active SOS requests. Ground teams on standby.")
            else:
                for _, row in sos_df.iterrows():
                    with st.expander(f"🆘 {row['category']} - {row['status'].upper()} ({row['created_at'].strftime('%H:%M:%S')})"):
                        st.write(f"**Device ID:** `{row['device_id']}`")
                        st.write(f"**Location:** {row['latitude']}, {row['longitude']}")
                        if row['responder_name']:
                            st.write(f"**Responder:** {row['responder_name']}")
                        else:
                            st.button(f"Assign Commander for {str(row['id'])[:8]}", key=f"btn_{row['id']}")

        with a2:
            st.write("#### System Alert Center")
            panic_count = status_df['is_panic'].sum() if not status_df.empty else 0
            sos_count = len(sos_df)
            
            alerts_df = get_recent_alerts(limit=5)
            
            if not alerts_df.empty:
                for _, alert in alerts_df.iterrows():
                    st.error(f"**{alert['event_type'].upper()}** @ {alert['camera_id']}")
                    st.write(f"_{alert['message']}_")
                    if alert['recommendation']:
                        st.info(f"💡 {alert['recommendation']}")
                    st.caption(f"Fired at: {alert['fired_at']}")
                    st.divider()
            
            if panic_count > 0:
                st.error(f"⚠️ AI detection: {panic_count} panic events active!")
            if sos_count > 0:
                st.warning(f"🆘 User reports: {sos_count} active emergency signals.")
            if panic_count == 0 and sos_count == 0 and alerts_df.empty:
                st.success("No critical safety alerts in last cycle.")

        st.divider()

        # 2. Camera Grid
        st.subheader("📍 Live Sector Surveillance")
        active_configs = [c for c in camera_configs if c.get('active', True)]
        
        if not active_configs:
            st.warning("No active cameras found in cameras.json.")
        else:
            # Using columns to create a responsive grid
            rows_needed = (len(active_configs) + 2) // 3
            for r in range(rows_needed):
                cols = st.columns(3)
                for c in range(3):
                    idx = r * 3 + c
                    if idx < len(active_configs):
                        cam_cfg = active_configs[idx]
                        cam_id = cam_cfg['id']
                        
                        # Try to find recent data in DB
                        if not status_df.empty and cam_id in status_df['camera_id'].values:
                            row_data = status_df[status_df['camera_id'] == cam_id].iloc[0]
                        else:
                            # Fallback for cameras with no data yet
                            row_data = {
                                'camera_id': cam_id,
                                'person_count': 0,
                                'density_level': 'low',
                                'panic_score': 0.0,
                                'is_panic': False,
                                'timestamp': datetime.now(timezone.utc) - timedelta(days=1)
                            }
                        
                        with cols[c]:
                            draw_camera_card(cam_id, row_data)

        st.markdown("---")
        
        # 3. Analytics Section
        st.subheader("📈 Integrated Trend Analysis")
        
        all_cam_ids = [c['id'] for c in camera_configs]
        if not all_cam_ids:
            st.info("Waiting for camera configuration...")
        else:
            col_select, col_empty = st.columns([1, 2])
            selected_cam = col_select.selectbox("Analyze History for Cam:", all_cam_ids)
            
            hist_df = get_history(selected_cam, hours=h_hours)
            
            if not hist_df.empty:
                # Multi-axis chart: Density vs Panic
                fig = go.Figure()
                # Density Trace
                fig.add_trace(go.Scatter(
                    x=hist_df['bucket'], y=hist_df['avg_count'],
                    name="Avg Density", line=dict(color='#0066ff', width=3),
                    fill='tozeroy'
                ))
                # Panic Events Trace (Bar on Y2)
                fig.add_trace(go.Bar(
                    x=hist_df['bucket'], y=hist_df['panic_events'],
                    name="Panic Events", marker_color='red', opacity=0.4,
                    yaxis="y2"
                ))
                
                fig.update_layout(
                    title=f"Crowd Trend: {selected_cam} (Last {h_hours}h)",
                    xaxis_title="Time",
                    yaxis=dict(title="Density (Pax/Frame)"),
                    yaxis2=dict(title="Panic Events", overlaying="y", side="right", range=[0, 10]),
                    height=450,
                    legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1),
                    margin=dict(l=0, r=0, t=50, b=0)
                )
                st.plotly_chart(fig, width='stretch')
                
                # Additional Summary Stats
                s1, s2, s3 = st.columns(3)
                s1.metric("Max Peak", f"{int(hist_df['max_count'].max())} pax")
                s2.metric("Total Panic Events", f"{int(hist_df['panic_events'].sum())}")
                s3.metric("Aggregation Bucket", "5 minutes")
            else:
                st.info(f"Historical trends for Camera '{selected_cam}' will appear here once data accumulates.")

    except Exception as e:
        st.error(f"🚨 Operational Fault: {e}")

# Call the fragment
dashboard_content_fragment(history_hours)
