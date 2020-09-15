REPORT ZBS_ALV_GRID.

DATA gdt_spfli TYPE STANDARD TABLE OF spfli.

DATA ok_code LIKE sy-ucomm.

DATA: container_r TYPE REF TO cl_gui_custom_container,
      grid_r      TYPE REF TO cl_gui_alv_grid.

START-OF-SELECTION.

    SELECT * FROM spfli 
        INTO TABLE gdt_spfli.

    CALL SCREEN 100.

MODULE user_command_0100 INPUT.
    CASE ok_code.
        WHEN 'BACK'.
            SET SCREEN 0.
        WHEN 'EXIT'.
            LEAVE PROGRAM.
    ENDCASE.
ENDMODULE.

MODULE status_0100 OUTPUT.
    SET PF-STATUS 'STATUS_100'.
*SET TITLEBAR 'xxx'.
ENDMODULE.

MODULE clear_ok_code OUTPUT.
    CLEAR OK_CODE.
ENDMODULE.

MODULE create_control OUTPUT.
    IF container_r IS INITIAL.
        CREATE OBJECT container_r
            EXPORTING
                container_name = 'CONTAINER_1'.
        
        CREATE OBJECT grid_r
            EXPORTING
                i_parent = container_r.
        
        CALL METHOD grid_r->set_table_for_first_display
            EXPORTING
                i_structure_name = 'SPFLI'
            CHANGING
                it_outtab        = gdt_spfli.
    ENDIF.
ENDMODULE.
