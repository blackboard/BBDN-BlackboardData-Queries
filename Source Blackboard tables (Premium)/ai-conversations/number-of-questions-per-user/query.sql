SELECT
    qad_item.pk1,
    qad_item.crsmain_pk1,
    u.student_id,
    u.firstname,
    u.lastname,
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
WHERE qad_item.bbmd_questiontype = 21
    AND qad_item.crsmain_pk1 = {coursepk}
    AND qrd_item.pk1 is not null 
ORDER BY qad_item.crsmain_pk1, u.student_id
;