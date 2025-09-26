@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination for ValueHelp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZFI_I_LastChangedBy
  as select from zfi_db_root
{


         @Search.defaultSearchElement: true
         @Search.fuzzinessThreshold: 0.7
  key    last_changed_by as LastChangedBy

} group by last_changed_by;
