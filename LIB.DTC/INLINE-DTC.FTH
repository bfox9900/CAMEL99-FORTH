\ INLINE-DTC.FTH                                      Dec 2, 2020 B Fox
\ A narrow focus, static JIT (just in time compiler)
\ *version 5* can optimize variables, constants and literal numbers*

\ APR 23 2022: Modified for DTC Forth

NEEDS .S   FROM DSK1.TOOLS
NEEDS CASE FROM DSK1.CASE

HERE
HEX
045A CONSTANT 'NEXT'  \ 9900 CODE for B *R10   Camel99 Forth's NEXT code

\ *** changed for kernel V2.69 ***
\ need copies of words that do not end in NEXT, in the Camel99 kernel
CODE DUP    0646 , C584 ,  NEXT, ENDCODE
CODE DROP   C136 ,         NEXT, ENDCODE
CODE !      C536 , C136 ,  NEXT, ENDCODE
CODE @      C114 ,         NEXT, ENDCODE
CODE +      A136 ,         NEXT, ENDCODE
CODE C@     D114 , 0984 ,  NEXT, ENDCODE

\ CFA of a Forth word contains the BL@xxxx instruction
: FORTH? ( -- ?)  @ 06A0 = ;

\ Heap management words
: JIT-RESET   2000 H !  H @ 1000 0 FILL ;
: HEAP    ( -- addr) H @ ;
: HALLOT  ( n -- )   H +! ;
: H,   ( n -- )    HEAP ! 2 HALLOT ;

: CODE,  ( CODExt --)  \ Read code word from kernel, compile to HEAP
           80 CELLS  ( -- addr len)
           BOUNDS ( -- IPend IPstart)
           BEGIN
              DUP @ 'NEXT' <>  \ the instruction is not 'NEXT'
           WHILE
             DUP @  ( -- IP instruction)
             H,     \ compile instruction
             CELL+  \ advance to next instruction
             2DUP < ABORT" End of code not found"
           REPEAT
           2DROP
;

HEX
\ POP/PUSH Optimizer removes code when DROP is followed by DUP
\ The speeds up CONSTANTS, Variables and USER Variables

HEX
C136 CONSTANT 'DROP'   \ 9900 machine code for DROP (*SP+ R4 MOV,)
VARIABLE #OPTS         \ # of optimizations made
VARIABLE OPTIMIZER

: LOOKBACK ( -- u) HEAP 2- @ ; \ fetch previous instruction code

: DUP,     0646 H, C584 H, ;

: OPT-DUP, ( n -- n ?n)
   OPTIMIZER @
   IF
      LOOKBACK 'DROP' =     \ look back for DROP
      IF   -2 HALLOT   #OPTS 1+!   \ erase DROP
      ELSE  DUP,             \ DROP not found, we must DUP TOS
      THEN
   ELSE
      DUP,                   \ compile normal DUP,
   THEN
;

: CALLNEXT,      045A H,  ;        \ compile called NEXT at end of HEAP code
: ILNEXT, ( -- ) C179 H, 0455 H, ; \ inline NEXT for optimized code segments

: OPTNEXT,
    OPTIMIZER @
    IF   ILNEXT,    \ faster
    ELSE CALLNEXT,  \ smaller
    THEN ;

: TOS!,   ( n --)  0204 H,  ( n) H, ;  \ LI R4,nnnn
: LIT,    ( n --)  OPT-DUP,  TOS!,     ;

\ new interpreter loop for inlining *future* make this the Forth compiler
: INLINE[ ( -- addr)  \ Returns address where code has been copied
           HEAP ( -- XT)  \ HEAP will be our new execution token (XT)
           BEGIN   BL WORD CHAR+ C@  [CHAR] ] <>
           WHILE
              HERE FIND
              IF ( *it's a Forth word* )
                 DUP FORTH?
                 IF DUP
                    CELL+ @  \ get the "executor" code address
                    CASE
                      _DOVAR  OF  >BODY   LIT, ENDOF
                      _DOCON  OF  EXECUTE LIT, ENDOF
                      _DOUSER OF  EXECUTE LIT, ENDOF
                      CR TRUE S" Can't optimize that Forth word" ?ABORT
                    ENDCASE

                 ELSE  \ it's a CODE primitive
                       CODE,  \ compile kernel code
                 THEN

             ELSE ( maybe its a number)
                 COUNT NUMBER? ?ERR
                 ( n ) LIT, \ compile n as a literal
             THEN
           REPEAT
           OPTNEXT,      \ compile inline next after instructions
           COMPILE,     \ compile HEAP XT into current colon definition
;  IMMEDIATE

HERE SWAP - SPACE DECIMAL . .( bytes) HEX CR

JIT-RESET
OPTIMIZER ON
CR .( Optimizer status=) OPTIMIZER @ .
