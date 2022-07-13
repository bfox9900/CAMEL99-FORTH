CR .( Extensions for DTC Forth)
WARNINGS OFF
.( .)
\ special compilers needed for hi-speed code in scratch-pad RAM
: ?BRANCH  _?HSBRANCH , ; IMMEDIATE
: BRANCH    _HSBRANCH , ; IMMEDIATE

: AHEAD  ( -- addr) HERE   0 , ;
: <BACK  ( addr --) HERE -  , ;

: THEN   ( addr -- ) HERE OVER - SWAP ! ;     IMMEDIATE
: BEGIN   HERE ;                              IMMEDIATE
: IF      POSTPONE ?BRANCH AHEAD ;            IMMEDIATE
: ELSE    POSTPONE BRANCH  AHEAD SWAP POSTPONE THEN ; IMMEDIATE
: UNTIL   POSTPONE ?BRANCH <BACK ;  IMMEDIATE
: AGAIN   POSTPONE BRANCH  <BACK ;  IMMEDIATE
: WHILE   POSTPONE IF SWAP ;        IMMEDIATE
: REPEAT  POSTPONE AGAIN POSTPONE THEN ; IMMEDIATE
.( .)
\ CAMEL Forth LEAVE stack pointer is initialized by QUIT
: >L       ( x -- ) ( L: -- x ) 2 LP +!  LP @ ! ;
: L>       ( -- x ) ( L: x -- ) LP @ @   -2 LP +! ;

\                   -compile this-  - run this now-
: DO      ( -- ) ?COMP POSTPONE <DO>  HERE  0 >L ;  IMMEDIATE
: ?DO     ( -- ) ?COMP POSTPONE <?DO> HERE  0 >L ;  IMMEDIATE
: LEAVE   ( -- ) ( L: -- addr )
  POSTPONE UNLOOP   POSTPONE BRANCH AHEAD  >L ; IMMEDIATE
.( .)
: RAKE   ( -- ) ( L: 0 a1 a2 .. aN -- )
  BEGIN  L> ?DUP       \ read leave stack, dup if <>0
  WHILE  POSTPONE THEN \ resolve branch in LEAVE
  REPEAT ;

: LOOP    ( -- )  POSTPONE <LOOP>   <BACK RAKE ; IMMEDIATE
: +LOOP   ( -- )  POSTPONE <+LOOP>  <BACK RAKE ; IMMEDIATE

\ Usage:  NEEDS HCHAR FROM DSK1.GRAFIX
: NEEDS  ( -- ?)  BL WORD FIND NIP ;
: FROM   ( ? -- ) PARSE-NAME ROT IF 2DROP EXIT THEN  INCLUDED ;

: PARSE-NAME ( <text> -- adr len ) BL PARSE-WORD ; \ Forth 2012 word
: INCLUDE ( <text>) PARSE-NAME INCLUDED SPACE LINES @ DECIMAL . ." lines" ;
.( .)

\ CODE let's you make machine code words or use with ASM9900
: CODE      ( -- )  HEADER  !CSP ;
: NEXT,     ( -- )  045A ,       ;  \ B *R10
: ENDCODE   ( -- )  ?CSP         ;
.( .)
\ 1 instruction aliases for ANS compliance
CODE CELLS   A104 , NEXT, ENDCODE  \ 2*
CODE CHAR+   0584 , NEXT, ENDCODE  \ 1+
CODE >BODY   05C4 , NEXT, ENDCODE  \ 2+
CODE CELL+   05C4 , NEXT, ENDCODE  \ 2+
CODE CHARS   NEXT, ENDCODE

.( .)
WARNINGS ON
