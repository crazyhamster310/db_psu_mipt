-- Книги, в которых есть существа класса Great Old One
SELECT DISTINCT b.title
FROM books b
JOIN creature_book cb ON b.book_id = cb.book_id
WHERE cb.creature_id = ANY (
    SELECT creature_id
    FROM creatures
    WHERE class = 'Great Old One'
);

