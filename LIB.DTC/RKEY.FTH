\ Repeating key based on Nouspikel TI-99 tech pages, V1.7 BFox
\ ** WORKS WITH NEW KEY? THAT SAVES GPL R11 **
DECIMAL
 40 CONSTANT LD
  3 CONSTANT SD
VARIABLE OUTKEY     \ key buffer
VARIABLE OLDKEY     \ previous key buffer
VARIABLE DLY        \ delay counter

HEX
: (RKEY) ( -- char)
    DLY @ SD >          \ Are we repeating?
    IF                  \ NO
      LD DLY !          \ Initially, use long delay
    THEN
    BEGIN
      83C8 ON           \ Erase previous key's scan code
      KEY?              \ Call scanning routine
      DUP OUTKEY !
      OLDKEY @ OVER <>   \ Same as before?
      IF
           DUP OLDKEY !  \ memorize and return the key
           LD DLY !      \ reload waiting delay
           EXIT          \ jump out
      ELSE
          DROP
      THEN
      DLY DUP 1-! @
   WHILE REPEAT          \ while true, repeat
   SD DLY !              \ load repeat delay
   OUTKEY @              \ return key
;

: RKEY ( -- char)
    VPOS VC@             \ read char from screen
    BEGIN
      PAUSE
      TMR@ 1FFF >        \ read 9901 timer, compare to 50% expired
      IF   CURS @        \ true? fetch cursor char
      ELSE DUP           \ false? use screen char
      THEN VPUT
     (RKEY)
      ?DUP
    UNTIL
    SWAP VPUT ;       \ put the char back

: TEST BEGIN  RKEY DUP EMIT  83 = UNTIL ;
