@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'view of pymbtch_line'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true

define view entity ZFI_PYBATCH_TRANSITEM
  as select from zfi_db_item


  association to parent ZFI_PYBATCH_TRANSLINE as _Items on  _Items.Paymentorder = $projection.Paymentorder
                                                        and _Items.Paymentline  = $projection.Paymentline
                                                        and _Items.Paymentbatch = $projection.paymentbatch


{
  key zfi_db_item.paymentorder       as Paymentorder,
  key zfi_db_item.paymentline        as Paymentline,
      zfi_db_item.paymenttype        as Paymenttype,
      zfi_db_item.paymenttypedesc    as Paymenttypedesc,
      zfi_db_item.payercompany       as Payercompany,
      zfi_db_item.payercompanyname   as Payercompanyname,
      zfi_db_item.paymentdate        as Paymentdate,
      zfi_db_item.reference          as Reference,
      zfi_db_item.description        as Description,
      @Semantics.amount.currencyCode: 'Currency'
      zfi_db_item.amount             as Amount,
      zfi_db_item.currency           as Currency,
      zfi_db_item.payeenumber        as Payeenumber,
      zfi_db_item.payeename          as Payeename,
      zfi_db_item.payeecountry       as Payeecountry,
      zfi_db_item.payeeidentifier    as Payeeidentifier,
      zfi_db_item.payeeiban          as Payeeiban,
      zfi_db_item.payeebank          as Payeebank,
      zfi_db_item.payeebankaccount   as Payeebankaccount,
      zfi_db_item.payeeswift         as Payeeswift,
      zfi_db_item.paymentcost        as Paymentcost,
      zfi_db_item.roww               as Roww,
      zfi_db_item.invoicedate        as Invoicedate,
      zfi_db_item.lettercreditref    as Lettercreditref,
      zfi_db_item.invoicedeclaration as Invoicedeclaration,
      zfi_db_item.payeebankname      as Payeebankname,
      zfi_db_item.paycostdescription as Paycostdescription,
      zfi_db_item.created_by         as CreatedBy,
      zfi_db_item.created_at         as CreatedAt,
      zfi_db_item.last_changed_by    as LastChangedBy,
      zfi_db_item.last_changed_at    as LastChangedAt,
      zfi_db_item.etag_master        as EtagMaster,
      zfi_db_item.statusdesc         as StatusDesc,
      zfi_db_item.status             as Status,
      _Items.Paymentbatch,
      _Items
}
