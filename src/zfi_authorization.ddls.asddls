@AbapCatalog.sqlViewName: 'ZFI_AUTHORIZATI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Yetkilendirme'
@Metadata.ignorePropagatedAnnotations: true
define view ZFI_AUTHORIZATION as select from zfi_authorizatio
{
    key username as Username,
    key companycode as Companycode
}
