-- Вывести все книги, изданных после смерти Лавкрафта
SELECT DISTINCT ON (b.title) b.title, b.publish_year
FROM books b
WHERE b.publish_year > (
	SELECT EXTRACT(YEAR FROM death_date)
	FROM authors
	WHERE name = 'H.P. Lovecraft'
);

-- Вывести топ-5 самых упоминаемых в книгах существ (порядок отбора: кол-во упоминаний -> год первого упоминания; на последнем месте может быть несколько существ)
SELECT c.name AS creature, COUNT(cb.book_id) AS mentions, MIN(b.publish_year) AS first_mention_year
FROM creatures c
JOIN creature_book cb ON c.creature_id = cb.creature_id
JOIN books b ON cb.book_id = b.book_id
GROUP BY c.creature_id, c.name
ORDER BY mentions DESC, first_mention_year ASC
FETCH FIRST 5 ROWS WITH TIES;

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

-- Количество книг по классам локаций
SELECT l.class, COUNT(lb.book_id) AS book_count
FROM locations l
JOIN location_book lb ON l.location_id = lb.location_id
GROUP BY l.class
ORDER BY book_count DESC;

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

-- Найти классы существ, у которых более 3 представителей
SELECT class, COUNT(*) as creature_count
FROM creatures
GROUP BY class
HAVING COUNT(*) > 3
ORDER BY creature_count DESC;

-- Количество книг по годам с нарастающим итогом
SELECT publish_year, COUNT(*) as books_count,
       SUM(COUNT(*)) OVER (ORDER BY publish_year) as running_total
FROM books
GROUP BY publish_year
ORDER BY publish_year;

-- Книги, в которых есть существа класса Great Old One
SELECT DISTINCT b.title
FROM books b
JOIN creature_book cb ON b.book_id = cb.book_id
WHERE cb.creature_id = ANY (
    SELECT creature_id 
    FROM creatures 
    WHERE class = 'Great Old One'
);

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