-- Количество книг по классам локаций
SELECT l.class, COUNT(lb.book_id) AS book_count
FROM locations l
JOIN location_book lb ON l.location_id = lb.location_id
GROUP BY l.class
ORDER BY book_count DESC;

