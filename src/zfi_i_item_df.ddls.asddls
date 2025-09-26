@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination For Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true


/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity ZFI_I_ITEM_DF
  as select from zfi_db_item   as SOItem
    inner join   zfi_paymenttd as _db on SOItem.paymenttype = _db.paymenttype   
//                                            and SOItem.status = _db.status
                                          
  association to parent ZFI_I_HEADER_DF as _Root on $projection.Paymentorder = _Root.Paymentorder                                                  
{

  key SOItem.paymentorder       as Paymentorder,
  key SOItem.paymentline        as Paymentline,
      //  key _db.paymenttype         as Paymenttype,
      SOItem.paymenttype        as Paymenttype,
      SOItem.payercompany       as Payercompany,
      SOItem.payercompanyname   as Payercompanyname,
      SOItem.paymentdate        as Paymentdate,
      SOItem.reference          as Reference,
      SOItem.description        as Description,
      @Semantics.amount.currencyCode: 'Currency'
      SOItem.amount             as amount,
      SOItem.currency           as Currency,
      SOItem.payeenumber        as Payeenumber,
      SOItem.payeename          as Payeename,
      SOItem.payeecountry       as Payeecountry,
      SOItem.payeeidentifier    as Payeeidentifier,
      SOItem.payeeiban          as Payeeiban,
      SOItem.payeebank          as Payeebank,
      SOItem.payeebankaccount   as Payeebankaccount,
      SOItem.payeeswift         as Payeeswift,
      SOItem.paymentcost        as Paymentcost,
      SOItem.roww               as Roww,
      SOItem.invoicedate        as Invoicedate,
      SOItem.invoicedeclaration as Invoicedeclaration,
      SOItem.lettercreditref    as Lettercreditref,
      SOItem.payeebankname      as Payeebankname,
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
