CLASS zcl_bsh_ab_first_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BSH_AB_FIRST_CLASS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    select * from ZBSH_AB_CDS_ENT( p_ctry = 'IN' ) into table @data(itab).

    "write : 'welcome to steampunk'.
    out->write(
      EXPORTING
        data   = itab
*        name   =
*      RECEIVING
*        output =
    ).

  ENDMETHOD.
ENDCLASS.
