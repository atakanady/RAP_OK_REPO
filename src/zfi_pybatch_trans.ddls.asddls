@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZFI_PYBATCH_TRANS
  as select from zfi_pymbtch_bank
  composition [1..*] of ZFI_PYBATCH_TRANSLINE       as _Line

  association [1..1] to ZFI_I_HouseBankAccountStdVH as _I_HouseBankAccountStdVH on _I_HouseBankAccountStdVH.BankAccountInternalID = $projection.Bankaccountinternalid


{


  key        paymentbatch                                    as Paymentbatch,
             companycode                                     as Companycode,
             bankaccountinternalid                           as Bankaccountinternalid,
             housebankaccount                                as Housebankaccount,
             housebank                                       as Housebank,
             status                                          as Status,
             bankcontrolkey                                  as BankControlKey,
             statusx                                         as Statusx,
             totalitem                                       as TotalItem,
             totalamount                                     as TotalAmount,
             paymentdatepb                                   as Paymentdatepb,
             _I_HouseBankAccountStdVH.IBAN                   as IBAN,
             lastchangedat                                   as lastchangedat,
             paymenttype                                     as Paymenttype,
             //             bankname                                        as BankName,
             selectdate                                      as sSelectedDate,
             bankinternalid                                  as BankInternalID,
             documentno                                      as DocumentNo,
             pzmessage                                       as PZMessage,


             _Line,
             
             _I_HouseBankAccountStdVH,
             _I_HouseBankAccountStdVH.SWIFTCode              as SWIFTCode,
             _I_HouseBankAccountStdVH.CompanyCodeName        as CompanyCodeName,
             _I_HouseBankAccountStdVH.BankAccountCurrency    as BankAccountCurrency,
             _I_HouseBankAccountStdVH.BankName               as BankName,
             _I_HouseBankAccountStdVH.BankAccount            as BankAccount,
             _I_HouseBankAccountStdVH.CompanyCode            as ICompanyCode,
             _I_HouseBankAccountStdVH.BankAccountDescription as BankAccountDescription
//             _I_HouseBankAccountStdVH.BankAccountInternalID  as Bankaccountinternalid


}
where
  status = 'Y'
