@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View of Payment Batch Line'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZFI_PYMBATCH_LINE
  as select from zfi_pymbtch_line
  association        to parent ZFI_PYMBATCH_BANK as _Parent on  $projection.Paymentbatch = _Parent.Paymentbatch

  //  composition [1..*] of ZFI_I_ITEM_DF2           as _ItemDF2
  association [1..1] to ZFI_I_ITEM_DF2           as _Items  on  _Items.Paymentorder = $projection.Paymentorder
                                                            and _Items.Paymentline  = $projection.Paymentline
{

  key                  paymentbatch              as Paymentbatch,
  key                  paymentorder              as Paymentorder,
  key                  paymentline               as Paymentline,
                       status                    as StatusValidation,
                       statusdesc                as StatusDesc,
                       _Parent,
                       //_ItemDF2.
                       _Items,
                       _Items.Paymenttype        as Paymenttype,
                       _Items.Paymenttypedesc    as Paymenttypedesc,
                       _Items.Payercompany       as Payercompany,
                       _Items.Payercompanyname   as Payercompanyname,
                       _Items.Paymentdate        as Paymentdate,
                       _Items.Reference          as Reference,
                       _Items.Description        as Description,
                       _Items.Amount             as Amount,
                       _Items.Currency           as Currency,
                       _Items.Payeenumber        as Payeenumber,
                       _Items.Payeename          as Payeename,
                       _Items.Payeecountry       as Payeecountry,
                       _Items.Payeeidentifier    as Payeeidentifier,
                       _Items.Payeeiban          as Payeeiban,
                       _Items.Payeebank          as Payeebank,
                       _Items.Payeebankaccount   as Payeebankaccount,
                       _Items.Payeeswift         as Payeeswift,
                       _Items.Paymentcost        as Paymentcost,
                       _Items.Roww               as Roww,
                       _Items.Invoicedate        as Invoicedate,
                       _Items.Lettercreditref    as Lettercreditref,
                       _Items.Invoicedeclaration as Invoicedeclaration,
                       _Items.Payeebankname      as Payeebankname,
                       _Items.Paycostdescription as Paycostdescription



}
