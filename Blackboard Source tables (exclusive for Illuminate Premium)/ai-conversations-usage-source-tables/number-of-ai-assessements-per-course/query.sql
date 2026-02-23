SELECT
    c.course_name,
    c.pk1 AS course_id,
    COUNT(qad.pk1) AS ai_conversations_in_course_count
FROM learn.course_main c
LEFT JOIN learn.qti_asi_data qad
    ON c.pk1 = qad.crsmain_pk1
WHERE qad.bbmd_assessment_subtype = 'AiConversation'
GROUP BY c.pk1, c.course_name
ORDER BY c.course_name
;