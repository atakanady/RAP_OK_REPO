@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For I_Bank_2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_Bank_2
  as select from I_Bank_2
{
  key BankCountry,
  key BankInternalID,
      CreationDate,
      CreatedByUser,
      BankName,
      Region,
      StreetName,
      ShortStreetName,
      CityName,
      ShortCityName,
      SWIFTCode,
      BankNetworkGrouping,
      IsPostBankAccount,
      IsMarkedForDeletion,
      Bank,
      PostOfficeBankAccount,
      Branch,
      BankBranch,
      CheckDigitCalculationMethod,
      BankDataFileFormat,
      AddressID,
      BankCategory,
      /* Associations */
      _Address,
      _BankAdditionalFields,
      _BankAddress,
      _Country,
      _HouseBank,
      _IntradayRule,
      _Region
}
