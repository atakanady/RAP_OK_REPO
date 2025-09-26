CLASS zcl_update_items DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_status_data,
             paymentbatch     TYPE zfi_pymbtch_line-paymentbatch,  " Doğru veri türüyle değiştirin
             paymentorder     TYPE zfi_pymbtch_line-paymentorder,
             paymentline      TYPE zfi_pymbtch_line-paymentline,
             statusvalidation TYPE zfi_pymbtch_line-status,
             statusdesc       TYPE zfi_pymbtch_line-statusdesc,
           END OF ty_status_data.

    TYPES: tt_status_data TYPE TABLE OF ty_status_data WITH EMPTY KEY.


    CLASS-METHODS update_external_status
      IMPORTING
        it_status TYPE tt_status_data." lt_status için uygun tablo tipi


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_UPDATE_ITEMS IMPLEMENTATION.


  METHOD update_external_status.

*    DATA: lt_update TYPE TABLE FOR UPDATE zfi_i_item_df.
*
*
*    LOOP AT it_status ASSIGNING FIELD-SYMBOL(<fs_status>).
*      APPEND VALUE #( paymentorder = <fs_status>-paymentorder
*                      status       = 'X' ) TO  lt_update   .
*    ENDLOOP.
*
*
*
*
*    MODIFY ENTITIES OF zfi_i_header_df IN LOCAL MODE
*      ENTITY zfi_i_item_df
*      UPDATE
*      FIELDS ( Paymentorder Status ) " Güncellenecek alanları belirtin
*      WITH lt_update " Güncelleme tablosunu geçirin
*      FAILED DATA(lt_failed).


*  ENDLOOP.

  ENDMETHOD.
ENDCLASS.
