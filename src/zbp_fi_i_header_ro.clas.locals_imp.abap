CLASS lhc_zfi_i_item_ro DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zfi_i_item_ro RESULT result.

ENDCLASS.

CLASS lhc_zfi_i_item_ro IMPLEMENTATION.

  METHOD get_global_features.
    result-%update = if_abap_behv=>fc-o-disabled.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_zfi_i_header_ro DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_i_header_ro RESULT result.
    METHODS setadminted FOR MODIFY
      IMPORTING keys FOR ACTION zfi_i_header_ro~setadminted RESULT result.
    METHODS backadminted FOR MODIFY
      IMPORTING keys FOR ACTION zfi_i_header_ro~backadminted RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zfi_i_header_ro RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfi_i_header_ro RESULT result.
    METHODS undo FOR MODIFY
      IMPORTING keys FOR ACTION zfi_i_header_ro~undo RESULT result.

ENDCLASS.

CLASS lhc_zfi_i_header_ro IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
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
      ls_currency_count  TYPE ty_currency_count,
      lv_paymentorder    TYPE zfi_db_root-paymentorder.

    DATA : lt_paymentamount   TYPE TABLE OF ty_payment_info,
           ls_paymentamount   TYPE ty_payment_info,
           lv_total           TYPE p DECIMALS 2,
*           lv_amount          TYPE p DECIMALS 2,
           lt_currency_totals TYPE TABLE OF ty_currency_amount,
           ls_currency_total  TYPE ty_currency_amount.


    DATA: iv_json_data TYPE string.

    DATA: lt_dynamic_data TYPE TABLE OF string,
          lv_body_data    TYPE string,
          lv_payment_line TYPE string,
          lv_eventtype    TYPE string.


    DATA lv_button_active TYPE abap_bool VALUE abap_true.
    READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
    ENTITY zfi_i_header_ro
    FIELDS ( status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lv_status).

    LOOP AT lv_status ASSIGNING FIELD-SYMBOL(<lfs_status>).
      IF <lfs_status>-status EQ '20'.
        MODIFY ENTITIES OF zfi_i_header_ro IN LOCAL MODE
        ENTITY zfi_i_header_ro " Alias
        UPDATE
        FIELDS ( status )
        WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '30' ) )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).


        READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
        ENTITY zfi_i_header_ro
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(data).
        result = VALUE #( FOR datarec IN data
        ( %tky = datarec-%tky %param = datarec )  ).

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

          ls_currency_total = VALUE #(  currency   = ls_paymentamount-currency
                                        amount     = ls_paymentamount-amount   ).
          COLLECT ls_currency_total INTO lt_currency_totals.

        ENDLOOP.


        READ TABLE data ASSIGNING FIELD-SYMBOL(<lfs_data>) WITH KEY paymentorder = lv_paymentorder.


        DATA: lt_json_parts TYPE TABLE OF string.

        LOOP AT lt_currency_totals ASSIGNING FIELD-SYMBOL(<lfs_currencyamount>).
          READ TABLE lt_currency_counts ASSIGNING FIELD-SYMBOL(<lfs_count>) WITH KEY currency = <lfs_currencyamount>-currency.


          DATA: body_json_array TYPE string,
                lt_body_json    TYPE TABLE OF string.

          " Create a properly quoted JSON string for each payment entry
          DATA(payment_json) = |"{ <lfs_data>-paymentorder } - { <lfs_data>-paymentdate } - { <lfs_count>-count } - { <lfs_currencyamount>-amount } - { <lfs_currencyamount>-currency }"|.
          APPEND payment_json TO lt_body_json.
        ENDLOOP.


        LOOP AT lt_body_json INTO lv_payment_line.
          IF body_json_array IS INITIAL.
            body_json_array = lv_payment_line.
          ELSE.
            body_json_array = body_json_array && ',' && lv_payment_line.
          ENDIF.
        ENDLOOP.

        SELECT
             j~companycodename,
             j~companycode
            FROM i_companycode AS j
            INTO TABLE @DATA(lt_table).

        READ TABLE lt_table WITH KEY companycode = <lfs_data>-payercompany TRANSPORTING NO FIELDS.

        IF sy-subrc = 0.

          CASE <lfs_data>-payercompany.
            WHEN '3001'.
              lv_eventtype = 'Spark'.
            WHEN '3002'.
              lv_eventtype = 'Breeze'.
            WHEN '3003'.
              lv_eventtype = 'Chalk'.
            WHEN '3004'.
              lv_eventtype = 'Mystic'.
            WHEN '3005'.
              lv_eventtype = 'Compass'.
            WHEN '3006'.
              lv_eventtype = 'Summit'.
            WHEN '3007'.
              lv_eventtype = 'Scalpel'.
            WHEN '3101'.
              lv_eventtype = 'Harmony'.
            WHEN '3102'.
              lv_eventtype = 'Shadow'.
            WHEN '3103'.
              lv_eventtype = 'Ocean'.
            WHEN '3201'.
              lv_eventtype = 'Trione'.
            WHEN '3202'.
              lv_eventtype = 'Echo'.
            WHEN '3203'.
              lv_eventtype = 'Marble'.
            WHEN '3301'.
              lv_eventtype = 'Orbit'.
            WHEN '3302'.
              lv_eventtype = 'Fable'.
            WHEN '3303'.
              lv_eventtype = 'Vortex'.
            WHEN '3304'.
              lv_eventtype = 'Cipher'.
            WHEN '3305'.
              lv_eventtype = 'Tundra'.
            WHEN '3306'.
              lv_eventtype = 'Quartz'.
            WHEN '3307'.
              lv_eventtype = 'Frost'.
            WHEN '3308'.
              lv_eventtype = 'Mirage'.
            WHEN '3401'.
              lv_eventtype = 'Nimbus'.
            WHEN '7000'.
              lv_eventtype = 'Septamill'.
          ENDCASE.

        ENDIF.
        SELECT SINGLE
                  paymenttypedesc
                  FROM zfi_paymenttype
                  WHERE paymenttype EQ @<lfs_data>-paymenttype
                  INTO @DATA(lv_paymenttypedesc).

        DATA(lv_text) = 'Ödeme Kokpiti - İşleme Alındı - '.
*        ** Construct the final JSON payload
        iv_json_data = '{' &&
                       '"eventType":"' && lv_eventtype && '",' &&
                       '"resource":{' &&
                       '"resourceName": "' && lv_text && <lfs_data>-payercompanyname && '",' &&
                       '"resourceType": "app"' &&
                       '},' &&
                       '"severity": "INFO",' &&
                       '"category": "NOTIFICATION",' &&
                       '"subject": "' && lv_paymentorder && ' numaralı ödeme talimatı Finans departmanı tarafından işleme alınmıştır. Aşağıda ilgili ödeme talimatı için özet bilgileri bulabilirsiniz.",' &&
                      '"body": " Ödeyen Firma: ' && | | && <lfs_data>-payercompanyname && |, | &&  'Ödeme Tarihi:' && | | && <lfs_data>-paymentdate && |, | &&  ' Ödeme Tipi: ' && | | && lv_paymenttypedesc && |, | &&
                      ' Toplam Tutar: ' && | | &&  <lfs_data>-Amounttotal && |, | &&
                      ' Toplam Kalem: ' && | | && <lfs_data>-itemtotal && | , | &&
                      ' Para Birimi:' && | | && <lfs_currencyamount>-currency && ' "'.
        iv_json_data = iv_json_data && '}'.




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


      ELSE.

        APPEND VALUE #( %tky = <lfs_status>-%tky ) TO failed-zfi_i_header_ro.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                  %msg = new_message_with_text(
                  severity = if_abap_behv_message=>severity-error
                  text = ' Güncelleme yalnız Durum alanı 20 ise yapılabilir.'
                  ) )

                  TO reported-zfi_i_header_ro.

      ENDIF.


    ENDLOOP.

    ELSE.
      READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
          ENTITY zfi_i_header_ro
          FIELDS ( status ) WITH CORRESPONDING #( keys )
          RESULT DATA(lv_status2).


      LOOP AT lv_status2 ASSIGNING FIELD-SYMBOL(<lfs_status2>).
        IF <lfs_status2>-status EQ '20'.
          MODIFY ENTITIES OF zfi_i_header_ro IN LOCAL MODE
          ENTITY zfi_i_header_ro " Alias
          UPDATE
          FIELDS ( status )
          WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '30' ) )
          FAILED DATA(lt_failed2)
          REPORTED DATA(lt_reported2).


          READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
          ENTITY zfi_i_header_ro
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(data_v).
          result = VALUE #( FOR datarec IN data_v
          ( %tky = datarec-%tky %param = datarec )  ).



        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD backadminted.
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
        ls_currency_count  TYPE ty_currency_count,
        lv_paymentorder    TYPE zfi_db_root-paymentorder.

      DATA : lt_paymentamount   TYPE TABLE OF ty_payment_info,
             ls_paymentamount   TYPE ty_payment_info,
             lv_total           TYPE p DECIMALS 2,
*           lv_amount          TYPE p DECIMALS 2,
             lt_currency_totals TYPE TABLE OF ty_currency_amount,
             ls_currency_total  TYPE ty_currency_amount.


      LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_message>).

        DATA(lv_message) = <lfs_message>-%param-reason.
      ENDLOOP.

      READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
      ENTITY zfi_i_header_ro
      FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_status).

      LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<lfs_status_v2>).

        IF <lfs_status_v2>-status EQ '20'.

          MODIFY ENTITIES OF zfi_i_header_ro IN LOCAL MODE
             ENTITY zfi_i_header_ro " Alias
             UPDATE
             FIELDS ( status processdescription )
             WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '35' processdescription = lv_message ) )
             FAILED DATA(lt_failed)
             REPORTED DATA(lt_reported).


          READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
          ENTITY zfi_i_header_ro
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(data).
          result = VALUE #( FOR datarec IN data
          ( %tky = datarec-%tky %param = datarec )  ).

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

            ls_currency_total = VALUE #(  currency   = ls_paymentamount-currency
                                          amount     = ls_paymentamount-amount   ).
            COLLECT ls_currency_total INTO lt_currency_totals.

          ENDLOOP.


          READ TABLE data ASSIGNING FIELD-SYMBOL(<lfs_data>) WITH KEY paymentorder = lv_paymentorder.


          DATA: lt_json_parts TYPE TABLE OF string, "Table to store individual JSON parts for payments
                iv_json_data  TYPE string.

          LOOP AT lt_currency_totals ASSIGNING FIELD-SYMBOL(<lfs_currencyamount>).
            READ TABLE lt_currency_counts ASSIGNING FIELD-SYMBOL(<lfs_count>) WITH KEY currency = <lfs_currencyamount>-currency.


            DATA: body_json_array TYPE string,
                  lt_body_json    TYPE TABLE OF string.

            DATA: lt_dynamic_data TYPE TABLE OF string,
                  lv_body_data    TYPE string,
                  lv_payment_line TYPE string,
                  lv_eventtype    TYPE string. " Table to hold JSON body data


            " Create a properly quoted JSON string for each payment entry
            DATA(payment_json) = |"{ <lfs_data>-paymentorder } - { <lfs_data>-paymentdate } - { <lfs_count>-count } - { <lfs_currencyamount>-amount } - { <lfs_currencyamount>-currency }"|.
            APPEND payment_json TO lt_body_json.
          ENDLOOP.


          LOOP AT lt_body_json INTO lv_payment_line.
            IF body_json_array IS INITIAL.
              body_json_array = lv_payment_line.
            ELSE.
              body_json_array = body_json_array && ',' && lv_payment_line.
            ENDIF.
          ENDLOOP.

          SELECT
               j~companycodename,
               j~companycode
              FROM i_companycode AS j
              INTO TABLE @DATA(lt_table).

          READ TABLE lt_table WITH KEY companycode = <lfs_data>-payercompany TRANSPORTING NO FIELDS.

          IF sy-subrc = 0.

            CASE <lfs_data>-payercompany.
              WHEN '3001'.
                lv_eventtype = 'Vensar '.
              WHEN '3002'.
                lv_eventtype = 'Orvex'.
              WHEN '3003'.
                lv_eventtype = 'Mirdan'.
              WHEN '3004'.
                lv_eventtype = 'Lunor'.
              WHEN '3005'.
                lv_eventtype = 'Xentis'.
              WHEN '3006'.
                lv_eventtype = 'Brayen'.
              WHEN '3007'.
                lv_eventtype = 'Zyphar'.
              WHEN '3101'.
                lv_eventtype = 'Tivex'.
              WHEN '3102'.
                lv_eventtype = 'Frodan'.
              WHEN '3103'.
                lv_eventtype = 'Quorel'.
              WHEN '3201'.
                lv_eventtype = 'Javon'.
              WHEN '3202'.
                lv_eventtype = 'Sernix'.
              WHEN '3203'.
                lv_eventtype = 'Targel'.
              WHEN '3301'.
                lv_eventtype = 'Lurex'.
              WHEN '3302'.
                lv_eventtype = 'Grivon'.
              WHEN '3303'.
                lv_eventtype = 'Xalor'.
              WHEN '3304'.
                lv_eventtype = 'Pryzon'.
              WHEN '3305'.
                lv_eventtype = 'Darnis'.
              WHEN '3306'.
                lv_eventtype = 'Moxen'.
              WHEN '3307'.
                lv_eventtype = 'Havex'.
              WHEN '3308'.
                lv_eventtype = 'Yarven'.
              WHEN '3401'.
                lv_eventtype = 'Zirnox'.
              WHEN '7000'.
                lv_eventtype = 'Velmox'.
            ENDCASE.

          ENDIF.
          SELECT SINGLE
                    paymenttypedesc
                    FROM zfi_paymenttype
                    WHERE paymenttype EQ @<lfs_data>-paymenttype
                    INTO @DATA(lv_paymenttypedesc).


* Construct the final JSON payload

DATA(lv_islemealma) = 'Ödeme Kokpiti - İşleme Alınmadı - '.
          iv_json_data = '{' &&
                         '"eventType":"' && lv_eventtype && '",' &&
                         '"resource":{' &&
                       '"resourceName": "' && lv_islemealma && <lfs_data>-payercompanyname && '",' &&
                         '"resourceType": "app"' &&
                         '},' &&
                         '"severity": "INFO",' &&
                         '"category": "NOTIFICATION",' &&
                         '"subject": "' && lv_paymentorder && ' numaralı ödeme talimatı Finans departmanı tarafından ' && | '{ lv_message }' | && ' gerekçesiyle işleme alınmamıştır. Aşağıda ilgili ödeme talimatı için özet bilgileri bulabilirsiniz.",' &&
                        '"body": " Ödeyen Firma: ' && | | && <lfs_data>-payercompanyname && |, | &&  'Ödeme Tarihi:' && | | && <lfs_data>-paymentdate && |, | &&  ' Ödeme Tipi: ' && | | && lv_paymenttypedesc && |, | &&
                        ' Toplam Tutar: ' && | | &&  <lfs_data>-Amounttotal && |, | &&
                        ' Toplam Kalem: ' && | | && <lfs_data>-itemtotal && | , | &&
                        ' Para Birimi:' && | | && <lfs_currencyamount>-currency && ' "'.
          iv_json_data = iv_json_data && '}'.




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

        ELSE.


          APPEND VALUE #( %tky = <lfs_status_v2>-%tky ) TO failed-zfi_i_header_ro.
          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                    %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text = ' Güncelleme yalnız Durum alanı 20 ise yapılabilir.'
                    ) )

                    TO reported-zfi_i_header_ro.

        ENDIF.
      ENDLOOP.


      READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
      ENTITY zfi_i_header_ro
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(data_v2).
      result = VALUE #( FOR datarec IN data_v2
      ( %tky = datarec-%tky %param = datarec )  ).

    ELSE.
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_message3>).

        DATA(lv_message3) = <lfs_message3>-%param-reason.
      ENDLOOP.

      READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
      ENTITY zfi_i_header_ro
      FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_status3).

      LOOP AT lt_status3 ASSIGNING FIELD-SYMBOL(<lfs_status_v23>).

        IF <lfs_status_v23>-status EQ '20'.

          MODIFY ENTITIES OF zfi_i_header_ro IN LOCAL MODE
             ENTITY zfi_i_header_ro " Alias
             UPDATE
             FIELDS ( status processdescription )
             WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '35' processdescription = lv_message3 ) )
             FAILED DATA(lt_failed3)
             REPORTED DATA(lt_reported3).


          READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
          ENTITY zfi_i_header_ro
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(data3).
          result = VALUE #( FOR datarec IN data3
          ( %tky = datarec-%tky %param = datarec )  ).

          LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys3>).
            lv_paymentorder = <lfs_keys3>-paymentorder.
          ENDLOOP.

        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD get_global_features.

    result-%update = if_abap_behv=>fc-o-disabled.

  ENDMETHOD.

  METHOD undo.

    READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
    ENTITY zfi_i_header_ro
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).

      IF <lfs_data>-status EQ '30'.

        MODIFY ENTITIES OF zfi_i_header_ro IN LOCAL MODE
        ENTITY zfi_i_header_ro " Alias
        UPDATE
        FIELDS ( status )
        WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '20' ) )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

      ELSEIF <lfs_data>-status EQ '35'.

        MODIFY ENTITIES OF zfi_i_header_ro IN LOCAL MODE
        ENTITY zfi_i_header_ro " Alias
        UPDATE
        FIELDS ( status )
        WITH VALUE #( FOR key IN  keys ( %tky = key-%tky status = '20' ) )
        FAILED DATA(lt_faileds)
        REPORTED DATA(lt_reporteds).

      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zfi_i_header_ro IN LOCAL MODE
    ENTITY zfi_i_header_ro
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(data).
    result = VALUE #( FOR datarec IN data
    ( %tky = datarec-%tky %param = datarec )  ).

  ENDMETHOD.

ENDCLASS.
