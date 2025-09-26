@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For I_RegionText'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_RegionText as select from I_RegionText
{
    key Country,
    key Region,
    key Language,
    RegionName,
    /* Associations */
    _Country,
    _Language,
    _Region
}
