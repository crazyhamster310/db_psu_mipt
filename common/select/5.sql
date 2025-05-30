-- Авторы, которые являются соавторами Лавкрафта
SELECT a.name
FROM authors a
WHERE EXISTS (
    SELECT 1
    FROM author_book ab
    JOIN author_book ab_lovecraft ON ab.book_id = ab_lovecraft.book_id
    WHERE ab.author_id = a.author_id
          AND ab_lovecraft.author_id = (
            SELECT a2.author_id
            FROM authors a2
            WHERE a2.name = 'H.P. Lovecraft'
          )
          AND ab.role = 'Co-Author'
);

