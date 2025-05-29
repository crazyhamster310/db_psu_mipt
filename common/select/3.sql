-- Вывести авторов и последнюю из опубликованных книг, в создании которых они участвовали
SELECT a.name, ab.role, b.title, b.publish_year
FROM authors a
JOIN author_book ab ON a.author_id = ab.author_id
JOIN books b ON ab.book_id = b.book_id
WHERE b.publish_year = (
    SELECT MAX(b2.publish_year)
    FROM books b2
    JOIN author_book ab2 ON b2.book_id = ab2.book_id
    WHERE ab2.author_id = a.author_id
)
ORDER BY a.name;

