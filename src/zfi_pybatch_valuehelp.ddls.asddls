@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help Defination'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_PYBATCH_VALUEHELP
  as select from zfi_db_item

{
  key paymentorder       as Paymentorder,
  key paymentline        as Paymentline,
      paymenttype        as Paymenttype,
      paymenttypedesc    as Paymenttypedesc,
      payercompany       as Payercompany,
      payercompanyname   as Payercompanyname,
      paymentdate        as Paymentdate,
      reference          as Reference,
      description        as Description,
      @Semantics.amount.currencyCode: 'Currency'
      amount             as Amount,
      currency           as Currency,
      payeenumber        as Payeenumber,
      payeename          as Payeename,
      payeecountry       as Payeecountry,
      payeeidentifier    as Payeeidentifier,
      payeeiban          as Payeeiban,
      payeebank          as Payeebank,
      payeebankaccount   as Payeebankaccount,
      payeeswift         as Payeeswift,
      paymentcost        as Paymentcost,
      roww               as Roww,
      invoicedate        as Invoicedate,
      lettercreditref    as Lettercreditref,
      invoicedeclaration as Invoicedeclaration,
      payeebankname      as Payeebankname,
      paycostdescription as Paycostdescription,
      created_by         as CreatedBy,
      created_at         as CreatedAt,
      last_changed_by    as LastChangedBy,
      last_changed_at    as LastChangedAt,
      etag_master        as EtagMaster
}
