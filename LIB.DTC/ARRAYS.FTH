\ Traditional Forth array words

\ These versions have replaced DOES> with ;CODE for more speed
INCLUDE DSK1.ASM99DTC
INCLUDE DSK1.TOOLS

\ CARRAY  creates a byte size array.
HEX
: CARRAY ( n -- addr)
         CREATE  ALLOT
         ;CODE
          R11 TOS ADD,
          NEXT,
        ENDCODE

\ ARRAY  creates a cell size array.
: ARRAY ( n -- addr)
         CREATE  CELLS ALLOT
         ;CODE
          TOS 1 SLA,  ( 2* ie: CELLS )
          R11 TOS ADD,
          NEXT,
        ENDCODE

 100 ARRAY ]Q
 100 CARRAY ]X

 : FILLQ  100 0 DO I I ]Q ! LOOP ;
 : FILLX  100 0 DO I I ]X C! LOOP ;

 : SEEQ   100 0 DO I ]Q @ . LOOP ;
 : SEEX   100 0 DO I ]X C@ . LOOP ;
