CLASS lhc_zfi_pymbatch_line DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS updatestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zfi_pymbatch_line~updatestatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfi_pymbatch_line RESULT result.

ENDCLASS.

CLASS lhc_zfi_pymbatch_line IMPLEMENTATION.

  METHOD updatestatus.

    TYPES: BEGIN OF ty_status_data,
             paymentbatch     TYPE zfi_pymbtch_line-paymentbatch,  " Correct data type
             paymentorder     TYPE zfi_pymbtch_line-paymentorder,
             paymentline      TYPE zfi_pymbtch_line-paymentline,
             statusvalidation TYPE zfi_pymbtch_line-status,
             statusdesc       TYPE zfi_pymbtch_line-statusdesc,
           END OF ty_status_data.
    TYPES: tt_status_data TYPE TABLE OF ty_status_data WITH EMPTY KEY.

    DATA: lt_stats TYPE tt_status_data.

    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_line
    FIELDS ( statusvalidation ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_status)
    REPORTED DATA(lt_reported).

    IF lt_status[] IS NOT INITIAL.

      SELECT h~paymentorder,
             h~paymentline,
             h~status
             FROM zfi_pymbtch_line AS h
             FOR ALL ENTRIES IN @lt_status
             WHERE h~paymentorder EQ @lt_status-paymentorder
             INTO TABLE @DATA(lt_pymbtch_status).


      LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<lfs_sts>).


        READ TABLE lt_pymbtch_status ASSIGNING FIELD-SYMBOL(<lfs_table>) WITH KEY status = 'X' paymentline = <lfs_sts>-paymentline paymentorder = <lfs_sts>-paymentorder  .

        IF sy-subrc IS NOT INITIAL.


          MODIFY ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
          ENTITY zfi_pymbatch_line " Alias
          UPDATE
          FIELDS ( statusvalidation statusdesc )
          WITH VALUE #( FOR key IN  keys ( %tky = key-%tky statusvalidation = 'X' statusdesc = 'Tayin Edildi' ) )
          FAILED DATA(lt_failed)
          REPORTED lt_reported.


        ELSE.

          APPEND VALUE #( %tky = <lfs_sts>-%tky ) TO reported-zfi_pymbatch_bank.
          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                         %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = 'Seçilen' && || && <lfs_sts>-paymentorder && '-' && <lfs_sts>-paymentline && || && 'değeri daha önce tayin edilmiştir!'
                         ) )

                         TO reported-zfi_pymbatch_bank.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD get_instance_features.


    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    FIELDS ( statusx status documentno ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_active)
    REPORTED DATA(lt_reported).

    LOOP AT lt_active ASSIGNING FIELD-SYMBOL(<lfs_active>).

      IF <lfs_active>-status EQ 'Y'.

        result = VALUE #(
          FOR <fs_key> IN keys (
            %tky = <fs_key>-%tky
            %delete = COND #( WHEN <lfs_active>-status EQ 'Y'
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled )
        ) ) .

      ENDIF.

    ENDLOOP.




  ENDMETHOD.

ENDCLASS.

CLASS lhc_zfi_pymbatch_bank DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_pymbatch_bank RESULT result.
    METHODS vpaymentbatch FOR VALIDATE ON SAVE
      IMPORTING keys FOR zfi_pymbatch_bank~vpaymentbatch.
    METHODS active FOR MODIFY
      IMPORTING keys FOR ACTION zfi_pymbatch_bank~active RESULT result.
    METHODS unactive FOR MODIFY
      IMPORTING keys FOR ACTION zfi_pymbatch_bank~unactive RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfi_pymbatch_bank RESULT result.
*    METHODS get_global_features FOR GLOBAL FEATURES
*      IMPORTING REQUEST requested_features FOR zfi_pymbatch_bank RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zfi_pymbatch_bank.
    METHODS oncreate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_pymbatch_bank~oncreate.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zfi_pymbatch_bank RESULT result.


ENDCLASS.

CLASS lhc_zfi_pymbatch_bank IMPLEMENTATION.

  METHOD get_instance_authorizations.


    IF sy-uname IS NOT INITIAL.

      READ ENTITIES OF  zfi_pymbatch_bank IN LOCAL MODE
      ENTITY zfi_pymbatch_bank
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).


      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).

*            result = VALUE #(
*               FOR <fs_key> IN keys (
*                 %tky = <fs_key>-%tky
*                 %delete = if_abap_behv=>fc-o-disabled ) ) .

      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD earlynumbering_create.

    SELECT MAX( paymentbatch ) FROM zfi_pymbatch_bank INTO @DATA(new_id).

    IF new_id IS INITIAL.
      new_id = 1000000000.
    ENDIF.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_ent>).

      new_id = new_id + 1.

      INSERT VALUE #(
        %cid = <lfs_ent>-%cid
        paymentbatch = new_id
      ) INTO TABLE mapped-zfi_pymbatch_bank.

    ENDLOOP.


  ENDMETHOD.


  METHOD vpaymentbatch.
  ENDMETHOD.

  METHOD active.

    DATA: lv_modify_success TYPE abap_bool VALUE abap_false.


    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    FIELDS ( statusx status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_active)
    REPORTED DATA(lt_reported).


    MODIFY ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    UPDATE
    FIELDS ( statusx status )
    WITH VALUE #( FOR key IN  keys ( %tky = key-%tky statusx = 'Aktif'  status = 'Y') )
    FAILED DATA(lt_failed)
    REPORTED lt_reported.

    IF sy-subrc IS INITIAL.

      APPEND VALUE #( %tky = keys[ 1 ]-%tky
                     %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text = 'Aktifleştirme başarılı'
                     ) )

                     TO reported-zfi_pymbatch_bank.

    ENDIF.

    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(data).
    result = VALUE #( FOR datarec IN data
    ( %tky = datarec-%tky %param = datarec )  ).


  ENDMETHOD.

  METHOD unactive.

    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
  ENTITY zfi_pymbatch_bank
  FIELDS ( statusx status ) WITH CORRESPONDING #( keys )
  RESULT DATA(lt_active)
  REPORTED DATA(lt_reported).


    MODIFY ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    UPDATE
    FIELDS ( statusx status )
    WITH VALUE #( FOR key IN  keys ( %tky = key-%tky statusx = 'Aktif Değil'  status = '') )
    FAILED DATA(lt_failed)
    REPORTED lt_reported.



    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(data).
    result = VALUE #( FOR datarec IN data
    ( %tky = datarec-%tky %param = datarec )  ).





  ENDMETHOD.

  METHOD get_instance_features.


    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    FIELDS ( statusx status documentno ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_active)
    REPORTED DATA(lt_reported).




    LOOP AT lt_active ASSIGNING FIELD-SYMBOL(<lfs_active>).

      IF <lfs_active>-status EQ 'Y'.

        result = VALUE #(
          FOR <fs_key> IN keys (
            %tky = <fs_key>-%tky
            %update = COND #( WHEN <lfs_active>-status EQ 'Y'
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled )
            %action-active = COND #( WHEN <lfs_active>-status EQ 'Y'
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled )
            %delete        = COND #( WHEN <lfs_active>-status EQ 'Y'
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled )
            %assoc-_line   =         if_abap_behv=>fc-o-disabled )
        ).
      ELSEIF <lfs_active>-status EQ ''.
        result = VALUE #(
          FOR <fs_key> IN keys (
            %tky = <fs_key>-%tky
            %action-unactive = COND #( WHEN <lfs_active>-status EQ ''
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled )

          )
        ).

      ENDIF.



      IF <lfs_active>-documentno IS NOT INITIAL.

        result = VALUE #(
                  FOR <fs_key> IN keys (
                    %tky = <fs_key>-%tky
                    %update           = if_abap_behv=>fc-o-disabled
                    %action-active    = if_abap_behv=>fc-o-disabled
                    %action-unactive  = if_abap_behv=>fc-o-disabled
                    %assoc-_line      = if_abap_behv=>fc-o-disabled
                     ) ).
      ENDIF.


    ENDLOOP.




  ENDMETHOD.

  METHOD oncreate.

    READ ENTITIES OF zfi_pymbatch_bank IN LOCAL MODE
    ENTITY zfi_pymbatch_bank
    FIELDS ( paymentbatch ) WITH CORRESPONDING #( keys )
    RESULT DATA(lv_status).

    LOOP AT lv_status INTO DATA(ls_status).

      IF  ls_status-paymentbatch IS INITIAL.


        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Manuel Kayıt İşlemi Yapılamaz!'
                        ) )

                        TO reported-zfi_pymbatch_bank.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD get_global_features.

  ENDMETHOD.

ENDCLASS.
