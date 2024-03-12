-- Function to calculate the average author score
CREATE OR REPLACE FUNCTION fn_calculate_average_author_score(
    prm_author_id IN tbl_author.author_id%TYPE,
    prm_book_rating IN tbl_user_review.book_rating%TYPE
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
        AND book_id IN (SELECT book_id FROM tbl_book WHERE author_id = prm_author_id);
    
    IF var_sum_rating IS NULL THEN
        var_sum_rating := 0;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Sum: ' || var_sum_rating || ' Count: ' || var_count);

    var_author_score := (var_sum_rating + prm_book_rating)/(var_count + 1);

    RETURN var_author_score;
END fn_calculate_average_author_score;
/


-- Function to calculate the average book rating for a book from user reviews.
CREATE OR REPLACE FUNCTION fn_calculate_book_rating(
    prm_book_id IN tbl_book.book_id%TYPE
) RETURN NUMBER
IS
    var_avg_rating NUMBER;
BEGIN
    SELECT AVG(book_rating)
    INTO var_avg_rating
    FROM tbl_user_review
    WHERE book_id = prm_book_id
        AND book_rating IS NOT NULL;
    
    IF var_avg_rating IS NULL THEN
        var_avg_rating := 0;
    END IF;

    RETURN var_avg_rating;
END fn_calculate_book_rating;
/


-- Function to check if a book is available in the store.
CREATE OR REPLACE FUNCTION fn_check_book_availability(
    prm_book_id IN tbl_book.book_id%TYPE,
    prm_quantity IN tbl_book.available_quantity%TYPE
) RETURN BOOLEAN
IS
    var_available_quantity tbl_book.available_quantity%TYPE;
BEGIN
    SELECT available_quantity
    INTO var_available_quantity
    FROM tbl_book
    WHERE book_id = prm_book_id;

    IF var_available_quantity >= prm_quantity THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END fn_check_book_availability;
/


-- Function to calculate the customer subscription discount.
CREATE OR REPLACE FUNCTION fn_get_customer_subscription_discount(
    prm_customer_id IN tbl_customer.customer_id%TYPE
) RETURN NUMBER
IS
    var_subscription_discount NUMBER;
BEGIN
    SELECT subscription_discount_on_order
    INTO var_subscription_discount
    FROM tbl_subscription
    WHERE subscription_status_id = (SELECT subscription_status_id FROM tbl_subscription_log_history WHERE customer_id = prm_customer_id AND subscription_end_date > SYSDATE);

    IF var_subscription_discount IS NULL THEN
        var_subscription_discount := 0;
    END IF;

    RETURN var_subscription_discount;
END fn_get_customer_subscription_discount;
/

-- Function to calculate the total cost of an order.
CREATE OR REPLACE PROCEDURE fn_calculate_order_total_cost(
    prm_order_id IN tbl_orders.order_id%TYPE
)
IS
    var_total_cost NUMBER;
    var_order_discount NUMBER;
BEGIN
    SELECT SUM(book_price * quantity)
    INTO var_total_cost
    FROM tbl_order_detail
    WHERE order_id = prm_order_id;

    SELECT order_discount
    INTO var_order_discount
    FROM tbl_orders
    WHERE order_id = prm_order_id;

    var_total_cost := var_total_cost - (var_total_cost * var_order_discount);

    DBMS_OUTPUT.PUT_LINE('Total Cost: ' || var_total_cost);
END fn_calculate_order_total_cost;
/