\ How get to the DATA field in DTC Forth with ;CODE

\ It is a bit different to get the data field address of a Forth word with ;CODE.
\ In Indirect threaded Forth the W register holds the DATA field address.

\ In CAMEL99 DTC Forth the "W" register that holds the CFA of a word is R5.
\ The CFA of a DTC Forth word contains a branch & link instruction to an address.
\ We COULD increment R5 register by 4 to get to the DATA field but
\ since we use a BL instruction to enter Forth DTC words we get the
\ DATA field for free in R11. Neat trick.

\ So TMS9900 BL and R11 makes it just a easy as ITC to use ;CODE in DTC Forth
\ by getting the data field from R11.

\ DEMONSTRATION
\ load the DTC Assembler. This will also give us ;CODE
INCLUDE DSK1.ASM9900

HEX

\ access VDP memory as fast arrays
: BYTE-ARRAY: ( Vaddr -- )
     CREATE                 \ make a name in the dictionary
            ,               \ compile the array's base address

     ;CODE ( n -- Vaddr')   \ RUN time
       *R11 TOS ADD,  ( add base address to index in TOS)
       NEXT,
     ENDCODE

\ VP is the Video RAM memory pointer. Initialized to HEX 1000 on boot-up
VP @  BYTE-ARRAY: ]VDP   \ array will start at location of VP

\ These two lines will now give us the same address: HEX 1000
VP @  .
0 ]VDP .

\ Remember to access ]VDP with VC@  and VC!
\  99 4 ]VDP VC!
