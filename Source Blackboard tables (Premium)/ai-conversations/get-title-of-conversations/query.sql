SELECT
    qad.pk1,
    IFF(
        CHECK_XML(qad.data) IS NULL,
        PARSE_XML(qad.data):"@title"::STRING,
        REGEXP_SUBSTR(qad.data, 'title="([^"]+)"', 1, 1, 'e', 1)
    ) AS title,
    qad.description as topic,
    qad.row_inserted_time,
FROM LEARN.QTI_ASI_DATA qad
WHERE qad.bbmd_questiontype = 16
ORDER BY qad.pk1;