\ Traditional Forth array words for CAMEL99 DTC Forth  26APR2022 Brian Fox 
\ These versions have replaced DOES> with ;CODE for more speed

\ CARRAY  creates a byte size array.
HEX
: CARRAY ( n -- addr)
         CREATE  2+ ALLOT
         ;CODE
          A10B ,  \ R11 TOS ADD,
          NEXT,
        ENDCODE

\ ARRAY  creates a cell size array.
: ARRAY ( n -- addr)
         CREATE  2+ CELLS ALLOT
         ;CODE
          0A14 , \ TOS 1 SLA,  ( 2* ie: CELLS )
          A10B , \ R11 TOS ADD,
          NEXT,
        ENDCODE

\ demo/test code
\  100 ARRAY ]Q
\ 100 CARRAY ]X

\ : FILLQ  100 0 DO I I ]Q !  LOOP ;
\ : SEEQ  100 0 DO I ]Q @ .   LOOP ;

\ : FILLX  100 0 DO I I ]X C!  LOOP ;
\ : SEEX   100 0 DO   I ]X C@ . LOOP ;
