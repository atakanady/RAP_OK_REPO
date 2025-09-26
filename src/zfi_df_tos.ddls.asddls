@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For ZFI_DF_TOS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZFI_DF_TOS
  as select from zfi_db_tos
{
  key sirketkodu        as Sirketkodu,
  key bankannumarasi    as Bankannumarasi,
      integrationno     as Integrationno,
      signaturetype     as Signaturetype,
      tos               as Tos,
      integrationno_tos as Integrationno_tos,
      integrationno_tos_yp as Integrationno_tos_yp
}
