/*
File: dml_triggers.sql
Description: All the triggers and PROCEDURAL FUNCTIONS for the database
Author: @Ayon-SSP
Date Created: 2024-03-08
*/


-- Create table for storing author information
CREATE TABLE tbl_author 
( 
    author_id VARCHAR2(10) NOT NULL, 
    author_name VARCHAR2(50) NOT NULL, 
    author_bio VARCHAR2(1000), 
    author_score NUMBER, 
    author_image VARCHAR2(255),
    author_birth_date DATE, 
CONSTRAINT pk_author 
    PRIMARY KEY (author_id),
CONSTRAINT ck_author_id
    CHECK (REGEXP_LIKE(author_id, 'au[0-9]{5}')),
CONSTRAINT ck_author_score   CHECK ((author_score >= 0 AND author_score <= 5))
) 
/

-- Create table for storing book categories
CREATE TABLE tbl_book_category 
( 
    category_id VARCHAR2(10) NOT NULL, 
    category_name VARCHAR2(50) NOT NULL, 
    category_description VARCHAR2(1000), 
    category_image VARCHAR2(255),
CONSTRAINT pk_book_category
    PRIMARY KEY (category_id),
CONSTRAINT ck_category_id 
    CHECK (REGEXP_LIKE(category_id, 'bc[0-9]{5}'))
)
/ 

-- Create table for storing book genres
CREATE TABLE tbl_genre 
( 
    genre_id VARCHAR2(10) NOT NULL, 
    genre_name VARCHAR2(50) NOT NULL, 
    genre_description VARCHAR2(1000), 
    genre_image VARCHAR2(255), 
CONSTRAINT pk_genre 
    PRIMARY KEY (genre_id),
CONSTRAINT ck_genre_id
    CHECK (REGEXP_LIKE(genre_id, 'ge[0-9]{5}'))
) 
/ 

-- Create a nested table type for storing genre ids
CREATE OR REPLACE
    TYPE type_genre_id_list AS TABLE OF VARCHAR2(10)
/

-- Create table for storing book information
CREATE TABLE tbl_book
(
    book_id VARCHAR2(10) NOT NULL,
    author_id VARCHAR2(10) NOT NULL,
    category_id VARCHAR2(10) NOT NULL,
    genre_ids type_genre_id_list,
    book_title VARCHAR2(100) NOT NULL,
    book_description VARCHAR2(1000),
    book_publish_date DATE,
    book_price NUMBER,
    discontinued NUMBER(1) DEFAULT 0 NOT NULL,
    book_pages NUMBER,
    book_discount NUMBER(1) DEFAULT 0,
    available_quantity NUMBER,
    book_language VARCHAR2(100),
    book_publisher VARCHAR2(100),
    book_isbn VARCHAR2(13),
    book_cover_image VARCHAR2(255),
CONSTRAINT pk_book
    PRIMARY KEY (book_id),
CONSTRAINT ck_book_id
    CHECK (REGEXP_LIKE(book_id, 'bo[0-9]{5}')),
CONSTRAINT ck_book_book_price   CHECK ((book_price > 0)),
CONSTRAINT ck_discontinued   CHECK ((discontinued = 0 or discontinued = 1)),
CONSTRAINT ck_book_pages   CHECK ((book_pages >= 0)),
CONSTRAINT ck_book_discount   CHECK ((book_discount >= 0 AND book_discount <= 1)),
CONSTRAINT ck_available_quantity   CHECK ((available_quantity >= 0)),
CONSTRAINT fk_book_author 
    FOREIGN KEY (author_id) 
    REFERENCES tbl_author(author_id)
    ON DELETE CASCADE,
CONSTRAINT fk_book_category 
    FOREIGN KEY (category_id) 
    REFERENCES tbl_book_category(category_id)
    ON DELETE CASCADE
) NESTED TABLE genre_ids STORE AS genre_ids_table
/
    
-- Create table for storing customer information
CREATE TABLE tbl_customer
( 
    customer_id VARCHAR2(10) NOT NULL, 
    customer_name VARCHAR2(30),
    customer_email VARCHAR2(100), 
    customer_phone1 VARCHAR2(24) NOT NULL,
    password_hash VARCHAR2(100),
CONSTRAINT pk_customer 
    PRIMARY KEY (customer_id),
CONSTRAINT ck_customer_id
    CHECK (REGEXP_LIKE(customer_id, 'cu[0-9]{5}'))
) 
/ 

-- Create table for storing customer address information
CREATE TABLE tbl_customer_address (
    customer_address_id VARCHAR2(10) NOT NULL,
    address_type VARCHAR2(16) NOT NULL,
    customer_id VARCHAR2(10) NOT NULL, 
    address_line1 VARCHAR2(255),
    address_line2 VARCHAR2(255),
    address_line3 VARCHAR2(255),
    city VARCHAR2(100),
    state VARCHAR2(100),
    country VARCHAR2(100),
    postalcode VARCHAR2(6),
    landmark VARCHAR2(255),
    phone VARCHAR2(24), 
CONSTRAINT pk_customer_address 
    PRIMARY KEY (customer_address_id), 
CONSTRAINT ck_customer_address_id
    CHECK (REGEXP_LIKE(customer_address_id, 'ca[0-9]{5}')),
-- Create a unique constraint for (address_type, customer_id)
CONSTRAINT ck_address_type_customer_id
    UNIQUE (address_type, customer_id),
CONSTRAINT fk_customer_address_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES tbl_customer(customer_id)
    ON DELETE CASCADE
)
/

-- Create table for storing customer payment information
CREATE TABLE tbl_subscription 
( 
    subscription_status_id VARCHAR2(10) NOT NULL, 
    subscription_name VARCHAR2(30),
    subscription_description VARCHAR2(1000), 
    subscription_price NUMBER,
    subscription_duration NUMBER,
    subscription_discount_on_order NUMBER(4, 4) DEFAULT 0,
CONSTRAINT pk_subscription 
    PRIMARY KEY (subscription_status_id),
CONSTRAINT ck_subscription_status_id
    CHECK (REGEXP_LIKE(subscription_status_id, 'su[0-9]{5}')),
CONSTRAINT ck_subscription_price   
    CHECK ((subscription_price >= 0)),
CONSTRAINT ck_subscription_discount_on_order   
    CHECK ((subscription_discount_on_order >= 0 AND subscription_discount_on_order <= 1))
) 
/ 

-- Create table for storing customer subscription information
CREATE TABLE tbl_subscription_log_history
( 
    subscription_log_id VARCHAR2(10) NOT NULL, 
    customer_id VARCHAR2(10) NOT NULL, 
    subscription_status_id VARCHAR2(10) NOT NULL, 
    subscription_start_date DATE,
    subscription_end_date DATE,
CONSTRAINT pk_subscription_log_history
    PRIMARY KEY (subscription_log_id),
CONSTRAINT ck_subscription_log_id
    CHECK (REGEXP_LIKE(subscription_log_id, 'sl[0-9]{5}')),
CONSTRAINT fk_subscription_log_history_customer
    FOREIGN KEY (customer_id) 
    REFERENCES tbl_customer(customer_id)
    ON DELETE CASCADE,
CONSTRAINT fk_subscription_log_history_subscription
    FOREIGN KEY (subscription_status_id) 
    REFERENCES tbl_subscription(subscription_status_id)
    ON DELETE CASCADE
)
/

-- Create table for storing customer payment information
CREATE TABLE tbl_shopping_cart 
(
    customer_id VARCHAR2(10) NOT NULL, 
    book_id VARCHAR2(10) NOT NULL, 
    quantity NUMBER NOT NULL,
CONSTRAINT pk_shopping_cart
    PRIMARY KEY (customer_id, book_id),
CONSTRAINT ck_quantity  
    CHECK ((quantity > 0)),
CONSTRAINT fk_shopping_cart_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES tbl_customer(customer_id)
    ON DELETE CASCADE,
CONSTRAINT fk_shopping_cart_book 
    FOREIGN KEY (book_id) 
    REFERENCES tbl_book(book_id)
    ON DELETE CASCADE
)
/

-- Create table for storing customer wishlist information
CREATE TABLE tbl_wishlist 
( 
    customer_wishlist_id VARCHAR2(10) NOT NULL, 
    customer_id VARCHAR2(10) NOT NULL, 
    wishlist_name VARCHAR2(50),
    wishlist_description VARCHAR2(1000),
    wishlist_image VARCHAR2(255),
CONSTRAINT pk_wishlist
    PRIMARY KEY (customer_wishlist_id, customer_id),
CONSTRAINT ck_wishlist_customer_wishlist_id
    CHECK (REGEXP_LIKE(customer_wishlist_id, 'wi[0-9]{5}')),
CONSTRAINT fk_wishlist_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES tbl_customer(customer_id)
    ON DELETE CASCADE
)
/

-- Create table for storing customer wishlist items
CREATE TABLE tbl_wishlist_item 
( 
    customer_wishlist_id VARCHAR2(10) NOT NULL, 
    customer_id VARCHAR2(10) NOT NULL,
    book_id VARCHAR2(10) NOT NULL,
CONSTRAINT pk_wishlist_item
    PRIMARY KEY (customer_wishlist_id, customer_id, book_id),
CONSTRAINT fk_wishlist_item_wishlist
    FOREIGN KEY (customer_wishlist_id, customer_id) 
    REFERENCES tbl_wishlist(customer_wishlist_id, customer_id)
    ON DELETE CASCADE,
CONSTRAINT fk_wishlist_item_book
    FOREIGN KEY (book_id) 
    REFERENCES tbl_book(book_id)
    ON DELETE CASCADE
)
/

-- Create table for storing customer review information
CREATE TABLE tbl_user_review 
( 
    book_id VARCHAR2(10) NOT NULL, 
    customer_id VARCHAR2(10) NOT NULL, 
    book_rating NUMBER(4, 4), 
    book_review VARCHAR2(1000), 
    review_date DATE,
CONSTRAINT pk_book_rating
    PRIMARY KEY (book_id, customer_id),
CONSTRAINT ck_book_rating   CHECK ((book_rating >= 0 and book_rating <= 5)),
CONSTRAINT fk_book_rating_book 
    FOREIGN KEY (book_id) 
    REFERENCES tbl_book(book_id)
    ON DELETE CASCADE,
CONSTRAINT fk_book_rating_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES tbl_customer(customer_id)
    ON DELETE CASCADE
)
/ 

-- Create table for storing order information
CREATE TABLE tbl_orders 
( 
    order_id VARCHAR2(10) NOT NULL, 
    customer_id VARCHAR2(10) NOT NULL,
    address_type VARCHAR2(16) NOT NULL, 
    order_date DATE, 
    shipped_date DATE,
    order_discount NUMBER NOT NULL, -- get from customer subscription status
    order_total_cost NUMBER,  -- this will be calculated 
    order_status VARCHAR2(16),
CONSTRAINT pk_order 
    PRIMARY KEY (order_id), 
CONSTRAINT ck_order_id
    CHECK (REGEXP_LIKE(order_id, 'or[0-9]{5}')),
CONSTRAINT fk_order_customer_address_customer
    FOREIGN KEY (customer_id, address_type)
    REFERENCES tbl_customer_address(customer_id, address_type)
    ON DELETE CASCADE,
CONSTRAINT ck_customer_address_type
    CHECK (address_type IN ('Home', 'Office', 'Work', 'Other')),
CONSTRAINT ck_order_discount 
    CHECK ((order_discount >= 0 
        AND order_discount <= 1)),
CONSTRAINT ck_order_total_cost 
    CHECK ((order_total_cost >= 0))
) 
/

-- Create table for storing order details
CREATE TABLE tbl_order_detail 
( 
    order_id VARCHAR2(10) NOT NULL, 
    book_id VARCHAR2(10) NOT NULL, 
    book_price NUMBER, 
    quantity NUMBER DEFAULT 1 NOT NULL, 
CONSTRAINT pk_order_detail 
    PRIMARY KEY (order_id, book_id), 
CONSTRAINT ck_book_price   
    CHECK ((book_price >= 0)), 
CONSTRAINT ck_order_detail_quantity   
    CHECK ((quantity >= 1)), 
CONSTRAINT fk_OrderDetails_Orders 
    FOREIGN KEY (order_id) 
    REFERENCES tbl_orders(order_id)
    ON DELETE CASCADE, 
CONSTRAINT fk_OrderDetails_Products 
    FOREIGN KEY (book_id) 
    REFERENCES tbl_book(book_id)
    ON DELETE CASCADE
)
/



-- Insert records into tbl_book_category
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00001', 'Magazines', 'Magazines are publications, usually periodical publications, that are printed or electronically published. They are generally published on a regular schedule and contain a variety of content.', 'https://www.example.com/magazines.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00002', 'Paperback', 'A paperback, also known as a softcover or softback, is a type of book characterized by a thick paper or paperboard cover, and often held together with glue rather than stitches or staples.', 'https://www.example.com/paperback.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00003', 'Hardcover', 'A hardcover or hardback book is a book bound with rigid protective covers. It has a sewn spine which allows the book to lie flat on a surface when opened.', 'https://www.example.com/hardcover.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00004', 'Audiobooks', 'An audiobook is a recording of a book or other work being read out loud. A reading of the complete text is described as "unabridged", while readings of a shorter version are an abridgement.', 'https://www.example.com/audiobooks.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00005', 'Ebooks', 'An electronic book, also known as an e-book or eBook, is a book publication made available in digital form, consisting of text, images, or both, readable on the flat-panel display of computers or other electronic devices.', 'https://www.example.com/ebooks.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00006', 'Comics', 'A comic book, also called comic magazine or simply comic, is a publication that consists of comics art in the form of sequential juxtaposed panels that represent individual scenes.', 'https://www.example.com/comics.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00007', 'Graphic Novels', 'A graphic novel is a book made up of comics content. Although the word "novel" normally refers to long fictional works, the term "graphic novel" is applied broadly and includes fiction, non-fiction, and anthologized work.', 'https://www.example.com/graphic_novels.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00008', 'Childrens Books', 'Childrens literature or juvenile literature includes stories, books, magazines, and poems that are made for children. Modern childrens literature is classified in two different ways: genre or the intended age of the reader.', 'https://www.example.com/childrens_books.jpg');
INSERT INTO tbl_book_category (category_id, category_name, category_description, category_image) VALUES ('bc00009', 'Young Adult', 'Young adult fiction, also known as YA fiction, is a category of fiction written for readers from 12 to 18 years of age. While the genre is targeted to teenagers, approximately half of YA readers are adults.', 'https://www.example.com/young_adult.jpg');

-- Insert records into tbl_genre
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00001', 'Fantasy', 'Fantasy is a genre of speculative fiction set in a fictional universe, often inspired by real world myth and folklore. Its roots are in oral traditions, which then became literature and drama.', 'https://www.example.com/fantasy.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00002', 'Science Fiction', 'Science fiction is a genre of speculative fiction that typically deals with imaginative and futuristic concepts such as advanced science and technology, space exploration, time travel, parallel universes, and extraterrestrial life.', 'https://www.example.com/science_fiction.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00003', 'Horror', 'Horror is a genre of speculative fiction which is intended to frighten, scare, or disgust. Literary historian J. A. Cuddon has defined the horror story as a piece of fiction in prose of variable length...', 'https://www.example.com/horror.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00004', 'Mystery', 'Mystery fiction is a genre of fiction usually involving a mysterious death or a crime to be solved. In a closed circle of suspects, each suspect must have a credible motive and a reasonable opportunity for committing the crime.', 'https://www.example.com/mystery.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00005', 'Thriller', 'Thriller is a genre of fiction, having numerous, often overlapping subgenres. Thrillers are characterized and defined by the moods they elicit, giving viewers heightened feelings of suspense, excitement, surprise, anticipation, and anxiety.', 'https://www.example.com/thriller.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00006', 'Romance', 'Romance is a literary genre that focuses on the romantic relationships of the characters and the writer often presents to the reader a vision of the way life should be, and not necessarily the way it is.', 'https://www.example.com/romance.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00007', 'Historical Fiction', 'Historical fiction is a literary genre in which the plot takes place in a setting located in the past. Although the term is commonly used as a synonym for the historical novel, it can also be applied to other types of narrative, including theatre, opera, cinema, and television.', 'https://www.example.com/historical_fiction.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00008', 'Non-Fiction', 'Non-fiction is a genre of writing that is based on facts, real events, and real people, such as biography or history. Non-fiction is one of the two main divisions in writing, particularly used in libraries, the other being fiction.', 'https://www.example.com/non_fiction.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00009', 'Biography', 'A biography, or simply bio, is a detailed description of a person''s life. It involves more than just the basic facts like education, work, relationships, and death; it portrays a person''s experience of these life events.', 'https://www.example.com/biography.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00010', 'Autobiography', 'An autobiography is a self-written account of the life of oneself. The word "autobiography" was first used deprecatingly by William Taylor in 1797 in the English periodical The Monthly Review, when he suggested the word as a hybrid, but condemned it as "pedantic".', 'https://www.example.com/autobiography.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00011', 'Humor', 'Humour is the tendency of particular cognitive experiences to provoke laughter and provide amusement. The term derives from the humoral medicine of the ancient Greeks, which taught that the balance of fluids in the human body, known as humours, controlled human health and emotion.', 'https://www.example.com/humor.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00012', 'Self-Help', 'Self-help or self-improvement is a self-guided improvement—economically, intellectually, or emotionally—often with a substantial psychological basis. Many different self-help group programs exist, each with its own focus, techniques, associated beliefs, proponents and in some cases, leaders.', 'https://www.example.com/self_help.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00013', 'Cookbooks', 'A cookbook or cookery book is a kitchen reference containing recipes. Cookbooks may be general, or may specialize in a particular cuisine or category of food. Recipes in cookbooks are organized in various ways: by course, by main ingredient, by cooking technique, alphabetically, by region or country, and so on.', 'https://www.example.com/cookbooks.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00014', 'Travel', 'Travel literature is travel writing of literary value. Travel literature typically records the experiences of an author touring a place for the pleasure of travel. An individual work is sometimes called a travelogue or itinerary.', 'https://www.example.com/travel.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00015', 'Poetry', 'Poetry is a form of literature that uses aesthetic and often rhythmic qualities of language—such as phonaesthetics, sound symbolism, and metre—to evoke meanings in addition to, or in place of, the prosaic ostensible meaning.', 'https://www.example.com/poetry.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00016', 'Drama', 'Drama is the specific mode of fiction represented in performance: a play, opera, mime, ballet, etc., performed in a theatre, or on radio or television. Considered as a genre of poetry in general, the dramatic mode has been contrasted with the epic and the lyrical modes ever since Aristotle''s Poetics (c. 335 BC)—the earliest work of dramatic theory.', 'https://www.example.com/drama.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00017', 'Spirituality', 'Spirituality is the quality of being concerned with the human spirit or soul as opposed to material or physical things. It is the quality or state of being spiritual. The spiritual is a dimension of reality that is deeper than the physical.', 'https://www.example.com/spirituality.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00018', 'Religion', 'Religion is a social-cultural system of designated behaviors and practices, morals, worldviews, texts, sanctified places, prophecies, ethics, or organizations, that relates humanity to supernatural, transcendental, and spiritual elements.', 'https://www.example.com/religion.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00019', 'Health', 'Health is a state of physical, mental and social well-being in which disease and infirmity are absent. Health is a resource for everyday life, not the objective of living; it is a positive concept, emphasizing social and personal resources, as well as physical capacities.', 'https://www.example.com/health.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00020', 'Fitness', 'Physical fitness is a state of health and well-being and, more specifically, the ability to perform aspects of sports, occupations and daily activities. Physical fitness is generally achieved through proper nutrition, moderate-vigorous physical exercise, and sufficient rest.', 'https://www.example.com/fitness.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00021', 'Science', 'Science is a systematic enterprise that builds and organizes knowledge in the form of testable explanations and predictions about the universe.', 'https://www.example.com/science.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00022', 'Mathematics', 'Mathematics includes the study of such topics as quantity (number theory), structure (algebra), space (geometry), and change (mathematical analysis). It has no generally accepted definition.', 'https://www.example.com/mathematics.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00023', 'Technology', 'Technology is the sum of techniques, skills, methods, and processes used in the production of goods or services or in the accomplishment of objectives, such as scientific investigation.', 'https://www.example.com/technology.jpg');
INSERT INTO tbl_genre (genre_id, genre_name, genre_description, genre_image) VALUES ('ge00024', 'Engineering', 'Engineering is the application of scientific, economic, social, and practical knowledge in order to invent, design, build, maintain, research, and improve structures, machines, devices, systems, materials, and processes.', 'https://www.example.com/engineering.jpg');

-- Insert records into tbl_author
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00001', 'J.K. Rowling', 'J.K. Rowling is a British author, philanthropist, film producer, television producer, and screenwriter. She is best known for writing the Harry Potter fantasy series, which has won multiple awards and sold more than 500 million copies, becoming the best-selling book series in history.', 4.5, 'https://www.example.com/jk_rowling.jpg', TO_DATE('1965-07-31', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00002', 'Stephen King', 'Stephen Edwin King is an American author of horror, supernatural fiction, suspense, crime, science-fiction, and fantasy novels. His books have sold more than 350 million copies, and many have been adapted into films, television series, miniseries, and comic books.', 4.3, 'https://www.example.com/stephen_king.jpg', TO_DATE('1947-09-21', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00003', 'Agatha Christie', 'Dame Agatha Mary Clarissa Christie, Lady Mallowan, was an English writer known for her sixty-six detective novels and fourteen short story collections, particularly those revolving around fictional detectives Hercule Poirot and Miss Marple. She also wrote the worlds longest-running play, The Mousetrap.', 4.7, 'https://www.example.com/agatha_christie.jpg', TO_DATE('1890-09-15', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00004', 'Dan Brown', 'Daniel Gerhard Brown is an American author best known for his thriller novels, including the Robert Langdon novels Angels & Demons, The Da Vinci Code, The Lost Symbol, Inferno and Origin. His novels are treasure hunts that usually take place over a period of 24 hours.', 4.2, 'https://www.example.com/dan_brown.jpg', TO_DATE('1964-06-22', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00005', 'David Aaron', 'David Aaron is a British author, known for his work in the field of science fiction and fantasy. He has written several best-selling novels and has won numerous awards for his work.', 4.6, 'https://www.example.com/david_aaron.jpg', TO_DATE('1975-03-12', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00006', 'George R.R. Martin', 'George Raymond Richard Martin, also known as GRRM, is an American novelist and short story writer in the fantasy, horror, and science fiction genres, screenwriter, and television producer. He is best known for his series of epic fantasy novels, A Song of Ice and Fire, which was adapted into the HBO series Game of Thrones.', 4.8, 'https://www.example.com/george_rr_martin.jpg', TO_DATE('1948-09-20', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00007', 'J.R.R. Tolkien', 'John Ronald Reuel Tolkien was an English writer, poet, philologist, and academic, who is best known as the author of the classic high fantasy works The Hobbit, The Lord of the Rings, and The Silmarillion.', 4.9, 'https://www.example.com/jrr_tolkien.jpg', TO_DATE('1892-01-03', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00008', 'Rachel Aaron', 'Rachel Aaron is an American author, known for her work in the field of science fiction and fantasy. She has written several best-selling novels and has won numerous awards for her work.', 4.6, 'https://www.example.com/rachel_aaron.jpg', TO_DATE('1980-11-21', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00009', 'Brandon Sanderson', 'Brandon Sanderson is an American author of epic fantasy and science fiction. He is best known for the Cosmere universe, in which most of his fantasy novels, most notably the Mistborn series and The Stormlight Archive, are set.', 4.7, 'https://www.example.com/brandon_sanderson.jpg', TO_DATE('1975-12-19', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00010', 'Terry Pratchett', 'Sir Terence David John Pratchett was an English humorist, satirist, and author of fantasy novels, especially comical works. He is best known for his Discworld series of 41 novels.', 4.5, 'https://www.example.com/terry_pratchett.jpg', TO_DATE('1948-04-28', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00011', 'J.R.R. Tolkien', 'John Ronald Reuel Tolkien was an English writer, poet, philologist, and academic, who is best known as the author of the classic high fantasy works The Hobbit, The Lord of the Rings, and The Silmarillion.', 4.9, 'https://www.example.com/jrr_tolkien.jpg', TO_DATE('1892-01-03', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00012', 'John Doe', 'John Doe is an American author, known for his work in the field of self-help. He has written several best-selling novels and has won numerous awards for his work.', 4.6, 'https://www.example.com/john_doe.jpg', TO_DATE('1980-11-21', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00013', 'Jane Doe', 'Jane Doe is an American author, known for his work in the field of Fantasy. She has written several best-selling novels and has won numerous awards for his work.', 4.6, 'https://www.example.com/jane_doe.jpg', TO_DATE('1980-11-21', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00014', 'Jack Doe', 'Jack Doe is an American author, known for his work in the field of Science. He has written several best-selling novels and has won numerous awards for his work.', 4.6, 'https://www.example.com/jack_doe.jpg', TO_DATE('1980-11-21', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00015', 'James Clear', 'James Clear is an American author, known for his work in the field of self-help. He has written several best-selling novels and has won numerous awards for his work.', 4.6, 'https://www.example.com/james_clear.jpg', TO_DATE('1986-11-21', 'YYYY-MM-DD'));
INSERT INTO tbl_author (author_id, author_name, author_bio, author_score, author_image, author_birth_date) VALUES ('au00016', 'Don Miguel Ruiz', 'Don Miguel Ángel Ruiz is a Mexican author of Toltec spiritualist and neoshamanistic texts. His work is best-received among members of the New Thought movement that focuses on ancient teachings as a means to achieve spiritual enlightenment.', 4.6, 'https://www.example.com/don_miguel_ruiz.jpg', TO_DATE('1952-08-27', 'YYYY-MM-DD'));

-- insert records into tbl_book which should cover all the book_category's and author's and genre's
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00001', 'au00001', 'bc00002', type_genre_id_list('ge00001', 'ge00002'), 'Harry Potter and the Philosophers Stone', 'Harry Potter and the Philosophers Stone is a fantasy novel written by British author J. K. Rowling. The first novel in the Harry Potter series and Rowling''s debut novel, it follows Harry Potter, a young wizard who discovers his magical heritage on his eleventh birthday, when he receives a letter of acceptance to Hogwarts School of Witchcraft and Wizardry.', TO_DATE('1997-06-26', 'YYYY-MM-DD'), 20.00, 0, 223, 0, 100, 'English', 'Bloomsbury Publishing', '9780747532743', 'https://www.example.com/harry_potter_and_the_philosophers_stone.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00002', 'au00001', 'bc00002', type_genre_id_list('ge00002', 'ge00003','ge00007','ge00021'), 'Dune', 'Dune is a science fiction novel written by American author Frank Herbert, originally published as two separate serials in Analog magazine. It tied with Roger Zelazny''s This Immortal for the Hugo Award in 1966, and it won the inaugural Nebula Award for Best Novel.', TO_DATE('1965-06-01', 'YYYY-MM-DD'), 25.00, 0, 412, 0, 100, 'English', 'Chilton Books', '9780801955841', 'https://www.example.com/dune.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00003', 'au00002', 'bc00002', type_genre_id_list('ge00003', 'ge00004','ge00005','ge00006'), 'The Shining', 'The Shining is a horror novel by American author Stephen King. Published in 1977, it is King''s third published novel and first hardback bestseller: the success of the book firmly established King as a preeminent author in the horror genre.', TO_DATE('1977-01-28', 'YYYY-MM-DD'), 30.00, 0, 447, 0, 100, 'English', 'Doubleday', '9780385121675', 'https://www.example.com/the_shining.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00004', 'au00002', 'bc00002', type_genre_id_list('ge00012', 'ge00009','ge00018','ge00007'), 'Cloud Atlas', 'Cloud Atlas is a novel by British author David Mitchell. It consists of six nested stories that take the reader from the remote South Pacific in the nineteenth century to a distant, post-apocalyptic future.', TO_DATE('2004-08-17', 'YYYY-MM-DD'), 35.00, 0, 509, 0, 100, 'English', 'Sceptre', '9780340822784', 'https://www.example.com/cloud_atlas.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00005', 'au00001', 'bc00002', type_genre_id_list('ge00001', 'ge00002','ge00003','ge00004'), 'The Stand', 'The Stand is a post-apocalyptic dark fantasy novel written by American author Stephen King and first published in 1978 by Doubleday. The plot centers on a pandemic of a weaponized strain of influenza that kills almost the entire world population.', TO_DATE('1978-10-03', 'YYYY-MM-DD'), 40.00, 0, 823, 0, 100, 'English', 'Doubleday', '9780385121682', 'https://www.example.com/the_stand.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00006', 'au00003', 'bc00002', type_genre_id_list('ge00005', 'ge00006','ge00007','ge00008', 'ge00009','ge00018','ge00007'), 'God Emperor of Dune', 'God Emperor of Dune is a science fiction novel by Frank Herbert, the fourth in his Dune series of six novels. It was ranked as the No. 11 hardcover fiction best seller of 1981 by Publishers Weekly.', TO_DATE('1981-05-28', 'YYYY-MM-DD'), 45.00, 0, 454, 0, 100, 'English', 'Putnam', '9780399125933', 'https://www.example.com/god_emperor_of_dune.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00007', 'au00004', 'bc00002', type_genre_id_list('ge00001', 'ge00002','ge00003','ge00004'), 'The Da Vinci Code', 'The Da Vinci Code is a mystery thriller novel by Dan Brown. It is Brown''s second novel to include the character Robert Langdon: the first was his 2000 novel Angels & Demons. The Da Vinci Code follows "symbologist" Robert Langdon and cryptologist SophieNeveu after ', TO_DATE('2003-03-18', 'YYYY-MM-DD'), 50.00, 0, 689, 0, 100, 'English', 'Doubleday', '9780385504201', 'https://www.example.com/the_da_vinci_code.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00008', 'au00004', 'bc00002', type_genre_id_list('ge00005', 'ge00006','ge00015','ge00008', 'ge00009','ge00018','ge00007'), 'Angels & Demons', 'Angels & Demons is a 2000 bestselling mystery-thriller novel written by American author Dan Brown and published by Pocket Books and then by Corgi Books. The novel introduces the character Robert Langdon, who recurs as the protagonist of Browns subsequent novels.', TO_DATE('2000-06-01', 'YYYY-MM-DD'), 55.00, 0, 713, 0, 100, 'English', 'Pocket Books', '9780671027360', 'https://www.example.com/angels_and_demons.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00009', 'au00005', 'bc00002', type_genre_id_list('ge00001', 'ge00002','ge00003','ge00004'), 'The Lost Symbol', 'The Lost Symbol is a 2009 novel written by American writer Dan Brown. It is a thriller set in Washington, D.C., after the events of The Da Vinci Code, and relies on Freemasonry for both its recurring theme and its major characters.', TO_DATE('2009-09-15', 'YYYY-MM-DD'), 60.00, 0, 509, 0, 100, 'English', 'Doubleday', '9780385504225', 'https://www.example.com/the_lost_symbol.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00010', 'au00006', 'bc00002', type_genre_id_list('ge00020', 'ge00002','ge00003','ge00004'), 'Inferno', 'Inferno is a 2013 mystery thriller novel by American author Dan Brown and the fourth book in his Robert Langdon series, following Angels & Demons, The Da Vinci Code and The Lost Symbol. The book was published on May 14, 2013, ten years after publication of The Da Vinci Code.', TO_DATE('2013-05-14', 'YYYY-MM-DD'), 65.00, 0, 462, 0, 100, 'English', 'Doubleday', '9780385537858', 'https://www.example.com/inferno.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00011', 'au00007', 'bc00002', type_genre_id_list('ge00001', 'ge00002','ge00020','ge00020'), 'The Hobbit', 'The Hobbit, or There and Back Again is a childrens fantasy novel by English author J. R. R. Tolkien. It was published on 21 September 1937 to wide critical acclaim, being nominated for the Carnegie Medal and awarded a prize from the New York Herald Tribune for best juvenile fiction.', TO_DATE('1937-09-21', 'YYYY-MM-DD'), 70.00, 0, 310, 0, 100, 'English', 'Allen & Unwin', '9780261102217', 'https://www.example.com/the_hobbit.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00012', 'au00007', 'bc00002', type_genre_id_list('ge00015', 'ge00002','ge00003','ge00004', 'ge00001', 'ge00002','ge00020','ge00020'), 'The Lord of the Rings', 'The Lord of the Rings is an epic high-fantasy novel written by English author and scholar J. R. R. Tolkien. The story began as a sequel to Tolkiens 1937 fantasy novel The Hobbit, but eventually developed into a much larger work.', TO_DATE('1954-07-29', 'YYYY-MM-DD'), 75.00, 0, 1178, 0, 100, 'English', 'Allen & Unwin', '9780261102385', 'https://www.example.com/the_lord_of_the_rings.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00013', 'au00008', 'bc00002', type_genre_id_list('ge00020', 'ge00002','ge00003','ge00004'), 'The Way of Kings', 'The Way of Kings is an epic fantasy novel written by American author Brandon Sanderson and the first book in The Stormlight Archive series. The novel was published on August 31, 2010 by Tor Books. The Way of Kings consists of one prelude, one prologue, 75 chapters, an epilogue and 9 interludes.', TO_DATE('2010-08-31', 'YYYY-MM-DD'), 80.00, 0, 1007, 0, 100, 'English', 'Tor Books', '9780765326355', 'https://www.example.com/the_way_of_kings.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00014', 'au00009', 'bc00002', type_genre_id_list('ge00001', 'ge00020','ge00015','ge00020'), 'Mistborn: The Final Empire', 'Mistborn: The Final Empire, also known simply as Mistborn or The Final Empire, is a fantasy novel written by American author Brandon Sanderson. It was published on July 17, 2006 by Tor Books and is the first novel in the Mistborn trilogy.', TO_DATE('2006-07-17', 'YYYY-MM-DD'), 85.00, 0, 541, 0, 100, 'English', 'Tor Books', '9780765311788', 'https://www.example.com/mistborn_the_final_empire.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00015', 'au00010', 'bc00002', type_genre_id_list('ge00001', 'ge00002','ge00003','ge00004'), 'Guards! Guards!', 'Guards! Guards! is a fantasy novel by British writer Terry Pratchett, the eighth in the Discworld series, first published in 1989. It is the first novel about the Ankh-Morpork City Watch.', TO_DATE('1989-11-01', 'YYYY-MM-DD'), 90.00, 0, 376, 0, 100, 'English', 'Gollancz', '9780575065841', 'https://www.example.com/guards_guards.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00016', 'au00011', 'bc00002', type_genre_id_list('ge00020', 'ge00002','ge00003','ge00015'), 'The Colour of Magic', 'The Colour of Magic is a comic fantasy novel by Terry Pratchett, and is the first book of the Discworld series. The first printing of the British edition consisted of only 506 copies.', TO_DATE('1983-11-24', 'YYYY-MM-DD'), 95.00, 0, 288, 0, 100, 'English', 'Colin Smythe', '9780861402032', 'https://www.example.com/the_colour_of_magic.jpg');
INSERT INTO tbl_book (book_id, author_id, category_id, genre_ids, book_title, book_description, book_publish_date, book_price, discontinued, book_pages, book_discount, available_quantity, book_language, book_publisher, book_isbn, book_cover_image) VALUES ('bo00017', 'au00012', 'bc00002', type_genre_id_list('ge00020', 'ge00002','ge00003','ge00015'), 'The Light Fantastic', 'The Light Fantastic is a comic fantasy novel by Terry Pratchett, the second of the Discworld series. It was published on June 2, 1986, the first printing being of 1,034 copies.', TO_DATE('1986-06-02', 'YYYY-MM-DD'), 100.00, 0, 288, 0, 100, 'English', 'Gollancz', '9780575070708', 'https://www.example.com/the_light_fantastic.jpg');

-- Insert records into tbl_customer
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00001', 'John Doe', 'john.doe@example.com', '+1234567890',  '$2y$10$placeholderhash1');
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00002', 'Jane Smith', 'jane.smith@email.com', '+4567890123', '$2y$10$placeholderhash2');
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00003', 'Olivia Garcia', 'olivia.garcia@webmail.com', '+7890123456', '$2y$10$placeholderhash3');
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00004', 'William Chen', 'william.chen@hotmail.com', '+9876543210', '$2y$10$placeholderhash4');
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00005', 'Sophia Nguyen', 'sophia.nguyen@gmail.com', '+1122334455', '$2y$10$placeholderhash5');
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00006', 'Liam Brown', 'liam.ssp@gmail.com', '+9988776655', '$2y$10$placeholderhash6');
INSERT INTO tbl_customer (customer_id, customer_name, customer_email, customer_phone1, password_hash) VALUES ('cu00007', 'Emma Wilson', 'emma.wilson@gmail.com', '+1122334455', '$2y$10$placeholderhash7');

-- Insert into tbl_customer_address
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00001', 'Home', 'cu00001', '123 Main St', 'Anytown', 'CA', 'USA', '94102');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00002', 'Work', 'cu00001', '123 abc St', 'Downtown', 'CA', 'USA', '94103');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00003', 'Office', 'cu00001', '123 xyz St', 'Uptown', 'CA', 'USA', '94101');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, address_line2, city, state, country, postalcode) VALUES ('ca00004', 'Other', 'cu00001', '456 Elm St', 'Apt. 2B', 'Springfield', 'NY', 'USA', '10001');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode, landmark) VALUES ('ca00005', 'Other', 'cu00004', '1213 Pine Rd', 'Sunnyvale', 'CA', 'USA', '94086', 'Near Central Park');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, address_line2, address_line3, city, state, country, postalcode) VALUES ('ca00006', 'Work', 'cu00005', '1415 Cedar St', 'Apt. 3C', 'Building 4', 'Palo Alto', 'CA', 'USA', '94301');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00007', 'Home', 'cu00006', '1617 Birch St', 'Mountain View', 'CA', 'USA', '94040');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00008', 'Office', 'cu00007', '1819 Ash St', 'Los Altos', 'CA', 'USA', '94022');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00009', 'Office', 'cu00002', '789 Maple Ave', 'Metropolis', 'IL', 'USA', '60601');
INSERT INTO tbl_customer_address (customer_address_id, address_type, customer_id, address_line1, city, state, country, postalcode) VALUES ('ca00010', 'Home', 'cu00003', '1011 Oak Blvd', 'Centerville', 'TX', 'USA', '78750');

-- Insert into tbl_subscription
INSERT INTO tbl_subscription (subscription_status_id, subscription_name, subscription_description, subscription_price, subscription_duration, subscription_discount_on_order) VALUES ('su00001', 'Gold', 'Great', 249.00, '9', 0.6);
INSERT INTO tbl_subscription (subscription_status_id, subscription_name, subscription_description, subscription_price, subscription_duration, subscription_discount_on_order) VALUES ('su00002', 'Silver', 'Better', 199.00, '6', 0.35);
INSERT INTO tbl_subscription (subscription_status_id, subscription_name, subscription_description, subscription_price, subscription_duration, subscription_discount_on_order) VALUES ('su00003', 'Bronze', 'Ok', 149.00, '3', 0.05);
INSERT INTO tbl_subscription (subscription_status_id, subscription_name, subscription_description, subscription_price, subscription_duration, subscription_discount_on_order) VALUES ('su00004', 'Free', 'Ok', 0.00, '0', 0.0);

-- Insert into tbl_subscription_log_history
INSERT INTO tbl_subscription_log_history (subscription_log_id, customer_id, subscription_status_id, subscription_start_date, subscription_end_date) VALUES ('sl00001', 'cu00001', 'su00002', SYSDATE, SYSDATE + INTERVAL '6' MONTH);  -- Estimate 6 months
INSERT INTO tbl_subscription_log_history (subscription_log_id, customer_id, subscription_status_id, subscription_start_date, subscription_end_date) VALUES ('sl00002', 'cu00002', 'su00001', TO_DATE('2024-02-15', 'YYYY-MM-DD'), TO_DATE('2024-02-15', 'YYYY-MM-DD') + INTERVAL '9' MONTH);
INSERT INTO tbl_subscription_log_history (subscription_log_id, customer_id, subscription_status_id, subscription_start_date, subscription_end_date) VALUES ('sl00003', 'cu00003', 'su00003', TO_DATE('2024-03-05', 'YYYY-MM-DD'), TO_DATE('2024-03-05', 'YYYY-MM-DD') + INTERVAL '3' MONTH);
INSERT INTO tbl_subscription_log_history (subscription_log_id, customer_id, subscription_status_id, subscription_start_date, subscription_end_date) VALUES ('sl00004', 'cu00003', 'su00003', TO_DATE('2023-02-05', 'YYYY-MM-DD'), TO_DATE('2023-02-05', 'YYYY-MM-DD') + INTERVAL '3' MONTH);

-- Insert into tbl_shopping_cart
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00001', 'bo00001', 2);
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00001', 'bo00005', 1);
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00001', 'bo00007', 3);
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00002', 'bo00003', 1);
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00003', 'bo00002', 3);
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00004', 'bo00004', 4);
INSERT INTO tbl_shopping_cart (customer_id, book_id, quantity) VALUES ('cu00005', 'bo00006', 5);
-- Insert into tbl_wishlist
INSERT INTO tbl_wishlist (customer_wishlist_id, customer_id, wishlist_name, wishlist_description, wishlist_image) VALUES ('wi00001', 'cu00001', 'Spring Reads', 'LoremIpsum()', 'REPLACE_IMAGE_URL_1');  -- Random description using Lorem Ipsum function
INSERT INTO tbl_wishlist (customer_wishlist_id, customer_id, wishlist_name, wishlist_description, wishlist_image) VALUES ('wi00002', 'cu00001', 'Sci-Fi Exploration', 'LoremIpsum()', 'REPLACE_IMAGE_URL_5');
INSERT INTO tbl_wishlist (customer_wishlist_id, customer_id, wishlist_name, wishlist_description, wishlist_image) VALUES ('wi00001', 'cu00002', 'Gift Ideas', 'Books for upcoming birthdays (friends and family)', 'REPLACE_IMAGE_URL_2');
INSERT INTO tbl_wishlist (customer_wishlist_id, customer_id, wishlist_name, wishlist_description, wishlist_image) VALUES ('wi00002', 'cu00002', 'Mystery Thriller', 'LoremIpsum()', 'REPLACE_IMAGE_URL_6');
INSERT INTO tbl_wishlist (customer_wishlist_id, customer_id, wishlist_name, wishlist_description, wishlist_image) VALUES ('wi00001', 'cu00003', 'Fantasy Adventure', 'LoremIpsum()', 'REPLACE_IMAGE_URL_3');
INSERT INTO tbl_wishlist (customer_wishlist_id, customer_id, wishlist_name, wishlist_description, wishlist_image) VALUES ('wi00002', 'cu00003', 'Technology Reads', 'LoremIpsum()', 'REPLACE_IMAGE_URL_4');

-- Insert into tbl_wishlist_item
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00001', 'cu00001', 'bo00007');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00001', 'cu00001', 'bo00002');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00001', 'cu00001', 'bo00008');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00002', 'cu00001', 'bo00005');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00002', 'cu00001', 'bo00006');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00002', 'cu00001', 'bo00007');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00002', 'cu00001', 'bo00017');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00001', 'cu00002', 'bo00004');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00002', 'cu00002', 'bo00006');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00001', 'cu00003', 'bo00001');
INSERT INTO tbl_wishlist_item (customer_wishlist_id, customer_id, book_id) VALUES ('wi00002', 'cu00003', 'bo00003');


-- Insert into tbl_user_review
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00001', 'cu00002', 4.4, 'I enjoyed the overall story, but I felt the ending was a bit rushed.  Would recommend with a caveat about the ending.', SYSDATE - INTERVAL '3' DAY);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00002', 'cu00001', 3.5, 'This book was absolutely captivating! The storyline kept me engaged from beginning to end, and the characters were well-developed and relatable. I highly recommend it to anyone who enjoys [genre of the book]', SYSDATE);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00003', 'cu00002', 4.2, 'I found the plot to be predictable and the characters to be one-dimensional. I would not recommend this book to others.', SYSDATE - INTERVAL '2' DAY);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00004', 'cu00003', 3.3, 'The writing style was engaging, but the plot lacked some originality.', SYSDATE - INTERVAL '5' DAY);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00005', 'cu00001', 4.4, 'A thought-provoking read that left me wanting more. The characters were complex and the themes were relevant.', SYSDATE - INTERVAL '7' DAY);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00006', 'cu00002', 3.5, 'I loved this book! The world-building was fantastic and the characters were so well-developed. I can''t wait to read the next book in the series.', SYSDATE - INTERVAL '9' DAY);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00007', 'cu00003', 4.2, 'I found the plot to be predictable and the characters to be one-dimensional. I would not recommend this book to others.', SYSDATE - INTERVAL '11' DAY);
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00008', 'cu00001', 3.3, 'The writing style was engaging, but the plot lacked some originality.', SYSDATE - INTERVAL '13' DAY);




DELETE FROM tbl_user_review WHERE book_id = 'bo00009' AND customer_id = 'cu00002';
INSERT INTO tbl_user_review (book_id, customer_id, book_rating, book_review, review_date) VALUES ('bo00009', 'cu00002', 4.4, 'A thought-provoking read that left me wanting more. The characters were complex and the themes were relevant.', SYSDATE - INTERVAL '15' DAY);



UPDATE tbl_author
SET author_score = calculate_average_author_score('bo00009')
WHERE author_id = (SELECT author_id FROM tbl_book WHERE book_id = 'bo00009');

SELECT * FROM tbl_author;

SELECT * FROM TBL_USER_REVIEW;



-- Insert into tbl_orders
INSERT INTO tbl_orders (order_id, customer_id, address_type, order_date, order_discount, order_status) VALUES ('or00001', 'cu00001', 'Home', TO_DATE('2024-03-05', 'YYYY-MM-DD'), 0.10, 'processing');  -- Assuming 10% discount
INSERT INTO tbl_orders (order_id, customer_id, address_type, order_date, order_discount, order_status) VALUES ('or00002', 'cu00002', 'Office', SYSDATE, 0.05, 'awaiting_payment');  -- Assuming 5% discount
INSERT INTO tbl_orders (order_id, customer_id, address_type, order_date, order_discount, order_status) VALUES ('or00003', 'cu00003', 'Home', SYSDATE, 0, 'created');
INSERT INTO tbl_orders (order_id, customer_id, address_type, order_date, order_discount, order_status) VALUES ('or00004', 'cu00001', 'Home', SYSDATE - INTERVAL '2' DAY, 0.15, 'shipped');  -- Assuming 15% discount, 2 days ago
INSERT INTO tbl_orders (order_id, customer_id, address_type, order_date, order_discount, order_status) VALUES ('or00005', 'cu00002', 'Office', SYSDATE - INTERVAL '4' DAY, 0.07, 'completed');  -- Assuming 7% discount, 4 days ago

-- Insert into tbl_order_detail
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00001', 'bo00005', 12.45, 2);  -- 2 copies of book B00007
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00001', 'bo00002', 18.99, 1);  -- 1 copy of book B00002
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00002', 'bo00003', 8.99, 1);  -- 1 copy of book B00003
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00003', 'bo00004', 10.99, 1);  -- 1 copy of book B00004
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00004', 'bo00001', 15.25, 1);  -- 1 copy of book B00001
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00005', 'bo00005', 9.75, 2);  -- 2 copies of book B00005
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00005', 'bo00001', 11.50, 1);  -- 1 copy of book B00009 



SELECT * FROM tbl_author;
SELECT * FROM tbl_book_category;
SELECT * FROM tbl_genre;
SELECT * FROM tbl_book;
SELECT * FROM tbl_customer;
SELECT * FROM tbl_customer_address;
SELECT * FROM tbl_subscription;
SELECT * FROM tbl_subscription_log_history;
SELECT * FROM tbl_shopping_cart;
SELECT * FROM tbl_wishlist;
SELECT * FROM tbl_wishlist_item;
SELECT * FROM tbl_user_review;
SELECT * FROM tbl_orders;
SELECT * FROM tbl_order_detail;

/

-- Function to calculate the average author score
CREATE OR REPLACE FUNCTION calculate_average_author_score(
    prc_author_id IN tbl_author.author_id%TYPE,
    prc_book_rating IN tbl_user_review.book_rating%TYPE
) RETURN tbl_author.author_score%TYPE 
IS
    var_author_score tbl_author.author_score%TYPE;
    var_sum_rating NUMBER := 0;
    var_count NUMBER := 0;
BEGIN

    SELECT SUM(book_rating), COUNT(book_rating)
    INTO var_sum_rating, var_count
    FROM tbl_user_review
    WHERE book_rating IS NOT NULL
        AND book_id IN (SELECT book_id FROM tbl_book WHERE author_id = prc_author_id);
    
    IF var_sum_rating IS NULL THEN
        var_sum_rating := 0;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Sum: ' || var_sum_rating || ' Count: ' || var_count);

    var_author_score := (var_sum_rating + prc_book_rating)/(var_count + 1);

    RETURN var_author_score;
END calculate_average_author_score;
/



-- Trigger to update the author score
CREATE OR REPLACE TRIGGER trg_update_author_score
BEFORE INSERT ON tbl_user_review
FOR EACH ROW
DECLARE
    var_author_id tbl_author.author_id%TYPE;
    var_author_score tbl_author.author_score%TYPE;
BEGIN
    SELECT author_id
    INTO var_author_id
    FROM tbl_book
    WHERE book_id = :NEW.book_id;

    var_author_score := calculate_average_author_score(var_author_id, :NEW.book_rating);

    UPDATE tbl_author
    SET author_score = var_author_score
    WHERE author_id = var_author_id;
END trg_update_author_score;
/




SELECT author_id, author_score FROM tbl_author;

UPDATE tbl_user_review
SET book_rating = 4.5
WHERE book_id = 'bo00009' AND customer_id = 'cu00002';




-- Trigger to check the order quantity
CREATE OR REPLACE TRIGGER trg_check_order_quantity
BEFORE INSERT ON tbl_order_detail
FOR EACH ROW
DECLARE
    var_available_quantity tbl_book.available_quantity%TYPE;
    var_book_id tbl_book.book_id%TYPE;
    var_order_quantity tbl_order_detail.quantity%TYPE;
BEGIN
    SELECT available_quantity
    INTO var_available_quantity
    FROM tbl_book
    WHERE book_id = :NEW.book_id;

    IF var_available_quantity < :NEW.quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 'The quantity ordered is more than the available quantity');
    END IF;

    UPDATE tbl_book
    SET available_quantity = var_available_quantity - :NEW.quantity
    WHERE book_id = :NEW.book_id;
END trg_check_order_quantity;
/

-- -- create a triggere on ck_order_detail_quantity update available_quantity in tbl_book
-- CREATE OR REPLACE TRIGGER trg_update_available_quantity
-- AFTER UPDATE ON tbl_order_detail
-- FOR EACH ROW
-- DECLARE
--     var_available_quantity tbl_book.available_quantity%TYPE;
--     var_book_id tbl_book.book_id%TYPE;
--     var_order_quantity tbl_order_detail.quantity%TYPE;
-- BEGIN
--     SELECT available_quantity
--     INTO var_available_quantity
--     FROM tbl_book
--     WHERE book_id = :NEW.book_id;


-- END trg_update_available_quantity;


select * from tbl_order_detail where order_id = 'or00001';
-- test above Code



DELETE FROM tbl_order_detail WHERE order_id = 'or00001' AND book_id = 'bo00007';
DELETE FROM tbl_order_detail WHERE order_id = 'or00002' AND book_id = 'bo00007';
DELETE FROM tbl_order_detail WHERE order_id = 'or00003' AND book_id = 'bo00007';


select book_id, available_quantity from tbl_book where book_id = 'bo00007';
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00001', 'bo00007', 12.45, 20);
select book_id, available_quantity from tbl_book where book_id = 'bo00007';
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00002', 'bo00007', 12.45, 50);
select book_id, available_quantity from tbl_book where book_id = 'bo00007';
INSERT INTO tbl_order_detail (order_id, book_id, book_price, quantity) VALUES ('or00003', 'bo00007', 12.45, 70);
select book_id, available_quantity from tbl_book where book_id = 'bo00007';


update tbl_book
set available_quantity = 100
where book_id = 'bo00007';




CREATE OR REPLACE FUNCTION get_customer_wishlist(
    p_customer_id IN VARCHAR2
)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
    SELECT wi.book_id, b.book_title
    FROM tbl_wishlist_item wi
    JOIN tbl_book b ON wi.book_id = b.book_id
    WHERE wi.customer_id = p_customer_id;

    RETURN v_cursor;
END;
/



-- TRIGGER TO AUTO FILL things
