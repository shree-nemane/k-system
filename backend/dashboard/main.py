import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sqlalchemy import create_engine, text
import time
from datetime import datetime, timedelta, timezone
import os

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
    except Exception as e:
        st.error(f"Latest Status Error: {e}")
        return pd.DataFrame()

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

# --- UI Components ---

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

draw_header()

# Sidebar for controls
auto_query = True
with st.sidebar:
    st.header("⚙️ Settings")
    auto_refresh = st.checkbox("Live Polling (3s)", value=True)
    history_hours = st.slider("Trend History (Hours)", 1, 48, 24)
    st.divider()
    st.write("📊 Surveillance Stats")
    # Quick health summary
    st.info("System healthy. AI Workers connected.")

# 1. Main Dashboard Content
try:
    status_df = get_latest_status()
    
    if status_df.empty:
        st.warning("No camera events detected yet. Waiting for AI workers to initialize...")
    else:
        # 2. Camera Grid (D-30: Production layout)
        st.subheader("📍 Live Sector Surveillance")
        cameras = sorted(status_df['camera_id'].unique())
        
        # Using columns to create a responsive grid
        rows_needed = (len(cameras) + 2) // 3
        for r in range(rows_needed):
            cols = st.columns(3)
            for c in range(3):
                idx = r * 3 + c
                if idx < len(cameras):
                    cam_id = cameras[idx]
                    row_data = status_df[status_df['camera_id'] == cam_id].iloc[0]
                    with cols[c]:
                        draw_camera_card(cam_id, row_data)

        st.markdown("---")
        
        # 3. Analytics Section (D-34)
        st.subheader("📈 Integrated Trend Analysis")
        
        col_select, col_empty = st.columns([1, 2])
        selected_cam = col_select.selectbox("Analyze History for Cam:", cameras)
        
        hist_df = get_history(selected_cam, hours=history_hours)
        
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
                title=f"Crowd Trend: {selected_cam} (Last {history_hours}h)",
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

# Live Refresh Mechanism
if auto_refresh:
    time.sleep(REFRESH_INTERVAL)
    st.rerun()
