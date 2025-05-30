-- Количество книг по годам с нарастающим итогом
SELECT publish_year, COUNT(*) as books_count,
       SUM(COUNT(*)) OVER (ORDER BY publish_year) as running_total
FROM books
GROUP BY publish_year
ORDER BY publish_year;

