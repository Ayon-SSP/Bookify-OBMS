/*
File: bookstore_schema_definition.sql
Description: SQL script to create tables for the Bookstore database.
Author: @Ayon-SSP
Date Created: 2024-03-07
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
    CHECK (REGEXP_LIKE(customer_id, 'cu[0-9]{5}')),
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
    book_id VARCHAR2(10) NOT NULL,
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
    ON DELETE CASCADE,
CONSTRAINT fk_wishlist_book 
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
