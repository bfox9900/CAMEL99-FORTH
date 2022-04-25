\ VALUEs for CAMEL99 DTC Forth
\ Usage:  0 VALUE W
\           99 TO W   1 +TO W
 .( .)
' CONSTANT ALIAS VALUE
: TO  ( n -- )
           '
           >BODY  \ compute PFA at compile time
           STATE @
           IF   POSTPONE LITERAL  POSTPONE ! EXIT
           THEN  ! ; IMMEDIATE
 .( .)
\ comment these if you don't need them
: +TO      ( n -- )
           '
           >BODY
           STATE @
           IF   POSTPONE LITERAL  POSTPONE +! EXIT
           THEN  +! ; IMMEDIATE
 .( .)
