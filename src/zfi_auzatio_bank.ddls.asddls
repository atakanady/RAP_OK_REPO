@AbapCatalog.sqlViewName: 'ZFI_AUZATIO_BAN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tayin Et Yetki'
@Metadata.ignorePropagatedAnnotations: true
define view ZFI_AUZATION_BANK as select from zfi_auzatio_bank
{
    key username as Username,
    key appoint as Appoint
}
