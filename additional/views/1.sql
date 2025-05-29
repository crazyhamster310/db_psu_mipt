CREATE OR REPLACE VIEW book_details_summary AS
SELECT
    b.title,
    b.publish_year,
    b.language,
    b.description,
    ARRAY_AGG(DISTINCT a.name) FILTER (WHERE ab.role IN ('Author', 'Co-Author')) AS authors,
    ARRAY_AGG(DISTINCT l.name) FILTER (WHERE lb.role = 'Primary') AS primary_locations,
    ARRAY_AGG(DISTINCT c.name) FILTER (WHERE cb.role IN ('Physical', 'Summoned')) AS key_creatures,
    ARRAY_AGG(DISTINCT ar.name) FILTER (WHERE arb.role IN ('Full Description', 'Summoning Ritual')) AS key_artefacts
FROM
    books b
LEFT JOIN
    author_book ab ON b.book_id = ab.book_id
LEFT JOIN
    authors a ON ab.author_id = a.author_id
LEFT JOIN
    location_book lb ON b.book_id = lb.book_id
LEFT JOIN
    locations l ON lb.location_id = l.location_id
LEFT JOIN
    creature_book cb ON b.book_id = cb.book_id
LEFT JOIN
    creatures c ON cb.creature_id = c.creature_id
LEFT JOIN
    artefact_book arb ON b.book_id = arb.book_id
LEFT JOIN
    artefacts ar ON arb.artefact_id = ar.artefact_id
GROUP BY
    b.title, b.publish_year, b.language, b.description
ORDER BY
    b.publish_year DESC;
