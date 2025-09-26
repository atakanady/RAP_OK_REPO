//@AbapCatalog.sqlViewName: 'ZFI_ONAYDOS'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Onay dosyası için data def.'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_I_ONAYDOS
  as select from zfi_api_onaydos
{
  key paymentorder as Paymentorder,
  key paymentline  as Paymentline,
      base64       as Base64,
      filetype     as Filetype,
      filename     as Filename,
      logdata      as Logdata,
      username     as Username
}
