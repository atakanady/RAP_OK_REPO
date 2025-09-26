@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For ZFI_DB_TXT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZFI_DF_TXT as select from zfi_txt_db
{
    key iban as Iban,
    txtdetay as Txtdetay,
    alt_txtdetay as Alt_txtdetay
}
