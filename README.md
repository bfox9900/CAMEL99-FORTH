# CAMEL99-FORTH DTC
Apr 18, 2022

This is the Direct Threaded version of Camel99 Forth built on source code improvements that have been developed in the ITC version.
The DTC version is faster than ITC code by as much as 18% under some conditions.
It is not ideal however for large projects on the TI 99 as Forth definitions
consume an extra 4 bytes per word.

### Super Cart to the Rescue
The TI-99 Editor/Assembler cartridge is available with extra RAM on board.
(Super Cart is the default version on the Classic99 Emulator)
If you have a Super Cart then you can load DSK1.CAM99DSC which puts the Forth
Kernel in Super Cart RAM. This lets you use the 32K CPU RAM for your programs.

### *NOTICE*
As of May 10, 2022 the library files have not all been vetted and some will
crash. This is primarily due to optimization assumptions made for ITC code that
do not work with the DTC code.

MTASK99 gives this system multi-tasking and it works
INLINE  gives you some pretty good speed-ups on code fragments and it works. 

### Important differences

The CAMEL99 DTC Kernel is cross-compiled and so all looping and branching has
been made by the cross-compiler. There are NO compiler words in the kernel to
do IF/ELSE/THEN , BEGIN/UNTIL etc.  

The file DSK1.ISOLOOPS is pulled in by the DSK1.START file when the system
boots to add this functionality.

DSK1.START also pulls in DSK1.SYSTEMDTC to add the rest of the CORE words to the kernel.  The file name is changed from DSK1.SYSTEM to clarify that one file is
for the earlier ITC system and the SYSTEMDTC is for the DTC system.

### DSK1.START Contents
If you don't like the screen colors on startup, just change the E4 value below.
E is foreground (gray)
4 is background ( dark blue) 

```
\ V2.1 START file loads NEEDS/FROM and then loads ANS Forth extensions
 
S" DSK1.SYSTEMDTC" INCLUDED
S" DSK1.HSPRIMS" INCLUDED
 
HEX E4 7 VWTR
 
INCLUDE DSK1.LOADSAVE
S" DSK1.FONT0230" LOAD-FONT
 
HEX
CR RP0 86 + HERE - DECIMAL  . ." Hi RAM free"
HEX
CR 4000 H @ - DECIMAL SPACE . ." Low RAM free"
CR VDPTOP  VP @ - DECIMAL   . ." VDP RAM free"
CR CR .( Ready)
DECIMAL
 

``` 

### Explanatio for DSK1.HS-PRIMS ie: FAST-RAM Primitives
Some of the common primitives use by Forth are copied into the tiny 16-bit RAM in the TI-99 console.  
To give the compiler access to these primitives the START file include the file: DSK1.HSPRIMS
There is lower percentage of performance enhancement with this TI-99 trick than in ITC Forth because 
the underlying DTC architecture is faster.

HSPRIMS loads STATE smart compiling versions of the following words.
They and may act weird if used in "creative" ways. You are warned.

The words affected by HSPRIMS are:
- @
- !
- DUP
- DROP
- '+'

Using the 16 bit primitives can improve benchmarks that make heavy use of
these primitives. Normal speed increases are on the order of 1..2%.

## Implementation Details for Forth Nerds
In a DTC Forth each CODE word has only the dictionary header followed by the
machine code that it runs.  Each Forth word in a DTC implementation must have
an entry routine that consists of a branch to the "executor" code.

Executors are my name for the code that determines how the Forth word will be interpreted. In this system there are four "types" of Executors.
- DOCOL
- DOVAR
- DOCON
- DOUSER

There is a special case for the DOES> word called DODOES.

### Why we BL to the Executor
It is possible to make DTC Forth using a Branch to the EXECUTOR code.
(JMP in some instructions sets)
If you use a simple Branch your Executor code must move the Forth interpreter
pointer (IP) past the branch instruction and the address of the executor to get
to the list of code pointers in the word and make that address the interpreter
pointer. (IP)

A symbolic view of a DTC Forth word looks like this:

    <header> <B @DOCOL> <code-field><code-field> ...  <exit>

In the TMS9900 CPU the <B @DOCOL> uses four bytes.
The code for DOCOL in this case would be:

``` 
l: _docol   IP RPUSH,  \ push current IP onto R stack
            IP 4 AI,   \ advance IP past the branching code 
            NEXT,      \ run the NEXT Forth word
 ```            

In CAMEL99 DTC Forth we replace the Branch with Branch and LINK. (BL)

    <header> <BL @DOCOL> <code-field> <code-field> ...  <exit>

The BL instruction lets the CPU compute the new IP address for us and puts it in
R11. This speeds up the DOCOL executor by replacing the addition with a faster
and smaller, register to register MOV instruction.

```
l: _docol    IP RPUSH,
             R11 IP MOV,
             NEXT,
```

(  It might be possible to improve this further by making R11 the Forth IP.
  This would require extra overhead however to push/pop R11 for all native
  sub-routine calls)
