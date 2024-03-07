/*
File: bookstore_truncate_tables.sql
Description: SQL script to truncate all tables for the Bookstore database.
Author: @Ayon-SSP
Date Created: 2024-03-07
*/

-- Truncate table for storing order details
TRUNCATE TABLE tbl_order_detail;

-- Truncate table for storing orders
TRUNCATE TABLE tbl_orders;

-- Truncate table for storing user reviews
TRUNCATE TABLE tbl_user_review;

-- Truncate table for storing wishlists
TRUNCATE TABLE tbl_wishlist;

-- Truncate table for storing shopping cart items
TRUNCATE TABLE tbl_shopping_cart;

-- Truncate table for storing subscription log history
TRUNCATE TABLE tbl_subscription_log_history;

-- Truncate table for storing subscription information
TRUNCATE TABLE tbl_subscription;

-- Truncate table for storing customer addresses
TRUNCATE TABLE tbl_customer_address;

-- Truncate table for storing customer information
TRUNCATE TABLE tbl_customer;

-- Truncate table for storing book information
TRUNCATE TABLE tbl_book;

-- Truncate table for storing book genres
TRUNCATE TABLE tbl_genre;

-- Truncate table for storing book categories
TRUNCATE TABLE tbl_book_category;

-- Truncate table for storing author information
TRUNCATE TABLE tbl_author;
