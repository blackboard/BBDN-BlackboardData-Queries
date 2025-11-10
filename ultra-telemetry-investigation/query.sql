
-- FIND COURSE BY PK1
select * from cdm_lms.course where source_id = 722; -- REPLACE NUMBER WITH COURSE PK1, RUN AND NOTE ID VALUE

-- FIND DELETED ITEMS IN COURSE
select * from cdm_lms.course_item where course_id = 216868 and row_deleted_time is not null; -- REPLACE COURSE_ID VALUE WITH ID FROM ABOVE, RUN AND DOWNLOAD RESULTS FOR COMPARISON

-- FIND DELETION TELEMETRY EVENTS
select
    ue.data:eventId::string as event_id,
    ue.data:interactionUrl::string as url,
    ue.data:objectId::string as object_id,
    ue.data:sessionId::string as session_id,
    ue.data:ipAddress::string as ip_address,
    ue.data:userAgent::string as user_agent,
    lp.stage:user_id::string as user_id,
    lc.name as course_name,
    lc.course_number as course_id,
    lci.name as item_name,
    lci.item_type,
    ue.event_time,
    lci.created_time as item_created_timestamp,
    timediff(second,ue.event_time,lci.created_time) as seconds_tlm_to_lci,
    lci.modified_time as item_modified_timestamp,
    ue.data
from cdm_tlm.ultra_events ue
left join cdm_lms.person lp
    on lp.stage:uuid::string = ue.data:userId::string
left join cdm_lms.course lc
    on concat('_',lc.source_id,'_1') = ue.data:contextId::string
left join cdm_lms.course_item lci
    on concat('_',split_part(lci.source_id,'COURSE_CONTENTS;',2),'_1') = ue.data:interactionContext:content:id::string
    or concat('_',split_part(lci.source_id,'FORUM_MAIN;',2),'_1') = ue.data:interactionContext:content:id::string
where -- HIGHLY GRANULAR DATA - **FILTERING IS ESSENTIAL**
    -- event_time::date = '2025-04-01' and -- UNCOMMENT AND INSERT DATE HERE IF NEEDED
    url like '%courses/_722_1%' and -- INSERT COURSE PK1 BETWEEN UNDERSCORES
    object_id ilike '%DELETE%' -- OPTIONS: DELETE, SAVE (changes), VISIBLE, DRAG (move), CREATE
order by event_time desc 
LIMIT 1000; -- ROW LIMIT RECOMMENDED BUT IN ADDITION TO FILTERING IN 'WHERE' CLAUSE

/* RUN ABOVE STATEMENT AND COPY EVENT_ID, USER_ID AND SESSION_ID OF EVENT OF INTEREST FOR USE BELOW */

-- GET CONTEXT OF A SPECIFIC EVENT
select
    ue.data:eventId::string as event_id,
    case
        when event_id = 'b33217de-cafe-44ae-c439-9a5c8618471c' -- REPLACE WITH EVENT_ID OF CHOSEN EVENT
        then '>>>>>>'
        else ''
    end as chosen_event_indicator,
    ue.data:interactionUrl::string as url,
    ue.data:objectId::string as object_id,
    ue.data:sessionId::string as session_id,
    ue.data:ipAddress::string as ip_address,
    ue.data:userAgent::string as user_agent,
    lp.stage:user_id::string as user_id,
    lc.name as course_name,
    lc.course_number as course_id,
    lci.name as item_name,
    lci.item_type,
    ue.event_time,
    lci.created_time as item_created_timestamp,
    timediff(second,ue.event_time,lci.created_time) as seconds_tlm_to_lci,
    lci.modified_time as item_modified_timestamp,
    ue.data
from cdm_tlm.ultra_events ue
left join cdm_lms.person lp
    on lp.stage:uuid::string = ue.data:userId::string
left join cdm_lms.course lc
    on concat('_',lc.source_id,'_1') = ue.data:contextId::string
left join cdm_lms.course_item lci
    on concat('_',split_part(lci.source_id,'COURSE_CONTENTS;',2),'_1') = ue.data:interactionContext:content:id::string
where -- HIGHLY GRANULAR DATA - FILTERING IS ESSENTIAL
    -- event_time::date = '2025-04-01' and -- UNCOMMENT AND INSERT DATE HERE IF NEEDED
    ue.data:contextId::string = '_722_1' and -- INSERT COURSE PK1 BETWEEN UNDERSCORES
    session_id = '8832403' and
    user_id = 'laura.mcnally'
order by event_time asc 
LIMIT 1000; -- ROW LIMIT RECOMMENDED BUT IN ADDITION TO FILTERING IN 'WHERE' CLAUSE
