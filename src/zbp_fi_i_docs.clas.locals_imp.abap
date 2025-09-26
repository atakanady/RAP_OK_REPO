CLASS lhc_ZFI_I_DOCS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_i_docs RESULT result.

    METHODS onSave FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_i_docs~onSave.


ENDCLASS.

CLASS lhc_ZFI_I_DOCS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD onSave.
  ENDMETHOD.

ENDCLASS.
