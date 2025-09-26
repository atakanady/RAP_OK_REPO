@AbapCatalog.sqlViewName: 'ZICOMPANYCODEVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I_CompanyCodeVH F4'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_CompanyCodeVH
  as select from I_CompanyCodeVH
{
  key CompanyCode,
      CompanyCodeName,
      ControllingArea,
      CityName,
      Country,
      Currency,
      Language,
      ChartOfAccounts,
      FiscalYearVariant,
      Company,
      CreditControlArea,
      CountryChartOfAccounts,
      FinancialManagementArea,
      /* Associations */
      _ChartOfAccounts,
      _ControllingArea,
      _Country,
      _CountryChartOfAccounts,
      _CreditControlArea,
      _Currency,
      _FiscalYearVariant,
      _Language
}
