@Metadata.allowExtensions: true
define view entity ZFI_I_ITEM_RO
  as select from zfi_db_item   as SOItem
    inner join   zfi_paymenttd as _db on SOItem.paymenttype = _db.paymenttype 
//    inner join   zfi_paymenttd as _db2 on SOItem.paymentcost = _db2.paymentcost
  association to parent ZFI_I_HEADER_RO as _Root on $projection.Paymentorder = _Root.Paymentorder

{

  key SOItem.paymentorder     as Paymentorder,
  key SOItem.paymentline      as Paymentline,
//  key _db.paymenttype         as Paymenttype,
      SOItem.paymenttype      as Paymenttype,
      SOItem.payercompany     as Payercompany,
      SOItem.payercompanyname as Payercompanyname,
      SOItem.paymentdate      as Paymentdate,
      SOItem.reference        as Reference,
      SOItem.description      as Description,
      SOItem.amount           as amount,
      SOItem.currency         as Currency,
      SOItem.payeenumber      as Payeenumber,
      SOItem.payeename        as Payeename,
      SOItem.payeecountry     as Payeecountry,
      SOItem.payeeidentifier  as Payeeidentifier,
      SOItem.payeeiban        as Payeeiban,
      SOItem.payeebank        as Payeebank,
      SOItem.payeebankaccount as Payeebankaccount,
      SOItem.payeeswift       as Payeeswift,
      SOItem.paymentcost      as Paymentcost,
//      _db2.paycostdescription  as Paycostdescription,
      SOItem.roww             as Roww,
      SOItem.invoicedate      as Invoicedate,
      SOItem.invoicedeclaration as Invoicedeclaration,
      SOItem.lettercreditref  as Lettercreditref,
      SOItem.payeebankname    as Payeebankname,
      SOItem.created_by       as CreatedBy,
      SOItem.created_at       as CreatedAt,
      SOItem.last_changed_by  as LastChangedBy,
      SOItem.last_changed_at  as LastChangedAt,
      SOItem.etag_master      as EtagMaster,
      _db.description         as DBDescription,
      
      
      _Root
}
