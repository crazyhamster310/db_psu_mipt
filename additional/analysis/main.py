import matplotlib.pyplot as plt
import pandas
import pandas as pd
import psycopg2
import seaborn as sns
from scipy import stats

import generators
from config import get_config


def fetch_data(
    conn: psycopg2._psycopg.connection, query: str
) -> pandas.DataFrame:
    df = pd.read_sql(query, conn)
    return df


def conduct_analysis(
    conn: psycopg2._psycopg.connection,
    df_books: pandas.DataFrame,
    df_authors: pandas.DataFrame,
    df_creatures: pandas.DataFrame,
    df_artefacts: pandas.DataFrame,
):
    print("\nАнализ данных")

    # 1. Построение графиков

    # Гистограмма распределения года публикации книг
    plt.figure(figsize=(10, 6))
    sns.histplot(df_books["publish_year"], bins=20, kde=True)
    plt.title("Распределение годов публикации книг")
    plt.xlabel("Год публикации")
    plt.ylabel("Количество книг")
    plt.grid(axis="y", alpha=0.75)
    plt.tight_layout()
    plt.savefig("publish_year_distribution.png")
    plt.show()

    # Круговая диаграмма распределения классов существ
    plt.figure(figsize=(8, 8))
    creature_class_counts = df_creatures["class"].value_counts()
    plt.pie(
        creature_class_counts,
        labels=creature_class_counts.index,
        autopct="%1.1f%%",
        startangle=90,
        pctdistance=0.85,
    )
    plt.title("Распределение классов существ")
    plt.axis("equal")
    plt.tight_layout()
    plt.savefig("creature_class_distribution.png")
    plt.show()

    # Столбчатая диаграмма количества книг по языкам
    plt.figure(figsize=(10, 6))
    book_language_counts = df_books["language"].value_counts()
    sns.barplot(
        x=book_language_counts.index,
        y=book_language_counts.values,
        palette="viridis",
    )
    plt.title("Количество книг по языкам")
    plt.xlabel("Язык")
    plt.ylabel("Количество книг")
    plt.tight_layout()
    plt.savefig("books_by_language.png")
    plt.show()

    # 2. Проверка гипотез

    print(
        "\nГипотеза 1: Средний год публикации книг, где упоминаются 'Great Old One', совпадает 'Deep One'"
    )
    query_creature_books = """
    SELECT
        c.class AS creature_class,
        b.publish_year
    FROM creature_book cb
    JOIN creatures c ON cb.creature_id = c.creature_id
    JOIN books b ON cb.book_id = b.book_id;
    """
    df_creature_books = fetch_data(conn, query_creature_books)

    go_years = df_creature_books[
        df_creature_books["creature_class"] == "Great Old One"
    ]["publish_year"]
    do_years = df_creature_books[
        df_creature_books["creature_class"] == "Deep One"
    ]["publish_year"]

    if len(go_years) > 1 and len(do_years) > 1:
        t_stat, p_value = stats.ttest_ind(
            go_years, do_years, equal_var=False
        )
        print(
            f"Средний год публикации для 'Great Old One': {int(go_years.mean())}"
        )
        print(f"Средний год публикации для 'Deep One': {int(do_years.mean())}")
        print(f"T-статистика: {t_stat:.2f}, P-значение: {p_value:.3f}")
        alpha = 0.05
        if p_value < alpha:
            print(
                f"P-значение ({p_value:.3f}) < alpha ({alpha}) => Есть основания полагать, что существует статистически значимая разница в среднем годе публикации."
            )
        else:
            print(
                f"P-значение ({p_value:.3f}) > alpha ({alpha}) => Можно принять гипотезу о том, что в среднем книги с существами данных классов публиковались в одно время"
            )
    else:
        print(
            "Недостаточно данных для проверки гипотезы 1 (нужно как минимум 2 книги для каждого класса существ)."
        )

    print(
        "\nГипотеза 2: Год рождения автора и количество написанных книг некоррелированные"
    )
    df_authors_for_corr = df_authors.dropna(
        subset=["birth_date", "book_count"]
    ).copy()
    if not df_authors_for_corr.empty:
        df_authors_for_corr["birth_year"] = df_authors_for_corr[
            "birth_date"
        ].apply(lambda x: x.year)

        corr, p_value = stats.spearmanr(
            df_authors_for_corr["birth_year"], df_authors_for_corr["book_count"]
        )
        print(
            f"Коэффициент корреляции Спирмена: {corr:.2f}, P-значение: {p_value:.3f}"
        )
        alpha = 0.05
        if p_value < alpha:
            print(
                f"P-значение ({p_value:.3f}) < alpha ({alpha}) => Есть основания полагать, что существует статистически значимая корреляция."
            )
            if corr > 0:
                print(
                    "Корреляция положительная (чем старше автор, тем больше книг)."
                )
            else:
                print(
                    "Корреляция отрицательная (чем моложе автор, тем больше книг)."
                )
        else:
            print(
                f"P-значение ({p_value:.3f}) > alpha ({alpha}) => Принимаем гипотезу, что нет статистически значимой корреляции."
            )
    else:
        print(
            "Недостаточно данных для проверки гипотезы 2 (нужны авторы с датой рождения и количеством книг)."
        )

    print(
        "\nГипотеза 3: Средняя длина описания артефактов класса 'Tome' совпадает с 'Relic'"
    )
    df_artefacts["description_length"] = df_artefacts["description"].apply(len)

    tome_lengths = df_artefacts[df_artefacts["class"] == "Tome"][
        "description_length"
    ]
    relic_lengths = df_artefacts[df_artefacts["class"] == "Relic"][
        "description_length"
    ]

    if len(tome_lengths) > 1 and len(relic_lengths) > 1:
        t_stat, p_value = stats.ttest_ind(
            tome_lengths, relic_lengths, equal_var=False
        )
        print(f"Средняя длина описания для 'Tome': {int(tome_lengths.mean())}")
        print(f"Средняя длина описания для 'Relic': {int(relic_lengths.mean())}")
        print(f"T-статистика: {t_stat:.2f}, P-значение: {p_value:.3f}")
        alpha = 0.05
        if p_value < alpha:
            print(
                f"P-значение ({p_value:.3f}) < alpha ({alpha}) => Есть основания полагать, что длина описаний отличается"
            )
        else:
            print(
                f"P-значение ({p_value:.3f}) > alpha ({alpha}) => Принимаем гипотезу о том, что для данных типов в среднем длина описания совпадает"
            )
    else:
        print(
            "Недостаточно данных для проверки гипотезы 3 (нужно как минимум 2 артефакта для каждого класса)."
        )


def main(truncate=True):
    conn = None
    try:
        config = get_config()
        conn = psycopg2.connect(
            dbname=config.POSTGRES_DB,
            host=config.POSTGRES_HOST,
            port=config.POSTGRES_PORT,
            user=config.POSTGRES_USER,
            password=config.POSTGRES_PASSWORD,
        )
        cursor = conn.cursor()
        print("Успешное подключение к базе данных.")

        if truncate:
            print("Очистка существующих данных")
            cursor.execute(
                "TRUNCATE TABLE creature_artefact, author_book, location_book, creature_book, artefact_book, books, authors, locations, creatures, artefacts RESTART IDENTITY CASCADE;"
            )
            conn.commit()
            print("Данные очищены")

        print("Генерация и вставка данных")
        generators.books_ids = generators.insert_data(
            conn,
            cursor,
            "books",
            ["title", "publish_year", "description", "language"],
            generators.generate_book_data(150),
            "book_id",
        )
        generators.authors_ids = generators.insert_data(
            conn,
            cursor,
            "authors",
            ["name", "previous_name", "birth_date", "death_date", "gender"],
            generators.generate_author_data(50),
            "author_id",
        )
        generators.locations_ids = generators.insert_data(
            conn,
            cursor,
            "locations",
            ["name", "description", "class", "country"],
            generators.generate_location_data(70),
            "location_id",
        )
        generators.creatures_ids = generators.insert_data(
            conn,
            cursor,
            "creatures",
            ["name", "description", "class", "habitat"],
            generators.generate_creature_data(60),
            "creature_id",
        )
        generators.artefacts_ids = generators.insert_data(
            conn,
            cursor,
            "artefacts",
            ["name", "description", "class"],
            generators.generate_artefact_data(40),
            "artefact_id",
        )
        generators.populate_junction_tables(conn, cursor)
        print("Все данные вставлены")

        print("Извлечение данных для анализа")
        df_books_extracted = fetch_data(conn, "SELECT * FROM books;")
        df_authors_extracted = fetch_data(conn, "SELECT * FROM authors;")
        df_creatures_extracted = fetch_data(conn, "SELECT * FROM creatures;")
        df_artefacts_extracted = fetch_data(conn, "SELECT * FROM artefacts;")

        print(f"Извлечено {len(df_books_extracted)} записей из 'books'.")
        print(f"Извлечено {len(df_authors_extracted)} записей из 'authors'.")
        print(
            f"Извлечено {len(df_creatures_extracted)} записей из 'creatures'."
        )
        print(
            f"Извлечено {len(df_artefacts_extracted)} записей из 'artefacts'."
        )

        conduct_analysis(
            conn,
            df_books_extracted,
            df_authors_extracted,
            df_creatures_extracted,
            df_artefacts_extracted,
        )

    except psycopg2.Error as e:
        print(f"Ошибка базы данных: {e}")
    except Exception as e:
        print(f"Произошла ошибка: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()
            print("Соединение с базой данных закрыто.")


if __name__ == "__main__":
    main()
