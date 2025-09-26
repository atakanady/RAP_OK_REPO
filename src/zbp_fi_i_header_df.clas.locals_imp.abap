CLASS lhc_zfi_i_item_df DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.


    METHODS oncreateitem FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_i_item_df~oncreateitem.
    METHODS vcounrtyitem FOR VALIDATE ON SAVE
      IMPORTING keys FOR zfi_i_item_df~vcounrtyitem.
    METHODS vcurrencyitem FOR VALIDATE ON SAVE
      IMPORTING keys FOR zfi_i_item_df~vcurrencyitem.
    METHODS oncreate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_i_item_df~oncreate.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfi_i_item_df RESULT result.

ENDCLASS.

CLASS lhc_zfi_i_item_df IMPLEMENTATION.
  METHOD oncreateitem.

  ENDMETHOD.


  METHOD vcounrtyitem.

    SELECT
  h~country
  FROM i_country AS h
  INTO TABLE @DATA(lt_counrty).

    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
    ENTITY zfi_i_item_df
    FIELDS ( payeecountry paymenttype ) WITH CORRESPONDING #( keys )

    RESULT DATA(lt_payeecountry)
    REPORTED DATA(lt_reported).


    LOOP AT lt_payeecountry ASSIGNING FIELD-SYMBOL(<lfs_country>).

      IF <lfs_country>-paymenttype = 'V' OR <lfs_country>-paymenttype = 'A'.

        IF <lfs_country>-payeecountry IS NOT INITIAL.

          READ TABLE lt_counrty ASSIGNING FIELD-SYMBOL(<lfs_i_country2>) WITH KEY country = <lfs_country>-payeecountry.

          IF sy-subrc IS NOT INITIAL.
            APPEND VALUE #( %tky = <lfs_country>-%tky ) TO failed-zfi_i_header_df.
            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                            %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'Geçersiz ülke kodu seçilmiştir!'
                              ) )
                              TO reported-zfi_i_header_df.


            RETURN.

            READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
            ENTITY zfi_i_header_df
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(data).

          ENDIF.

        ENDIF.

      ELSE.

        READ TABLE lt_counrty ASSIGNING FIELD-SYMBOL(<lfs_i_country>) WITH KEY country = <lfs_country>-payeecountry.

        IF sy-subrc IS NOT INITIAL.
          APPEND VALUE #( %tky = <lfs_country>-%tky ) TO failed-zfi_i_header_df.
          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'Geçersiz ülke kodu seçilmiştir!'
                            ) )
                            TO reported-zfi_i_header_df.


          RETURN.

          READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
          ENTITY zfi_i_header_df
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT data.

        ENDIF.

      ENDIF.



    ENDLOOP.




  ENDMETHOD.

  METHOD vcurrencyitem.


    SELECT
  h~currency
  FROM i_currency AS h
  INTO TABLE @DATA(lt_currencyys).

    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
    ENTITY zfi_i_item_df
    FIELDS ( currency ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_currency)
    REPORTED DATA(lt_reported).


    LOOP AT lt_currency ASSIGNING FIELD-SYMBOL(<lfs_currency>).

      READ TABLE lt_currencyys ASSIGNING FIELD-SYMBOL(<lfs_i_currency>) WITH KEY currency = <lfs_currency>-currency.

      IF sy-subrc IS NOT INITIAL.
        APPEND VALUE #( %tky = <lfs_currency>-%tky ) TO failed-zfi_i_header_df.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Geçersiz para birimi seçilmiştir!'
                        ) )

                        TO reported-zfi_i_header_df.

        RETURN.

        READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
        ENTITY zfi_i_header_df
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(data).

      ENDIF.


    ENDLOOP.

  ENDMETHOD.



  METHOD oncreate.


    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
    ENTITY zfi_i_item_df
    FIELDS ( paymentorder ) WITH CORRESPONDING #( keys )
    RESULT DATA(lv_status).

    LOOP AT lv_status INTO DATA(ls_status).

      IF  ls_status-paymentorder IS INITIAL.


        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Manuel Kayıt İşlemi Yapılamaz!'
                        ) )

                        TO reported-zfi_i_item_df.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*  METHOD vcostname.
*
*    TYPES: BEGIN OF ty_cost,
*             value TYPE string,
*           END OF ty_cost.
*
*    TYPES: BEGIN OF ty_paymenttd,
*             cost TYPE string,
*             desc TYPE string,
*           END OF ty_paymenttd.
*
*    DATA: ls_cost      TYPE ty_cost,
*          lt_cost      TYPE TABLE OF ty_cost,
*          t_paymenttd  TYPE TABLE OF ty_paymenttd,
*          ls_paymenttd TYPE ty_paymenttd,
*          lt_cost_c    TYPE TABLE OF string.
*
*
*    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
*    ENTITY zfi_i_item_df
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_custname)
*    FAILED DATA(failed).
*
*    SELECT
*          h~paymentcost,
*          h~paycostdescription
*          FROM zfi_db_custinfo AS h
*          INTO TABLE @DATA(lt_tablecost).
*
*    LOOP AT lt_custname ASSIGNING FIELD-SYMBOL(<lfs_keys>).
*
*      READ TABLE lt_tablecost ASSIGNING FIELD-SYMBOL(<lfs_tablecost>) WITH KEY paymentcost = <lfs_keys>-paymentcost.
*      IF sy-subrc IS INITIAL.
*
*        <lfs_keys>-paycostdescription = <lfs_tablecost>-paycostdescription.
*
*      ENDIF.
*
*    ENDLOOP.
*
*
*    MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
*    ENTITY zfi_i_item_df
*    UPDATE FIELDS ( paycostdescription ) WITH CORRESPONDING #( lt_custname ).
*
*
*
*  ENDMETHOD.

  METHOD get_instance_features.

*    DATA:lt_paymentorderroot TYPE TABLE OF zfi_db_root.
*
*    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
*        ENTITY zfi_i_item_df
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_result)
*        FAILED DATA(ls_failed)
*        REPORTED DATA(ls_reported).
*
*    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>) WHERE status = '10'.
*
*      SELECT *
*       FROM zfi_db_root AS j
*          WHERE paymentorder = @<lfs_result>-paymentorder
*          INTO TABLE @lt_paymentorderroot.
*
*      READ TABLE lt_paymentorderroot ASSIGNING FIELD-SYMBOL(<lfs_paymentorderroot>) WITH KEY paymentorder = <lfs_result>-paymentorder.
*
*      IF <lfs_paymentorderroot>-status EQ '20'.
*
*        MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
*             ENTITY zfi_i_item_df " Alias
*             UPDATE
*             FIELDS ( status )
*             WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '20' ) )
*             FAILED DATA(lt_failed)
*             REPORTED DATA(lt_reported).
*
*
*      ENDIF.
*    ENDLOOP.

  ENDMETHOD.
ENDCLASS.


CLASS lhc_zfi_i_header_df DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
    DATA lv_payments TYPE string.

*INTERFACES if_abap_behv
  PRIVATE SECTION.
    DATA io_input TYPE REF TO zfi_filestr.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_i_header_df RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfi_i_header_df RESULT result.
    METHODS oncreate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_i_header_df~oncreate.
    METHODS setadminted FOR MODIFY
      IMPORTING keys FOR ACTION zfi_i_header_df~setadminted RESULT result.
    METHODS backadminted FOR MODIFY
      IMPORTING keys FOR ACTION zfi_i_header_df~backadminted RESULT result.
    METHODS vcounrty FOR VALIDATE ON SAVE
      IMPORTING keys FOR zfi_i_header_df~vcounrty.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR ACTION zfi_i_header_df~delete RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zfi_i_header_df RESULT result.
    METHODS vcostname FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_i_header_df~vcostname.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zfi_i_header_df.
    METHODS earlynumbering_cba_child FOR NUMBERING
      IMPORTING entities FOR CREATE zfi_i_header_df\_child.


ENDCLASS.

CLASS lhc_zfi_i_header_df IMPLEMENTATION.

  METHOD get_instance_authorizations.

    LOOP  AT keys ASSIGNING FIELD-SYMBOL(<lfs_data>).
    ENDLOOP.


    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
    ENTITY zfi_i_header_df
    FIELDS ( payercompany ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_currency)
    REPORTED DATA(lt_reported).

    IF sy-uname IS NOT INITIAL.

      IF sy-uname EQ 'CC0000000004'.

*       result = VALUE #(
*          FOR <fs_key> IN keys (
*            %tky = <fs_key>-%tky
*            %action-setAdminted = if_abap_behv=>fc-o-disabled ) ) .

      ENDIF.


    ENDIF.

  ENDMETHOD.


  METHOD earlynumbering_create.


    DATA: lv_date(10)      TYPE c,
          last_paymentdate TYPE TABLE OF zfi_db_root-paymentdate,
          lt_sorted_dates  TYPE TABLE OF sy-datum,
          last_changed_at  TYPE TABLE OF zfi_db_root-last_changed_at.

    SELECT MAX( paymentorder ) FROM zfi_db_root INTO @DATA(new_id).

    SELECT paymentdate
      FROM zfi_db_root
      INTO TABLE @last_paymentdate.

    LOOP AT last_paymentdate INTO DATA(lv_paymentdate).
      lv_date = condense( lv_paymentdate ).
      lv_date = lv_date+6(4) && lv_date+3(2) && lv_date+0(2).
      APPEND lv_date TO lt_sorted_dates.
    ENDLOOP.

    SORT lt_sorted_dates DESCENDING.
    READ TABLE lt_sorted_dates INTO DATA(lv_first_date) INDEX 1.

    IF last_paymentdate IS INITIAL.
      new_id = 10000.
    ENDIF.

    DATA: lv_last_year TYPE i.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_ent>).

      DATA(lv_selectpaymentdate) = <lfs_ent>-paymentdate.

      lv_date = condense( lv_selectpaymentdate ).
      lv_date = lv_date+6(4) && lv_date+3(2) && lv_date+0(2).

      DATA : lv_year_first_date  TYPE i,
             lv_year_paymentdate TYPE i.

      lv_year_first_date = lv_first_date+0(4). " Extracting year from lv_first_date
      lv_year_paymentdate = lv_date+0(4).      " Extracting year from lv_date

      IF lv_last_year IS INITIAL.
        lv_last_year = lv_year_first_date.
      ENDIF.

      IF lv_year_paymentdate <> lv_last_year.
        new_id = 10000.
      ELSE.
        new_id = new_id + 1.
      ENDIF.

      " Kayıt ekleme işlemi
      INSERT VALUE #( %cid = <lfs_ent>-%cid
                      paymentorder = new_id
      ) INTO TABLE mapped-zfi_i_header_df.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_child.

    DATA new_id(8) TYPE n.

    new_id = 0.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_ent>).

      LOOP AT <lfs_ent>-%target ASSIGNING FIELD-SYMBOL(<lfs_target>).

        new_id = new_id + 1.

        INSERT VALUE #( %cid = <lfs_target>-%cid
                          paymentorder = <lfs_ent>-paymentorder
                          paymentline = new_id

      ) INTO TABLE mapped-zfi_i_item_df.

      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD get_instance_features.


*      " Giriş parametresi 'keys' artık düzgün şekilde iletildi
*
*      DATA: lt_item         TYPE TABLE OF zfi_db_item,
*            lv_paymentorder TYPE zfi_db_root-paymentorder,
*            lv_status       TYPE zfi_db_item-status,
*            lv_all_items_ok TYPE abap_bool.
*
*      READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
*          ENTITY zfi_i_header_df
*          FIELDS ( paymentorder status )
*          WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_header).
*
*      DELETE lt_header WHERE status <> 30.
*
*      LOOP AT lt_header INTO DATA(ls_header).
*        lv_paymentorder = ls_header-paymentorder.
*        lv_all_items_ok = abap_true.
*
*        " İlgili öğeleri al
*        SELECT * FROM zfi_db_item
*          WHERE paymentorder = @lv_paymentorder
*          INTO TABLE @lt_item.
*
*        LOOP AT lt_item INTO DATA(ls_item).
*          " Durumun 40 olup olmadığını kontrol et
*          IF ls_item-status <> '40'.
*            CONTINUE.
*          ENDIF.
*
*          lv_all_items_ok = abap_true.
*          EXIT.
*        ENDLOOP.
*
*        " Gerekirse header durumunu güncelle
*        IF lv_all_items_ok = abap_true.
*          MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
*            ENTITY zfi_i_header_df
*            UPDATE
*            FIELDS ( status )
*            WITH VALUE #( ( %tky = ls_header-%tky
*                             status = '95' ) )
*            FAILED DATA(lt_failed)
*            REPORTED DATA(lt_reported).
*        ENDIF.
*      ENDLOOP.
*



*      " Burada vcostname() çağırmayın
*      " Bunun yerine, duruma bağlı olarak özelliklerin etkinleştirilmesini/devre dışı bırakılmasını sağlayın
*
    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
      ENTITY zfi_i_header_df
      FIELDS ( status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header_data).
*
    " Header durumuna göre özellik kontrolünü ayarla
    result = VALUE #( FOR ls_header IN lt_header_data
                     ( %tky = ls_header-%tky
                       %features-%action-setadminted = COND #( WHEN ls_header-status = '10'
                                                             THEN if_abap_behv=>fc-o-enabled
                                                             ELSE if_abap_behv=>fc-o-disabled )
                       %features-%action-backadminted = COND #( WHEN ls_header-status = '20'
                                                             THEN if_abap_behv=>fc-o-enabled
                                                             ELSE if_abap_behv=>fc-o-disabled )
                       %features-%action-delete = COND #( WHEN ls_header-status = '10'
                                                        THEN if_abap_behv=>fc-o-enabled
                                                        ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.


  METHOD oncreate.



    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
    ENTITY zfi_i_header_df
    FIELDS ( status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lv_status).

    LOOP AT lv_status INTO DATA(ls_status).

      IF  ls_status-status IS INITIAL.


        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Manuel Kayıt İşlemi Yapılamaz!'
                        ) )

                        TO reported-zfi_i_header_df.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.



  METHOD setadminted.

    TRY.
        DATA(lv_surl) = cl_abap_context_info=>get_system_url(  ).
      CATCH cx_abap_context_info_error INTO DATA(lo_eror).
    ENDTRY.
    IF lv_surl EQ 'my419526.s4hana.cloud.sap'.

    TYPES: BEGIN OF ty_currency_count,
             currency TYPE zfi_db_item-currency,
             count    TYPE i,
           END OF ty_currency_count.

    TYPES: BEGIN OF ty_currency_amount,
             amount   TYPE p LENGTH 16 DECIMALS 2,
             currency TYPE zfi_db_item-currency,
           END OF ty_currency_amount.


    TYPES: BEGIN OF ty_payment_info,
             amount   TYPE zfi_db_item-amount,
             currency TYPE zfi_db_item-currency,
           END OF ty_payment_info.

    DATA:
      lt_currency_counts TYPE TABLE OF ty_currency_count,
      ls_currency_count  TYPE ty_currency_count.

    DATA : lt_paymentamount   TYPE TABLE OF ty_payment_info,
           ls_paymentamount   TYPE ty_payment_info,
           lv_total           TYPE p DECIMALS 2,
           lv_amount          TYPE p DECIMALS 2,
           lt_currency_totals TYPE TABLE OF ty_currency_amount,
           ls_currency_total  TYPE ty_currency_amount.

    DATA: lt_items            TYPE TABLE OF zfi_db_item,   " zfi_db_item tablosu için veri tablosu
          lt_data             TYPE TABLE OF zfi_db_doc,    " zfi_db_doc tablosu için veri tablosu
          lv_paymentorder(10) TYPE c,   " Kullanıcının seçtiği paymentorder
          lv_found_m          TYPE abap_bool,              " Paymenttype 'M' bulunduğunu belirtir
          lv_found_p          TYPE abap_bool.              " Paymenttype 'P' bulunduğunu belirtir

    DATA lv_error TYPE abap_bool.
    lv_error = abap_false.

    FIELD-SYMBOLS: <lfs_item> TYPE zfi_db_item,
                   <lfs_doc>  TYPE zfi_db_doc.

    READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
         ENTITY zfi_i_header_df
           ALL FIELDS
           WITH CORRESPONDING #( keys )
           RESULT DATA(entities).


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_payment>).

      lv_paymentorder = <lfs_payment>-paymentorder.

    ENDLOOP.

    SELECT *
      FROM zfi_db_item
      WHERE paymentorder = @lv_paymentorder
      INTO CORRESPONDING FIELDS OF TABLE @lt_items.

    IF lt_items IS NOT INITIAL.
      LOOP AT lt_items ASSIGNING <lfs_item>.
        CASE <lfs_item>-paymenttype.
          WHEN 'M'.
            lv_found_m = abap_true.
          WHEN 'P'.
            lv_found_p = abap_true.
        ENDCASE.
        IF lv_found_m = abap_true AND lv_found_p = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_found_m = abap_true OR lv_found_p = abap_true.
      SELECT
      h~header,
      h~paymenttype
        FROM zfi_db_doc AS h
        WHERE header = @lv_paymentorder
        INTO CORRESPONDING FIELDS OF TABLE @lt_data.

      IF lv_found_m = abap_true.
        READ TABLE lt_data ASSIGNING <lfs_doc> WITH KEY paymenttype = 'M'.
        IF sy-subrc IS NOT INITIAL.
          lv_error = abap_true.
          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                  %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text = 'M türü için doküman bulunamadı!'
                  ) )

                  TO reported-zfi_i_header_df.
        ENDIF.
      ENDIF.

      IF lv_found_p = abap_true.
        READ TABLE lt_data ASSIGNING <lfs_doc> WITH KEY paymenttype = 'P'.
        IF sy-subrc IS NOT INITIAL.
          lv_error = abap_true.
          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                  %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text = 'P türü için doküman bulunamadı!'
                  ) )

                  TO reported-zfi_i_header_df.

        ENDIF.
      ENDIF.

    ENDIF.

    IF lv_error = abap_false.

      READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
      ENTITY zfi_i_header_df
      FIELDS ( paymentorder status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_status).



      LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<lfs_status>).

        IF <lfs_status>-status EQ '10'.

          MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
             ENTITY zfi_i_header_df " Alias
             UPDATE
             FIELDS ( status )
             WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '20' ) )
             FAILED DATA(lt_failed)
             REPORTED DATA(lt_reported).

          READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
        ENTITY zfi_i_item_df
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result)
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).

          READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
          ENTITY zfi_i_header_df
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(data).
          result = VALUE #( FOR datarec IN data
          ( %tky = datarec-%tky %param = datarec )  ).

          IF sy-subrc IS INITIAL.


            LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
              lv_paymentorder = <lfs_keys>-paymentorder.
            ENDLOOP.

            SELECT currency, COUNT(*) AS count
              FROM zfi_db_item
              WHERE paymentorder = @lv_paymentorder
              GROUP BY currency
              INTO TABLE @lt_currency_counts.


            SELECT
                amount,
                currency
              FROM zfi_db_item AS _amount
              WHERE paymentorder = @lv_paymentorder
              INTO TABLE @lt_paymentamount.


            LOOP AT lt_paymentamount INTO ls_paymentamount.

              CLEAR ls_currency_total.

*              REPLACE ALL OCCURRENCES OF '.' IN ls_paymentamount-amount WITH ''.
*              REPLACE ALL OCCURRENCES OF ',' IN ls_paymentamount-amount WITH ''.

              ls_currency_total = VALUE #(  currency   = ls_paymentamount-currency
                                            amount     = ls_paymentamount-amount   ).

              COLLECT ls_currency_total INTO lt_currency_totals.

            ENDLOOP.


            READ TABLE data ASSIGNING FIELD-SYMBOL(<lfs_data>) WITH KEY paymentorder = lv_paymentorder.


            DATA: lt_json_parts TYPE TABLE OF string, "Table to store individual JSON parts for payments
                  iv_json_data  TYPE string.

            LOOP AT lt_currency_totals ASSIGNING FIELD-SYMBOL(<lfs_currencyamount>).
              READ TABLE lt_currency_counts ASSIGNING FIELD-SYMBOL(<lfs_count>) WITH KEY currency = <lfs_currencyamount>-currency.

*        REPLACE ALL OCCURRENCES OF ',' IN <lfs_currencyAmount>- WITH '.'.


              DATA(payment_json) = |{ <lfs_data>-paymentorder } - { <lfs_data>-paymentdate } - { <lfs_count>-count } - { <lfs_currencyamount>-amount } - { <lfs_currencyamount>-currency }|.
              APPEND payment_json TO lt_json_parts.

            ENDLOOP.

            DATA: lt_dynamic_data TYPE TABLE OF string,
                  lv_body_data    TYPE string,
                  lv_payment_line TYPE string.

            DATA: lv_company   TYPE string,
                  lv_type(1)   TYPE c,
                  lv_eventtype TYPE string.


            SELECT
                 j~companycodename,
                 j~companycode
                FROM i_companycode AS j
                INTO TABLE @DATA(lt_table).

            READ TABLE lt_table WITH KEY companycode = <lfs_data>-payercompany TRANSPORTING NO FIELDS.

            IF sy-subrc = 0.

              CASE <lfs_data>-payercompany.
                WHEN '3001'.
                  lv_eventtype = 'Univora '.
                WHEN '3002'.
                  lv_eventtype = 'Triovent'.
                WHEN '3003'.
                  lv_eventtype = 'Trinexus'.
                WHEN '3004'.
                  lv_eventtype = 'Quadrix'.
                WHEN '3005'.
                  lv_eventtype = 'Quintora'.
                WHEN '3006'.
                  lv_eventtype = 'Hexalis'.
                WHEN '3007'.
                  lv_eventtype = 'Septenox'.
                WHEN '3101'.
                  lv_eventtype = 'Onixis'.
                WHEN '3102'.
                  lv_eventtype = 'Binovex'.
                WHEN '3103'.
                  lv_eventtype = 'Trivexis'.
                WHEN '3201'.
                  lv_eventtype = 'Duoventis'.
                WHEN '3202'.
                  lv_eventtype = 'Quadrisys'.
                WHEN '3203'.
                  lv_eventtype = 'Triovex'.
                WHEN '3301'.
                  lv_eventtype = 'Trionis'.
                WHEN '3302'.
                  lv_eventtype = 'Tetravox'.
                WHEN '3303'.
                  lv_eventtype = 'Pentaris'.
                WHEN '3304'.
                  lv_eventtype = 'Hexora'.
                WHEN '3305'.
                  lv_eventtype = 'Septanova'.
                WHEN '3306'.
                  lv_eventtype = 'Octavex'.
                WHEN '3307'.
                  lv_eventtype = 'Nonovent'.
                WHEN '3308'.
                  lv_eventtype = 'Decadyn'.
                WHEN '3401'.
                  lv_eventtype = 'Tetraflux'.
                WHEN '7000'.
                  lv_eventtype = 'MyDemoEventType'.
              ENDCASE.

            ENDIF.

            DATA(lv_islemegonder) = 'Ödeme Kokpiti - Talep Edildi - '.

            SELECT SINGLE paymenttypedesc
              FROM zfi_paymenttype
              WHERE paymenttype EQ @<lfs_data>-paymenttype
              INTO @DATA(lv_paymenttypedesc).


              iv_json_data = '{' &&
                             '"eventType":"' && lv_eventtype && '",' &&
                             '"resource":{' &&
                         '"resourceName": "' && lv_islemegonder && <lfs_data>-payercompanyname && '",' &&
                             '"resourceType": "app"' &&
                             '},' &&
                             '"severity": "INFO",' &&
                             '"category": "NOTIFICATION",' &&
                            '"subject": "' && lv_paymentorder &&
  ' numaralı ödeme talimatı Finans departmanı tarafından işlenmek üzere Eren Holding Ödeme Kokpiti ekranlarına aktarılmıştır. Aşağıda ilgili ödeme talimatı için özet bilgileri bulabilirsiniz.",' &&
                             '"body": " Ödeyen Firma: ' && | | && <lfs_data>-payercompanyname && | , | &&
                             ' Ödeme Tarihi: ' && | | && <lfs_data>-paymentdate && | , | &&
                             ' Ödeme Tipi: ' && | | && lv_paymenttypedesc && | , | &&
                             ' Toplam Tutar: ' && | | && <lfs_data>-amounttotal && | , | &&
                             ' Toplam Kalem: ' && | | && <lfs_data>-itemtotal && | , | &&
                             ' Para Birimi: ' && | | && <lfs_currencyamount>-currency && ' "' &&
                             '}'.
              LOOP AT lt_json_parts INTO lv_payment_line.

                lv_body_data = lv_body_data && lv_payment_line && '\n'.
              ENDLOOP.

              IF strlen( lv_body_data ) > 0.
                SHIFT lv_body_data BY -1 PLACES.
              ENDIF.

              DATA(iv_url) = 'https://clm-sl-ans-live-ans-service-api.cfapps.eu10.hana.ondemand.com/cf/producer/v1/resource-events'.
              DATA(url) = |{ iv_url }|.


              TRY.
                  DATA(dest)   = cl_http_destination_provider=>create_by_url( url ).
                CATCH cx_http_dest_provider_error.
                  "handle exception
              ENDTRY.
              TRY.
                  DATA(client) = cl_web_http_client_manager=>create_by_http_destination( dest ).
                CATCH cx_web_http_client_error.
                  "handle exception
              ENDTRY.
              DATA(req) = client->get_http_request(  ).
              req->set_authorization_basic( i_username = 'd6029506-4c90-4215-8ed3-84eca1c62078'
                                            i_password = 'FLSjVl8TaHYA6IZHTVV95v4tJwIp1qlV' ).
              req->set_header_fields( VALUE #( (  name = 'Content-Type'    value = 'application/json' )
                                               ) ).

              req->set_text( iv_json_data ).
              TRY.
                  DATA(http_response) = client->execute( if_web_http_client=>post ).
                CATCH cx_web_http_client_error.
                  "handle exception
              ENDTRY.
              DATA(get_text)   = http_response->get_text(  ).
              DATA(get_status) = http_response->get_status(  ).

            ENDIF.
          ELSE.

            READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
                    ENTITY zfi_i_header_df
                    FIELDS ( paymentorder status ) WITH CORRESPONDING #( keys )
                    RESULT lt_status.


            LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<lfs_statuss>).

              IF <lfs_statuss>-status EQ '10'.

                MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
                   ENTITY zfi_i_header_df " Alias
                   UPDATE
                   FIELDS ( status )
                   WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '20' ) )
                   FAILED DATA(lt_failed2)
                   REPORTED DATA(lt_reporteds).

                READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
              ENTITY zfi_i_item_df
                ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(lt_result2)
              FAILED DATA(ls_failed2)
              REPORTED DATA(ls_reported3).

                READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
                ENTITY zfi_i_header_df
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT data.
                result = VALUE #( FOR datarec IN data
                ( %tky = datarec-%tky %param = datarec )  ).
              ENDIF.
            ENDLOOP.


            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text = <lfs_status>-paymentorder && || && ' değeri önceden işlendi.Değiştirilemez.'
                    ) )

                    TO reported-zfi_i_header_df.


          ENDIF.
        ENDLOOP.

        ENDIF.
*      ENDLOOP.
*      ENDIF.
    ELSE.
      READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
        ENTITY zfi_i_header_df
        FIELDS ( paymentorder status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_statuss).


      LOOP AT lt_statuss ASSIGNING FIELD-SYMBOL(<lfs_status2>).

        IF <lfs_status2>-status EQ '10'.

          MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
             ENTITY zfi_i_header_df " Alias
             UPDATE
             FIELDS ( status )
             WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '20' ) )
             FAILED DATA(lt_faileds)
             REPORTED DATA(lt_reported2).

          READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
        ENTITY zfi_i_item_df
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_results)
        FAILED DATA(ls_faileds)
        REPORTED DATA(ls_reporteds).

          READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
          ENTITY zfi_i_header_df
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(datas).
          result = VALUE #( FOR datarec IN datas
          ( %tky = datarec-%tky %param = datarec )  ).

*          APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text = 'Test ortamında mail gönderilmez'
*                        ) )
*
*                        TO reported-zfi_i_header_df.
        ENDIF.
      ENDLOOP.
    ENDIF.
    ENDMETHOD.

    METHOD backadminted.

      READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
      ENTITY zfi_i_header_df
      FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_status).

      LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<lfs_status>).

        IF <lfs_status>-status EQ '20'.

          MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
           ENTITY zfi_i_header_df " Alias
           UPDATE
           FIELDS ( status )
           WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '10' ) )
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).


          READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
          ENTITY zfi_i_header_df
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(data).
          result = VALUE #( FOR datarec IN data
          ( %tky = datarec-%tky %param = datarec )  ).

        ELSEIF <lfs_status>-status EQ '10'.

          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text = 'Talimat işleme alınmadı.'
                    ) )

                    TO reported-zfi_i_header_df.

        ELSEIF <lfs_status>-status EQ '30'.

          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text = 'Durum alanı ''30'' ise değişiklik yapılamaz!'
                    ) )

                    TO reported-zfi_i_header_df.
        ENDIF.
      ENDLOOP.
    ENDMETHOD.

    METHOD vcounrty.
    ENDMETHOD.


    METHOD delete.

      READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
      ENTITY zfi_i_header_df
      FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_status).

      LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<lfs_status>).

        DATA(lv_status) = <lfs_status>-status.

      ENDLOOP.


      IF lv_status EQ '10'.

        MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
           ENTITY zfi_i_header_df " Alias
           UPDATE
           FIELDS ( used )
           WITH VALUE #( FOR key IN  keys ( %tky = key-%tky used = 'Y' ) )
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).


        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text = 'Silme işlemi başarılı!'
                        ) )

                        TO reported-zfi_i_header_df.


        READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
        ENTITY zfi_i_header_df
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(data).
        result = VALUE #( FOR datarec IN data
        ( %tky = datarec-%tky %param = datarec )  ).


      ELSE.


        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        text = 'Durum alanı ''20'' ise silinemez!'
                        severity = if_abap_behv_message=>severity-error

                        ) )
                        TO reported-zfi_i_header_df.
      ENDIF.

    ENDMETHOD.




    METHOD get_global_features.

      result-%update = if_abap_behv=>fc-o-disabled.


    ENDMETHOD.



    METHOD vcostname.

      DATA: lt_item         TYPE TABLE OF zfi_db_item,
            lv_paymentorder TYPE zfi_db_root-paymentorder,
            lv_status       TYPE zfi_db_item-status,
            lv_all_items_ok TYPE abap_bool.

      READ ENTITIES OF zfi_i_header_df IN LOCAL MODE
          ENTITY zfi_i_header_df
          FIELDS ( paymentorder status )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_header).

      DELETE lt_header WHERE status <> 30.

      LOOP AT lt_header INTO DATA(ls_header).


        lv_paymentorder = ls_header-paymentorder.
        lv_all_items_ok = abap_true.  " Varsayılan olarak tüm item'ler ok

        " paymentorder ile ilişkili item'leri alalım
        SELECT * FROM zfi_db_item
          WHERE paymentorder = @lv_paymentorder
          INTO TABLE @lt_item.

          LOOP AT lt_item INTO DATA(ls_item).
            " Eğer item'in status'u 40 değilse, bu item'i kontrol etmiyoruz
            IF ls_item-status <> '40'.
              CONTINUE.  " 40 olmayan item'leri atla
            ENDIF.

            " Eğer item'in status'u 40 ise kontrol etmeye devam et
            lv_all_items_ok = abap_true.
            EXIT.
          ENDLOOP.

          " Eğer tüm item'lerin status'u 40 ise header status'u da 95 yapalım
          IF lv_all_items_ok = abap_true.
            " ENTITIES ile güncelleme yapıyoruz
            MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
           ENTITY zfi_i_header_df " Alias
           UPDATE
           FIELDS ( status )
           WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '95' ) )
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).


          ENDIF.

        ENDLOOP.



      ENDMETHOD.

ENDCLASS.
