### ER Diagram
```
1. check all not null, check constraints and unique constraints
2. check all foreign keys & primary keys
3. check all unique constraints
4. check id datatypes
```

### genre
- genre_id [PK]
- genre_name
- genre_description
  - Optional:
    - genre_image (to display in the website when filter applyed)

```sql
CREATE TABLE genre 
( 
  genre_id  NUMBER NOT NULL, 
  genre_name  VARCHAR2(15) NOT NULL, 
  genre_description  VARCHAR2(300), 
  genre_image  LONG RAW, 
CONSTRAINT PK_genre 
  PRIMARY KEY (genre_id)
) 
/ 
```

### author
- author_id [PK]
- author_name
- author_bio
- author_email
  - Optional:
    - author_ratting or author_score [auto calculate average ratings of all books] - ⚠️ suggest a attrubute name
    - author_image (to display in the website when filter applyed)
    - author_birth_date
    - author_death_date
    - author_country
    - author_phone
    - ⚠️ no of books can be calculated from books table count(book_id) where book.author_id = author.auther_id

```sql
CREATE TABLE author 
( 
  author_id  NUMBER NOT NULL, 
  author_name  VARCHAR2(15) NOT NULL, 
  author_bio  VARCHAR2(300), 
  author_image  LONG RAW, 
CONSTRAINT PK_author 
  PRIMARY KEY (author_id)
) 
/ 

-- (Opt) update or insert trigure if author_death_date not null then set author_email null
```

### book
- book_id [PK]
- book_title 
- book_description
- book_publish_date
- author_id [FK-> author.author_id]
- genre_id [FK-> genre.genre_id]
- unit_price [check >=0]
- unit_in_stock [check >=0] 
- book_rating  - ⚠️ what will be the initial value? TODO: implement `book rating`
- total_book_reviews [check >=0]
- discontinued [Default: false]
  - Optional:
    - book_cover_image
    - book_publisher
    - book_language
    - book_pages


```SQL
CREATE TABLE book 
( 
  book_id  NUMBER NOT NULL, 
  book_title  VARCHAR2(40) NOT NULL, 
  book_description  VARCHAR2(300),
  book_publish_date  DATE, 
  author_id  NUMBER, 
  genre_id  NUMBER, 
  unit_price  NUMBER, 
  unit_in_stock  NUMBER, 
  book_rating  NUMBER(5, 2),
  total_book_reviews  NUMBER, 
  discontinued  NUMBER(1) NOT NULL,
  book_cover_image LONG RAW, 
CONSTRAINT PK_book 
  PRIMARY KEY (book_id), 
CONSTRAINT CK_book_unit_price   CHECK ((unit_price >= 0)), 
CONSTRAINT CK_total_book_reviews   CHECK ((total_book_reviews >= 0)), 
CONSTRAINT CK_unit_in_stock   CHECK ((unit_in_stock >= 0)), 
CONSTRAINT FK_book_author FOREIGN KEY (author_id) REFERENCES author(author_id), 
CONSTRAINT FK_book_genre FOREIGN KEY (genre_id) REFERENCES genre(genre_id), 
) 
/ 
```

### premium_type - ⚠️ suggest a table name
- premium_status_id (1, 2, 3 ...)
- premium_name (Gold, Silver, Bronze ...) TODO: suggest premium names
- premium_description (description about the premium type)
- premium_price   (149, 199, 249 ...)
  - Optional:
    - premium_duration or life time premium (cause hard to implement the premium expire date)
    - premium_image (to display in the website when filter applyed)


```sql
CREATE TABLE premium_type 
( 
  premium_status_id NUMBER NOT NULL, 
  premium_name  VARCHAR2(30),
  premium_description VARCHAR2(300), 
  premium_price NUMBER,
CONSTRAINT PK_premium_type 
  PRIMARY KEY (premium_status_id)
) 
/ 
```

### customer
- customer_id  [PK]
- customer_name
- customer_email
- primary_customer_phone
- password_hash
- premium_status_id  [FK-> premium_type.premium_status_id]
  - Optional:
    - join_date
    - premium_expire_date


```sql
CREATE TABLE customer
( 
  customer_id  NUMBER NOT NULL, 
  customer_name  VARCHAR2(30),
  customer_email VARCHAR2(100), 
  primary_customer_phone  VARCHAR2(24), 
  password_hash VARCHAR2(100),
  premium_status_id NUMBER NOT NULL,
CONSTRAINT PK_customer 
  PRIMARY KEY (customer_id),
CONSTRAINT FK_customer_customer_address FOREIGN KEY (premium_status_id) REFERENCES customer_address(premium_status_id)
) 
/ 
```

### customer_address (⚠️ Do we realy need to add multiple address for a single customer?) -commit with verfiy request
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
- other_address_details
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
    other_address_details VARCHAR2(255),
    phone VARCHAR2(24), 

CONSTRAINT PK_customer_address 
  PRIMARY KEY (address_type, customer_id), 
CONSTRAINT FK_customer_address_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
```

<!-- complex[order & orderDetains] -->


### order
- order_id [PK]
- customer_id [FK-> customer.customer_id]
- address_type (customer_id & customer_address_type) -> Delivery Address   [FK-> customer_addressaddress_type]
- order_date [auto calculated current date]
- shipped_date (basic algorithm to calculate the shipping date)
- order_discount (applying discount by customer's premium status) (initial random data insertion) "function" to calculate the total price with discount with 10 or 20% discount [auto calculated SUM(order_detail.unit_price) WHERE order_id = order_detail.order_id]
- order_total_cost (calculating with the unit_price & unit_discount) [auto calculated/PLSQL]
                    - ( SUM(order_detail.unit_price * (1 - order_detail.unit_discount) * order_detail.quantity) * (1 - order_discount) ) WHERE order_id = order.order_id   `Order Processing (point 2)`
- order_status (pending, processing, shipped, delivered, cancelled, returned, etc.)
  - Optional:
    - required_date


```sql
CREATE TABLE order 
( 
  order_id  NUMBER NOT NULL, 
  customer_id  CHAR(5),
  address_type VARCHAR2(16) NOT NULL, 
  order_date  DATE, 
  shipped_date  DATE,
  order_discount NUMBER NOT NULL,
  order_total_cost NUMBER,
  order_status VARCHAR2(16),
CONSTRAINT PK_order 
  PRIMARY KEY (order_id), 
CONSTRAINT FK_order_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id), 
CONSTRAINT FK_order_customer FOREIGN KEY (address_type) REFERENCES customer_address(address_type)
) 
-- create a insert trigger to calculate the order_total_cost
```


### order_detail
- order_id [FK-> order.order_id] [PK]
- book_id [FK-> book.book_id] [PK]
- unit_price [auto calculated book.unit_price] 
- unit_discount [0.0 - 1.0]
- quantity
  - Optional:

```sql
CREATE TABLE order_detail 
( 
  order_id  NUMBER NOT NULL, 
  book_id  NUMBER NOT NULL, 
  unit_price  NUMBER NOT NULL, 
  unit_discount  NUMBER NOT NULL, 
  quantity  NUMBER NOT NULL, 
CONSTRAINT PK_order_detail 
  PRIMARY KEY (order_id, book_id), 
CONSTRAINT CK_unit_price   CHECK ((unit_price >= 0)), 
CONSTRAINT CK_unit_discount   CHECK ((unit_discount >= 0 and unit_discount <= 1)), 
CONSTRAINT CK_quantity   CHECK ((quantity > 0)), 
CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (order_id) REFERENCES order(order_id), 
CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (book_id) REFERENCES book(book_id)
)
/
-- create a insert trigger to calculate the unit_price
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


### website_rating - ⚠️ do we need this?
- avg_rating
- total_reviews_count


## Ignore
### genre(Optional)
### Publishers(Optional)