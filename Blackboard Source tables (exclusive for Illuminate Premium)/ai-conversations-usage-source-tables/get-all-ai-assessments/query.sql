SELECT 
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(assess_qad.data) IS NULL, assess_qad.data, NULL)) AS VARIANT) AS qad_obj,
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT) AS qrd_obj,
    IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL) AS raw_message,
    XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'chatQuestionType'):"$"::STRING AS chat_question_type,
    XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botName'):"$"::STRING AS bot_name,
    XMLGET(XMLGET(qad_obj, 'itemproc_extension'):"$"::VARIANT, 'botRole'):"$"::STRING AS bot_role,
    REGEXP_REPLACE(raw_message, '^[^,]+,[^,]+,[^,]+,[^,]+,', '') AS conversation_message,
    SPLIT_PART(raw_message, ',', 1) AS message_source,
    r.index AS response_order,
    SPLIT_PART(raw_message, ',', 3) AS timestamp_ms,
    qad.description,
    qad.pk1 AS qad_pk1,
    qrd.pk1 AS qrd_pk1,
    qad.bbmd_questiontype,
    qad.ai_state AS is_assessment_ai_generated,
    section_qad.bbmd_sectiontype AS section_type,
    section_qad.title AS section_title,
    section_qad.description AS section_description,
    section_qad.position AS section_position,
    assess_qad.bbmd_questiontype AS question_type,
    assess_qad.title AS assess_title,
    assess_qad.description AS assess_description,
    assess_qad.position AS assess_position
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