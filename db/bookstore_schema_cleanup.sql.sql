/*
File: bookstore_schema_cleanup.sql
Description: SQL script to drop all tables and types for the production-level Bookstore database.
Author: @Ayon-SSP
Date Created: 2024-03-07
*/

-- Drop table for storing order details
DROP TABLE tbl_order_detail;

-- Drop table for storing orders
DROP TABLE tbl_orders;

-- Drop table for storing user reviews
DROP TABLE tbl_user_review;

-- Drop table for storing wishlists
DROP TABLE tbl_wishlist;

-- Drop table for storing shopping cart items
DROP TABLE tbl_shopping_cart;

-- Drop table for storing subscription log history
DROP TABLE tbl_subscription_log_history;

-- Drop table for storing subscription information
DROP TABLE tbl_subscription;

-- Drop table for storing customer addresses
DROP TABLE tbl_customer_address;

-- Drop table for storing customer information
DROP TABLE tbl_customer;

-- Drop table for storing book information
DROP TABLE tbl_book;

-- Drop user-defined type for genre IDs list
DROP TYPE tbl_genre_id_list;

-- Drop table for storing book genres
DROP TABLE tbl_genre;

-- Drop table for storing book categories
DROP TABLE tbl_book_category;

-- Drop table for storing author information
DROP TABLE tbl_author;