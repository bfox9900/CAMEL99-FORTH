\ LOWTOOLS  puts ASSEMBLER and tools into LOW RAM  Feb 27 2020  BFox
NEEDS MALLOC FROM DSK1.MALLOC
HEX
VARIABLE SAVEDP
: COMPILE-LOW ( -- )
    HERE  SAVEDP !    \ save the dictionary pointer
    1E00 MALLOC DP !  \ get a big buffer, DP(dictionary) points to the buffer
;

: COMPILE-HI  ( -- )
    HERE H !          \ give back what we didn't use to the HEAP
    SAVEDP @ DP !     \ restore DP back to original address
;
COMPILE-LOW
  INCLUDE DSK1.ASM9900
  INCLUDE DSK1.TOOLS
COMPILE-HI
.FREE
HEX
