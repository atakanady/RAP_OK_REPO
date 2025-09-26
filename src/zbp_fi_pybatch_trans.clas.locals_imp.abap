CLASS lhc_zfi_pybatch_trans DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_pybatch_trans RESULT result.
    METHODS oncreate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zfi_pybatch_trans~oncreate.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfi_pybatch_trans RESULT result.

ENDCLASS.

CLASS lhc_zfi_pybatch_trans IMPLEMENTATION.


  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD oncreate.
  ENDMETHOD.

  METHOD get_instance_features.



  ENDMETHOD.

ENDCLASS.
