SELECT 
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(assess_qad.data) IS NULL, assess_qad.data, NULL)) AS VARIANT) AS qad_obj,
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(section_qad.data) IS NULL, section_qad.data, NULL)) AS VARIANT) AS section_qad_obj,
    TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT) AS qrd_obj,
    r.index AS response_order,
    IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL) AS raw_message,
    r.value:"$":"$" as test,
    r.value:"@response_status"::STRING AS response_status,
    r.value:"@response_time"::STRING AS response_time,
    qad.pk1 AS qad_pk1,
    qrd.pk1 AS qrd_pk1,
    qad.bbmd_questiontype,
    qad.ai_state as is_assessment_ai_generated,
    section_qad.bbmd_sectiontype as section_type,
    section_qad.ai_state as is_section_ai_generated,
    section_qad.position as section_postition,
    assess_qad.bbmd_questiontype as question_type,
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
        CONTAINS(raw_message, '<formatted_text')
    ORDER BY 
        qad_pk1, qrd_pk1, response_order
;