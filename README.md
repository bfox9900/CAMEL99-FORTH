# CAMEL99-FORTH
Apr 18, 2022

This is the Direct Threaded version of Camel99 Forth built on source code improvements that have been developed in the ITC version.
The DTC version is faster than ITC code by as much as 18% under some conditions.
It is not ideal however for large projects on the TI 99 as Forth definitions consume an extra 4 bytes per word. The TI-99 is a little memory constrained.

However as a platform for linking together CODE words it might be useful since
CODE words take 2 bytes less than the ITC version. And of course if your
project can fit it's a faster system.

### *NOTICE*
As of April 2022 the library files have not all been vetted and many will
crash. This is primarily due to optimization assumptions made for ITC code that
do not work with the DTC code.

Needless to say the ITC version of INLINE does not work at this time.

### Important differences

The CAMEL99 DTC Kernel is cross-compiled and so all looping and branching has
been made by the cross-compiler. There are NO compiler words in the kernel to
do IF/ELSE/THEN , BEGIN/UNTIL etc.  

The file DSK1.ISOLOOPS is pulled in by the DSK1.START file when the system
boots to add this functionality.

DSK1.START also pulls in DSK1.SYSTEMDTC to add the rest of the CORE words to the kernel.  The file name is changed from DSK1.SYSTEM to clarify that one is FORTH
the earlier ITC system and the other for the DTC system.

### DSK1.START Contents

`\ V1.0 START file loads ANS Forth extensions`
` S" DSK1.ISOLOOPS" INCLUDED`
` S" DSK1.SYSTEMDTC" INCLUDED`
` DECIMAL`

### Using FAST-RAM Primitives
Some of the common primitives use by Forth are copied into the tiny 16-bit RAM in the TI-99 console.  To give the compiler access to these primitives use:

`INCLUDE DSK1.HSPRIMS`

In your code or add that line to the START file if you always want them used.
These are STATE smart compiling words and may act weird if used in "creative"
ways.
The words affected are:
- @
- !
- DUP
- DROP
- '+'
