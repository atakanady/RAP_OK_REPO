CLASS lhc_zfi_api_root DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_api_root RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zfi_api_root.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zfi_api_root.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zfi_api_root.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfi_api_root RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zfi_api_root.

    METHODS rba_child FOR READ
      IMPORTING keys_rba FOR READ zfi_api_root\_child FULL result_requested RESULT result LINK association_links.

    METHODS cba_child FOR MODIFY
      IMPORTING entities_cba FOR CREATE zfi_api_root\_child.

ENDCLASS.

CLASS lhc_zfi_api_root IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA: lv_new_id     TYPE zfi_db_root-paymentorder,
          lv_last_year  TYPE i,
          lt_dates      TYPE TABLE OF sy-datum,
          lv_first_date TYPE sy-datum,
          lv_date_str   TYPE string.


    DATA(lv_user) = sy-uname.

    SELECT SINGLE
     u~companycode,
     u~username
      FROM zfi_api_userdb AS u
        WHERE username EQ  @lv_user
        INTO @DATA(lt_companycode).


    SELECT SINGLE
     d~companycodename
        FROM i_companycode AS d
        WHERE companycode EQ @lt_companycode-companycode
        INTO  @DATA(lv_username).

    IF sy-subrc IS INITIAL.

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_alldata>).

        " Payment Type kontrolü
        SELECT SINGLE paymenttype
          FROM zfi_paymenttd
          WHERE paymenttype = @<lfs_alldata>-payment_type
          INTO @DATA(lv_paymenttype).

        IF sy-subrc <> 0.
          " Hatalı PaymentType mesajı
          APPEND VALUE #( %key = <lfs_alldata>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_alldata>-%key
            %msg = new_message(
              id      = 'ZFI'
              number  = '002'
              severity = if_abap_behv_message=>severity-error
              v1      = |Geçersiz ödeme biçimi: { <lfs_alldata>-payment_type }|
            )
          ) TO reported-zfi_api_root.
        ENDIF.


        " Tarih boş mu kontrolü
        IF <lfs_alldata>-payment_date IS INITIAL.
          " Tarih boş, hata ekle
          APPEND VALUE #( %key = <lfs_alldata>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_alldata>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '001'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Tarih alanı boş olamaz'
            ) ) TO reported-zfi_api_root.
        ELSE.
          DATA lv_raw          TYPE string.
          DATA lv_input        TYPE string.
          DATA lv_valid        TYPE abap_bool.
          DATA lv_date         TYPE d.
          DATA lv_input_format TYPE c LENGTH 8.

          DATA lv_tmp        TYPE c LENGTH 8.
          DATA lv_year_str   TYPE c LENGTH 4.
          DATA lv_month_str  TYPE c LENGTH 2.
          DATA lv_day_str    TYPE c LENGTH 2.

          DATA lv_years       TYPE i.
          DATA lv_month      TYPE i.
          DATA lv_day        TYPE i.
          DATA lv_max_day    TYPE i.

          " Kullanıcının girdiği tarihi al
          lv_raw   = <lfs_alldata>-payment_date.
          lv_input = lv_raw.
          lv_valid = abap_true.

          " Tireleri kaldır ve baş/son boşlukları temizle
          REPLACE ALL OCCURRENCES OF '-' IN lv_input WITH ''.
          CONDENSE lv_input NO-GAPS.

          lv_input_format = lv_input.

          " 1) Boş mu veya uzunluğu yanlış mı?
          IF lv_input_format IS INITIAL OR strlen( lv_input_format ) <> 8.
            lv_valid = abap_false.
          ELSE.
            " 2) Sadece rakamlardan mı oluşuyor?
            lv_tmp = lv_input_format.
            REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN lv_tmp WITH ''.

            IF lv_tmp = lv_input_format.
              " 3) Yıl, ay, gün değerlerini al
              lv_year_str  = lv_input_format(4).
              lv_month_str = lv_input_format+4(2).
              lv_day_str   = lv_input_format+6(2).

              lv_years  = CONV i( lv_year_str ).
              lv_month = CONV i( lv_month_str ).
              lv_day   = CONV i( lv_day_str ).

              " 4) Ay 1-12 arasında mı?
              IF lv_month BETWEEN 1 AND 12.

                " 5) Ay bazlı maksimum gün sayısı
                CASE lv_month.
                  WHEN 1 OR 3 OR 5 OR 7 OR 8 OR 10 OR 12.
                    lv_max_day = 31.
                  WHEN 4 OR 6 OR 9 OR 11.
                    lv_max_day = 30.
                  WHEN 2.
                    " Şubat: artık yıl kontrolü
                    IF ( lv_years MOD 400 = 0 ) OR ( lv_years MOD 4 = 0 AND lv_years MOD 100 <> 0 ).
                      lv_max_day = 29.
                    ELSE.
                      lv_max_day = 28.
                    ENDIF.
                ENDCASE.

                " 6) Gün geçerli mi?
                IF lv_day BETWEEN 1 AND lv_max_day.
                  TRY.
                      " ABAP tarihi geçerli mi
                      lv_date = lv_input_format.
                    CATCH cx_sy_conversion_error.
                      lv_valid = abap_false.
                  ENDTRY.
                ELSE.
                  lv_valid = abap_false.
                ENDIF.

              ELSE.
                lv_valid = abap_false.
              ENDIF.

            ELSE.
              lv_valid = abap_false.
            ENDIF.
          ENDIF.

          " Hata varsa RAP mesajı üret
          IF lv_valid = abap_false.
            APPEND VALUE #( %key = <lfs_alldata>-%key ) TO failed-zfi_api_item.
            APPEND VALUE #(
              %key = <lfs_alldata>-%key
              %msg = new_message(
                id       = 'ZFI'
                number   = '002'
                severity = if_abap_behv_message=>severity-error
                v1       = |Geçersiz tarih: { lv_raw }|
              )
            ) TO reported-zfi_api_root.
          ENDIF.


        ENDIF.


        " mt_create_zfi, sınıf içinde create için kullanılan global tablo
*    DATA(lt_entities) = zcl_zfi_api_buffer=>mt_create_zfi.

*    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).

        DATA(lv_raw_date) = <lfs_alldata>-payment_date.
        REPLACE ALL OCCURRENCES OF '-' IN lv_raw_date WITH ''.
        CONDENSE lv_raw_date NO-GAPS.

        " Tarih uzunluğu kontrolü (güvenlik için)
        IF strlen( lv_raw_date ) = 8.
          APPEND lv_raw_date TO lt_dates.
        ENDIF.

*    ENDLOOP.


        " Tarihleri azalan sırada sıralıyoruz
        SORT lt_dates DESCENDING.

        READ TABLE lt_dates INDEX 1 INTO lv_first_date.

        " En son paymentorder numarasını alıyoruz
        SELECT MAX( paymentorder ) FROM zfi_db_root INTO @lv_new_id.

        " Eğer hiç kayıt yoksa başlangıç numarası ver
        IF lv_new_id IS INITIAL.
          lv_new_id = 10000.
        ENDIF.

        lv_last_year = lv_first_date+0(4).

*    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_ents>).

        DATA(lv_year) = lv_last_year.

        IF lv_year <> lv_last_year.
          lv_new_id = 10000.
          lv_last_year = lv_year.
        ELSE.
          lv_new_id = lv_new_id + 1.
        ENDIF.


*      <lfs_alldata>-paymentorder =  lv_new_id.

        APPEND VALUE #( %cid = <lfs_alldata>-%cid
                        paymentorder = lv_new_id ) TO mapped-zfi_api_root.


        DATA(ls_root) = VALUE zfi_db_root(
        paymentorder       = lv_new_id
        payercompany       = lt_companycode-companycode
        payercompanyname   = lv_username
        is_used            = <lfs_alldata>-used
        processdescription = <lfs_alldata>-processdescription
        paymentdate        = <lfs_alldata>-payment_date
        status             = <lfs_alldata>-status
        paymenttype        = <lfs_alldata>-payment_type
        amounttotal        = <lfs_alldata>-amounttotal
        itemtotal          = <lfs_alldata>-itemtotal
        userinfo           = <lfs_alldata>-userinfo
        created_by         = <lfs_alldata>-createdby
        created_at         = <lfs_alldata>-createdat
        last_changed_by    = <lfs_alldata>-lastchangedby
        last_changed_at    = <lfs_alldata>-lastchangedat
        etag_master        = <lfs_alldata>-etagmaster
        ).
        APPEND ls_root TO zcl_zfi_api_buffer=>mt_create_zfi.

      ENDLOOP.

    ELSE.

      IF sy-subrc IS NOT INITIAL.
        LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_error>).
          APPEND VALUE #( %key = <lfs_error>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_error>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '004'
              severity = if_abap_behv_message=>severity-error
              v1 = |Kullanıcıya ait şirket kodu bulunamadı: { lv_user }|
            )
          ) TO reported-zfi_api_root.
        ENDLOOP.
        RETURN.
      ENDIF.


    ENDIF.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_child.
  ENDMETHOD.

  METHOD cba_child.


    DATA new_id(8) TYPE n.
    DATA lt_payment_types TYPE SORTED TABLE OF c WITH UNIQUE KEY table_line.
    DATA lt_currencies    TYPE SORTED TABLE OF c WITH UNIQUE KEY table_line.

    new_id = 0.

    SELECT
      h~currency
      FROM i_currency AS h
      INTO TABLE @DATA(lt_currencyys).

    SELECT
        d~country
        FROM i_country AS d
        INTO TABLE @DATA(lt_country).

    DATA(lv_user) = sy-uname.

    SELECT SINGLE
     u~companycode,
     u~username
      FROM zfi_api_userdb AS u
        WHERE username EQ  @lv_user
        INTO @DATA(lt_companycode).


    SELECT SINGLE
     d~companycodename
        FROM i_companycode AS d
        WHERE companycode EQ @lt_companycode-companycode
        INTO  @DATA(lv_username).



    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_data_cba>).
      LOOP AT <lfs_data_cba>-%target ASSIGNING FIELD-SYMBOL(<lfs_target>).

        new_id = new_id + 1.

        APPEND <lfs_target>-payment_type    TO lt_payment_types.
        APPEND <lfs_target>-payment_currency TO lt_currencies.


        IF strlen( <lfs_target>-invoice_reference ) > 20.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '002'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Referans alanı karakter uzunluğu uygun değil'
            ) ) TO reported-zfi_api_root.
        ENDIF.

        IF strlen( <lfs_target>-invoice_description ) > 40.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '002'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Açıklama alanı karakter uzunluğu uygun değil'
            ) ) TO reported-zfi_api_root.
        ENDIF.

        IF strlen( <lfs_target>-invoice_declaration ) > 20.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '002'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Fatura Beyanname alanının karakter uzunluğu uygun değil'
            ) ) TO reported-zfi_api_root.
        ENDIF.


        IF strlen( <lfs_target>-letter_credit_ref ) > 25.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '002'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Fatura Beyanname alanının karakter uzunluğu uygun değil'
            ) ) TO reported-zfi_api_root.
        ENDIF.

        " Negatif değer kontrolü
        IF <lfs_target>-payment_amount < 0.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id       = 'ZFI'
              number   = '002'
              severity = if_abap_behv_message=>severity-error
              v1       = 'Tutar değeri negatif olamaz'
            )
          ) TO reported-zfi_api_root.
        ENDIF.

        IF line_exists( lt_currencyys[ currency = <lfs_target>-payment_currency ] ).
          " Geçerli bir para birimi
        ELSE.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '002'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Geçersiz para birimi'
            ) ) TO reported-zfi_api_root.
        ENDIF.


        IF strlen( <lfs_target>-payee_name ) > 40.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.

          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '003'
              severity = if_abap_behv_message=>severity-error
              v1 = 'PAYEE_NAME alanı 40 karakterden uzun olamaz'
            )
          ) TO reported-zfi_api_root.
        ENDIF.


        " Ödeme tipi özel zorunluluk kontrolleri
        " -----------------------------
        CASE <lfs_target>-payment_type.

          WHEN 'A' OR 'V'.
            IF <lfs_target>-letter_credit_ref IS INITIAL.
              APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
              APPEND VALUE #(
                %key = <lfs_target>-%key
                %msg = new_message(
                  id       = 'ZFI'
                  number   = '005'
                  severity = if_abap_behv_message=>severity-error
                  v1       = 'Ödeme tipi A veya V için Akreditif Referansı zorunludur.'
                )
              ) TO reported-zfi_api_root.
            ENDIF.

          WHEN 'M' OR 'P'.
            IF <lfs_target>-invoice_reference IS INITIAL
            OR <lfs_target>-invoice_date IS INITIAL
            OR <lfs_target>-invoice_declaration IS INITIAL.
              APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
              APPEND VALUE #(
                %key = <lfs_target>-%key
                %msg = new_message(
                  id       = 'ZFI'
                  number   = '006'
                  severity = if_abap_behv_message=>severity-error
                  v1       = 'Ödeme tipi M veya P için Fatura Referansı, Fatura Tarihi ve Fatura Beyannamesi zorunludur.'
                )
              ) TO reported-zfi_api_root.
            ENDIF.

        ENDCASE.




        IF line_exists( lt_country[ country = <lfs_target>-payee_country ] ).
          " Geçerli bir ülke
          IF <lfs_target>-payee_country NE 'TR'.
            IF <lfs_target>-payment_type EQ 'Y'.

              DATA lv_iban_sub TYPE c LENGTH 5.

              lv_iban_sub = <lfs_target>-payee_iban+4(5).

              SELECT SINGLE
                     sw~swift
                FROM zfi_swift AS sw
                WHERE eft EQ @lv_iban_sub
                INTO @DATA(lv_swift).

              IF lv_swift IS INITIAL.
                lv_swift = <lfs_target>-payee_bank_swift.
              ENDIF.


            ELSE.
              IF <lfs_target>-payee_bank_swift IS NOT INITIAL.

                " Türkiye ise IBAN zorunlu
                IF <lfs_target>-payee_iban IS INITIAL.
                  APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
                  APPEND VALUE #(
                    %key = <lfs_target>-%key
                    %msg = new_message(
                      id       = 'ZFI'
                      number   = '004'
                      severity = if_abap_behv_message=>severity-error
                      v1       = 'Döviz ödemelerinde SWIFT zorunludur.'
                    )
                  ) TO reported-zfi_api_root.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.


        IF line_exists( lt_country[ country = <lfs_target>-payee_country ] ).
          " Geçerli bir ülke

          IF <lfs_target>-payee_country = 'TR'.
            " Türkiye ise IBAN zorunlu
            IF <lfs_target>-payee_iban IS INITIAL.
              APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
              APPEND VALUE #(
                %key = <lfs_target>-%key
                %msg = new_message(
                  id       = 'ZFI'
                  number   = '004'
                  severity = if_abap_behv_message=>severity-error
                  v1       = 'TR için alacaklı IBAN zorunludur'
                )
              ) TO reported-zfi_api_root.
            ENDIF.



          ELSE.
            " Türkiye değilse Bank Account, Bank Number ve Bank Name zorunlu
            IF <lfs_target>-payee_bank_account IS INITIAL
               OR <lfs_target>-payee_bank_number IS INITIAL
               OR <lfs_target>-payee_bank_name IS INITIAL.
              APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
              APPEND VALUE #(
                %key = <lfs_target>-%key
                %msg = new_message(
                  id       = 'ZFI'
                  number   = '005'
                  severity = if_abap_behv_message=>severity-error
                  v1       = 'TR dışı için banka hesabı, banka numarası ve banka ismi zorunludur'
                )
              ) TO reported-zfi_api_root.
            ENDIF.
          ENDIF.

        ELSE.
          " Geçersiz ülke
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.
          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id       = 'ZFI'
              number   = '003'
              severity = if_abap_behv_message=>severity-error
              v1       = 'Geçersiz Ülke Bilgisi'
            )
          ) TO reported-zfi_api_root.
        ENDIF.


        IF strlen( <lfs_target>-payee_bank_name ) > 40.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.

          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '003'
              severity = if_abap_behv_message=>severity-error
              v1 = 'PAYEE_BANK_NAME alanı 40 karakterden uzun olamaz'
            )
          ) TO reported-zfi_api_root.
        ENDIF.


        IF strlen( <lfs_target>-payee_bank_swift ) > 40.
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.

          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id = 'ZFI'
              number = '003'
              severity = if_abap_behv_message=>severity-error
              v1 = 'PAYEE_BANK_SWIFT alanı 8 karakterden uzun olamaz'
            )
          ) TO reported-zfi_api_root.
        ENDIF.


        IF strlen( <lfs_target>-payee_identifier ) <> 10
           AND strlen( <lfs_target>-payee_identifier ) <> 11.
          " Hata ekle
          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.

          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id       = 'ZFI'
              number   = '003'
              severity = if_abap_behv_message=>severity-error
              v1       = 'Geçersiz TCKN-VKN uzunluk, sadece 10 veya 11 olabilir'
            )
          ) TO reported-zfi_api_root.
        ENDIF.

        DATA(lv_amount_string) = <lfs_target>-payment_amount.

        DATA lv_amount_curr TYPE p LENGTH 11 DECIMALS 2.
        lv_amount_curr = lv_amount_string.


        " Ödeme masrafı boş ise SHA olarak doldur
        IF <lfs_target>-payee_bank_cost IS INITIAL.
*          <lfs_target>-payee_bank_cost = 'SHA'.

          APPEND VALUE #( %key = <lfs_target>-%key ) TO failed-zfi_api_item.

          APPEND VALUE #(
            %key = <lfs_target>-%key
            %msg = new_message(
              id       = 'ZFI'
              number   = '003'
              severity = if_abap_behv_message=>severity-error
              v1       = 'payee_bank_cost değeri boş gönderilemez'
            )
          ) TO reported-zfi_api_root.
        ENDIF.



        DATA(ls_item) = VALUE zfi_db_item(
                  reference           = <lfs_target>-invoice_reference
                  paymenttype         = <lfs_target>-payment_type
                  description         = <lfs_target>-invoice_description
                  payercompany        = lt_companycode-companycode
                  payercompanyname    = lv_username
                  amount              = lv_amount_curr
                  currency            = <lfs_target>-payment_currency
                  payeenumber         = <lfs_target>-payee_number
                  payeename           = <lfs_target>-payee_name
                  payeecountry        = <lfs_target>-payee_country
                  payeeidentifier     = <lfs_target>-payee_identifier
                  payeeiban           = <lfs_target>-payee_iban
                  payeebank           = <lfs_target>-payee_bank_number
                  payeebankaccount    = <lfs_target>-payee_bank_account
                  payeeswift          = lv_swift
                  paymentcost         = <lfs_target>-payee_bank_cost
                  invoicedate         = <lfs_target>-invoice_date
                  invoicedeclaration  = <lfs_target>-invoice_declaration
                  lettercreditref     = <lfs_target>-letter_credit_ref
                  payeebankname       = <lfs_target>-payee_bank_name
                  client              = sy-mandt
                  paymentorder        = <lfs_data_cba>-paymentorder
                  paymentline         =  new_id
                ).
        APPEND ls_item TO zcl_zfi_api_buffer=>mt_create_zfi_item.


      ENDLOOP.
    ENDLOOP.

    " Kontroller
    IF lines( lt_payment_types ) > 1.
      APPEND VALUE #( %key = 'GLOBAL' ) TO failed-zfi_api_item.
      APPEND VALUE #(
        %key = 'GLOBAL'
        %msg = new_message(
          id       = 'ZFI'
          number   = '007'
          severity = if_abap_behv_message=>severity-error
          v1       = 'Request içerisinde sadece tek bir ödeme tipi olabilir'
        )
      ) TO reported-zfi_api_root.
    ENDIF.

    IF lines( lt_currencies ) > 1.
      APPEND VALUE #( %key = 'GLOBAL' ) TO failed-zfi_api_item.
      APPEND VALUE #(
        %key = 'GLOBAL'
        %msg = new_message(
          id       = 'ZFI'
          number   = '008'
          severity = if_abap_behv_message=>severity-error
          v1       = 'Request içerisinde sadece tek bir para birimi olabilir'
        )
      ) TO reported-zfi_api_root.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zfi_api_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zfi_api_item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zfi_api_item.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfi_api_item RESULT result.

    METHODS rba_root FOR READ
      IMPORTING keys_rba FOR READ zfi_api_item\_root FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zfi_api_item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_root.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zfi_api_root DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.
  PRIVATE SECTION.


ENDCLASS.

CLASS lsc_zfi_api_root IMPLEMENTATION.



  METHOD finalize.
  ENDMETHOD.



  METHOD check_before_save.
  ENDMETHOD.



  METHOD adjust_numbers.


  ENDMETHOD.


  METHOD save.

    DATA: lt_data      TYPE STANDARD TABLE OF zfi_db_root,
          lt_item      TYPE STANDARD TABLE OF zfi_db_item,
          lv_index     TYPE sy-tabix,
          lv_lines     TYPE i,
          lv_total_amt TYPE zfi_db_item-amount,
          lv_user      TYPE sy-uname,
          lv_timestamp TYPE char14.

    FIELD-SYMBOLS: <fs_data>      TYPE zfi_db_root,
                   <fs_data_item> TYPE zfi_db_item.



    " Verileri al
    lt_data = zcl_zfi_api_buffer=>mt_create_zfi.
    lt_item = zcl_zfi_api_buffer=>mt_create_zfi_item.

    lv_user      = sy-uname.
    lv_timestamp = sy-datum.

    lv_lines = lines( lt_item ).

    CLEAR lv_total_amt.
    LOOP AT lt_item ASSIGNING <fs_data_item>.
      lv_total_amt = lv_total_amt + <fs_data_item>-amount.
    ENDLOOP.


    DATA(lv_total_amt_str) = CONV string( lv_total_amt ).

    LOOP AT lt_data ASSIGNING <fs_data>.

      <fs_data>-itemtotal         = lv_lines.
      <fs_data>-amounttotal       = lv_total_amt_str.
      <fs_data>-created_by        = lv_user.
      DATA(lv_formatted_date) = |{ lv_timestamp+6(2) }.{ lv_timestamp+4(2) }.{ lv_timestamp+0(4) }|.
      <fs_data>-created_at        = lv_formatted_date.
      <fs_data>-last_changed_by   = lv_user.
*      <fs_data>-last_changed_at   = lv_timestamp.
      <fs_data>-status            = '10'.
      <fs_data>-is_used           = 'N'.
      INSERT zfi_db_root FROM @<fs_data>.
    ENDLOOP.

    DO lv_lines TIMES.
      lv_index = sy-index.

      READ TABLE lt_item ASSIGNING <fs_data_item> INDEX lv_index.
      READ TABLE lt_data ASSIGNING <fs_data>      INDEX lv_index.

      IF <fs_data_item> IS ASSIGNED AND <fs_data> IS ASSIGNED.
        <fs_data_item>-paymentorder      = <fs_data>-paymentorder.
        <fs_data_item>-paymenttype       = <fs_data>-paymenttype.
        <fs_data_item>-created_by        = lv_user.
        <fs_data_item>-created_at        = lv_formatted_date.
        <fs_data_item>-last_changed_by   = lv_user.
        <fs_data_item>-status            = '10'.
        INSERT zfi_db_item FROM @<fs_data_item>.
      ENDIF.
    ENDDO.

    zcl_zfi_api_buffer=>clear_all( ).


  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
