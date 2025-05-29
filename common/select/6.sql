-- Найти классы существ, у которых более 3 представителей
SELECT class, COUNT(*) as creature_count
FROM creatures
GROUP BY class
HAVING COUNT(*) > 3
ORDER BY creature_count DESC;

