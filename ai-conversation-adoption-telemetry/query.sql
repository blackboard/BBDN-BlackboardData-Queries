with ai_conversation_creation as (
select
    data:sessionId::string as session_id,
    data:userId::string as uuid,
    data:contextId::string as course,
    data:interactionContext:content:id::string as course_contents_pk1,
    event_time
from cdm_tlm.ultra_events
where 
    data:interactionUrl::string like '%create%' and 
    data:objectId::string like '%AiConversation'
)

select
    lc.name as course_name,
    lc.course_number as course_id,
    concat(lp.first_name, ' ',lp.last_name) as creator_name,
    lp.stage:user_id::string as creator_userid,
    lp.email as creator_email,
    count(course_contents_pk1) as item_count,
    min(acc.event_time) as first_item_created_time,
    max(acc.event_time) as last_item_created_time
from ai_conversation_creation acc
inner join cdm_lms.course lc
    on lc.source_id = split_part(acc.course,'_',2)
inner join cdm_lms.person lp
    on lp.stage:uuid::string = acc.uuid
group by all;
