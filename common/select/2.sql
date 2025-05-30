-- Вывести топ-5 самых упоминаемых в книгах существ (порядок отбора: кол-во упоминаний -> год первого упоминания; на последнем месте может быть несколько существ)
SELECT c.name AS creature, COUNT(cb.book_id) AS mentions, MIN(b.publish_year) AS first_mention_year
FROM creatures c
JOIN creature_book cb ON c.creature_id = cb.creature_id
JOIN books b ON cb.book_id = b.book_id
GROUP BY c.creature_id, c.name
ORDER BY mentions DESC, first_mention_year ASC
FETCH FIRST 5 ROWS WITH TIES;
