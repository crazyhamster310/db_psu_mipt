ALTER TABLE authors ADD COLUMN IF NOT EXISTS book_count INTEGER DEFAULT 0;

-- Обновление book_count в authors при добавлении/удалении записей в author_book
CREATE OR REPLACE FUNCTION trg_update_author_book_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE authors
        SET book_count = book_count + 1
        WHERE author_id = NEW.author_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE authors
        SET book_count = book_count - 1
        WHERE author_id = OLD.author_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_authors_book_count
AFTER INSERT OR DELETE ON author_book
FOR EACH ROW
EXECUTE FUNCTION trg_update_author_book_count();
