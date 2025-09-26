@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Masraf DF'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_I_MASRAFTOS as select from zfi_db_masraftos
//composition of target_data_source_name as _association_name
{
    
    key sirketkodu as Sirketkodu,
    key bankakodu as Bankakodu,
    masrafhesap as Masrafhesap
    
}
