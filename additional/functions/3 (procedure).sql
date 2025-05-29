-- Обновление даты смерти автора
CREATE OR REPLACE PROCEDURE sp_update_author_death_date(
    in_author_id INTEGER,
    in_death_date DATE
)
AS $$
BEGIN
    UPDATE authors
    SET death_date = in_death_date
    WHERE author_id = in_author_id;

    IF FOUND THEN
        RAISE NOTICE 'Death date for author_id % updated to %', in_author_id, in_death_date;
    ELSE
        RAISE WARNING 'Author with ID % not found.', in_author_id;
    END IF;
END;
$$ LANGUAGE plpgsql;