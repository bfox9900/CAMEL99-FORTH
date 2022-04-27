\ How get to the DATA field in DTC Forth with ;CODE

\ It is a bit harder to get the data field address of a word use ;CODE.
\ In Indirect threaded Forth the W register holds the DATA field address
\ after NEXT runs.
\ In CAMEL99 DTC Forth the "W" register that hold the CFA of a word is R5.
\ The CFA of a Forth word contain a branch & link instruction and an address.
\ We COULD increment the W register by 4 to get to the DATA field but
\ because we use a BL instruction to enter Forth hi-level words we get the
\ DATA field for free in R11. :)
\ So TMS9900 BL and R11 makes it just a easy as ITC to use ;CODE in DTC Forth.


\ first load the DTC Assembler. This will also give us ;CODE
INCLUDE DSK1.ASM99DTC

HEX
CREATE Q 100 ALLOT

\ access VDP memory as fast arrays
: VDP-BYTE-ARRAY: ( Vaddr -- )
     CREATE     ,               \ compile base address in VDP RAM
     ;CODE ( n -- Vaddr')       \ RUN time
       A11B ,    \ *R11 TOS ADD,  ( add base address to index in TOS)
       NEXT,
     ENDCODE

Q  VDP-BYTE-ARRAY: ]Q

\ These two lines will give us the same address
Q U.
0 ]Q U.
