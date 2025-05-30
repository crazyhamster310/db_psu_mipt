-- author_book
CREATE INDEX IF NOT EXISTS idx_author_book_author_id ON author_book (author_id);
CREATE INDEX IF NOT EXISTS idx_author_book_book_id ON author_book (book_id);

-- creature_book
CREATE INDEX IF NOT EXISTS idx_creature_book_creature_id ON creature_book (creature_id);
CREATE INDEX IF NOT EXISTS idx_creature_book_book_id ON creature_book (book_id);

-- artefact_book
CREATE INDEX IF NOT EXISTS idx_artefact_book_artefact_id ON artefact_book (artefact_id);
CREATE INDEX IF NOT EXISTS idx_artefact_book_book_id ON artefact_book (book_id);

-- location_book
CREATE INDEX IF NOT EXISTS idx_location_book_location_id ON location_book (location_id);
CREATE INDEX IF NOT EXISTS idx_location_book_book_id ON location_book (book_id);
