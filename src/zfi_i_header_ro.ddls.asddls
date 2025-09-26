@Metadata.allowExtensions: true
define root view entity ZFI_I_HEADER_RO
  as select from zfi_db_root as so_hdr 
    inner join   zfi_paymenttd as _db on so_hdr.status = _db.status 
  composition [0..*] of ZFI_I_ITEM_RO as _Child
  
  

{

      @UI.facet: [{
                id: 'StudentData',
                purpose: #STANDARD,
                label: 'Attachment Information',
                type: #IDENTIFICATION_REFERENCE,
                position: 10
            }]

      @UI: {
            lineItem: [{ position: 10 }],
            identification: [{ position: 10 }]
        }
  key so_hdr.paymentorder     as Paymentorder,
      so_hdr.is_used          as Used,
      so_hdr.payercompany     as Payercompany,
      so_hdr.processdescription as Processdescription,
      

      so_hdr.payercompanyname as Payercompanyname,
      so_hdr.paymentdate      as Paymentdate,
      so_hdr.status           as Status,
      _db.statusdescription   as Statusdescription,
      so_hdr.paymenttype      as Paymenttype,
      so_hdr.amounttotal      as Amounttotal,
      so_hdr.itemtotal        as Itemtotal,
      @Semantics.user.createdBy: true

      so_hdr.created_by       as CreatedBy,
      //      @Semantics.systemDateTime.createdAt: true

      so_hdr.created_at       as CreatedAt,
      @Semantics.user.lastChangedBy: true

      so_hdr.last_changed_by  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true

      so_hdr.last_changed_at  as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      so_hdr.etag_master      as EtagMaster,

//      _Attachments,
      _Child
//      zfi_paymenttd
       
}
where so_hdr.is_used <> 'Y' 
   and so_hdr.status <> '10'
