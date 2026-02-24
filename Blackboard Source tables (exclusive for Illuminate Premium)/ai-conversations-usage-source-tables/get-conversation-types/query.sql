SELECT
    qad.pk1,
    qad.crsmain_pk1,
    REGEXP_SUBSTR(qad.data, '<chatQuestionType>(.*?)<\/chatQuestionType>', 1, 1, 'e', 1) AS chat_question_type,
    qad.title,
    qad.description,
    qad.row_inserted_time,
    qad.ai_state AS is_ai_generated,
    qad.data AS question_data,
    qrd.data AS conversation_data,
    c.* -- All CDM_LMS.COURSE data
FROM LEARN.QTI_ASI_DATA qad
    LEFT JOIN LEARN.QTI_RESULT_DATA qrd
        ON qrd.qti_asi_data_pk1 = qad.pk1
    LEFT JOIN CDM_LMS.COURSE c
        ON c.source_id = qad.crsmain_pk1
WHERE qad.bbmd_questiontype = 21
ORDER BY qad.pk1
;