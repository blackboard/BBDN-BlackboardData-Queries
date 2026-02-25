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
        qad.ai_state,
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
            qad.bbmd_questiontype = 21
)
SELECT    
    cm.course_id,
    cd.msg_timestamp,
    cd.chat_question_type,
    cd.message_source,
    cd.conversation_message,
    cd.bot_name,
    u.firstname AS user_first_name,
    u.lastname AS user_last_name,
    u.user_id AS user_id,
    u.student_id AS student_id,
    cd.bot_role,
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
    CASE
        WHEN gm.formative_ind = 0 THEN 'Assessment is not formative'
        WHEN gm.formative_ind = 1 THEN 'Assessment is formative and the formative label is not visible to students'
        WHEN gm.formative_ind = 2 THEN 'Assessment is formative and the formative label is visible to students'
        ELSE NULL
    END AS formative_status,
    gm.title AS conversation_title,
    a.student_comments,
    a.instructor_comments,
    cd.ai_state AS is_question_generated_by_ai,
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
;
