-- Обновление времени изменения в authors
CREATE OR REPLACE FUNCTION trg_set_authors_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_authors_update_timestamp
BEFORE UPDATE ON authors
FOR EACH ROW
EXECUTE FUNCTION trg_set_authors_update_timestamp();
