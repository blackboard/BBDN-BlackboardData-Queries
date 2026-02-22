SELECT 
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(assess_qad.data) IS NULL, assess_qad.data, NULL)) AS VARIANT) AS qad_obj,
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(section_qad.data) IS NULL, section_qad.data, NULL)) AS VARIANT) AS section_qad_obj,
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT) AS qrd_obj,
    XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'chatQuestionType'):"$"::STRING AS chat_question_type,
    XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botName'):"$"::STRING AS bot_name,
    XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botRole'):"$"::STRING AS bot_role,
    r.index AS response_order,
    IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL) AS raw_message,
    r.value:"@response_status"::STRING AS response_status,
    r.value:"@response_time"::STRING AS response_time,
    SPLIT_PART(raw_message, ',', 1) AS message_source,
    SPLIT_PART(raw_message, ',', 3) AS timestamp_ms,
    CASE 
        WHEN timestamp_ms IS NULL THEN NULL
        ELSE TO_TIMESTAMP(timestamp_ms / 1000)
    END AS msg_timestamp,
    qad.description,
    REGEXP_REPLACE(raw_message, '^[^,]+,[^,]+,[^,]+,[^,]+,', '') AS conversation_message,
    qad.pk1 AS qad_pk1,
    qrd.pk1 AS qrd_pk1,
    qad.bbmd_questiontype,
    qad.ai_state as is_assessment_ai_generated,
    section_qad.bbmd_sectiontype as section_type,
    section_qad.ai_state as is_section_ai_generated,
    section_qad.title as section_title,
    section_qad.description as section_desciption,
    section_qad.position as section_postition,
    assess_qad.bbmd_questiontype as question_type,
    assess_qad.title as assess_title,
    assess_qad.description as assess_description,
    assess_qad.ai_state as assess_is_ai_generated,
    assess_qad.position as assess_position
FROM LEARN.QTI_ASI_DATA qad
    LEFT JOIN LEARN.QTI_ASI_DATA section_qad
        ON section_qad.parent_pk1 = qad.pk1
    LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
        ON assess_qad.parent_pk1 = section_qad.pk1
    LEFT JOIN LEARN.QTI_RESULT_DATA qrd
            ON qrd.qti_asi_data_pk1 = assess_qad.pk1,
LATERAL FLATTEN(
    input => qrd_obj:"$"
) f
,LATERAL FLATTEN(
    input => f.value:"$"
) r
    WHERE 
        STARTSWITH(r.value, '<response_value') AND
        qad.bbmd_assessment_subtype = 'AiConversation' AND
        (CONTAINS(raw_message, 'Bot,') OR CONTAINS(raw_message, 'Student,'))
    ORDER BY 
        qad_pk1, qrd_pk1, response_order
;


select 
'qad->',
qad.*,
'course_main->',
cm.*,
'qrd->',
qrd.*,
'ca->',
ca.*,
'lnk->',
lnk.*,
'COURSE_CONTENTS->',
cc.*,
'ATTEMPT',
a.*,
'GRADEBOOK_GRADE',
gg.*,
'GRADEBOOK_MAIN',
gm.*,
'COURSE_USERS',
cu.*,
'USERS',
u.*
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.COURSE_MAIN cm
    ON cm.pk1 = qad.crsmain_pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd
        ON qrd.qti_asi_data_pk1 = qad.pk1
left join LEARN.COURSE_ASSESSMENT ca
    on ca.qti_asi_data_pk1 = qad.pk1
left join LEARN.LINK lnk
    on lnk.link_source_pk1 = ca.pk1 
    and lnk.link_source_table = 'COURSE_ASSESSMENT'
left join LEARN.COURSE_CONTENTS cc
    on lnk.course_contents_pk1 = cc.pk1
 LEFT JOIN LEARN.ATTEMPT a 
    ON a.qti_result_data_pk1 = qrd.pk1
LEFT JOIN LEARN.GRADEBOOK_GRADE gg 
    ON gg.pk1 = a.gradebook_grade_pk1
LEFT JOIN LEARN.GRADEBOOK_MAIN gm
    ON gm.pk1 = gg.gradebook_main_pk1
LEFT JOIN LEARN.COURSE_USERS cu 
    ON cu.pk1 = gg.course_users_pk1
LEFT JOIN LEARN.USERS u 
    ON u.pk1 = cu.users_pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;

select 
'qad->',
qad.*,
'section_qad ->',
section_qad.*,
'assess_qad ->',
assess_qad.*,
'qrd->',
qrd.*,
'qrd_section->',
qrd_section.*,
'qrd_assess->',
qrd_assess.* ---this .data has the conversation
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.QTI_ASI_DATA section_qad
    ON section_qad.parent_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
    ON assess_qad.parent_pk1 = section_qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd
        ON qrd.qti_asi_data_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_section
        ON qrd_section.qti_asi_data_pk1 = section_qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_assess
        ON qrd_assess.qti_asi_data_pk1 = assess_qad.pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;


select 
'qad->',
qad.*,
'course_main->',
cm.*,
'qrd->',
qrd.*,
'qrd_section->',
qrd_section.*,
'qrd_assess->',
qrd_assess.*
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.COURSE_MAIN cm
    ON cm.pk1 = qad.crsmain_pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd
    ON qrd.qti_asi_data_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_section 
    ON qrd.parent_pk1 = qrd_section.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_assess 
    ON qrd_section.parent_pk1 = qrd_assess.pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
    ;
select 
cc.title,
'qad->',
qad.*,
'section_qad ->',
section_qad.*,
'assess_qad ->',
assess_qad.*,
'course_main->',
cm.*,
'qrd->',
qrd.*,
'ca->',
ca.*,
'lnk->',
lnk.*,
'COURSE_CONTENTS->',
cc.*,
'ATTEMPT->',
a.*,
'GRADEBOOK_GRADE->',
gg.*,
'GRADEBOOK_MAIN->',
gm.*,
'COURSE_USERS->',
cu.*,
'USERS->',
u.*
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.QTI_ASI_DATA section_qad
    ON section_qad.parent_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
    ON assess_qad.parent_pk1 = section_qad.pk1
LEFT JOIN LEARN.COURSE_MAIN cm
    ON cm.pk1 = qad.crsmain_pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd
        ON qrd.qti_asi_data_pk1 = qad.pk1
left join LEARN.COURSE_ASSESSMENT ca
    on ca.qti_asi_data_pk1 = qad.pk1
left join LEARN.LINK lnk
    on lnk.link_source_pk1 = ca.pk1 
    and lnk.link_source_table = 'COURSE_ASSESSMENT'
left join LEARN.COURSE_CONTENTS cc
    on lnk.course_contents_pk1 = cc.pk1
 LEFT JOIN LEARN.ATTEMPT a 
    ON a.qti_result_data_pk1 = qrd.pk1
LEFT JOIN LEARN.GRADEBOOK_GRADE gg 
    ON gg.pk1 = a.gradebook_grade_pk1
LEFT JOIN LEARN.GRADEBOOK_MAIN gm
    ON gm.pk1 = gg.gradebook_main_pk1
LEFT JOIN LEARN.COURSE_USERS cu 
    ON cu.pk1 = gg.course_users_pk1
LEFT JOIN LEARN.USERS u 
    ON u.pk1 = cu.users_pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;

select * from LEARN.QTI_ASI_DATA qad
    LEFT JOIN LEARN.QTI_RESULT_DATA qrd
            ON qrd.qti_asi_data_pk1 = qad.pk1
    LEFT JOIN LEARN.COURSE_ASSESSMENT ca
            on ca.qti_asi_data_pk1 = qad.pk1
where qad.bbmd_assessment_subtype = 'AiConversation'

select 
'qad->',
qad.*,
'course_main->',
cm.*,
'qrd->',
qrd.*,
'ca->',
ca.*,
'lnk->',
lnk.*,
'COURSE_CONTENTS->',
cc.*,
'ATTEMPT',
a.*,
'GRADEBOOK_GRADE',
gg.*,
'GRADEBOOK_MAIN',
gm.*,
'COURSE_USERS',
cu.*,
'USERS',
u.*
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.COURSE_MAIN cm
    ON cm.pk1 = qad.crsmain_pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd
        ON qrd.qti_asi_data_pk1 = qad.pk1
left join LEARN.COURSE_ASSESSMENT ca
    on ca.qti_asi_data_pk1 = qad.pk1
left join LEARN.LINK lnk
    on lnk.link_source_pk1 = ca.pk1 
    and lnk.link_source_table = 'COURSE_ASSESSMENT'
left join LEARN.COURSE_CONTENTS cc
    on lnk.course_contents_pk1 = cc.pk1
 LEFT JOIN LEARN.ATTEMPT a 
    ON a.qti_result_data_pk1 = qrd.pk1
LEFT JOIN LEARN.GRADEBOOK_GRADE gg 
    ON gg.pk1 = a.gradebook_grade_pk1
LEFT JOIN LEARN.GRADEBOOK_MAIN gm
    ON gm.pk1 = gg.gradebook_main_pk1
LEFT JOIN LEARN.COURSE_USERS cu 
    ON cu.pk1 = gg.course_users_pk1
LEFT JOIN LEARN.USERS u 
    ON u.pk1 = cu.users_pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;

WITH conversation_data AS (
    SELECT 
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(qad.data) IS NULL, qad.data, NULL)) AS VARIANT) AS qad_obj,
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT) AS qrd_obj,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'chatQuestionType'):"$"::STRING AS chat_question_type,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botName'):"$"::STRING AS bot_name,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botRole'):"$"::STRING AS bot_role,
        r.index AS response_order,
        IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL) AS raw_message,
        r.value:"@response_status"::STRING AS response_status,
        r.value:"@response_time"::STRING AS response_time,
        SPLIT_PART(raw_message, ',', 1) AS message_source,
        SPLIT_PART(raw_message, ',', 3) AS timestamp_ms,
        CASE 
            WHEN timestamp_ms IS NULL THEN NULL
            ELSE TO_TIMESTAMP(timestamp_ms / 1000)
        END AS msg_timestamp,
        qad.description,
        REGEXP_REPLACE(raw_message, '^[^,]+,[^,]+,[^,]+,[^,]+,', '') AS conversation_message,
        qrd_assess.pk1 AS qrd_assess_pk1,
        qad.crsmain_pk1 AS qad_crsmain_pk1,
        qad.pk1 AS qad_pk1,
        qrd.pk1 AS qrd_pk1
    FROM LEARN.QTI_ASI_DATA qad
        LEFT JOIN LEARN.QTI_RESULT_DATA qrd
            ON qrd.qti_asi_data_pk1 = qad.pk1
        LEFT JOIN LEARN.QTI_RESULT_DATA qrd_section 
            ON qrd.parent_pk1 = qrd_section.pk1
        LEFT JOIN LEARN.QTI_RESULT_DATA qrd_assess 
            ON qrd_section.parent_pk1 = qrd_assess.pk1,
    LATERAL FLATTEN(
        input => qrd_obj:"$"
    ) f
    ,LATERAL FLATTEN(
        input => f.value:"$"
    ) r
        WHERE 
            STARTSWITH(r.value, '<response_value') AND
            qad.bbmd_assessment_subtype = 'AiConversation'
)
SELECT    
    cm.course_id,
    cd.msg_timestamp,
    cd.message_source,
    cd.conversation_message,
    cd.bot_name,
    u.firstname AS user_first_name,
    u.lastname AS user_last_name,
    u.user_id AS user_id,
    u.student_id AS student_id,
    cd.bot_role,
    cd.chat_question_type,
    cd.description,
    cm.course_name,
    a.score,
    a.grade,
    CASE 
        WHEN a.status = 1 THEN 'NOT_ATTEMPTED'
        WHEN a.status = 3 THEN 'IN_PROGRESS'
        WHEN a.status = 4 THEN 'SUSPENDED'
        WHEN a.status = 6 THEN 'NEEDS_GRADING'
        WHEN a.status = 7 THEN 'COMPLETED'
        WHEN a.status = 8 THEN 'IN_MORE_PROGRESS'
        WHEN a.status = 9 THEN 'NEEDS_MORE_GRADING'
        ELSE NULL
    END AS attempt_status,
    gm.title as conversation_title,
    a.student_comments,
    a.instructor_comments,
    u.pk1 AS user_pk1,
    cm.pk1 AS course_main_pk1,
    a.pk1 AS attempt_pk1,
    gg.pk1 AS gradebook_grade_pk1,
    cu.pk1 AS course_users_pk1,
    u.pk1 AS user_pk1
FROM conversation_data cd
    LEFT JOIN LEARN.COURSE_MAIN cm
        ON cm.pk1 = cd.qad_crsmain_pk1
    LEFT JOIN LEARN.ATTEMPT a 
        ON a.qti_result_data_pk1 = cd.qrd_assess_pk1
    LEFT JOIN LEARN.GRADEBOOK_GRADE gg 
        ON gg.pk1 = a.gradebook_grade_pk1
    LEFT JOIN LEARN.GRADEBOOK_MAIN gm
        ON gm.pk1 = gg.gradebook_main_pk1
    LEFT JOIN LEARN.COURSE_USERS cu 
        ON cu.pk1 = gg.course_users_pk1
    LEFT JOIN LEARN.USERS u 
        ON u.pk1 = cu.users_pk1
WHERE (CONTAINS(cd.raw_message, 'Bot,') OR CONTAINS(cd.raw_message, 'Student,'))
ORDER BY cd.qad_pk1, cd.qrd_pk1, cd.response_order


SELECT
    qad_item.pk1,
    u.student_id,
    REGEXP_COUNT(qrd_item.data, '>Student,') AS student_message_count
FROM LEARN.QTI_RESULT_DATA qrd_item
JOIN LEARN.QTI_ASI_DATA qad_item 
    ON qrd_item.qti_asi_data_pk1 = qad_item.pk1
JOIN LEARN.QTI_RESULT_DATA qrd_section 
    ON qrd_item.parent_pk1 = qrd_section.pk1
JOIN LEARN.QTI_RESULT_DATA qrd_assess 
    ON qrd_section.parent_pk1 = qrd_assess.pk1
LEFT JOIN LEARN.ATTEMPT a 
    ON a.qti_result_data_pk1 = qrd_assess.pk1
LEFT JOIN LEARN.GRADEBOOK_GRADE gg 
    ON gg.pk1 = a.gradebook_grade_pk1
LEFT JOIN LEARN.COURSE_USERS cu 
    ON cu.pk1 = gg.course_users_pk1
LEFT JOIN LEARN.USERS u 
    ON u.pk1 = cu.users_pk1
WHERE qad_item.data ILIKE '%<bbmd_questiontype>AI Chat</bbmd_questiontype>%' 

AND qad_item.crsmain_pk1 = 4412 AND qrd_item.pk1 is not null 
ORDER BY qrd_item.pk1;


select * from 
    LEARN.QTI_ASI_DATA qad_parent
left join LEARN.QTI_ASI_DATA qad_children
    on qad_children.parent_pk1 = qad.pk1
where
    qad_parent.bbmd_assessment_subtype = 'AiConversation'
;

select * from 
    LEARN.QTI_ASI_DATA qad
left join LEARN.COURSE_ASSESSMENT ca
    on ca.qti_asi_data_pk1 = qad.pk1
left join LEARN.LINK lnk
    on lnk.link_source_pk1 = ca.pk1 
    and lnk.link_source_table = 'COURSE_ASSESSMENT'
left join LEARN.COURSE_CONTENTS cc
    on lnk.course_contents_pk1 = cc.pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
    ;

SELECT
    'Course Main ->',
    cm.*,
    'QTI_RESULT_DATA ->',
    qrd.*,
    'COURSE_ASSESSMENT ->',
    ca.*,
    'LINK ->',
    lnk.*
FROM LEARN.QTI_ASI_DATA qad
    left join LEARN.COURSE_MAIN cm
        on cm.pk1 = qad.crsmain_pk1
    left join LEARN.QTI_RESULT_DATA qrd
        on qrd.qti_asi_data_pk1 = qad.pk1
        
    left join LEARN.COURSE_ASSESSMENT ca
        on ca.qti_asi_data_pk1 = qad.pk1
    left join LEARN.LINK lnk
        on lnk.link_source_pk1 = qad.pk1 
        and lnk.link_source_table = 'COURSE_ASSESSMENT'
WHERE qad.bbmd_questiontype = 21 ;

select 
    'QTI_ASI_DATA ->',
    qad.*, 
    'QTI_RESULT_DATA',
    qrd.*,
    'ACTIVITY ->',
    a.*,
    'GRADEBOOK_GRADE ->',
    gg.*,
    'COURSE_USERS ->',
    cu.*,
    'USERS ->',
    u.*,
    'qad_children',
    qad_children.*
from 
    LEARN.QTI_ASI_DATA qad
left join LEARN.QTI_RESULT_DATA qrd
    on qrd.qti_asi_data_pk1 = qad.pk1
left join LEARN.ATTEMPT a
    on a.qti_result_data_pk1 = qrd.pk1
left join LEARN.GRADEBOOK_GRADE gg
    on gg.pk1 = a.gradebook_grade_pk1
left join LEARN.COURSE_USERS cu
    on cu.pk1 = gg.course_users_pk1
left join LEARN.USERS u
    on u.pk1 = cu.users_pk1
left join LEARN.QTI_ASI_DATA qad_children
    on qad_children.parent_pk1 = qad.pk1
WHERE qad.bbmd_assessment_subtype = 'AiConversation'
;

select 
    'QTI_ASI_DATA ->',
    qad.*, 
    'QTI_RESULT_DATA',
    qrd.*,
    'ACTIVITY ->',
    a.*,
    'GRADEBOOK_GRADE ->',
    gg.*,
    'COURSE_USERS ->',
    cu.*,
    'USERS ->',
    u.*
from 
    LEARN.QTI_ASI_DATA qad
left join LEARN.QTI_RESULT_DATA qrd
    on qrd.qti_asi_data_pk1 = qad.pk1
left join LEARN.ATTEMPT a
    on a.qti_result_data_pk1 = qrd.pk1
left join LEARN.GRADEBOOK_GRADE gg
    on gg.pk1 = a.gradebook_grade_pk1
left join LEARN.COURSE_USERS cu
    on cu.pk1 = gg.course_users_pk1
left join LEARN.USERS u
    on u.pk1 = cu.users_pk1
WHERE qad.bbmd_assessment_subtype = 'AiConversation'
;

SELECT
    qad.pk1,
    qrd.pk1 AS result_id,
    qrd.qti_asi_data_pk1 AS question_id,
    REGEXP_COUNT(qrd.data, '>Student,') AS student_message_count,
    REGEXP_COUNT(qrd.data, '>Bot,') AS bot_message_count
FROM LEARN.qti_result_data qrd
JOIN LEARN.QTI_ASI_DATA qad ON qrd.qti_asi_data_pk1 = qad.pk1
WHERE qad.data ILIKE '%<bbmd_questiontype>AI Chat</bbmd_questiontype>%'
ORDER BY qrd.pk1
;

SELECT
    qad.pk1,
    REGEXP_SUBSTR(qad.data, '<chatQuestionType>(.*?)<\/chatQuestionType>', 1, 1, 'e', 1) AS chat_question_type,
    qad.row_inserted_time
FROM LEARN.QTI_ASI_DATA qad
WHERE qad.data ILIKE '%AI Chat%'
ORDER BY qad.pk1;
 

select top 1000 * from LEARN.COURSE_ASSESSMENT ca
    left join LEARN.QTI_ASI_DATA qrd
        on ca.qti_asi_data_pk1 = qrd.pk1











        select 
cc.title,
'qad->',
qad.*,
'section_qad ->',
section_qad.*,
'assess_qad ->',
assess_qad.*,
'course_main->',
cm.*,
'qrd->',
qrd.*,
'qasses_qrd->',
qasses_qrd.*,
'ca->',
ca.*,
'lnk->',
lnk.*,
'COURSE_CONTENTS->',
cc.*,
'ATTEMPT->',
a.*,
'GRADEBOOK_GRADE->',
gg.*,
'GRADEBOOK_MAIN->',
gm.*,
'COURSE_USERS->',
cu.*,
'USERS->',
u.*
FROM LEARN.QTI_ASI_DATA qad
    LEFT JOIN LEARN.QTI_ASI_DATA section_qad
        ON section_qad.parent_pk1 = qad.pk1
    LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
        ON assess_qad.parent_pk1 = section_qad.pk1
    LEFT JOIN LEARN.QTI_RESULT_DATA qasses_qrd
            ON qasses_qrd.qti_asi_data_pk1 = assess_qad.pk1
    LEFT JOIN LEARN.QTI_RESULT_DATA qrd
    ON qrd.qti_asi_data_pk1 = qad.pk1
LEFT JOIN LEARN.COURSE_MAIN cm
    ON cm.pk1 = qad.crsmain_pk1
left join LEARN.COURSE_ASSESSMENT ca
    on ca.qti_asi_data_pk1 = qad.pk1
left join LEARN.LINK lnk
    on lnk.link_source_pk1 = ca.pk1 
    and lnk.link_source_table = 'COURSE_ASSESSMENT'
left join LEARN.COURSE_CONTENTS cc
    on lnk.course_contents_pk1 = cc.pk1
 LEFT JOIN LEARN.ATTEMPT a 
    ON a.qti_result_data_pk1 = qrd.pk1
LEFT JOIN LEARN.GRADEBOOK_GRADE gg 
    ON gg.pk1 = a.gradebook_grade_pk1
LEFT JOIN LEARN.GRADEBOOK_MAIN gm
    ON gm.pk1 = gg.gradebook_main_pk1
LEFT JOIN LEARN.COURSE_USERS cu 
    ON cu.pk1 = gg.course_users_pk1
LEFT JOIN LEARN.USERS u 
    ON u.pk1 = cu.users_pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;
   
   
   SELECT 

        TRY_CAST(PARSE_XML(IFF(CHECK_XML(assess_qad.data) IS NULL, assess_qad.data, NULL)) AS VARIANT) AS qad_obj,
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(section_qad.data) IS NULL, section_qad.data, NULL)) AS VARIANT) AS section_qad_obj,
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT) AS qrd_obj,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'chatQuestionType'):"$"::STRING AS chat_question_type,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botName'):"$"::STRING AS bot_name,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botRole'):"$"::STRING AS bot_role,
        XMLGET(qad_obj, 'presentation'):"$"::VARIANT:"$"::STRING AS TEST,
        XMLGET(qad_obj, 'presentation'):"$"::VARIANT[0]['$']['$']['$']['$']['$']::STRING AS question_text,
        XMLGET(qad_obj, 'presentation'):"$"::VARIANT[0]['$']['$']['$']['$']::STRING AS question_text1,
        XMLGET(qad_obj, 'presentation'):"$"::VARIANT[0]['$']['$']['$']::STRING AS question_text2,
        XMLGET(qad_obj, 'presentation'):"$"::VARIANT[0]['$']['$']::STRING AS question_text3,
        XMLGET(qad_obj, 'presentation'):"$"::VARIANT[0]['$']::STRING AS question_text4,
        GET_PATH(XMLGET(qad_obj, 'presentation'):"$"::VARIANT, '[0].$.$.$.$.$')::STRING AS question_text5,
        XMLGET(
          XMLGET(
            XMLGET(
              XMLGET(
                XMLGET(
                  XMLGET(
                    XMLGET(qad_obj, 'presentation'),
                    'flow'
                  ),
                  'flow', 0
                ),
                'flow'
              ),
              'material'
            ),
            'mat_extension'
          ),
          'mat_formattedtext'
        ):"$"::STRING AS question_text23423,
                qad.*,
        section_qad.*,
        assess_qad.*,
        qrd.*,
        r.index AS response_order,
        IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL) AS raw_message,
        r.value:"@response_status"::STRING AS response_status,
        r.value:"@response_time"::STRING AS response_time,
        SPLIT_PART(raw_message, ',', 1) AS message_source,
        SPLIT_PART(raw_message, ',', 3) AS timestamp_ms,
        -- CASE 
        --     WHEN timestamp_ms IS NULL THEN NULL
        --     ELSE TO_TIMESTAMP(timestamp_ms / 1000)
        -- END AS msg_timestamp,
        qad.description,
        REGEXP_REPLACE(raw_message, '^[^,]+,[^,]+,[^,]+,[^,]+,', '') AS conversation_message,
        qad.pk1 AS qad_pk1,
        qrd.pk1 AS qrd_pk1,
        qad.bbmd_questiontype,
        qad.ai_state as is_assessment_ai_generated,
        section_qad.bbmd_sectiontype as section_type,
        section_qad.ai_state as is_section_ai_generated,
        section_qad.title as section_title,
        section_qad.description as section_desciption,
        section_qad.position as section_postition,
        assess_qad.bbmd_questiontype as question_type, --translate!
        assess_qad.title as assess_title,
        assess_qad.description as assess_description,
        assess_qad.ai_state as assess_is_ai_generated,
        assess_qad.position as assess_position,
        'f--------',
        f.*,
        'r--------',
        r.*
    FROM LEARN.QTI_ASI_DATA qad
        LEFT JOIN LEARN.QTI_ASI_DATA section_qad
            ON section_qad.parent_pk1 = qad.pk1
        LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
            ON assess_qad.parent_pk1 = section_qad.pk1
        LEFT JOIN LEARN.QTI_RESULT_DATA qrd
                ON qrd.qti_asi_data_pk1 = assess_qad.pk1,
    LATERAL FLATTEN(
        input => qrd_obj:"$"
    ) f
    ,LATERAL FLATTEN(
        input => f.value:"$"
    ) r
        WHERE 
            --STARTSWITH(r.value, '<response_value') AND
            qad.bbmd_assessment_subtype = 'AiConversation'

--in qad:
--bbmd_questiontype
--ai_state, is_ai_generated
--in qad section:
--bbmd_sectiontype
--ai_state, is_ai_generated
--title,  section_title
--description, section_description
--position, section_postition
--in qad assess:
--title,  question_title
--position, question_postition
--description, question_description
--bbmd_questiontype 16=Short Answer, 21 - AI Conversation
--in qad assess xml data:
--<material><mat_extension><mat_formattedtext type={}>{description}</mat_formattedtext></mat_extension></material>
--qrd assess
--bbmd_grade, grade_earned
--same xml stuff as 
select 

'qad->',
qad.*,
'section_qad ->',
section_qad.*,
'assess_qad ->',
assess_qad.*,
'qrd_assess->',
qrd_assess.* ---this .data has the conversation
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.QTI_ASI_DATA section_qad
    ON section_qad.parent_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
    ON assess_qad.parent_pk1 = section_qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_assess
        ON qrd_assess.qti_asi_data_pk1 = assess_qad.pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;


select 
'qad->',
qad.*,
'section_qad ->',
section_qad.*,
'assess_qad ->',
assess_qad.*,
'qrd->',
qrd.*,
'qrd_section->',
qrd_section.*,
'qrd_assess->',
qrd_assess.* ---this .data has the conversation
from 
    LEARN.QTI_ASI_DATA qad
LEFT JOIN LEARN.QTI_ASI_DATA section_qad
    ON section_qad.parent_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
    ON assess_qad.parent_pk1 = section_qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd
        ON qrd.qti_asi_data_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_section
        ON qrd_section.qti_asi_data_pk1 = section_qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd_assess
        ON qrd_assess.qti_asi_data_pk1 = assess_qad.pk1
where
    qad.bbmd_assessment_subtype = 'AiConversation'
;

-- get Assessment questions
WITH assessment_questions AS (
    SELECT
        qad.pk1 as main_pk1,
        section_qad.pk1 as section_pk1,
        assess_qad.pk1 as assess_pk1,
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(assess_qad.data) IS NULL, assess_qad.data, NULL)) AS VARIANT) AS assess_qad_obj,
        f.value AS node_value,
        f.path AS node_path
    FROM LEARN.QTI_ASI_DATA qad
        LEFT JOIN LEARN.QTI_ASI_DATA section_qad
            ON section_qad.parent_pk1 = qad.pk1
        LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
            ON assess_qad.parent_pk1 = section_qad.pk1,
    LATERAL FLATTEN(
        input => XMLGET(assess_qad_obj, 'presentation'):"$"::VARIANT,
        recursive => TRUE
    ) f
    WHERE 
    f.value:"@class"::STRING = 'QUESTION_BLOCK' and 
    qad.bbmd_assessment_subtype = 'AiConversation'
)
SELECT 
    assessment_questions.main_pk1,
    assessment_questions.section_pk1,
    assessment_questions.assess_pk1,
    assessment_questions.node_value:"$":"$":"$":"$":"$" as ai_assessment_question,
FROM assessment_questions 
;

  SELECT 

        TRY_CAST(PARSE_XML(IFF(CHECK_XML(assess_qad.data) IS NULL, assess_qad.data, NULL)) AS VARIANT) AS qad_obj,
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(section_qad.data) IS NULL, section_qad.data, NULL)) AS VARIANT) AS section_qad_obj,
        TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT) AS qrd_obj,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'chatQuestionType'):"$"::STRING AS chat_question_type,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botName'):"$"::STRING AS bot_name,
        XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botRole'):"$"::STRING AS bot_role,
        XMLGET(qad_obj, 'presentation') AS TEST,
        r.index AS response_order,
        IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL) AS raw_message,
        r.value:"@response_status"::STRING AS response_status,
        r.value:"@response_time"::STRING AS response_time,
        SPLIT_PART(raw_message, ',', 1) AS message_source,
        SPLIT_PART(raw_message, ',', 3) AS timestamp_ms,
        -- CASE 
        --     WHEN timestamp_ms IS NULL THEN NULL
        --     ELSE TO_TIMESTAMP(timestamp_ms / 1000)
        -- END AS msg_timestamp,
        qad.description,
        REGEXP_REPLACE(raw_message, '^[^,]+,[^,]+,[^,]+,[^,]+,', '') AS conversation_message,
        qad.pk1 AS qad_pk1,
        qrd.pk1 AS qrd_pk1,
        qad.bbmd_questiontype,
        qad.ai_state as is_assessment_ai_generated,
        section_qad.bbmd_sectiontype as section_type,
        section_qad.ai_state as is_section_ai_generated,
        section_qad.title as section_title,
        section_qad.description as section_desciption,
        section_qad.position as section_postition,
        assess_qad.bbmd_questiontype as question_type, --translate!
        assess_qad.title as assess_title,
        assess_qad.description as assess_description,
        assess_qad.ai_state as assess_is_ai_generated,
        assess_qad.position as assess_position,
        'f--------',
        f.*,
        'r--------',
        r.*
    FROM LEARN.QTI_ASI_DATA qad
        LEFT JOIN LEARN.QTI_ASI_DATA section_qad
            ON section_qad.parent_pk1 = qad.pk1
        LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
            ON assess_qad.parent_pk1 = section_qad.pk1
        LEFT JOIN LEARN.QTI_RESULT_DATA qrd
                ON qrd.qti_asi_data_pk1 = assess_qad.pk1,
    LATERAL FLATTEN(
        input => qrd_obj:"$"
    ) f
    ,LATERAL FLATTEN(
        input => f.value:"$"
    ) r
        WHERE 
            --STARTSWITH(r.value, '<response_value') AND
            qad.bbmd_assessment_subtype = 'AiConversation'