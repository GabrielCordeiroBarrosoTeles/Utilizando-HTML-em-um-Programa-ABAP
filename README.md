# Utilizando HTML em um Programa ABAP

Neste exemplo, vamos aprender como integrar HTML dentro de um programa ABAP. Esse tipo de abordagem é menos comum e pode ser difícil de encontrar na internet. Caso tenha dúvidas, deixe um comentário e podemos adicionar mais exemplos ou melhorias.

## Classes da SAP Utilizadas

Usaremos algumas classes da SAP para facilitar a implementação da exibição de HTML no ABAP. A classe principal é a **cl_gui_html_viewer**, que nos permite carregar e exibir conteúdo HTML diretamente em um programa ABAP, sem a necessidade de declarar telas adicionais.

### Considerações Importantes

O **GUI** possui um navegador embutido que, em alguns casos, pode estar desatualizado. Isso pode resultar em problemas com a exibição de tags CSS mais avançadas, como o comando `flex` do CSS.

## Componentes Principais

- **build_html**: Método responsável por gerar um HTML simples.
- **on_sapevent**: Método que trata os eventos gerados a partir do HTML. No exemplo, estamos usando um evento de clique no link.

O evento **SAPEVENT:CLK_1** é capturado pelo método **on_sapevent** e pode ser usado para executar ações específicas, como exibir uma mensagem.

## Exemplo de Código

```abap
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
```

## Conclusão

Este exemplo mostra como é possível carregar e exibir HTML diretamente em programas ABAP. A classe **cl_gui_html_viewer** facilita essa integração, permitindo que você adicione conteúdo HTML simples sem precisar de telas adicionais.

Se você tiver dúvidas ou sugestões para melhorar o exemplo, sinta-se à vontade para abrir uma issue ou enviar um pull request!

