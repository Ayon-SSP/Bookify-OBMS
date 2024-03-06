/*
File: bookstore_truncate_tables.sql
Description: SQL script to truncate all tables for the Bookstore database.
Author: @Ayon-SSP
Date Created: 2024-03-07
*/

-- Truncate table for storing order details
TRUNCATE TABLE order_detail;

-- Truncate table for storing orders
TRUNCATE TABLE orders;

-- Truncate table for storing user reviews
TRUNCATE TABLE user_review;

-- Truncate table for storing wishlists
TRUNCATE TABLE wishlist;

-- Truncate table for storing shopping cart items
TRUNCATE TABLE shopping_cart;

-- Truncate table for storing subscription log history
TRUNCATE TABLE subscription_log_history;

-- Truncate table for storing subscription information
TRUNCATE TABLE subscription;

-- Truncate table for storing customer addresses
TRUNCATE TABLE customer_address;

-- Truncate table for storing customer information
TRUNCATE TABLE customer;

-- Truncate table for storing book information
TRUNCATE TABLE book;

-- Truncate table for storing book genres
TRUNCATE TABLE genre;

-- Truncate table for storing book categories
TRUNCATE TABLE book_category;

-- Truncate table for storing author information
TRUNCATE TABLE author;
