WITH assessment_questions AS (
    SELECT
        qad.pk1 AS main_pk1,
        section_qad.pk1 AS section_pk1,
        assess_qad.pk1 AS assess_pk1,
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
    f.value:"@class"::STRING = 'QUESTION_BLOCK' AND 
    qad.bbmd_assessment_subtype = 'AiConversation'
)
SELECT
    assessment_questions.main_pk1,
    assessment_questions.section_pk1,
    assessment_questions.assess_pk1,
    assessment_questions.node_value:"$":"$":"$":"$":"$" as ai_assessment_question,
FROM assessment_questions
;