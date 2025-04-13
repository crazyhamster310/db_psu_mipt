CREATE TABLE IF NOT EXISTS books(
	book_id			SERIAL			PRIMARY KEY,
	title			VARCHAR(100)	NOT NULL,
	publish_year	INTEGER			CHECK (publish_year >= 1890),
	description		TEXT,
	language		CHAR(2)			DEFAULT 'en' CHECK (language ~ '^[a-z]{2}$')
);

CREATE TABLE IF NOT EXISTS authors(
	author_id		SERIAL						PRIMARY KEY,
	name			VARCHAR(100)				NOT NULL,
	previous_name	VARCHAR(100),
	birth_date		DATE,
	death_date		DATE,
	gender			CHAR(1)						CHECK (gender IS NULL OR gender IN ('M', 'F')),
	update_time		TIMESTAMP WITH TIME ZONE	DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT CHK_lifedates CHECK (birth_date IS NULL OR death_date IS NULL OR birth_date < death_date)
);

CREATE TABLE IF NOT EXISTS locations(
	location_id	SERIAL			PRIMARY KEY,
	name		VARCHAR(100)	NOT NULL,
	description	TEXT,
	class		VARCHAR(25)		CHECK (class IN ('Planet', 'City', 'Ruins', 'Ocean', 'Mountain', 'Forest', 'Other')),
	country		VARCHAR(70)
);

CREATE TABLE IF NOT EXISTS creatures(
	creature_id	SERIAL			PRIMARY KEY,
	name		VARCHAR(100)	NOT NULL,
	description	TEXT,
	class		VARCHAR(25)		CHECK (class IN ('Great Old One', 'Outer God', 'Elder Thing', 'Deep One', 'Human', 'Other')),
	habitat		VARCHAR(25)		CHECK (habitat IN ('Space', 'Aquatic', 'Soil', 'Terrestrial', 'Host', 'Everywhere'))
);

CREATE TABLE IF NOT EXISTS artefacts(
	artefact_id	SERIAL			PRIMARY KEY,
	name		VARCHAR(100)	NOT NULL,
	description	TEXT,
	class		VARCHAR(25)		CHECK (class IN ('Tome', 'Relic', 'Ornament', 'Device', 'Other'))
);

CREATE TABLE IF NOT EXISTS creature_artefact(
	creature_artefact_id	SERIAL		PRIMARY KEY,
	creature_id				INTEGER		NOT NULL,
	artefact_id				INTEGER		NOT NULL,
	artefact_role			VARCHAR(25)	CHECK (artefact_role IN ('Created', 'Created by', 'Summoned', 'Owned by', 'Bound to', 'Worshipped by', 'Mentioned', 'Other')),

	FOREIGN KEY (creature_id) REFERENCES creatures(creature_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (artefact_id) REFERENCES artefacts(artefact_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS author_book(
	author_book_id	SERIAL		PRIMARY KEY,
	author_id		INTEGER		NOT NULL,
	book_id			INTEGER		NOT NULL,
	role			VARCHAR(25)	CHECK (role IN ('Author', 'Co-Author', 'Editor', 'Translator', 'Illustrator', 'Other')),

	FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS location_book(
	location_book_id	SERIAL		PRIMARY KEY,
	location_id			INTEGER		NOT NULL,
	book_id				INTEGER		NOT NULL,
	role				VARCHAR(25)	CHECK (role IN ('Primary', 'Secondary', 'Mentioned', 'Other')),

	FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS creature_book(
	creature_book_id	SERIAL		PRIMARY KEY,
	creature_id			INTEGER		NOT NULL,
	book_id				INTEGER		NOT NULL,
	role				VARCHAR(25)	CHECK (role IN ('Physical', 'Summoned', 'Mentioned', 'Dream', 'Observer', 'Other')),

	FOREIGN KEY (creature_id) REFERENCES creatures(creature_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS artefact_book(
	artefact_book_id	SERIAL		PRIMARY KEY,
	artefact_id			INTEGER		NOT NULL,
	book_id				INTEGER		NOT NULL,
	role				VARCHAR(25)	CHECK (role IN ('Full Description', 'Summoning Ritual', 'Created', 'Destroyed', 'Mentioned', 'Other')),

	FOREIGN KEY (artefact_id) REFERENCES artefacts(artefact_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
);