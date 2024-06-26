## ER Diagram
```
1. check all not null, `check` constraints and `unique` constraints
2. check all foreign keys & primary keys
3. check all unique constraints
4. check id datatypes
5. there are many mistakes 


FORMAT SQL OBJECT FILE
change NUMBER -> VARCHAR2(10) for id's
CHECK REGEXP FOR ID'S
```

### author
- author_id [PK]
- author_name
- author_bio
- author_score
-    [auto calculate average ratings of all books]
- author_image
- author_birth_date
  - Optional:
    - author_email
    - author_death_date
    - author_country

```sql
CREATE TABLE author 
( 
  author_id  NUMBER NOT NULL, 
  author_name  VARCHAR2(50) NOT NULL, 
  author_bio  VARCHAR2(300), 
  author_score NUMBER, 
  author_image  VARCHAR2(255),
  author_birth_date DATE,
CONSTRAINT PK_author 
  PRIMARY KEY (author_id)
CONSTRAINT CK_author_score   CHECK ((author_score >= 0 AND author_score <= 5))
) 
/

-- CREATE A TRIGGER ON USER_REVIEW TABLE SO WHEN A NEW ROCORD IS INSERTED, UPDATED AND DELETED  INTO THE TABLE, THE AUTHOR_SCORE IS UPDATED.(For this we will create a main package for calculation and in that package we will create a function to calulate average_author_rating and then we will create an insert trigger to calculate the average_author_rating when a new record is inserted into the user_review table by calling the function from that package.)

```

### book_category
- category_id [PK]
- category_name (like magazine, novel, etc)
- category_description
  - Optional:
    - category_image

```sql
CREATE TABLE book_category 
( 
  category_id  NUMBER NOT NULL, 
  category_name  VARCHAR2(50) NOT NULL, 
  category_description  VARCHAR2(300), 
  category_image  VARCHAR2(255),
CONSTRAINT PK_book_category
  PRIMARY KEY (category_id),
)
/ 

```

### genre
- genre_id [PK]
- genre_name
- genre_description
- genre_image
  - Optional:

```sql
CREATE TABLE genre 
( 
  genre_id  NUMBER GENERATED BY DEFAULT AS IDENTITY
    START WITH 101 NOT NULL, 
  genre_name  VARCHAR2(50) NOT NULL, 
  genre_description  VARCHAR2(300), 
  genre_image  VARCHAR2(255), 
CONSTRAINT PK_genre 
  PRIMARY KEY (genre_id)
) 
/ 
```

### book
- book_id [PK]
- book_title 
- book_description
- book_publish_date
- author_id [FK-> author.author_id]
- category_id [FK-> book_category.category_id]
- book_price [check >=0]
- book_discount [0.0 - 1.0]
- available_quantity [check >=0] 
- discontinued [Default: false]
- book_cover_image
- book_publisher
- book_language
- book_pages
- book_isbn
  - Optional:
    - book_rating
    - total_book_reviews

-- 

```SQL
CREATE OR REPLACE 
  TYPE genre_id_list AS TABLE OF NUMBER; -- Define a nested table type for genre IDs

CREATE TABLE book 
( 
  book_id  NUMBER NOT NULL, 
  book_title  VARCHAR2(40) NOT NULL, 
  book_description  VARCHAR2(300),
  book_publish_date  DATE, 
  author_id  NUMBER NOT NULL, 
  category_id  NUMBER NOT NULL,
  genre_ids  genre_id_list, -- Define the column as the nested table type
  book_price  NUMBER, 
  book_discount  NUMBER(1) DEFAULT 0 NOT NULL,
  available_quantity  NUMBER, 
  discontinued  NUMBER(1) NOT NULL,
  book_cover_image VARCHAR2(255), 
  book_publisher VARCHAR2(100),
  book_language VARCHAR2(100),
  book_pages NUMBER,
  book_isbn VARCHAR2(13) UNIQUE,
CONSTRAINT PK_book 
  PRIMARY KEY (book_id), 
CONSTRAINT CK_book_book_price   CHECK ((book_price > 0)), 
CONSTRAINT CK_book_discount   CHECK ((book_discount >= 0 AND book_discount <= 1)),
CONSTRAINT CK_book_pages   CHECK ((book_pages >= 0)), 
CONSTRAINT CK_discontinued   CHECK ((discontinued = 0 or discontinued = 1)),
CONSTRAINT CK_available_quantity   CHECK ((available_quantity >= 0)), 
CONSTRAINT FK_book_author FOREIGN KEY (author_id) REFERENCES author(author_id), 
CONSTRAINT FK_book_category FOREIGN KEY (category_id) REFERENCES book_category(category_id)
) 
/ 

DECLARE
  v_genre_ids genre_id_list;
BEGIN
  -- Initialize the genre IDs for a specific book
  v_genre_ids := genre_id_list(1, 3, 5); -- Example genre IDs
  
  -- Insert data into the book table
  INSERT INTO book (
    book_id,
    book_title,
    book_description,
    book_publish_date,
    author_id,
    category_id,
    genre_ids,
    book_price,
    available_quantity,
    discontinued,
    book_cover_image,
    book_publisher,
    book_language,
    book_pages,
    book_isbn
  ) VALUES (
    1, -- Example book_id
    'Example Book Title',
    'This is an example book description.',
    TO_DATE('2024-03-05', 'YYYY-MM-DD'), -- Example publish date
    1, -- Example author_id
    1, -- Example category_id
    v_genre_ids, -- Use the variable containing genre IDs
    10.99, -- Example book price
    100, -- Example available quantity
    0, -- Example discontinued
    'example_cover_image.jpg',
    'Example Publisher',
    'English',
    250, -- Example number of pages
    '9781234567890' -- Example ISBN
  );
END;
/




-- OTHER EXAMPLES TO INSERT

--   write a simple plsql code to create and insert where using PL/SQL Nested Tables a table contains a column of nested table type. 
-- 

CREATE OR REPLACE TYPE nested_table AS TABLE OF VARCHAR2(100);
/

CREATE TABLE employees (
  employee_id NUMBER,
  employee_name VARCHAR2(100),
  employee_address nested_table
)
NESTED TABLE employee_address STORE AS employee_address_tab;

INSERT INTO employees VALUES (1, 'John', nested_table('Address1', 'Address2'));
INSERT INTO employees VALUES (2, 'Smith', nested_table('Address3', 'Address4'));


```

TODO: suggest subscription names
### subscription - ⚠️ suggest a table name
- subscription_status_id (1, 2, 3 ...)
- subscription_name (Gold, Silver, Bronze ...) TODO: suggest subscription names (royalmember, )
- subscription_description (description about the subscription type)
- subscription_price   (149, 199, 249 ...)
- subscription_duration (3M, 6M, 12M) x all are of 1M
- subscription_discount (0.1, 0.2, 0.3)  - 10%, 20%, 30%
  - Optional:

```sql
CREATE TABLE subscription 
( 
  subscription_status_id NUMBER NOT NULL, 
  subscription_name  VARCHAR2(30),
  subscription_description VARCHAR2(300), 
  subscription_price NUMBER,
  subscription_duration VARCHAR2(3),
  subscription_discount NUMBER(1, 2),
CONSTRAINT PK_subscription 
  PRIMARY KEY (subscription_status_id),
CONSTRAINT CK_subscription_price   CHECK ((subscription_price > 0)),
CONSTRAINT CK_subscription_discount   CHECK ((subscription_discount >= 0 AND subscription_discount <= 1))
) 
/ 
```


### customer
- customer_id  [PK]
- customer_name
- customer_email
- customer_phone1
- customer_phone2
- password_hash
<!-- - premium_expire_date -->
<!-- - subscription_status_id  [FK-> subscription.subscription_status_id] -->
  - Optional:
    - join_date
    - subscription_expire_date


```sql
CREATE TABLE customer
( 
  customer_id  NUMBER NOT NULL, 
  customer_name  VARCHAR2(30),
  customer_email VARCHAR2(100), 
  customer_phone1  VARCHAR2(24) NOT NULL, 
  customer_phone2  VARCHAR2(24), 
  password_hash VARCHAR2(100),
  -- subscription_status_id NUMBER NOT NULL,
  -- premium_expire_date DATE,
CONSTRAINT PK_customer 
  PRIMARY KEY (customer_id),
-- CONSTRAINT FK_customer_customer_address FOREIGN KEY (subscription_status_id) REFERENCES customer_address(subscription_status_id)
) 
/ 

-- need to update the subscription_expire_date when the premium_expire_date is expired
```


### customer_address 
- customer_address_id [/PK]              customer_address_id -> (customer_id, address_type)
- address_type (home, office, etc)   [PK]
- customer_id [FK-> customer.customer_id]  [PK]
- address_line1 [not null]
- address_line2
- address_line3
- city
- state [not null]
- country
- pincode (or postalcode) [not null] - ⚠️ suggest a name
- landmark
- phone [not null]
  - Optional:
    - country


```sql
CREATE TABLE customer_address (
    address_type VARCHAR2(16) NOT NULL,
    customer_id  NUMBER NOT NULL, 
    address_line1 VARCHAR2(255),
    address_line2 VARCHAR2(255),
    address_line3 VARCHAR2(255),
    city VARCHAR2(100),
    state VARCHAR2(100),
    country VARCHAR2(100),
    postalcode VARCHAR2(6),
    landmark VARCHAR2(255),
    phone VARCHAR2(24), 
CONSTRAINT PK_customer_address 
  PRIMARY KEY (address_type, customer_id), 
CONSTRAINT FK_customer_address_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
)
/

-- triggere if phone is null then set phone = customer.phone
```


### subscription_log_history
- subscription_log_id [PK]
- customer_id [FK-> customer.customer_id] 
- subscription_status_id [FK-> subscription.subscription_status_id] 
- subscription_start_date -- sysdate
- subscription_end_date -- sysdate + 6M
  - Optional:
    - subscription_cancel_date
    - subscription_cancel_reason

```sql
CREATE TABLE subscription_log_history
( 
    subscription_log_id  NUMBER NOT NULL, 
    customer_id  NUMBER NOT NULL, 
    subscription_status_id  VARCHAR2(10) NOT NULL, 
    subscription_start_date DATE,
    subscription_end_date DATE,
CONSTRAINT PK_subscription_log_history
    PRIMARY KEY (subscription_log_id),
CONSTRAINT FK_subscription_log_history_customer
    FOREIGN KEY (customer_id) 
    REFERENCES customer(customer_id)
    ON DELETE CASCADE,
CONSTRAINT FK_subscription_log_history_subscription
    FOREIGN KEY (subscription_status_id) 
    REFERENCES subscription(subscription_status_id)
    ON DELETE CASCADE
)
/
```


<!-- Customers browse the bookstore website and add books to their shopping cart. -->
### shopping_cart
- customer_id [FK-> customer.customer_id] [PK]
- book_id [FK-> book.book_id] [PK]
- quantity
  - Optional:
    - added_date
    - removed_date

```sql  
CREATE TABLE shopping_cart 
(
  customer_id  NUMBER NOT NULL, 
  book_id  NUMBER NOT NULL, 
  quantity  NUMBER NOT NULL,
CONSTRAINT PK_shopping_cart
  PRIMARY KEY (customer_id, book_id),
CONSTRAINT CK_quantity   CHECK ((quantity > 0)),
CONSTRAINT FK_shopping_cart_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
CONSTRAINT FK_shopping_cart_book FOREIGN KEY (book_id) REFERENCES book(book_id)
)
/
```


### wishlist
- customer_id [FK-> customer.customer_id] [PK]
- customer_wishlist_id [PK]     
- book_id [FK-> book.book_id] [PK]
- wishlist_name
- wishlist_description
- wishlist_image
- date_added
- removed_date
  - Optional:

```sql
CREATE TABLE wishlist 
( 
  customer_id  NUMBER NOT NULL, 
  customer_wishlist_id  NUMBER NOT NULL, 
  book_id  NUMBER NOT NULL,
  wishlist_name VARCHAR2(50),
  wishlist_description VARCHAR2(300),
  wishlist_image VARCHAR2(255),
  date_added DATE,
  removed_date DATE,
CONSTRAINT PK_wishlist
  PRIMARY KEY (customer_id, customer_wishlist_id, book_id),
CONSTRAINT FK_wishlist_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
CONSTRAINT FK_wishlist_book FOREIGN KEY (book_id) REFERENCES book(book_id)
)
/

```


### user_review
- book_id [FK-> book.book_id] [PK]
- customer_id [FK-> customer.customer_id] [PK]
- book_rating [0-5]
- book_review
- review_date
  - Optional:
    - user_liked  (-1, 0, 1) (disliked, neutral, liked)
  
```sql
CREATE TABLE user_review 
( 
  book_id  NUMBER NOT NULL, 
  customer_id  NUMBER NOT NULL, 
  book_rating  NUMBER(1, 1), 
  book_review  VARCHAR2(300), 
  review_date DATE,
CONSTRAINT PK_book_rating
  PRIMARY KEY (book_id, customer_id),
CONSTRAINT CK_book_rating   CHECK ((book_rating >= 0 and book_rating <= 5)),
CONSTRAINT FK_book_rating_book FOREIGN KEY (book_id) REFERENCES book(book_id),
CONSTRAINT FK_book_rating_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
)
/ 

```

### order              
> 🤖-> from shopping cart
- order_id [PK]
- customer_id [FK-> customer.customer_id]
- address_type (customer_id & customer_address_type) -> Delivery Address   [FK-> customer_addressaddress_type]
- order_date [auto calculated current date]
- shipped_date (basic algorithm to calculate the shipping date)
- order_discount (applying discount by customer's subscription status) (initial random data insertion) "function" to calculate the total price with discount with 10 or 20% discount [auto calculated SUM(order_detail.book_price) WHERE order_id = order_detail.order_id]
- order_total_cost (calculating with the book_price & book_discount) [auto calculated/PLSQL]
                    - ( SUM(order_detail.book_price * (1 - order_detail.book_discount) * order_detail.quantity) * (1 - order_discount) ) WHERE order_id = order.order_id   `Order Processing (point 2`
- order_status (pending, processing, shipped, delivered, cancelled, returned, etc.)
  - Optional:
    - required_date
    -  salesman_id


```sql
CREATE TABLE order 
( 
  order_id  NUMBER NOT NULL, 
  customer_id  NUMBER NOT NULL,
  address_type VARCHAR2(16) NOT NULL, 
  order_date  DATE, 
  shipped_date  DATE,
  order_discount NUMBER NOT NULL, -- get from customer subscription status
  order_total_cost NUMBER,  -- this will be calculated 
  order_status VARCHAR2(16),
CONSTRAINT PK_order 
  PRIMARY KEY (order_id), 
CONSTRAINT FK_order_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id), 
CONSTRAINT FK_order_customer FOREIGN KEY (address_type) REFERENCES customer_address(address_type),
CONSTRAINT CK_order_discount   CHECK ((order_discount >= 0 AND order_discount <= 1)),
CONSTRAINT CK_order_total_cost   CHECK ((order_total_cost >= 0))
) 
-- create a insert trigger to calculate the order_total_cost -> cancelled
```


### order_detail
- order_id [FK-> order.order_id] [PK]
- book_id [FK-> book.book_id] [PK]
- book_price [auto calculated book.book_price] 
- quantity
  - Optional:

```sql
CREATE TABLE order_detail 
( 
  order_id  NUMBER NOT NULL, 
  book_id  NUMBER NOT NULL, 
  book_price  NUMBER NOT NULL, 
  quantity  NUMBER NOT NULL, 
CONSTRAINT PK_order_detail 
  PRIMARY KEY (order_id, book_id), 
CONSTRAINT CK_book_price   CHECK ((book_price >= 0)), 
CONSTRAINT CK_quantity   CHECK ((quantity > 0)), 
CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (order_id) REFERENCES order(order_id), 
CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (book_id) REFERENCES book(book_id)
)

-- create a insert trigger to calculate the book_price
-- create a avalable stock count trigger
-- create a update trigger to update the available stock count -...
```

## Ignore
- Publishers(Optional)

Id's starts with 
  genre_id: Gen100 101 ...
  author_id: Auth200 201 ...
  book_id: Boo300 301 ...
  subscription_status_id: Sub400 401 ...
  customer_id: cus500 501 ...
  shopping_cart_id: sho800 801 ...
  order_id: ord600 601 ...
  address_id: add700 701 ...
  wishlist_id: wis900 901 ...
  user_review_id: rev1000 1001 ...
  SUBSCRIPTION_ID: SUB100 101 ...

## T0do
- TODO: auto increment id's ❌
- TODO: Think about the how to give custome names to id columns DONE:
- TODO: add the triggers AND exceptions and packages
  - author: au00001
  - book_category: bc00001
  - genre: ge00001
  - book: bo00001
  - subscription: su00001
  - customer: cu00001
  - order: or00001
  - customer_address: ca00001
  - wishlist: wi00001
  - order_detail: od00001
  - subscription_log_history: sl00001
  
- TODO: DISIDE THE largest limit for the id columns.
- USING PACKAGES
- pls_integer insted of NUMBER
- 
- designing all the triggers

# login logout triggers, History of login and logout
# history of every eddits made database and schema level triggers.
# startup and shutdown triggers

-----------------------------------------------------------------------------------------------------------
### PACKAGE_CALCULATE
- TRIGGER(FUNCTION return  calculate.get_avg_author_rating)






### PACKAGE_OPERATIONS
- Procedure(Book Table[price] perform update operation using DML statement operatins.set_book_discount(author_id, discount)
- Procedure(Book Table[available_quantity]
- increase the book count on book stock update 
  - operation.add_book_quantity(book_id, quantity)
- decrement the book count on book sale (triggers)
  - operation.decrement_book_quantity(book_id, quantity)




### Packages
#### Operation
  - decrement the book quantity on book sale procedure
    - operation.pr_decrement_book_count(book_id, quantity)
  - book order cancled so decrement the book_quantity of a book
    - operation.pr_increment_book_count(book_id, quantity)
  - function to calculate the price of a book_id with discount
    - operation.fn_get_book_price(book_id)

#### Calculate
  - procedure to update the author_score
    - operation.pr_update_author_score(author_id, book_rating)

### Trigger

- book_sale_trigger on order_detail -> decrement the book count on book sale

- create a trigger on table user_review on insert delete and update to updat the author.author_score by calculating the average rating of all the books of the author.
  - tr_set_author_score on user_review -> update author.author_score

- triggered cart -> on order_details(auto insert the new order_id in order table) ->  update book_price in order_detail using book_price
-














_______________________________________________________________________________________________




-- Create Tables
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(100)
);

CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255),
    AuthorID INT,
    Price DECIMAL(10,2),
    StockQuantity INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(255),
    Address VARCHAR(255)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    BookID INT,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- Create Triggers (Example: Update StockQuantity after an order)
CREATE TRIGGER UpdateStockQuantity
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE Books
    SET StockQuantity = StockQuantity - NEW.Quantity
    WHERE BookID = NEW.BookID;
END;

-- Create Procedures (Example: PlaceOrder)
DELIMITER //
CREATE PROCEDURE PlaceOrder(
    IN custID INT,
    IN bookID INT,
    IN qty INT
)
BEGIN
    DECLARE totalAmount DECIMAL(10,2);
    DECLARE price DECIMAL(10,2);

    SELECT Price INTO price FROM Books WHERE BookID = bookID;
    SET totalAmount = price * qty;

    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES (custID, CURDATE(), totalAmount);

    INSERT INTO OrderDetails (OrderID, BookID, Quantity, Price)
    VALUES (LAST_INSERT_ID(), bookID, qty, price);
END//
DELIMITER ;

-- Create Functions (Example: CalculateTotalPrice)
CREATE FUNCTION CalculateTotalPrice(bookID INT, qty INT) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE price DECIMAL(10,2);
    SELECT Price INTO price FROM Books WHERE BookID = bookID;
    RETURN price * qty;
END;

-- Create Packages (Example: BookstoreManagement)
CREATE PACKAGE BookstoreManagement AS
    PROCEDURE PlaceOrder(custID INT, bookID INT, qty INT);
    FUNCTION CalculateTotalPrice(bookID INT, qty INT) RETURNS DECIMAL(10,2);
END BookstoreManagement;
/

CREATE PACKAGE BODY BookstoreManagement AS
    PROCEDURE PlaceOrder(custID INT, bookID INT, qty INT) AS
        -- implementation details
    END PlaceOrder;

    FUNCTION CalculateTotalPrice(bookID INT, qty INT) RETURNS DECIMAL(10,2) AS
        -- implementation details
    END CalculateTotalPrice;
END BookstoreManagement;
/

