-- Function to calculate the average author score
CREATE OR REPLACE FUNCTION fnc_calculate_average_author_score(
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
END fnc_calculate_average_author_score;
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

    var_author_score := fnc_calculate_average_author_score(var_author_id, :NEW.book_rating);

    UPDATE tbl_author
    SET author_score = var_author_score
    WHERE author_id = var_author_id;
END trg_update_author_score;
/

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

-- Trigger to update the order total
CREATE OR REPLACE TRIGGER trg_update_order_total
AFTER INSERT ON tbl_order_detail
FOR EACH ROW
DISABLE
DECLARE
    var_order_id tbl_order_detail.order_id%TYPE;
    var_order_total tbl_order.total%TYPE;
BEGIN
    SELECT order_id
    INTO var_order_id
    FROM tbl_order_detail
    WHERE order_detail_id = :NEW.order_detail_id;

    SELECT SUM(book_price * quantity)
    INTO var_order_total
    FROM tbl_order_detail
    WHERE order_id = var_order_id;

    UPDATE tbl_order
    SET total = var_order_total
    WHERE order_id = var_order_id;
END trg_update_order_total;
/
