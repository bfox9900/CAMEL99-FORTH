CR .( Extensions for DTC Forth)

CR .( ANS/ISO Looping & Branching)
\ special compilers needed for hi-speed code in scratch-pad RAM
: ?BRANCH  _?HSBRANCH , ; IMMEDIATE
: BRANCH    _HSBRANCH , ; IMMEDIATE

: AHEAD    ( -- addr) HERE   0 , ;
: <BACK ( addr --) HERE -  , ;

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
: >L       ( x -- ) ( L: -- x )  2 LP +!  LP @ ! ;
: L>       ( -- x )  ( L: x -- ) LP @ @   -2 LP +! ;

\                      -compile this-  - run this now-
: DO      ( -- ) ?COMP POSTPONE <DO>     HERE 0 >L ;  IMMEDIATE
: ?DO     ( -- ) ?COMP POSTPONE <?DO>    HERE 0 >L ;  IMMEDIATE
: LEAVE   ( -- ) ( L: -- addr )
  POSTPONE UNLOOP   POSTPONE BRANCH AHEAD >L ; IMMEDIATE

: RAKE   ( -- ) ( L: 0 a1 a2 .. aN -- )
  BEGIN  L> ?DUP       \ read leave stack, dup if <>0
  WHILE  POSTPONE THEN \ resolve branch in LEAVE
  REPEAT
;

: LOOP    ( -- )  POSTPONE <LOOP>   <BACK RAKE ; IMMEDIATE
: +LOOP   ( -- )  POSTPONE <+LOOP>  <BACK RAKE ; IMMEDIATE

\ USE:  NEEDS HCHAR FROM DSK1.GRAFIX
CR .( NEEDS FROM INCLUDE )
: NEEDS  ( -- ?)  BL WORD FIND NIP  ;
.( .)
: FROM   ( ? -- )
         BL PARSE-WORD ROT ( addr len ? --)
         0= IF  INCLUDED
         ELSE   2DROP
         THEN ;
.( .)
\ INCLUDE  Forth 2012 word
: PARSE-NAME ( <text> -- adr len ) BL PARSE-WORD ; \ Forth 2012 word
: INCLUDE  ( <text> -- )  PARSE-NAME INCLUDED SPACE
            LINES @ DECIMAL . ." lines"
            HEX ;

\ CODE.FTH let's you make machine code words
\ for use with the assembler AND DTC Forth
HEX
: CODE      ( -- )  HEADER  !CSP ;
: NEXT,     ( -- )  045A ,       ;  \ B *R10
: ENDCODE   ( -- )  ?CSP         ;
.( .)

CR .( CELLS etc )
: ALIAS  ( XT -- ) >R : R> COMPILE, POSTPONE ; ;

' 2* ALIAS CELLS  ' 2+ ALIAS CELL+   ' 1+ ALIAS CHAR+
.( .)
: CHARS ;  \ noop in CAMEL99 Forth
\ for interpret mode
: CHAR    ( -- <c>) BL WORD CHAR+ C@ ;
\ for compiling a colon definition
: [CHAR]  ( -- <c>) ?COMP CHAR POSTPONE LITERAL ; IMMEDIATE

.( .)
: ;CODE
   POSTPONE (;CODE)
   ?CSP POSTPONE [
   REVEAL
; IMMEDIATE
.( .)
