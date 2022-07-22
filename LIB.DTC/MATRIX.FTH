\ 2D matrix generator for cells or bytes    Jul 7 2022 Brian Fox
\ Usage:
\ 5 10 MATRIX: []DATA
\ 5 5 BYTE-MATRIX: []Q

INCLUDE DSK1.TOOLS

HEX
 CODE *+  ( addr ndx size -- addr')
      3936 ,  \ *SP+ TOS MPY,
      C136 ,  \ *SP+ TOS MOV,
      A105 ,  \  R5  TOS ADD,
      NEXT,
 ENDCODE

DECIMAL
: ERASE  ( addr len -- ) 0 FILL ;
: INITIALIZED ( u -- ) HERE OVER ERASE ALLOT ;

: MATRIX: ( rows cols -- )
          CREATE
              DUP , * CELLS INITIALIZED

          DOES> ( row col  -- addr)
                DUP>R @ ( row col addr #cols )
                *+ CELLS R> +  [ 2 CELLS ] LITERAL +
;

: BYTE-MATRIX: ( rows cols -- )
          CREATE
             DUP , * INITIALIZED
          DOES> ( row col  -- addr)
             DUP>R @ ( col row rows) * +  R> + CELL+
;
