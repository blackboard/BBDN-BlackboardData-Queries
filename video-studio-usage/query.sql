/* Explore Video Studio Usage through CDM_MEDIA */

with node_course as (
select
    ifnull(ih.hierarchy_name_seq, 'No Node') as ih_node,
    ifnull(lt.name, 'No Term') as term,
    lc.id as course_id,
    lc.name as course_name,
    lc.course_number,
    mpc.media_container_id
from cdm_lms.course lc
left join cdm_lms.institution_hierarchy_course ihc
    on ihc.course_id = lc.id
    And ihc.primary_ind = 1
left join cdm_lms.institution_hierarchy ih
    on ihc.institution_hierarchy_id = ih.id
left join cdm_lms.term lt
    on lt.id = lc.term_id
left join cdm_map.course mpc
    on mpc.lms_course_id = lc.id
)
-- select * from node_course limit 100; -- UNCOMMENT TO TEST

, video_summary as (
select
    nc.*,
    --mpc.lms_course_id,
    mm.id as media_id,
    mm.stage:mimetype::string as mime_type,
    mm.stage:language::string as language,
    ceil(mm.media_duration/60,0) as duration_mins,
    mm.media_size,
    concat(lp.first_name,' ',lp.last_name) as creator_name,
    mm.media_created_time,
    mm.media_deleted_time
from cdm_media.media mm
inner join cdm_media.container mc
    on mc.id = mm.container_id
left join cdm_map.course mpc
    on mpc.media_container_id = mc.id
left join cdm_map.person mpp
    on mpp.media_person_id = mm.owner_person_id
inner join cdm_lms.person lp
    on lp.id = mpp.lms_person_id
left join node_course nc
    on nc.media_container_id = mm.container_id
)
-- select * from video_summary limit 100; -- UNCOMMENT TO TEST

, video_usage as (
select
    nc.*,
    msa.container_id,
    msa.media_id,
    msa.person_id,
    concat(lp.first_name,' ',lp.last_name) as viewer_name,
    lp.email as viewer_email,
    mm.media_duration,
    count(msa.id) as view_count,
    round(sum(duration_sum)/60) as minutes_viewed,
    round(div0(sum(duration_sum),mm.media_duration),2) as pc_viewed,
    min(first_accessed_time)::date as first_access_date,
    max(first_accessed_time)::date as last_access_date
from cdm_media.session_activity msa
inner join cdm_media.media mm
    on msa.media_id = mm.id
left join cdm_map.person mpp
    on mpp.media_person_id = mm.owner_person_id
inner join cdm_lms.person lp
    on lp.id = mpp.lms_person_id
left join node_course nc
    on nc.media_container_id = msa.container_id
group by all
)
-- select * from video_usage limit 100; -- UNCOMMENT TO TEST

/** UNCOMMENT (delete the first two dashes of) *ONE* OF THE FOLLOWING LINES AND RUN TO PRODUCE RESULTS **/

/* how many videos have we created per month? */

-- select date_trunc(month,media_created_time)::date as month, count(media_id) as video_count, sum(duration_mins) as total_mins from video_summary group by 1 order by 1;

/* which nodes have the most videos? */

--select ih_node, count(distinct course_id) as course_using_count, count(media_id) as video_count, sum(duration_mins) as total_duration from video_summary group by 1 order by course_using_count desc limit 25;

/* which courses have the most videos? */

--select ih_node, term, course_number, course_name, count(media_id) as video_count, sum(duration_mins) as total_duration from video_summary group by all order by video_count desc limit 25;

/* which instructors have the most videos? */

--select creator_name, count(media_id) as video_count, sum(duration_mins) as total_duration from video_summary group by 1 order by video_count desc limit 25;

/* which videos have the most views? */

-- select ih_node, term, course_number, course_name, media_id, media_duration, sum(view_count) as total_views, avg(pc_viewed) as avg_pc_viewed from video_usage group by all order by total_views desc limit 25;

/* which courses have the longest videos? */

-- select ih_node, term, course_number, course_name, count(media_id) as video_count, max(zeroifnull(duration_mins)) as max_duration from video_summary group by all order by max_duration desc limit 25;

/* which students have the most usage? */
-- select viewer_name, viewer_email, count(distinct container_id) as active_course_count, count(distinct media_id) as active_media_count, sum(view_count) as total_views, sum(minutes_viewed) as total_minutes, max(pc_viewed) as max_pc_viewed from video_usage group by all order by total_views desc limit 25;
