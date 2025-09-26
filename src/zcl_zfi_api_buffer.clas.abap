CLASS zcl_zfi_api_buffer DEFINITION
  PUBLIC CREATE PRIVATE.

  PUBLIC SECTION.


    TYPES: BEGIN OF ty_zfi_api_objrepo,
             repoid TYPE zfi_db_doc-repoid,
             objid  TYPE zfi_db_doc-obj_id,
           END OF ty_zfi_api_objrepo.



    TYPES: BEGIN OF ty_zfi_api_root,
             paymentorder       TYPE zfi_db_root-paymentorder,
             used               TYPE zfi_db_root-is_used,
             payercompany       TYPE zfi_db_root-payercompany,
             processdescription TYPE zfi_db_root-processdescription,
             payercompanyname   TYPE zfi_db_root-payercompanyname,
             paymentdate        TYPE zfi_db_root-paymentdate,
             status             TYPE zfi_db_root-status,
             statusdescription  TYPE zfi_db_root-processdescription,
             paymenttype        TYPE zfi_db_root-paymenttype,
             amounttotal        TYPE zfi_db_root-amounttotal,
             itemtotal          TYPE zfi_db_root-itemtotal,
             userinfo           TYPE zfi_db_root-userinfo,
             created_by         TYPE zfi_db_root-created_by,
             created_at         TYPE zfi_db_root-created_at,
             last_changed_by    TYPE zfi_db_root-last_changed_by,
             last_changed_at    TYPE zfi_db_root-last_changed_at,
             etag_master        TYPE zfi_db_root-etag_master,
           END OF ty_zfi_api_root.



    TYPES: BEGIN OF ty_zfi_api_item,
             invoice_reference   TYPE zfi_db_item-reference,
             invoice_description TYPE zfi_db_item-description,
             payment_amount      TYPE zfi_db_item-amount,
             payment_currency    TYPE zfi_db_item-currency,
             payee_number        TYPE zfi_db_item-payeenumber,
             payee_name          TYPE zfi_db_item-payeename,
             payee_country       TYPE zfi_db_item-payeecountry,
             payee_identifier    TYPE zfi_db_item-payeeidentifier,
             payee_iban          TYPE zfi_db_item-payeeiban,
             payee_bank_number   TYPE zfi_db_item-payeebank,
             payee_bank_account  TYPE zfi_db_item-payeebankaccount,
             payee_bank_swift    TYPE zfi_db_item-payeeswift,
             payee_bank_cost     TYPE zfi_db_item-paymentcost,
             invoice_date        TYPE zfi_db_item-invoicedate,
             invoice_declaration TYPE zfi_db_item-invoicedeclaration,
             letter_credit_ref   TYPE zfi_db_item-lettercreditref,
             payee_bank_name     TYPE zfi_db_item-payeebankname,
           END OF ty_zfi_api_item.



    TYPES: BEGIN OF ty_zfi_api_onay,
             paymentorder TYPE zfi_api_onaydos-paymentorder,
             base64       TYPE zfi_api_onaydos-base64,
             filetype     TYPE zfi_api_onaydos-filetype,
             filename     TYPE zfi_api_onaydos-filename,
             logdata      TYPE zfi_api_onaydos-logdata,
             username     TYPE zfi_api_onaydos-username,
           END OF ty_zfi_api_onay.



    TYPES: BEGIN OF ty_zfi_api_status,
             paymentorder TYPE zfi_db_root-paymentorder,
             status       TYPE zfi_db_root-status,
           END OF ty_zfi_api_status.


    TYPES: BEGIN OF ty_zfi_api_statusitem,
             paymentorder TYPE zfi_db_root-paymentorder,
             status       TYPE zfi_db_root-status,
             paymentline  TYPE zfi_db_item-paymentline,
           END OF ty_zfi_api_statusitem.


    CLASS-DATA: mt_create_zfi            TYPE TABLE OF zfi_db_root.
    CLASS-DATA: mt_create_zfi_item       TYPE TABLE OF zfi_db_item.
    CLASS-DATA: mt_create_zfi_onay       TYPE TABLE OF zfi_api_onaydos.
    CLASS-DATA: mt_create_zfi_status     TYPE TABLE OF zfi_db_root.
    CLASS-DATA: mt_create_zfi_statusitem TYPE TABLE OF zfi_db_item.
    CLASS-DATA: mt_id_doc                TYPE TABLE OF zfi_db_doc.

    CLASS-METHODS: clear_all.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZFI_API_BUFFER IMPLEMENTATION.


  METHOD clear_all.
    CLEAR: mt_create_zfi.
  ENDMETHOD.
ENDCLASS.
