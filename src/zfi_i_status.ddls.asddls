@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination for ValueHelp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_Status as select from zfi_status
{
 
  @Search.defaultSearchElement: true
 key status as Status,

     @Search.defaultSearchElement: true
     @Search.fuzzinessThreshold: 0.7   
     statusdesc as StatusDesc

 

}
