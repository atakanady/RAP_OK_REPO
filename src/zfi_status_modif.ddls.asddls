@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status alanını değişimi'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_STATUS_MODIF
  as select from zfi_db_root
  composition [0..*] of ZFI_status_ITEM as _StatsuChild
{
  key paymentorder as Paymentorder,
      //    is_used as İsUsed,
      //    payercompany as Payercompany,
      //    payercompanyname as Payercompanyname,
      //    paymentdate as Paymentdate,
      status       as Status,
      //    created_by as CreatedBy,
      //    created_at as CreatedAt,
      //    paymenttype as Paymenttype,
      //    processdescription as Processdescription,
      //    amounttotal as Amounttotal,
      //    itemtotal as İtemtotal,
      //    userinfo as Userinfo,
      //    last_changed_by as LastChangedBy,
      //    etag_master as EtagMaster,
      //    local_created_by as LocalCreatedBy,
      //    local_created_at as LocalCreatedAt,
      //    local_last_changed_by as LocalLastChangedBy,
      //    local_last_changed_at as LocalLastChangedAt,
      //    last_changed_at as LastChangedAt,
      //    _association_name // Make association public
      _StatsuChild
}
