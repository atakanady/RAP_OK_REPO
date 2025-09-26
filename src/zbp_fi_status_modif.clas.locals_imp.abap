CLASS lhc_zfi_status_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zfi_status_item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zfi_status_item.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfi_status_item RESULT result.

    METHODS rba_statusroot FOR READ
      IMPORTING keys_rba FOR READ zfi_status_item\_statusroot FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zfi_status_item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_statusroot.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zfi_status_modif DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_status_modif RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zfi_status_modif.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zfi_status_modif.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zfi_status_modif.

    METHODS read FOR READ
      IMPORTING keys FOR READ zfi_status_modif RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zfi_status_modif.
    METHODS rba_statsuchild FOR READ
      IMPORTING keys_rba FOR READ zfi_status_modif\_statsuchild FULL result_requested RESULT result LINK association_links.

    METHODS cba_statsuchild FOR MODIFY
      IMPORTING entities_cba FOR CREATE zfi_status_modif\_statsuchild.

ENDCLASS.

CLASS lhc_zfi_status_modif IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_datas>) INDEX 1.

    DATA(lv_paymentorder) = <lfs_datas>-paymentorder.

    SELECT *  FROM zfi_db_item AS item
    WHERE paymentorder = @lv_paymentorder
    INTO TABLE @DATA(lt_item).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      DATA(ls_root) = VALUE zfi_db_root(
      paymentorder       = <fs_entity>-paymentorder
      status             = <fs_entity>-status
      ).
      APPEND ls_root TO zcl_zfi_api_buffer=>mt_create_zfi_status.

    ENDLOOP.


    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<lfs_item>).

      DATA(ls_item) = VALUE zfi_db_item(
        paymentorder       = <lfs_item>-paymentorder
        paymentline        = <lfs_item>-paymentline
        status             = <lfs_item>-status
        ).
      APPEND ls_item TO zcl_zfi_api_buffer=>mt_create_zfi_statusitem.


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

  METHOD rba_statsuchild.
  ENDMETHOD.

  METHOD cba_statsuchild.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zfi_status_modif DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zfi_status_modif IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.


    DATA: lt_data      TYPE STANDARD TABLE OF zfi_db_root,
          lt_data_item TYPE STANDARD TABLE OF zfi_db_item.

    FIELD-SYMBOLS: <fs_data>      TYPE zfi_db_root,
                   <fs_data_item> TYPE zfi_db_item.

    " Verileri al
    lt_data      = zcl_zfi_api_buffer=>mt_create_zfi_status.
    lt_data_item = zcl_zfi_api_buffer=>mt_create_zfi_statusitem.

    LOOP AT lt_data ASSIGNING <fs_data>.

      IF <fs_data>-status EQ 'X'.
        <fs_data>-status = '20'.

        UPDATE zfi_db_root
          SET status = @<fs_data>-status
          WHERE paymentorder = @<fs_data>-paymentorder.

      ENDIF.
    ENDLOOP.


    LOOP AT lt_data_item ASSIGNING <fs_data_item>.

      IF <fs_data>-status EQ '20'.
        <fs_data_item>-status = '20'.

        UPDATE zfi_db_item
          SET status = @<fs_data_item>-status
          WHERE paymentorder = @<fs_data_item>-paymentorder
          AND paymentline    = @<fs_data_item>-paymentline.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
