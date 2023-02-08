#  Using ;CODE in DTC Forth
 ( How get to the DATA field)
 
The Forth word ;CODE is loaded in Camel99 DTC with SYSTEMDTC file when the system boots. This word allows you to make compiling words like CREATE DOES>
but the execution happens at machine speeds because Assembly language is used rather than high-level Forth. 

It is a bit different to get the data field address of a direct threaded
Forth word with ;CODE. In Indirect threaded Forth the W register (R8) holds the DATA field address. In CAMEL99 DTC Forth, the "IP" register (R5) holds the CODE field address (CFA) and there is no 'W' register per se. 

The CFA of a DTC Forth word contains the address of a branch & link
instruction that branches to the "executor" for a high-level word.

(See: <colon:> in file DTCTYPES.HSF)

We COULD just increment the Forth IP register (R5) by 4 to get to the DATA field but since we use a BL instruction to enter a DTC colon definition, we get the DATA field for free in the "link" register, R11. 
Neat trick.

So TMS9900 BL and R11 makes it just a easy as ITC to use ;CODE in DTC Forth.

### DEMONSTRATION
Load the DTC Assembler.

```
INCLUDE DSK1.ASM9900

HEX

\ access VDP memory as fast arrays
: VDP-CARRAY: ( Vaddr -- )
     CREATE                 \ make a name in the dictionary
        DUP  ,              \ compile the array's base address
        VP +!               \ also move the VDP memory pointer forward

     ;CODE ( n -- Vaddr')   \ RUN time
       *R11 TOS ADD,        \ indirect R11 gives us the base address 
                            \ which we add to n, returning the array 
                            \ location
       NEXT,
     ENDCODE
```
#### Note:
VP is the Video RAM memory pointer analogous to DP in the CPU RAM. 
VP is initialized to HEX 1000 on system boot.

     VP @  BYTE-ARRAY: ]VDP   \ create array at location of VP

These two lines will now give us the same address: (HEX 1000 in VDP RAM) 
     VP @  .
     0 ]VDP .

Remember to read and write ]VDP with VC@  and VC!

     HEX 
     AB 4 ]VDP VC! \ put byte AB in location 4
