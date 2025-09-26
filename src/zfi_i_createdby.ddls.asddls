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
define root view entity ZFI_I_CreatedBy
  as select from zfi_db_root
//    inner join   zfi_db_root   as _db on _CreatedBy.created_by = _db.created_by
{

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  key created_by     as CreatedBy



} group by created_by;
