
-- author table
CREATE TABLE author 
( 
    author_id  VARCHAR2(10) NOT NULL, 
    author_name  VARCHAR2(50) NOT NULL, 
    author_bio  VARCHAR2(300), 
    author_score NUMBER, 
    author_image  VARCHAR2(255),
    author_birth_date DATE, 
CONSTRAINT PK_author 
    PRIMARY KEY (author_id),
CONSTRAINT CK_author_id
    CHECK (REGEXP_LIKE(author_id, 'au[0-9]{5}')),
CONSTRAINT CK_author_score   CHECK ((author_score >= 0 AND author_score <= 5))
) 
/


CREATE TABLE book_category 
( 
    category_id  VARCHAR2(10) NOT NULL, 
    category_name  VARCHAR2(50) NOT NULL, 
    category_description  VARCHAR2(300), 
    category_image  VARCHAR2(255),
CONSTRAINT PK_book_category
    PRIMARY KEY (category_id),
CONSTRAINT CK_category_id 
    CHECK (REGEXP_LIKE(category_id, 'bc[0-9]{5}'))
)
/ 

CREATE TABLE genre 
( 
    genre_id  VARCHAR2(10) NOT NULL, 
    genre_name  VARCHAR2(50) NOT NULL, 
    genre_description  VARCHAR2(300), 
    genre_image  VARCHAR2(255), 
CONSTRAINT PK_genre 
    PRIMARY KEY (genre_id),
CONSTRAINT CK_genre_id
    CHECK (REGEXP_LIKE(genre_id, 'ge[0-9]{5}'))
) 
/ 

CREATE OR REPLACE
    TYPE genre_id_list AS TABLE OF VARCHAR2(10);
/
CREATE TABLE book
(
    book_id  VARCHAR2(10) NOT NULL,
    author_id  VARCHAR2(10) NOT NULL,
    category_id  VARCHAR2(10) NOT NULL,
    genre_ids  genre_id_list,
    book_title  VARCHAR2(40) NOT NULL,
    book_description  VARCHAR2(300),
    book_publish_date  DATE,
    book_price  NUMBER,
    discontinued  NUMBER(1) NOT NULL,
    book_pages NUMBER,
    book_discount  NUMBER(1) DEFAULT 0,
    available_quantity  NUMBER,
    book_language VARCHAR2(100),
    book_publisher VARCHAR2(100),
    book_isbn VARCHAR2(13),
    book_cover_image VARCHAR2(255),
CONSTRAINT PK_book
    PRIMARY KEY (book_id),
CONSTRAINT CK_book_id
    CHECK (REGEXP_LIKE(book_id, 'bo[0-9]{5}')),
CONSTRAINT CK_book_book_price   CHECK ((book_price > 0)),
CONSTRAINT CK_discontinued   CHECK ((discontinued = 0 or discontinued = 1)),
CONSTRAINT CK_book_pages   CHECK ((book_pages >= 0)),
CONSTRAINT CK_book_discount   CHECK ((book_discount >= 0 AND book_discount <= 1)),
CONSTRAINT CK_available_quantity   CHECK ((available_quantity >= 0)),
CONSTRAINT FK_book_author 
    FOREIGN KEY (author_id) 
    REFERENCES author(author_id)
    ON DELETE CASCADE,
CONSTRAINT FK_book_category 
    FOREIGN KEY (category_id) 
    REFERENCES book_category(category_id)
    ON DELETE CASCADE
) NESTED TABLE genre_ids STORE AS genre_ids_table
/


-- insert data

INSERT INTO author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00001', 'J.K. Rowling', 'Joanne Rowling, better known by her pen name J.K. Rowling, is a British author, philanthropist, film producer, television producer, and screenwriter. She is best known for writing the Harry Potter fantasy series.', 5, 'https://upload.wikimedia.org/wikipedia/commons/5/5d/J._K._Rowling_2010.jpg', TO_DATE('1965-07-31', 'YYYY-MM-DD'));
INSERT INTO author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00002', 'Stephen King', 'Stephen Edwin King is an American author of horror, supernatural fiction, suspense, crime, science-fiction, and fantasy novels. His books have sold more than 350 million copies.', 5, 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Stephen_King%2C_Comicon.jpg', TO_DATE('1947-09-21', 'YYYY-MM-DD'));
INSERT INTO author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00003', 'J.R.R. Tolkien', 'John Ronald Reuel Tolkien was an English writer, poet, philologist, and academic, best known as the author of the high fantasy works The Hobbit, The Lord of the Rings, and The Silmarillion.', 5, 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Tolkien_1916.jpg', TO_DATE('1892-01-03', 'YYYY-MM-DD'));

select * from author;
INSERT INTO book_category (category_id, category_name, category_description, category_image) VALUES ('bc00001', 'Fantasy', 'Fantasy is a genre of speculative fiction set in a fictional universe, often inspired by real world myth and folklore. Its roots are in oral traditions, which then became literature and drama.', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fantasy.jpg');
INSERT INTO book_category (category_id, category_name, category_description, category_image) VALUES ('bc00002', 'Horror', 'Horror is a genre of speculative fiction which is intended to frighten, scare, or disgust. Literary historian J.A. Cuddon defined the horror story as "a piece of fiction in prose of variable length... which shocks, or even frightens the reader, or perhaps induces a feeling of repulsion or loathing".', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fantasy.jpg');
INSERT INTO book_category (category_id, category_name, category_description, category_image) VALUES ('bc00003', 'Science Fiction', 'Science fiction (sometimes shortened to sci-fi or SF) is a genre of speculative fiction that typically deals with imaginative and futuristic concepts such as advanced science and technology, space exploration, time travel, parallel universes, and extraterrestrial life.', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fantasy.jpg');



INSERT INTO genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00001', 'Epic Fantasy', 'Epic fantasy is a subgenre of fantasy defined by its epic scope and grandeur. It often involves a struggle between good and evil, and features larger-than-life characters, themes, and plotlines.', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fantasy.jpg');
INSERT INTO genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00002', 'Urban Fantasy', 'Urban fantasy is a subgenre of fantasy that takes place in a modern, urban setting. It combines elements of fantasy with the real world, often featuring mythical creatures, magic, and supernatural beings coexisting with humans.', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fantasy.jpg');
INSERT INTO genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00003', 'Dark Fantasy', 'Dark fantasy is a subgenre of fantasy that incorporates elements of horror, supernatural, and gothic fiction. It often has a dark and brooding atmosphere, with themes of fear, dread, and the macabre.', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Fantasy.jpg');



INSERT INTO book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00001', 'au00001', 'bc00001', genre_id_list('ge00001','ge00002'), 'Harry Potter and the Philosopher''s Stone', 'Harry Potter and the Philosopher''s Stone is a fantasy novel written by British author J. K. Rowling. The first novel in the Harry Potter series and Rowling''s debut novel, it follows Harry Potter, a young wizard who discovers his months old.', TO_DATE('1997-06-26', 'YYYY-MM-DD'), 20, 0, 223, 0, 100, 'English', 'Bloomsbury Publishing', '9780747532743', 'https://upload.wikimedia.org/wikipedia/en/b/bf/Harry_Potter_and_the_Sorcerer%27s_Stone.jpg');
INSERT INTO book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00002', 'au00001', 'bc00001', genre_id_list('ge00001','ge00002'), 'Harry Potter and the Chamber of Secrets', 'Harry Potter and thwhen he was just 15 months old.', TO_DATE('1998-07-02', 'YYYY-MM-DD'), 20, 0, 251, 0, 100, 'English', 'Bloomsbury Publishing', '9780747532743', 'https://upload.wikimedia.org/wikipedia/en/5/5c/Harry_Potter_and_the_Chamber_of_Secrets.jpg');

select * from book;

-- delete the bc00001 from book_category
DELETE FROM book_category WHERE category_id = 'bc00001';

