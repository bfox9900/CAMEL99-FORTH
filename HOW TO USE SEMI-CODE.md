#  Using ;CODE in DTC Forth
 ( How get to the DATA field)

It is a bit different to get the data field address of a direct threaded
Forth word with ;CODE. In Indirect threaded Forth the W register (R8) holds the DATA field address. In CAMEL99 DTC Forth, the "W" register (R5) holds the CODE field address. 

The CFA of a DTC Forth word contains the address of a branch & link
instruction that branches to the "executor" for a high-level word.
(DOCOL DOCON DOVAR)

We COULD just increment the Forth IP register (R5) by 4 to get to the DATA field but since we use a BL instruction to enter a DTC colon definition  words we get the DATA field for free in the "link" register, R11. 
Neat trick.

So TMS9900 BL and R11 makes it just a easy as ITC to use ;CODE in DTC Forth.

### DEMONSTRATION
Load the DTC Assembler to give us ;CODE

```
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
```

VP is the Video RAM memory pointer analogous to DP in the CPU RAM. 
VP is initialized to HEX 1000 on boot-up.

     VP @  BYTE-ARRAY: ]VDP   \ create array at location of VP

These two lines will now give us the same address: HEX 1000
     VP @  .
     0 ]VDP .

Remember to access ]VDP with VC@  and VC!

     HEX AB 4 ]VDP VC!
