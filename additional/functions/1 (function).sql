-- Подсчет книг, написанных определенным автором
CREATE OR REPLACE FUNCTION fn_get_author_book_count(in_author_id INTEGER)
RETURNS INTEGER AS $$
    SELECT COUNT(book_id)
    FROM author_book
    WHERE author_id = in_author_id;
$$ LANGUAGE SQL;
