@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Defination For Document Information'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_I_DOCS
  as select from zfi_db_doc

{

      @UI.facet: [{
                id: 'doc',
                purpose: #STANDARD,
                label: 'xxx',
                type: #IDENTIFICATION_REFERENCE,
                position: 10
            }]

  key zfi_db_doc.header      as Header,
  key zfi_db_doc.item        as Item,

      @UI: {
            lineItem: [{ position: 10 }],
            identification: [{ position: 10 }]
        }
      zfi_db_doc.obj_id      as Object,
      zfi_db_doc.repoid      as RepoId,
      zfi_db_doc.paymenttype as Paymenttype,
      zfi_db_doc.base64      as Base64,
      zfi_db_doc.filename    as FileName,
      ssize                  as Sizes,
      type                   as Type


}
