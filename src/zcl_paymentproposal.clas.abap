CLASS zcl_paymentproposal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.


  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA lv_datum TYPE budat.
    DATA lv_runId(4) TYPE c.
    DATA lo_log TYPE REF TO if_bali_log.

    DATA: lt_ProposalPayment TYPE TABLE OF I_PaymentProposalPayment,
          lt_ProposalItem    TYPE TABLE OF I_PaymentProposalItem,
          ls_ZFI_DB_ROOT     TYPE zfi_db_root,
          ls_ZFI_DB_ITEM     TYPE zfi_db_item.


ENDCLASS.



CLASS ZCL_PAYMENTPROPOSAL IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(  (  selname = 'P_RunDat'
                                    kind = if_apj_dt_exec_object=>parameter
                                    datatype = 'D'
                                    length   = 8
                                    param_text = 'Ödeme çalıştırma tarihi'
                                    changeable_ind = abap_true
*                                    mandatory_ind  = abap_true
)
                                 (  selname = 'P_RunID'
                                    kind = if_apj_dt_exec_object=>parameter
                                    datatype = 'C'
                                    length   = 10
*                                    mandatory_ind = abap_true
                                    param_text = 'Ödeme Çalıştırması Kimliği'
                                    changeable_ind = abap_true )
                                  ).


  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA: lv_max_paymentorder TYPE zfi_db_root-paymentorder,
          lv_formatted_date   TYPE zfi_db_root-paymentdate,
          new_id(8)           TYPE n.

    ASSIGN it_parameters[ selname = 'P_RunDat' ]-low TO FIELD-SYMBOL(<param>).
    IF sy-subrc IS INITIAL.
      lv_datum = <param>.
    ENDIF.
    UNASSIGN <param>.

    ASSIGN it_parameters[ selname = 'P_RunID' ]-low TO <param>.
    IF sy-subrc IS INITIAL.
      lv_runId = <param>.
    ENDIF.

    SELECT *
      FROM I_PaymentProposalPayment
      WHERE PaymentRunDate = @lv_datum
        AND PaymentRunID   = @lv_runId
      INTO TABLE @lt_ProposalPayment.

    IF lt_ProposalPayment[] IS NOT INITIAL.

      SELECT *
        FROM I_PaymentProposalItem
        FOR ALL ENTRIES IN @lt_ProposalPayment
        WHERE PaymentRunDate       = @lt_ProposalPayment-PaymentRunDate
          AND PaymentRunID         = @lt_ProposalPayment-PaymentRunID
          AND PaymentRunIsProposal = ''
          AND PayingCompanyCode    = '7000'
          AND FinancialAccountType = 'K'
        INTO TABLE @lt_ProposalItem.

    ENDIF.

    SELECT MAX( paymentorder )
      FROM zfi_db_root
      INTO @lv_max_paymentorder.

    IF lv_max_paymentorder IS INITIAL.
      lv_max_paymentorder = 10000.
    ENDIF.

    LOOP AT lt_ProposalPayment INTO DATA(ls_ProposalPayment).
      CLEAR ls_ZFI_DB_ROOT.

      lv_max_paymentorder = lv_max_paymentorder + 1.
      lv_formatted_date = |{ ls_ProposalPayment-PaymentRunDate+6(2) }.{ ls_ProposalPayment-PaymentRunDate+4(2) }.{ ls_ProposalPayment-PaymentRunDate+0(4) }|.

      ls_ZFI_DB_ROOT-paymentdate      = lv_formatted_date.
      ls_ZFI_DB_ROOT-payercompany     = ls_ProposalPayment-PayingCompanyCode.
      CASE ls_ProposalPayment-PaymentMethod.
        WHEN 'C'.
            ls_ZFI_DB_ROOT-paymenttype    = 'C'.
        WHEN 'F'.
            ls_ZFI_DB_ROOT-paymenttype    = 'Y'.
        WHEN OTHERS.
            ls_ZFI_DB_ROOT-paymenttype    = ls_ProposalPayment-PaymentMethod.
      ENDCASE.
      ls_ZFI_DB_ROOT-payercompanyname = 'Eren Holding A.Ş.'.
      ls_ZFI_DB_ROOT-paymentorder     = lv_max_paymentorder.
      ls_ZFI_DB_ROOT-is_used          = 'N'.
      ls_ZFI_DB_ROOT-status           = '10'.
      ls_ZFI_DB_ROOT-created_by       = sy-uname.
      ls_ZFI_DB_ROOT-created_at       = lv_formatted_date.
      ls_ZFI_DB_ROOT-amounttotal      = ''.
      ls_ZFI_DB_ROOT-itemtotal        = ''.

      INSERT zfi_db_root FROM @ls_ZFI_DB_ROOT.

      new_id = 0.

      LOOP AT lt_ProposalItem INTO DATA(ls_ProposalItem).
        CLEAR ls_ZFI_DB_ITEM.

        READ TABLE lt_ProposalPayment INTO DATA(ls_RelatedProposalPayment)
          WITH KEY PaymentRunDate = ls_ProposalItem-PaymentRunDate
               PaymentRunID   = ls_ProposalItem-PaymentRunID.

        IF sy-subrc IS INITIAL.
          new_id = new_id + 1.

          ls_ZFI_DB_ITEM-reference    = ls_ProposalItem-AccountingDocExternalReference.
          ls_ZFI_DB_ITEM-description  = ls_ProposalItem-DocumentItemText.
          ls_ZFI_DB_ITEM-amount       = ls_ProposalItem-AmountInTransactionCurrency.
          ls_ZFI_DB_ITEM-currency     = ls_ProposalItem-PaymentCurrency.
          ls_ZFI_DB_ITEM-paymentcost  = 'SHA'.
          ls_ZFI_DB_ITEM-paymentorder = lv_max_paymentorder.
          ls_ZFI_DB_ITEM-paymentline  = new_id.
          ls_ZFI_DB_ITEM-paymenttype  = ls_ZFI_DB_ROOT-paymenttype.
          ls_ZFI_DB_ITEM-payercompany = ls_ZFI_DB_ROOT-payercompany.
          ls_ZFI_DB_ITEM-paymentdate  = lv_formatted_date.

          ls_ZFI_DB_ITEM-payeename    = ls_RelatedProposalPayment-PayeeName.
          ls_ZFI_DB_ITEM-payeecountry = ls_RelatedProposalPayment-PayeeCountry.
          ls_ZFI_DB_ITEM-payeeiban    = ls_RelatedProposalPayment-IBAN.
          ls_ZFI_DB_ITEM-payeeswift   = ls_RelatedProposalPayment-PayeeSWIFTCode.

          INSERT zfi_db_item FROM @ls_ZFI_DB_ITEM.
        ELSE.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
*
*    DATA: lv_max_paymentorder TYPE zfi_db_root-paymentorder,
*          lv_formatted_date   TYPE zfi_db_root-paymentdate,
*          new_id(8)           TYPE n.
*
*    lv_datum = '20241024'.
*    lv_runId = 'WEEK'.
*
*    SELECT *
*      FROM I_PaymentProposalPayment
*      WHERE PaymentRunDate = @lv_datum
*        AND PaymentRunID   = @lv_runId
*      INTO TABLE @lt_ProposalPayment.
*
*    IF lt_ProposalPayment[] IS NOT INITIAL.
*
*      SELECT *
*        FROM I_PaymentProposalItem
*        FOR ALL ENTRIES IN @lt_ProposalPayment
*        WHERE PaymentRunDate       = @lt_ProposalPayment-PaymentRunDate
*          AND PaymentRunID         = @lt_ProposalPayment-PaymentRunID
*          AND PaymentRunIsProposal = ''
*          AND PayingCompanyCode    = '7000'
*          AND FinancialAccountType = 'K'
*        INTO TABLE @lt_ProposalItem.
*
*    ENDIF.
*
*    SELECT MAX( paymentorder )
*      FROM zfi_db_root
*      INTO @lv_max_paymentorder.
*
*    IF lv_max_paymentorder IS INITIAL.
*      lv_max_paymentorder = 10000.
*    ENDIF.
*
*    LOOP AT lt_ProposalPayment INTO DATA(ls_ProposalPayment).
*      CLEAR ls_ZFI_DB_ROOT.
*
*      lv_max_paymentorder = lv_max_paymentorder + 1.
*      lv_formatted_date = |{ ls_ProposalPayment-PaymentRunDate+6(2) }.{ ls_ProposalPayment-PaymentRunDate+4(2) }.{ ls_ProposalPayment-PaymentRunDate+0(4) }|.
*
*      ls_ZFI_DB_ROOT-paymentdate      = lv_formatted_date.
*      ls_ZFI_DB_ROOT-payercompany     = ls_ProposalPayment-PayingCompanyCode.
*      ls_ZFI_DB_ROOT-paymenttype      = 'T'.
*      ls_ZFI_DB_ROOT-payercompanyname = ls_ProposalPayment-Supplier.
*      ls_ZFI_DB_ROOT-paymentorder     = lv_max_paymentorder.
*      ls_ZFI_DB_ROOT-is_used          = 'N'.
*      ls_ZFI_DB_ROOT-status           = '10'.
*      ls_ZFI_DB_ROOT-created_by       = sy-uname.
*      ls_ZFI_DB_ROOT-created_at       = lv_formatted_date.
*
*      INSERT zfi_db_root FROM @ls_ZFI_DB_ROOT.
*
*      new_id = 0.
*
*      LOOP AT lt_ProposalItem INTO DATA(ls_ProposalItem).
*        CLEAR ls_ZFI_DB_ITEM.
*
*        READ TABLE lt_ProposalPayment INTO DATA(ls_RelatedProposalPayment)
*          WITH KEY PaymentRunDate = ls_ProposalItem-PaymentRunDate
*               PaymentRunID   = ls_ProposalItem-PaymentRunID.
*
*        IF sy-subrc IS INITIAL.
*          new_id = new_id + 1.
*
*          ls_ZFI_DB_ITEM-reference    = ls_ProposalItem-AccountingDocExternalReference.
*          ls_ZFI_DB_ITEM-description  = ls_ProposalItem-DocumentItemText.
*          ls_ZFI_DB_ITEM-amount       = ls_ProposalItem-AmountInTransactionCurrency.
*          ls_ZFI_DB_ITEM-currency     = ls_ProposalItem-PaymentCurrency.
*          ls_ZFI_DB_ITEM-paymentcost  = 'SHA'.
*          ls_ZFI_DB_ITEM-paymentorder = lv_max_paymentorder.
*          ls_ZFI_DB_ITEM-paymentline  = new_id.
*          ls_ZFI_DB_ITEM-paymenttype  = 'T'.
*          ls_ZFI_DB_ITEM-payercompany = ls_ProposalItem-PayingCompanyCode.
*          ls_ZFI_DB_ITEM-paymentdate  = lv_formatted_date.
*
*          ls_ZFI_DB_ITEM-payeename    = ls_RelatedProposalPayment-PayeeName.
*          ls_ZFI_DB_ITEM-payeecountry = ls_RelatedProposalPayment-PayeeCountry.
*          ls_ZFI_DB_ITEM-payeeiban    = ls_RelatedProposalPayment-iban.
*          ls_ZFI_DB_ITEM-payeeswift   = ls_RelatedProposalPayment-PayeeSWIFTCode.
*
*          INSERT zfi_db_item FROM @ls_ZFI_DB_ITEM.
*        ELSE.
*        ENDIF.
*      ENDLOOP.
*
*    ENDLOOP.
*
*
  ENDMETHOD.
ENDCLASS.
