-- Получение всех книг по определенному классу артефакта
CREATE OR REPLACE FUNCTION fn_get_books_by_artefact_class(in_artefact_class VARCHAR)
RETURNS TABLE (
    book_title VARCHAR(100),
    publish_year INTEGER,
    artefact_name VARCHAR(100)
) AS $$
    SELECT b.title, b.publish_year, a.name
    FROM books b
    JOIN artefact_book ab ON b.book_id = ab.book_id
    JOIN artefacts a ON ab.artefact_id = a.artefact_id
    WHERE a.class = in_artefact_class;
$$ LANGUAGE SQL;
