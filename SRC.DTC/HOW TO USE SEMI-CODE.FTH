\ HOW TO USE ;CODE in DTC Forth.

\ The example below shows that it takes a bit more trouble to get the
\ contents of the data field in DTC when using ;CODE.
\ The W register (R8) is pointing to the BL instruction so we must First
\ bump W by 4.  Then we can "fetch" the contents of W with indirect addressing.

INCLUDE DSK1.ASM9900

HEX
: ;CODE
   POSTPONE (;CODE)
   ?CSP POSTPONE [
   REVEAL
; IMMEDIATE

CREATE Q 100 ALLOT

\ access VDP memory as fast arrays
: TABLE: ( Vaddr -- )
     CREATE     ,               \ compile base address in VDP RAM
     ;CODE ( n -- Vaddr')       \ RUN time
         *W+ *W+ MOV,       \ INC W by 4
         *W TOS ADD,        \ W holds the PFA pointer of the word.
         NEXT,
ENDCODE

Q TABLE: ]Q

Q U.    \ these 2 expressions should produce the same address
0 ]Q U.
