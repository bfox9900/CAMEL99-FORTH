\ search dictionary in Forth

\ NEEDS .S     FROM DSK1.TOOLS
\ NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS COMPARE FROM DSK1.COMPARE
NEEDS MALLOC  FROM DSK1.MALLOC

30 MALLOC CONSTANT TEMP$

: FIND-NAME  ( addr len -- nfa )  \ 4.4x SLOWER than ASM (FIND)
             TEMP$ PLACE
             LATEST @
             BEGIN
                DUP 1+  TEMP$ COUNT S=
                0= IF  EXIT  THEN
                NFA>LFA @ DUP
             WHILE REPEAT ;
