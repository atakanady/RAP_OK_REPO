CLASS lhc_zfi_i_onaydos DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    DATA: lv_token    TYPE string,
          lt_listrepo TYPE REF TO data,
          lv_folderid TYPE string,
          lv_repoid   TYPE string,
          lv_boundary TYPE string VALUE '----WebKitFormBoundary7MA4YWxkTrZu0gW',
          lt_data_v2  TYPE REF TO data,
          len         TYPE i,
          lt_data_v3  TYPE REF TO data,
          lv_docid    TYPE string.

    DATA: lt_tab TYPE TABLE OF  zfi_api_onaydos,
          ls_tab TYPE zfi_api_onaydos.

  PRIVATE SECTION.
    CONSTANTS scms_string_to_xstring TYPE string VALUE 'SCMS_STRING_TO_XSTRING'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_i_onaydos RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zfi_i_onaydos.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zfi_i_onaydos.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zfi_i_onaydos.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfi_i_onaydos RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zfi_i_onaydos.

ENDCLASS.

CLASS lhc_zfi_i_onaydos IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      SELECT SINGLE header
   FROM zfi_db_doc
   WHERE header       = @<fs_entity>-paymentorder
     AND item  = @<fs_entity>-Paymentline
   INTO @DATA(lv_existing).

      IF sy-subrc = 0.
        APPEND VALUE #( %key = <fs_entity>-%key ) TO failed-zfi_i_onaydos.
        APPEND VALUE #(
          %key = <fs_entity>-%key
          %msg = new_message(
            id       = 'ZFI'
            number   = '001'
            severity = if_abap_behv_message=>severity-error
            v1       = |Aynı Paymentorder ve Paymentline zaten mevcut: { <fs_entity>-paymentorder } / { <fs_entity>-paymentline }|
          )
        ) TO reported-zfi_i_onaydos.
      ENDIF.


      IF <fs_entity>-filetype <> 'PDF'.
        APPEND VALUE #( %key = <fs_entity>-%key ) TO failed-zfi_i_onaydos.
        APPEND VALUE #(
          %key = <fs_entity>-%key
          %msg = new_message(
            id      = 'ZFI'
            number  = '002'
            severity = if_abap_behv_message=>severity-error
            v1      = |Geçersiz Filetype: { <fs_entity>-filetype }|
          )
        ) TO reported-zfi_i_onaydos.
      ENDIF.

      IF lv_existing IS INITIAL.

        DATA : iv_url   TYPE string.

        iv_url = 'https://eren-holding-build-code-mhe8ahfp.authentication.us10.hana.ondemand.com/oauth/token?grant_type=client_credentials'.

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

        req->set_authorization_basic( i_username = 'sb-06e8d8b4-4105-4519-9c6d-8d547a7bb105!b344217|sdm-di-DocumentManagement-sdm_integration!b6332' i_password = 'kICJQo7ERcynYFRvHt33yEk5lkI=' ).

        TRY.
            DATA(http_response) = client->execute( if_web_http_client=>get ).
          CATCH cx_web_http_client_error.
            "handle exception
        ENDTRY.

        DATA(get_text)   = http_response->get_text(  ).
        DATA(get_status) = http_response->get_status(  ).

        IF get_status-code EQ 200.

          DATA: lt_data   TYPE REF TO data.

          CALL METHOD /ui2/cl_json=>deserialize
            EXPORTING
              json         = get_text
              pretty_name  = /ui2/cl_json=>pretty_mode-user
              assoc_arrays = abap_true
            CHANGING
              data         = lt_data.

          FIELD-SYMBOLS:
            <data>        TYPE data,
            <results>     TYPE any,
            <field>       TYPE any,
            <field_value> TYPE data,
            <table>       TYPE ANY TABLE.

          IF lt_data IS BOUND.
            ASSIGN lt_data->* TO <data>.
            ASSIGN COMPONENT `ACCESS_TOKEN` OF STRUCTURE <data> TO <results>.
            ASSIGN <results>->* TO <data>.
            IF <data> IS ASSIGNED.
              lv_token = <data>.
            ENDIF.
          ENDIF.

*           Repo Oluşturma
          DATA(iv_url_createrepo) = 'https://api-sdm-di.cfapps.us10.hana.ondemand.com/rest/v2/repositories'.

          DATA(url_createrepo) = |{ iv_url_createrepo }|.

          TRY.
              DATA(dest_createrepo)   = cl_http_destination_provider=>create_by_url( url_createrepo ).
            CATCH cx_http_dest_provider_error.
              "handle exception
          ENDTRY.
          TRY.
              DATA(client_createrepo) = cl_web_http_client_manager=>create_by_http_destination( dest_createrepo ).
            CATCH cx_web_http_client_error.
              "handle exception
          ENDTRY.

          DATA(req_createrepo) = client_createrepo->get_http_request(  ).

          req_createrepo->set_authorization_bearer( i_bearer = lv_token ).
          req_createrepo->set_header_fields( VALUE #(  (  name = 'Content-Type'    value = 'application/json' ) ) ).

          DATA(iv_json_data_createrepo) = '{' &&
                    '"repository":{' &&
                    '"displayName": "Repository",' &&
                    '"description": "Repository",' &&
                    '"repositoryType": "internal",' &&
                    '"isVersionEnabled": "true",' &&
                    '"isVirusScanEnabled": "false",' &&
                    '"skipVirusScanForLargeFile": "false",' &&
                    '"hashAlgorithms": "SHA-256"' &&
                         '}}'
            .
          req_createrepo->set_text( iv_json_data_createrepo ).

          TRY.
              DATA(http_response_createrepo) = client_createrepo->execute( if_web_http_client=>post ).
            CATCH cx_web_http_client_error.
              "handle exception
          ENDTRY.

          DATA(get_text_createrepo)   = http_response_createrepo->get_text(  ).
          DATA(get_status_createrepo) = http_response_createrepo->get_status(  ).

          CALL METHOD /ui2/cl_json=>deserialize
            EXPORTING
              json         = get_text_createrepo
              pretty_name  = /ui2/cl_json=>pretty_mode-user
              assoc_arrays = abap_true
            CHANGING
              data         = lt_listrepo.

          FIELD-SYMBOLS:
            <data2>        TYPE data,
            <results2>     TYPE any,
            <field2>       TYPE any,
            <field_value2> TYPE data,
            <table2>       TYPE ANY TABLE.

          IF lt_listrepo IS BOUND.
            ASSIGN lt_listrepo->* TO <data2>.
            ASSIGN COMPONENT `ID` OF STRUCTURE <data2> TO <results2>.
            ASSIGN <results2>->* TO <data2>.
            IF <data2> IS ASSIGNED.
              lv_repoid = <data2>.
            ENDIF.
          ENDIF.

*         Klasör oluşturma
          DATA(iv_url_createfolder) = |https://api-sdm-di.cfapps.us10.hana.ondemand.com/browser/{ lv_repoid }/root|.

          DATA(url_createfolder) = |{ iv_url_createfolder }|.

          DATA(lv_form_data) = |--{ lv_boundary }| && cl_abap_char_utilities=>cr_lf &&
                         |Content-Disposition: form-data; name="cmisaction"| && cl_abap_char_utilities=>cr_lf &&
                         cl_abap_char_utilities=>cr_lf &&
                         |createFolder| && cl_abap_char_utilities=>cr_lf &&
                         |--{ lv_boundary }| && cl_abap_char_utilities=>cr_lf &&
                         |Content-Disposition: form-data; name="propertyId[0]"| && cl_abap_char_utilities=>cr_lf &&
                         cl_abap_char_utilities=>cr_lf &&
                         |cmis:objectTypeId| && cl_abap_char_utilities=>cr_lf &&
                         |--{ lv_boundary }| && cl_abap_char_utilities=>cr_lf &&
                         |Content-Disposition: form-data; name="propertyValue[0]"| && cl_abap_char_utilities=>cr_lf &&
                         cl_abap_char_utilities=>cr_lf &&
                         |cmis:folder| && cl_abap_char_utilities=>cr_lf &&
                         |--{ lv_boundary }| && cl_abap_char_utilities=>cr_lf &&
                         |Content-Disposition: form-data; name="propertyId[1]"| && cl_abap_char_utilities=>cr_lf &&
                         cl_abap_char_utilities=>cr_lf &&
                         |cmis:name| && cl_abap_char_utilities=>cr_lf &&
                         |--{ lv_boundary }| && cl_abap_char_utilities=>cr_lf &&
                         |Content-Disposition: form-data; name="propertyValue[1]"| && cl_abap_char_utilities=>cr_lf &&
                         cl_abap_char_utilities=>cr_lf &&
                         |Folder| && cl_abap_char_utilities=>cr_lf &&
                         |--{ lv_boundary }| && cl_abap_char_utilities=>cr_lf &&
                         |Content-Disposition: form-data; name="succinct"| && cl_abap_char_utilities=>cr_lf &&
                         cl_abap_char_utilities=>cr_lf &&
                         |true| && cl_abap_char_utilities=>cr_lf &&
                         |--{ lv_boundary }--|.

          TRY.
              DATA(dest_createfolder)   = cl_http_destination_provider=>create_by_url( url_createfolder ).
            CATCH cx_http_dest_provider_error.
              "handle exception
          ENDTRY.
          TRY.
              DATA(client_createfolder) = cl_web_http_client_manager=>create_by_http_destination( dest_createfolder ).
            CATCH cx_web_http_client_error.
              "handle exception
          ENDTRY.
          DATA(req_createfolder) = client_createfolder->get_http_request(  ).
          req_createfolder->set_authorization_bearer( i_bearer = lv_token ).
          req_createfolder->set_header_field( i_name = 'Content-Type' i_value = |multipart/form-data; boundary={ lv_boundary }| ).

          req_createfolder->set_text( lv_form_data  ).
          TRY.
              DATA(http_response_createfolder) = client_createfolder->execute( if_web_http_client=>post ).
*            CATCH cx_web_dest_provider_error.
              "handle exception
          ENDTRY.
          DATA(get_text_createfolder)            = http_response_createfolder->get_text(  ).
          DATA(get_status_createfolder)          = http_response_createfolder->get_status(  ).

          IF get_status_createfolder-code EQ '201'.

            CALL METHOD /ui2/cl_json=>deserialize
              EXPORTING
                json         = get_text_createfolder
                pretty_name  = /ui2/cl_json=>pretty_mode-user
                assoc_arrays = abap_true
              CHANGING
                data         = lt_data_v2.

            FIELD-SYMBOLS:
              <data3>        TYPE data,
              <results3>     TYPE any,
              <field3>       TYPE any,
              <field_value3> TYPE data,
              <table3>       TYPE ANY TABLE.

            IF lt_data IS BOUND.
              ASSIGN lt_data_v2->* TO <data3>.
              ASSIGN COMPONENT `SUCCINCTPROPERTIES` OF STRUCTURE <data3> TO <results3>.
              ASSIGN <results3>->* TO <data3>.
              ASSIGN COMPONENT `CMIS_OBJECTID` OF STRUCTURE <data3> TO <results3>.
              ASSIGN <results3>->* TO <data3>.
              IF <data3> IS ASSIGNED.
                lv_folderid = <data3>.
              ENDIF.
            ENDIF.

*           Doküman Ekle
            DATA: lv_base64_content TYPE string,
                  lv_mime_type      TYPE string,
                  lv_filename       TYPE string,
                  lv_binary_data    TYPE xstring,
                  lv_size           TYPE i,
                  lv_crlf           TYPE string VALUE cl_abap_char_utilities=>cr_lf.

            lv_base64_content = <fs_entity>-base64.
            lv_filename       = <fs_entity>-filename.
            lv_mime_type      = <fs_entity>-filetype.

            CASE lv_mime_type.
              WHEN 'PDF'. lv_mime_type = 'application/pdf'.
              WHEN 'JPG'. lv_mime_type = 'image/jpeg'.
              WHEN 'PNG'. lv_mime_type = 'image/png'.
              WHEN OTHERS. lv_mime_type = 'application/octet-stream'.
            ENDCASE.

            TRY.

                CALL METHOD cl_web_http_utility=>decode_x_base64
                  EXPORTING
                    encoded = lv_base64_content
                  RECEIVING
                    decoded = lv_binary_data.

                lv_size = xstrlen( lv_binary_data ).
              CATCH cx_web_http_client_error.

                " Base64 decode hatası
                APPEND VALUE #( %key = <fs_entity>-%key ) TO failed-zfi_i_onaydos.
                APPEND VALUE #(
                  %key = <fs_entity>-%key
                  %msg = new_message(
                    id      = 'ZFI'
                    number  = '003'
                    severity = if_abap_behv_message=>severity-error
                    v1      = |Base64 decode hatası: { <fs_entity>-paymentorder }|
                  )
                ) TO reported-zfi_i_onaydos.
                CONTINUE.
            ENDTRY.

            DATA(lv_form_header) =
              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="cmisaction"{ lv_crlf }{ lv_crlf }| &&
              |createDocument{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="propertyId[0]"{ lv_crlf }{ lv_crlf }| &&
              |cmis:objectTypeId{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="propertyValue[0]"{ lv_crlf }{ lv_crlf }| &&
              |cmis:document{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="propertyId[1]"{ lv_crlf }{ lv_crlf }| &&
              |cmis:name{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="propertyValue[1]"{ lv_crlf }{ lv_crlf }| &&
              |{ lv_filename }{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="filename"{ lv_crlf }{ lv_crlf }| &&
              |{ lv_filename }{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="succinct"{ lv_crlf }{ lv_crlf }| &&
              |true{ lv_crlf }| &&

              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="includeAllowableActions"{ lv_crlf }{ lv_crlf }| &&
              |true{ lv_crlf }|.

            " Binary file header
            DATA(lv_file_header) =
              |--{ lv_boundary }{ lv_crlf }| &&
              |Content-Disposition: form-data; name="content"; filename="{ lv_filename }"{ lv_crlf }| &&
              |Content-Type: { lv_mime_type }{ lv_crlf }{ lv_crlf }|.

            DATA(lv_form_footer) = |{ lv_crlf }--{ lv_boundary }--|.

            DATA(lv_header_xstr) = xco_cp=>string( lv_form_header )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
            DATA(lv_file_header_xstr) = xco_cp=>string( lv_file_header )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
            DATA(lv_footer_xstr) = xco_cp=>string( lv_form_footer )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.

            DATA lv_final_body TYPE xstring.
            lv_final_body = lv_header_xstr && lv_file_header_xstr && lv_binary_data && lv_footer_xstr.

            iv_url = |https://api-sdm-di.cfapps.us10.hana.ondemand.com/browser/{ lv_repoid }/root|.
            url = |{ iv_url }|.

            TRY.
                dest = cl_http_destination_provider=>create_by_url( url ).
                client = cl_web_http_client_manager=>create_by_http_destination( dest ).
              CATCH cx_http_dest_provider_error.
            ENDTRY.

            DATA(req_3) = client->get_http_request( ).

            req_3->set_authorization_bearer( i_bearer = lv_token ).
            req_3->set_header_field( i_name = 'Content-Type' i_value = |multipart/form-data; boundary={ lv_boundary }| ).
            req_3->set_binary( i_data = lv_final_body ).

            TRY.
                DATA(http_responses) = client->execute( if_web_http_client=>post ).
              CATCH cx_web_http_client_error.
            ENDTRY.

            DATA(get_text_v2)   = http_responses->get_text(  ).
            DATA(get_status_v2) = http_responses->get_status(  ).

            IF get_status_v2-code EQ '201'.

              CALL METHOD /ui2/cl_json=>deserialize
                EXPORTING
                  json         = get_text_v2
                  pretty_name  = /ui2/cl_json=>pretty_mode-user
                  assoc_arrays = abap_true
                CHANGING
                  data         = lt_data_v3.

              FIELD-SYMBOLS:
                <data4>        TYPE data,
                <results4>     TYPE data,
                <field4>       TYPE any,
                <field_value4> TYPE data,
                <table4>       TYPE ANY TABLE.

              IF lt_data_v3 IS BOUND.
                ASSIGN lt_data_v3->* TO <data4>.
                ASSIGN COMPONENT `SUCCINCTPROPERTIES` OF STRUCTURE <data4> TO <results4>.
                ASSIGN <results4>->* TO <data4>.
                ASSIGN COMPONENT `CMIS_OBJECTID` OF STRUCTURE <data4> TO <results4>.
                ASSIGN <results4>->* TO <data4>.
                ASSIGN COMPONENT `VALUE` OF STRUCTURE <data4> TO <results4>.
                ASSIGN <results4>->* TO <data4>.

                IF <data4> IS ASSIGNED.
                  lv_docid = <data4>.
                  DATA(ls_doc) = VALUE zfi_db_doc(
                     header       = <fs_entity>-paymentorder
                     filename     = lv_filename
                     obj_id       = lv_docid
                     repoid       = lv_repoid
                     ssize        = lv_size
                     ).
                  APPEND ls_doc TO zcl_zfi_api_buffer=>mt_id_doc.
                ENDIF.
              ENDIF.
            ELSE.
              APPEND VALUE #( %key = <fs_entity>-%key ) TO failed-zfi_i_onaydos.
              APPEND VALUE #(
                %key = <fs_entity>-%key
                %msg = new_message(
                  id      = 'ZFI'
                  number  = '001'
                  severity = if_abap_behv_message=>severity-error
                  v1      = |Doküman eklemede hata: { <fs_entity>-paymentorder }|
                )
              ) TO reported-zfi_i_onaydos.
            ENDIF.

          ELSE.
            APPEND VALUE #( %key = <fs_entity>-%key ) TO failed-zfi_i_onaydos.
            APPEND VALUE #(
              %key = <fs_entity>-%key
              %msg = new_message(
                id      = 'ZFI'
                number  = '001'
                severity = if_abap_behv_message=>severity-error
                v1      = |Klasör eklemede hata: { <fs_entity>-paymentorder }|
              )
            ) TO reported-zfi_i_onaydos.
          ENDIF.
        ELSE.
          APPEND VALUE #( %key = <fs_entity>-%key ) TO failed-zfi_i_onaydos.
          APPEND VALUE #(
            %key = <fs_entity>-%key
            %msg = new_message(
              id      = 'ZFI'
              number  = '001'
              severity = if_abap_behv_message=>severity-error
              v1      = |Token alımında hata: { <fs_entity>-paymentorder }|
            )
          ) TO reported-zfi_i_onaydos.
        ENDIF.

      ENDIF.

      DATA(ls_root) = VALUE zfi_api_onaydos(
      paymentorder  = <fs_entity>-paymentorder
      base64        = <fs_entity>-base64
      filename      = <fs_entity>-filename
      filetype      = <fs_entity>-filetype
      logdata       = <fs_entity>-logdata
      username      = sy-uname
      ).
      APPEND ls_root TO zcl_zfi_api_buffer=>mt_create_zfi_onay.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zfi_i_onaydos DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zfi_i_onaydos IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA: lt_data TYPE STANDARD TABLE OF zfi_api_onaydos,
          lt_doc  TYPE STANDARD TABLE OF zfi_db_doc.

    FIELD-SYMBOLS: <fs_data> TYPE zfi_api_onaydos,
                   <fs_doc>  TYPE zfi_db_doc.

    lt_data = zcl_zfi_api_buffer=>mt_create_zfi_onay.
    lt_doc  = zcl_zfi_api_buffer=>mt_id_doc.

    LOOP AT lt_data ASSIGNING <fs_data>.
      INSERT zfi_api_onaydos FROM @<fs_data>.
    ENDLOOP.

    LOOP AT lt_doc ASSIGNING <fs_doc>.
      INSERT zfi_db_doc FROM @<fs_doc>.
    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
