//@AbapCatalog.sqlViewName: 'ZFI_STATUSITEM'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status alanını değişimi'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_status_ITEM
  as select from zfi_db_item

  association to parent ZFI_STATUS_MODIF as _StatusRoot on $projection.Paymentorder = _StatusRoot.Paymentorder
{
  key paymentorder as Paymentorder,
  key paymentline  as Paymentline,
      //      paymenttype        as Paymenttype,
      //      paymenttypedesc    as Paymenttypedesc,
      //      payercompany       as Payercompany,
      //      payercompanyname   as Payercompanyname,
      //      paymentdate        as Paymentdate,
      //      reference          as Reference,
      //      description        as Description,
      //      amount             as Amount,
      //      currency           as Currency,
      //      payeenumber        as Payeenumber,
      //      payeename          as Payeename,
      //      payeecountry       as Payeecountry,
      //      payeeidentifier    as Payeeidentifier,
      //      payeeiban          as Payeeiban,
      //      payeebank          as Payeebank,
      //      payeebankaccount   as Payeebankaccount,
      //      payeeswift         as Payeeswift,
      //      paymentcost        as Paymentcost,
      //      roww               as Roww,
      //      invoicedate        as İnvoicedate,
      //      lettercreditref    as Lettercreditref,
      //      invoicedeclaration as İnvoicedeclaration,
      //      payeebankname      as Payeebankname,
      //      paycostdescription as Paycostdescription,
      //      created_by         as CreatedBy,
      //      created_at         as CreatedAt,
      //      status             as Status,
      //      statusdesc         as Statusdesc,
      //      bankinformation    as Bankinformation,
      //      selectediban       as Selectediban,
      //      last_changed_by    as LastChangedBy,
      //      last_changed_at    as LastChangedAt,
      //      etag_master        as EtagMaster
      _StatusRoot
}
