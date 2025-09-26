CLASS zcl_job_updatedoc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: iv_json_data   TYPE string,
          lt_data        TYPE REF TO data,
          lv_token       TYPE string,
          lt_data_status TYPE REF TO data,
          lv_docno       TYPE string,
          lv_docstr      TYPE string.


    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JOB_UPDATEDOC IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.


*
*GET tokene

*    DATA(lv_url)  = 'https://yoda.paperzero.com/token'.
    DATA(lv_url)  = 'https://erenholdingtest.test.apimanagement.us10.hana.ondemand.com/Paperzero/Token'.
    DATA(lv_body) = |username=finans.odeme@erenholding.com.tr&password=Eren3434@&grant_type=password|.
*    DATA(iv_url) = 'https://erenholdingtest.test.apimanagement.us10.hana.ondemand.com:443/Paperzero/TokenProd'.

    DATA(url) = |{ lv_url }|.

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

*    req->set_authorization_basic( i_username = 'berkecan.erten@montag.com.tr'
*                                  i_password = 'Montag2024**' ).

    req->set_header_field( i_name = 'Content-Type' i_value = 'application/x-www-form-urlencoded' ).
    req->set_text( lv_body ).


    DATA(http_response) = client->execute( if_web_http_client=>post ).

    DATA(get_text)   = http_response->get_text(  ).
    DATA(get_status) = http_response->get_status(  ).


    IF get_status-code EQ '200'.
      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json         = get_text
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        CHANGING
          data         = lt_data.


      FIELD-SYMBOLS:
        <sdata>        TYPE data,
        <sresults>     TYPE any,
        <sfield>       TYPE any,
        <sfield_value> TYPE data.

      IF lt_data IS BOUND.
        ASSIGN lt_data->* TO <sdata>.
        ASSIGN COMPONENT `ACCESS_TOKEN` OF STRUCTURE <sdata> TO <sresults>.
        ASSIGN <sresults>->* TO <sdata>.
        IF <sdata> IS ASSIGNED.
          lv_token = <sdata>.
        ENDIF.
      ENDIF.
    ENDIF.

    SELECT
    *
    FROM zfi_pymbtch_bank AS bank
    WHERE pzmessage EQ 'Tamamlanmadı'
    INTO TABLE @DATA(lt_bank).

    SORT lt_bank BY paymentbatch DESCENDING.


    LOOP AT lt_bank ASSIGNING FIELD-SYMBOL(<lfs_bank>).

*      DATA(lv_status_url) = |https://erenholdingtest.test.apimanagement.us10.hana.ondemand.com:443/PaperZero/GetDocumentStatusByNo?processNumber={ <lfs_bank>-documentno }|.
      DATA(lv_status_url) = |https://yodauat.paperzero.com/v1/Document/GetDocumentStatusByNo?processNumber={ <lfs_bank>-documentno }|.
      DATA(url_status) = |{ lv_status_url }|.

      TRY.
          DATA(dest_status)   = cl_http_destination_provider=>create_by_url( url_status ).
        CATCH cx_http_dest_provider_error.
          "handle exception
      ENDTRY.
      TRY.
          DATA(client_status) = cl_web_http_client_manager=>create_by_http_destination( dest_status ).
        CATCH cx_web_http_client_error.
          "handle exception
      ENDTRY.

      DATA(req_status) = client_status->get_http_request(  ).

      req_status->set_authorization_bearer( i_bearer = lv_token ).

      TRY.
          DATA(http_response_status) = client_status->execute( if_web_http_client=>get ).
        CATCH cx_web_http_client_error.
          "handle exception
      ENDTRY.

      DATA(get_text_status)   = http_response_status->get_text(  ).
      DATA(get_status_code)   = http_response_status->get_status(  ).

      IF get_status-code EQ '200'.
        CALL METHOD /ui2/cl_json=>deserialize
          EXPORTING
            json         = get_text_status
            pretty_name  = /ui2/cl_json=>pretty_mode-user
            assoc_arrays = abap_true
          CHANGING
            data         = lt_data_status.


        FIELD-SYMBOLS:
          <data>        TYPE data,
          <results>     TYPE any,
          <field>       TYPE any,
          <field_value> TYPE data.


        IF lt_data_status IS BOUND.
          ASSIGN lt_data_status->* TO <data>.
          ASSIGN COMPONENT `DOCUMENTSTATUS` OF STRUCTURE <data> TO <results>.
          ASSIGN <results>->* TO <data>.
          IF <data> IS ASSIGNED.
            lv_docstr  = <data>.

            UPDATE zfi_pymbtch_bank
               SET pzmessage = @lv_docstr
             WHERE paymentbatch = @<lfs_bank>-paymentbatch.




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

            READ TABLE lt_table WITH KEY companycode = <lfs_bank>-companycode TRANSPORTING NO FIELDS.

            IF sy-subrc = 0.

              CASE <lfs_bank>-companycode.
                WHEN '3001'.
                  lv_eventtype = 'Spark '.
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
                  lv_eventtype = 'Spark'.
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


            SELECT SINGLE
             comp~companycodename
             FROM i_companycode AS comp
             WHERE companycode EQ @<lfs_bank>-companycode
             INTO  @DATA(lv_code).

            DATA(lv_islemegonder) = 'Ödeme Paketlerini Aktar'.



            iv_json_data = '{' &&
              '"eventType":"' && lv_eventtype && '",' &&
              '"resource":{' &&
              '"resourceName": "' && lv_islemegonder && '",' &&
              '"resourceType": "app"' &&
              '},' &&
              '"severity": "INFO",' &&
              '"category": "NOTIFICATION",' &&
              '"subject": "' && lv_code && '  ' && <lfs_bank>-iban &&
              ' banka hesabından ' && <lfs_bank>-paymentbatch &&
              ' numaralı ödeme talepleri için aşağıdaki işlemler bankaya iletilmiştir.",' &&
              '"body": "Ödeyen Firma: ' && lv_code &&
              ', Ödeme Tarihi: ' && <lfs_bank>-paymentdatepb &&
              ', Ödeme Tipi: ' && <lfs_bank>-paymenttype &&
              ', Toplam Tutar: ' && <lfs_bank>-totalamount &&
              ', Toplam Kalem: ' && <lfs_bank>-totalitem &&
              '"}'.


            IF strlen( lv_body_data ) > 0.
              SHIFT lv_body_data BY -1 PLACES.
            ENDIF.

            DATA(iv_url) = 'https://clm-sl-ans-live-ans-service-api.cfapps.eu10.hana.ondemand.com/cf/producer/v1/resource-events'.
            DATA(url_mail) = |{ iv_url }|.


            TRY.
                DATA(dest2)   = cl_http_destination_provider=>create_by_url( url_mail ).
              CATCH cx_http_dest_provider_error.
                "handle exception
            ENDTRY.
            TRY.
                DATA(client2) = cl_web_http_client_manager=>create_by_http_destination( dest2 ).
              CATCH cx_web_http_client_error.
                "handle exception
            ENDTRY.
            DATA(req2) = client2->get_http_request(  ).
            req2->set_authorization_basic( i_username = 'd6029506-4c90-4215-8ed3-84eca1c62078'
                                          i_password = 'FLSjVl8TaHYA6IZHTVV95v4tJwIp1qlV' ).
            req2->set_header_fields( VALUE #( (  name = 'Content-Type'    value = 'application/json' )
                                             ) ).

            req2->set_text( iv_json_data ).
            TRY.
                DATA(http_responses) = client2->execute( if_web_http_client=>post ).
              CATCH cx_web_http_client_error.
                "handle exception
            ENDTRY.
            DATA(get_text2)   = http_responses->get_text(  ).
            DATA(get_status2) = http_responses->get_status(  ).

          ENDIF.

          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.


  ENDMETHOD.
ENDCLASS.
