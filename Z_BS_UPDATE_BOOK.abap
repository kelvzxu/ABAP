FUNCTION Z_BS_UPDATE_BOOK.

    DATA: wa_sbook       LIKE sbook,
        delta_loccuram LIke sbook-loccuram.

    DATA: BEGIN OF h_book,
            mandt     LIKE sbook-mandt,
            carrid    LIKE sbook-carrid,
            connid    LIKE sbook-connid,
            fldate    LIKE sbook-fldate,
            bookid    LIKE sbook-bookid,
            customid  LIKE sbook-customid,
            custtype  LIKE sbook-custtype,
            smoker    LIKE sbook-smoker,
            class     LIKE sbook-class,
            forcuram  LIKE sbook-forcuram,
            forcurkey LIKE sbook-forcurkey,
            loccuram  LIKE sbook-loccuram,
            loccurkey LIKE sbook-loccurkey,
        END OF h_book.


    SELECT SINGLE * FROM sbook INTO wa_sbook
        WHERE  carrid   = iv_book-carrid
        AND    connid   = iv_book-connid
        AND    fldate   = iv_book-fldate
        AND    bookid   = iv_book-bookid.

    IF sy-subrc NE 0.
        MESSAGE e026 RAISING book_not_found.
    ENDIF.

    MOVE : iv_book-mandt    TO h_book-mandt,
        iv_book-carrid   TO h_book-carrid,
        iv_book-connid   TO h_book-connid,
        iv_book-fldate   TO h_book-fldate,
        iv_book-bookid   TO h_book-bookid,
        iv_book-customid TO h_book-customid,
        iv_book-custtype TO h_book-custtype,
        iv_book-smoker   TO h_book-smoker,
        iv_book-class    TO h_book-class.
        
    IF iv_book-loccurkey = wa_sbook-loccurkey.
        MOVE: iv_book-loccuram  TO h_book-loccuram,
            iv_book-loccurkey TO h_book-loccurkey.

        CLEAR: iv_book-forcuram, h_book-forcurkey.
    ELSE.
        MOVE: iv_book-loccuram   TO h_book-forcuram, 
            iv_book-loccurkey  TO h_book-forcurkey,
            wa_sbook-loccurkey TO h_book-loccurkey.
        
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
                CLIENT              = SY-MANDT
                date                = sy-datum
                foreign_amount      = h_book-forcuram
                foreign_currency    = h_book-forcurkey
                local_currency      = h_book-loccurkey
                RATE                = 0
                TYPE_OF_RATE        = 'M'
                read_tcurr          = 'X'
            IMPORTING
                EXCHANGE_RATE       =
                FOREIGN_FACTOR      = 
                local_amount        = h_book-loccuram
                LOCAL_FACTOR        = 
                EXCHANGE_RATEX      = 
                FIXED_RATE          = 
                DERIVED_RATE_TYPE   = 
            EXCEPTIONS
                no_rate_found       = 1
                overflow            = 2
                no_factors_found    = 3
                no_spread_found     = 4
                derived_2_times     = 5
                OTHERS              = 6
        IF sy-subrc <> 0.
            MESSAGE a025(zbs) RAISING currency_conversion_error.
        ENDIF.

    ENDIF.

    UPDATE sbook set custtype       = h_book-custtype
                    smoker         = h_book-smoker
                    class          = h_book-class
                    forcuram       = h_book-forcuram
                    forcurkey      = h_book-forcurkey
                    loccuram       = h_book-loccuram
                    loccurkey      = h_book-loccurkey
                    where carrid   = h_book-carrid
                    AND   connid   = h_book-connid
                    AND   fldate   = h_book-fldate
                    AND   bookid   = h_book-bookid
                    AND   customid = h_book-customid.

    IF sy-subrc NE 0.
        MESSAGE a023.
    ENDIF.

    delta_loccuram = wa_sbook-loccuram - h_book-loccuram.
    UPDATE sflight SET paymentsum = paymentsum - delta_loccuram
                    where carrid   = h_book-carrid
                    AND   connid   = h_book-connid
                    AND   fldate   = h_book-fldate.

    IF sy-subrc NE 0.
        MESSAGE a023.
    ENDIF.

ENDFUNCTION.