\ shift right circular.  9900 native instruction

\ NEEDS MOV, FROM DSK1.ASM9900

HEX
CODE SRC ( n bits -- n')     \ non ANS Forth. Circular shift. Nice!
           C004 ,  \  TOS R0  MOV,
           C136 ,  \ *SP+ TOS MOV,
           0B04 ,  \  TOS R0  SRC,
           NEXT,
           ENDCODE

\ fast 1 instruction, 1 bit shifters
CODE 1SLA  ( u -- u') \ shift left 1 bit
          0914 ,  \ TOS 1 SLA,
          NEXT,
          ENDCODE

CODE 1SRL ( u -- u') \ shift right 1 bit
          0914 ,   \  TOS 1 SRL,
          NEXT,
          ENDCODE

