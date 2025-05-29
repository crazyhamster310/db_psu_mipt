-- Вывести все книги, изданных после смерти Лавкрафта
SELECT DISTINCT ON (b.title) b.title, b.publish_year
FROM books b
WHERE b.publish_year > (
	SELECT EXTRACT(YEAR FROM death_date)
	FROM authors
	WHERE name = 'H.P. Lovecraft'
);
