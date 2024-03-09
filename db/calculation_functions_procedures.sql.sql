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