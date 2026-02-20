SELECT
    qad.pk1,
    REGEXP_SUBSTR(qad.data, '<chatQuestionType>(.*?)<\/chatQuestionType>', 1, 1, 'e', 1) AS chat_question_type,
    qad.row_inserted_time
FROM LEARN.QTI_ASI_DATA qad
WHERE qad.data ILIKE '%AI Chat%'
ORDER BY qad.pk1;