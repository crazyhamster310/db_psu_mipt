import random
from datetime import date, timedelta

import psycopg2
from faker import Faker

fake = Faker("en_US")
random.seed(42)

def generate_book_data(num_books: int) -> list:
    books_data = []
    for _ in range(num_books):
        title = (
            fake.catch_phrase()
            + " of "
            + fake.word().capitalize()
            + " "
            + fake.last_name()
        )
        publish_year = random.randint(1900, 2020)
        description = fake.text(max_nb_chars=500)
        language = random.choice(["en", "ru", "fr", "de"])
        books_data.append((title, publish_year, description, language))
    return books_data


def generate_author_data(num_authors: int) -> list:
    authors_data = []
    for _ in range(num_authors):
        name = fake.name()
        previous_name = fake.name() if random.random() < 0.1 else None
        birth_date = fake.date_of_birth(minimum_age=20, maximum_age=100)
        death_date = None
        if random.random() < 0.7:
            death_date = fake.date_between(
                start_date=birth_date + timedelta(days=365 * 20),
                end_date=date.today(),
            )
        gender = random.choice(["M", "F", None])
        authors_data.append(
            (name, previous_name, birth_date, death_date, gender)
        )
    return authors_data


def generate_location_data(num_locations: int) -> list:
    locations_data = []
    location_classes = [
        "Planet",
        "City",
        "Ruins",
        "Ocean",
        "Mountain",
        "Forest",
        "Other",
    ]
    countries = ["USA", "UK", "France", "Egypt", "Antarctica", "Unknown"]
    for _ in range(num_locations):
        name = (
            fake.city() + " " + fake.word().capitalize()
            if random.random() < 0.7
            else fake.word().capitalize() + " " + fake.last_name()
        )
        description = fake.text(max_nb_chars=300)
        loc_class = random.choice(location_classes)
        country = random.choice(countries)
        locations_data.append((name, description, loc_class, country))
    return locations_data


def generate_creature_data(num_creatures: int) -> list:
    creatures_data = []
    creature_classes = [
        "Great Old One",
        "Outer God",
        "Elder Thing",
        "Deep One",
        "Human",
        "Other",
    ]
    habitats = ["Space", "Aquatic", "Soil", "Terrestrial", "Host", "Everywhere"]
    for _ in range(num_creatures):
        name = (
            fake.first_name() + " of " + fake.word().capitalize()
            if random.random() < 0.7
            else fake.last_name() + " " + fake.word().capitalize()
        )
        description = fake.text(max_nb_chars=400)
        creature_class = random.choice(creature_classes)

        if creature_class in ["Great Old One", "Outer God"]:
            habitat = random.choice(["Space", "Everywhere"])
        else:
            habitat = random.choice(habitats)

        creatures_data.append((name, description, creature_class, habitat))
    return creatures_data


def generate_artefact_data(num_artefacts: int) -> list:
    artefacts_data = []
    artefact_classes = ["Tome", "Relic", "Ornament", "Device", "Other"]
    for _ in range(num_artefacts):
        name = fake.unique.word().capitalize() + " of " + fake.last_name()
        description = fake.text(max_nb_chars=350)
        art_class = random.choice(artefact_classes)
        artefacts_data.append((name, description, art_class))
    return artefacts_data


authors_ids = []
books_ids = []
locations_ids = []
creatures_ids = []
artefacts_ids = []


def insert_data(
    conn: psycopg2._psycopg.connection,
    cursor: psycopg2._psycopg.cursor,
    table_name: str,
    columns: list[str],
    data: list,
    id_column_name: str,
) -> list[int]:
    if not data:
        return []
    placeholders = ",".join(["%s"] * len(columns))
    cols_str = ",".join(columns)
    insert_query = f"INSERT INTO {table_name} ({cols_str}) VALUES ({placeholders}) RETURNING {id_column_name};"

    inserted_ids = []
    for record in data:
        try:
            cursor.execute(insert_query, record)
            inserted_ids.append(cursor.fetchone()[0])
        except psycopg2.Error as e:
            print(f"Ошибка базы данных: {e}")
            conn.rollback()
            continue
    conn.commit()
    print(f"Вставлено {len(inserted_ids)} строк в {table_name}")
    return inserted_ids


def populate_junction_tables(
    conn: psycopg2._psycopg.connection, cursor: psycopg2._psycopg.cursor
) -> None:
    print("Заполнение таблиц-связок")
    # author_book
    author_book_data = []
    for book_id in books_ids:
        num_authors_for_book = random.choices(
            [1, 2, 3], weights=[0.8, 0.15, 0.05], k=1
        )[0]
        selected_authors = random.sample(
            authors_ids, min(num_authors_for_book, len(authors_ids))
        )
        for author_id in selected_authors:
            role = random.choice(["Author", "Co-Author", "Editor"])
            author_book_data.append((author_id, book_id, role))
    insert_data(
        conn,
        cursor,
        "author_book",
        ["author_id", "book_id", "role"],
        author_book_data,
        "author_book_id",
    )

    # location_book
    location_book_data = []
    for book_id in books_ids:
        num_locations_for_book = random.choices(
            [1, 2, 3, 4], weights=[0.6, 0.2, 0.1, 0.1], k=1
        )[0]
        selected_locations = random.sample(
            locations_ids, min(num_locations_for_book, len(locations_ids))
        )
        for location_id in selected_locations:
            role = random.choice(["Primary", "Secondary", "Mentioned"])
            location_book_data.append((location_id, book_id, role))
    insert_data(
        conn,
        cursor,
        "location_book",
        ["location_id", "book_id", "role"],
        location_book_data,
        "location_book_id",
    )

    # creature_book
    creature_book_data = []
    for book_id in books_ids:
        num_creatures_for_book = random.choices(
            [0, 1, 2, 3], weights=[0.4, 0.3, 0.2, 0.1], k=1
        )[0]
        if num_creatures_for_book > 0:
            selected_creatures = random.sample(
                creatures_ids, min(num_creatures_for_book, len(creatures_ids))
            )
            for creature_id in selected_creatures:
                role = random.choice(
                    ["Physical", "Summoned", "Mentioned", "Dream"]
                )
                creature_book_data.append((creature_id, book_id, role))
    insert_data(
        conn,
        cursor,
        "creature_book",
        ["creature_id", "book_id", "role"],
        creature_book_data,
        "creature_book_id",
    )

    # artefact_book
    artefact_book_data = []
    for book_id in books_ids:
        num_artefacts_for_book = random.choices(
            [0, 1, 2], weights=[0.5, 0.3, 0.2], k=1
        )[0]
        if num_artefacts_for_book > 0:
            selected_artefacts = random.sample(
                artefacts_ids, min(num_artefacts_for_book, len(artefacts_ids))
            )
            for artefact_id in selected_artefacts:
                role = random.choice(
                    ["Full Description", "Summoning Ritual", "Mentioned"]
                )
                artefact_book_data.append((artefact_id, book_id, role))
    insert_data(
        conn,
        cursor,
        "artefact_book",
        ["artefact_id", "book_id", "role"],
        artefact_book_data,
        "artefact_book_id",
    )

    # creature_artefact
    creature_artefact_data = []
    for creature_id in creatures_ids:
        num_artefacts_for_creature = random.choices(
            [0, 1, 2], weights=[0.6, 0.3, 0.1], k=1
        )[0]
        if num_artefacts_for_creature > 0:
            selected_artefacts = random.sample(
                artefacts_ids,
                min(num_artefacts_for_creature, len(artefacts_ids)),
            )
            for artefact_id in selected_artefacts:
                role = random.choice(["Created", "Owned by", "Mentioned"])
                creature_artefact_data.append((creature_id, artefact_id, role))
    insert_data(
        conn,
        cursor,
        "creature_artefact",
        ["creature_id", "artefact_id", "artefact_role"],
        creature_artefact_data,
        "creature_artefact_id",
    )
