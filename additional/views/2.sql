CREATE OR REPLACE VIEW entity_popularity_by_mentions AS
SELECT
    'Creature' AS entity_type,
    c.creature_id AS entity_id,
    c.name AS entity_name,
    c.class AS entity_class_or_category,
    COUNT(cb.book_id) AS total_mentions
FROM
    creatures c
LEFT JOIN
    creature_book cb ON c.creature_id = cb.creature_id
GROUP BY
    c.creature_id, c.name, c.class

UNION ALL

SELECT
    'Artefact' AS entity_type,
    ar.artefact_id AS entity_id,
    ar.name AS entity_name,
    ar.class AS entity_class_or_category,
    COUNT(arb.book_id) AS total_mentions
FROM
    artefacts ar
LEFT JOIN
    artefact_book arb ON ar.artefact_id = arb.artefact_id
GROUP BY
    ar.artefact_id, ar.name, ar.class

UNION ALL

SELECT
    'Location' AS entity_type,
    l.location_id AS entity_id,
    l.name AS entity_name,
    l.class AS entity_class_or_category,
    COUNT(lb.book_id) AS total_mentions
FROM
    locations l
LEFT JOIN
    location_book lb ON l.location_id = lb.location_id
GROUP BY
    l.location_id, l.name, l.class

ORDER BY
    total_mentions DESC, entity_type, entity_name;
