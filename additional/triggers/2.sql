-- "Great Old One" и "Outer God" должны обитать в 'Space' или 'Everywhere'
CREATE OR REPLACE FUNCTION trg_check_creature_habitat()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.class IN ('Great Old One', 'Outer God') AND NEW.habitat NOT IN ('Space', 'Everywhere') THEN
        RAISE EXCEPTION 'Creatures of class "%" must have habitat "Space" or "Everywhere".', NEW.class;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_creature_habitat_check
BEFORE INSERT OR UPDATE ON creatures
FOR EACH ROW
EXECUTE FUNCTION trg_check_creature_habitat();
