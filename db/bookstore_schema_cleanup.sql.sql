/*
File: bookstore_schema_cleanup.sql
Description: SQL script to drop all tables and types for the production-level Bookstore database.
Author: @Ayon-SSP
Date Created: 2024-03-07
*/

-- Drop table for storing order details
DROP TABLE order_detail;

-- Drop table for storing orders
DROP TABLE orders;

-- Drop table for storing user reviews
DROP TABLE user_review;

-- Drop table for storing wishlists
DROP TABLE wishlist;

-- Drop table for storing shopping cart items
DROP TABLE shopping_cart;

-- Drop table for storing subscription log history
DROP TABLE subscription_log_history;

-- Drop table for storing subscription information
DROP TABLE subscription;

-- Drop table for storing customer addresses
DROP TABLE customer_address;

-- Drop table for storing customer information
DROP TABLE customer;

-- Drop table for storing book information
DROP TABLE book;

-- Drop user-defined type for genre IDs list
DROP TYPE genre_id_list;

-- Drop table for storing book genres
DROP TABLE genre;

-- Drop table for storing book categories
DROP TABLE book_category;

-- Drop table for storing author information
DROP TABLE author;