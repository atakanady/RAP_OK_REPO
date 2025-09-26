@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'vh for payment order and line'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_PYMBATCH_VH
  as select from ZFI_I_HEADER_DF

{
  key Paymentorder,
      Used,
      Payercompany,
      Payercompanyname,
      Paymentdate,
      Status,
      Statusdescription,
      Paymenttype,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      EtagMaster,
      /* Associations */
      _Child.Paymentline,
      _Child.Reference,
      _Child.Description,
      @Semantics.amount.currencyCode: 'Currency'
      _Child.amount,
      _Child.Currency,
      _Child.Payeenumber,
      _Child.Payeename,
      _Child.Payeecountry,
      _Child.Payeeidentifier,
      _Child.Payeeiban,
      _Child.Payeebank,
      _Child.Payeebankaccount,
      _Child.Payeeswift,
      _Child.Paymentcost,
      _Child.Roww,
      _Child.Invoicedate,
      _Child.Invoicedeclaration,
      _Child.Lettercreditref,
      _Child.Payeebankname,
      _Child.Paycostdescription,
      _Child.DBDescription
//      _Child._Root
}
where
  Status = '30'
