@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination For Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true


/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity ZFI_API_ITEM
  as select from zfi_db_item   as SOItem
    inner join   zfi_paymenttd as _db on SOItem.paymenttype = _db.paymenttype   
//                                            and SOItem.status = _db.status
                                          
  association to parent ZFI_API_ROOT as _Root on $projection.Paymentorder = _Root.Paymentorder                                                  
{

  key SOItem.paymentorder       as Paymentorder,
  key SOItem.paymentline        as Paymentline,
      //  key _db.paymenttype         as Paymenttype,
      SOItem.paymenttype        as PAYMENT_TYPE,
      SOItem.payercompany       as PAYMENT_COMPANY,
      SOItem.payercompanyname   as Payercompanyname,
      SOItem.paymentdate        as PAYMENT_DATE,
      SOItem.reference          as INVOICE_REFERENCE,
      SOItem.description        as INVOICE_DESCRIPTION,
      @Semantics.amount.currencyCode: 'PAYMENT_CURRENCY'
      SOItem.amount             as PAYMENT_AMOUNT,
      SOItem.currency           as PAYMENT_CURRENCY,
      SOItem.payeenumber        as PAYEE_NUMBER,
      SOItem.payeename          as PAYEE_NAME,
      SOItem.payeecountry       as PAYEE_COUNTRY,
      SOItem.payeeidentifier    as PAYEE_IDENTIFIER,
      SOItem.payeeiban          as PAYEE_IBAN,
      SOItem.payeebank          as PAYEE_BANK_NUMBER,
      SOItem.payeebankaccount   as PAYEE_BANK_ACCOUNT,
      SOItem.payeeswift         as PAYEE_BANK_SWIFT,
      SOItem.paymentcost        as PAYEE_BANK_COST,
      SOItem.roww               as Roww,
      SOItem.invoicedate        as INVOICE_DATE,
      SOItem.invoicedeclaration as INVOICE_DECLARATION,
      SOItem.lettercreditref    as LETTER_CREDIT_REF,
      SOItem.payeebankname      as PAYEE_BANK_NAME,
      //      _db2.paycostdescription   as Paycostdescription,
      SOItem.paycostdescription as Paycostdescription,
      SOItem.created_by         as CreatedBy,
      SOItem.created_at         as CreatedAt,
      SOItem.last_changed_by    as LastChangedBy,
      SOItem.last_changed_at    as LastChangedAt,
      SOItem.etag_master        as EtagMaster,
      _db.description           as DBDescription,
      SOItem.status             as Status,
      SOItem.selectediban       as SelectedIban,
      SOItem.bankinformation    as BankInfo,
//      _db.statusdescription     as Statusdescription,

      _Root
}
