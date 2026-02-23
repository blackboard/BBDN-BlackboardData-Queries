SELECT 
    r.index AS response_order,
    r.value:"$":"$" AS response_message,
    qad.pk1 AS qad_pk1,
    qrd.pk1 AS qrd_pk1
FROM LEARN.QTI_ASI_DATA qad
    LEFT JOIN LEARN.QTI_ASI_DATA section_qad
        ON section_qad.parent_pk1 = qad.pk1
    LEFT JOIN LEARN.QTI_ASI_DATA assess_qad
        ON assess_qad.parent_pk1 = section_qad.pk1
    LEFT JOIN LEARN.QTI_RESULT_DATA qrd
            ON qrd.qti_asi_data_pk1 = assess_qad.pk1,
LATERAL FLATTEN(
    input => TRY_CAST(PARSE_XML(IFF(CHECK_XML(qrd.data) IS NULL, qrd.data, NULL)) AS VARIANT):"$"
) f
,LATERAL FLATTEN(
    input => f.value:"$"
) r
WHERE
    STARTSWITH(r.value, '<response_value') AND
    qad.bbmd_assessment_subtype = 'AiConversation' AND
    CONTAINS(IFF(CONTAINS(r.value, '<response_value'), r.value:"$", NULL), '<formatted_text')
ORDER BY 
    qad_pk1, qrd_pk1, response_order
;
