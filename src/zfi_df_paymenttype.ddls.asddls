@AbapCatalog.sqlViewName: 'ZFIPAYMENTTYPE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'payment type and description for data defination'
@Metadata.ignorePropagatedAnnotations: true
define view ZFI_DF_PAYMENTTYPE as select from zfi_paymenttype
{
    key paymenttype as Paymenttype,
    paymenttypedesc as Paymenttypedesc
}
