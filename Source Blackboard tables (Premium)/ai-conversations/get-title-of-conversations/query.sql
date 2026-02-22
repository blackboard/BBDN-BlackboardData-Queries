SELECT
    qad.pk1,
    qad.title,
    qad.description as description,
    qad.row_inserted_time,
FROM LEARN.QTI_ASI_DATA qad
WHERE qad.bbmd_questiontype = 21
ORDER BY qad.pk1;