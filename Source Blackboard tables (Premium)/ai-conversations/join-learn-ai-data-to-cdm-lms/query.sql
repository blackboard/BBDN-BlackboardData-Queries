SELECT
    qad.pk1,
    qad.crsmain_pk1,
    REGEXP_SUBSTR(qad.data, '<chatQuestionType>(.*?)<\/chatQuestionType>', 1, 1, 'e', 1) AS chat_question_type,
    qad.title,
    qad.description,
    qad.row_inserted_time,
    qad.ai_state as is_ai_generated,
    c.*
FROM LEARN.QTI_ASI_DATA qad
    LEFT JOIN CDM_LMS.COURSE c
        ON c.source_id = qad.crsmain_pk1
WHERE qad.bbmd_questiontype = 21
ORDER BY qad.pk1;