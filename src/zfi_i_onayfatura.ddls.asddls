@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fatura görseli ekleme'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_I_ONAYFATURA
  as select from zfi_api_onaydos
  //composition of target_data_source_name as _association_name
{

  key paymentorder as Paymentorder,
  key paymentline  as Paymentline,
      base64       as Base64,
      filetype     as Filetype,
      filename     as Filename,
      logdata      as Logdata,
      username     as Username

      //      _association_name // Make association public
}
