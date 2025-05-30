-- Найти локации, которые появляются в книгах с существами класса "Outer God"
SELECT l.name, l.class, COUNT(lb.book_id) AS book_count
FROM locations l
JOIN location_book lb ON l.location_id = lb.location_id
WHERE lb.book_id = ANY (
    SELECT DISTINCT cb.book_id
    FROM creature_book cb
    JOIN creatures c ON cb.creature_id = c.creature_id
    WHERE c.class = 'Outer God'
)
GROUP BY l.location_id, l.name, l.class
ORDER BY book_count DESC;

