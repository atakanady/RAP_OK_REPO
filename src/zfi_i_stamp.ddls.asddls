@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definiton for Company Stamp'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_I_STAMP as select from zfi_db_stamp
{
    key zfi_db_stamp.companycode as Companycode,
    zfi_db_stamp.stamp as Stamp
}
