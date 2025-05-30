-- Классифицировать книги по "эпохам" творчества и пронумеровать в каждой эпохе
SELECT
    title,
    publish_year,
    CASE
        WHEN publish_year < 1925 THEN 'Ранний период'
        WHEN publish_year BETWEEN 1925 AND 1930 THEN 'Расцвет'
        WHEN publish_year > 1930 THEN 'Поздний период'
    END AS creative_period,
    ROW_NUMBER() OVER (PARTITION BY
        CASE
            WHEN publish_year < 1925 THEN 'Ранний период'
            WHEN publish_year BETWEEN 1925 AND 1930 THEN 'Расцвет'
            WHEN publish_year > 1930 THEN 'Поздний период'
        END
        ORDER BY publish_year
    ) AS period_rank
FROM books
WHERE book_id IN (
    SELECT book_id FROM author_book WHERE author_id = 1
)
ORDER BY publish_year, period_rank;

