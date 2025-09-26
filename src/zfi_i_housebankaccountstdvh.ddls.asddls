@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F4 For I_HouseBankAccountStdVH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define root view entity ZFI_I_HouseBankAccountStdVH
  as select from I_HouseBankAccountLinkage
{
  key    CompanyCode,
  key    HouseBankAccount,
  key    BankAccountInternalID,
         HouseBank,
         BankInternalID,
         BankCountry,
         CompanyCodeName,
         SWIFTCode,
         BankName,
         BankNumber,
         BankAccount,
         //      BankAccountAlternative,
         //      ReferenceInfo,
         BankControlKey,
         BankAccountCurrency,
         IBAN,
         BankAccountDescription,
         //      GLAccount,
         //      BankAccountHolderName,
         BankAccountNumber
         /* Associations */
         //      _BankAccount,
         //      _CompanyCode,
         //      _CountryText,
         //      _HouseBank
}
