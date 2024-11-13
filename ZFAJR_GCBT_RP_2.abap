*&---------------------------------------------------------------------*
*& Report ZFAJR_GCBT_RP_2
*&---------------------------------------------------------------------*
*& Utilizando HTML em um Programa ABAP
*&---------------------------------------------------------------------*
REPORT ZFAJR_GCBT_RP_2.

* Tela de seleção ilustrativa - Não remover
TABLES: sflight.
SELECT-OPTIONS:s_carrid FOR sflight-carrid.

CLASS lcl_report DEFINITION.

  PUBLIC SECTION.

    TYPES: tt_event TYPE TABLE OF cntl_simple_event WITH DEFAULT KEY,
           tt_html  TYPE TABLE OF string WITH DEFAULT KEY.

    DATA lt_html TYPE TABLE OF char1024.
    DATA doc_url(80).
    DATA lt_report TYPE tt_html.

    DATA: lo_dock TYPE REF TO cl_gui_docking_container,
          lo_cont TYPE REF TO cl_gui_container,
          lo_html TYPE REF TO cl_gui_html_viewer.

    METHODS:  init,
              build_html,

              on_sapevent FOR EVENT sapevent OF cl_gui_html_viewer
                IMPORTING action
                          frame
                          getdata
                          postdata
                          query_table.

ENDCLASS.

CLASS lcl_report IMPLEMENTATION.

  METHOD init.

    CHECK lo_dock IS INITIAL.

    CREATE OBJECT lo_dock
      EXPORTING
        repid                   = sy-cprog
        dynnr                   = sy-dynnr
        side                    = cl_gui_docking_container=>dock_at_bottom
        extension               = 1800
        style                   = lo_dock->ws_child
        metric                  = lo_dock->metric_pixel
        no_autodef_progid_dynnr = 'X'.

    IF sy-subrc <> 0.
      MESSAGE 'Erro ao gerar container' TYPE 'S'.
      EXIT.
    ENDIF.

    CREATE OBJECT lo_html
      EXPORTING
        parent = lo_dock.

    CALL METHOD cl_gui_cfw=>flush.

    build_html( ).

    CALL METHOD cl_gui_cfw=>flush.

    DATA(lt_events) = VALUE tt_event(
      ( eventid = lo_html->m_id_sapevent appl_event = 'X' )
    ).
    lo_html->set_registered_events( EXPORTING events = lt_events ).

    SET HANDLER on_sapevent FOR lo_html.

    lo_html->load_data( IMPORTING assigned_url = doc_url
                        CHANGING  data_table = lt_html[] ).

    lo_html->load_data( EXPORTING type    = 'text'
                                  subtype = 'html'
                        IMPORTING assigned_url = doc_url
                        CHANGING  data_table = lt_html[] ).

    CALL METHOD lo_html->show_data( url = doc_url ).

  ENDMETHOD.

  METHOD build_html.

    lt_html = VALUE #(
      ( |<!DOCTYPE html><html>| )
      ( | <head>| )
      ( | </head>| )
      ( | | )
      ( | <body>| )
      ( |   <h2 style="color:blue;">Olá HTML</h2>| )
      ( |   <a href="SAPEVENT:CLK_1">Evento Click</a>| )
      ( | </body>| )
      ( |</html>| )
    ).

  ENDMETHOD.

  METHOD on_sapevent.

    CASE action.
      WHEN 'CLK_1'. " Call Transaction
        MESSAGE 'Clicou' TYPE 'I'.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.

INITIALIZATION.
  DATA(lo_report) = NEW lcl_report( ).
  lo_report->init( ).