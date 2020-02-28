select
  count(distinct room_id) as room_count,
  count(id) as session_count,
  session_count / room_count as avg_sessions_per_room,
  sum(attended_duration/60) as session_minutes_sum
from cdm_clb.session
where attended_duration > 0