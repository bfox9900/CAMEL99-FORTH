CR .( SAVESYS.FTH for DTC Forth B Fox Apr 2022)
\ creates a binary program E/A 5 format.
\ Makes as many files as needed to save the system
\ APR 2021 - Removed using PAD for file name store. Uses stack string.
CR .( Nov 2021 Update)
\   - Changed SYS-SIZE to use ORGDP value instead of HERE)
\     This means saved binary does not include SAVESYS.FTH code.

\ Usage:
\ Load your library code and your program.
\ INCLUDE DSK1.myprogram
\ YOUR PROGRAM> must have BOOT routine that begins with WARM
\ INCLUDE DSK1.MARKER    ( you must include MARKER to get the LOCK word )
\ use LOCK directive at the end of your program.
\ After LOCK:
\ Add this to your progam or type:
\  INCLUDE DSK1.SAVESYS
\ ' MYBOOTWORD SAVESYS DSK?.MYFILENAME
\ Where MYBOOTWORD begins with WARM and then runs your code.


HERE
NEEDS LOCK      FROM DSK1.MARKER 
NEEDS LOAD-FILE FROM DSK1.LOADSAVE  \ we use SAVE-FILE from this library

HEX
A000 CONSTANT 'ORG     \ start of Camel99 Forth program in CPU RAM
1000 CONSTANT VDPBUFF  \ Programs write to file from VDP Ram
2000 CONSTANT 8K
  13 CONSTANT PROG     \ file mode for Program files

\ define the file header fields. *THESE ARE VDP ADDRESSES*
VDPBUFF            CONSTANT MULTIFLAG
VDPBUFF  1 CELLS + CONSTANT PROGSIZE
VDPBUFF  2 CELLS + CONSTANT LOADADDR
VDPBUFF  3 CELLS + CONSTANT CODEORG     \ COPY 8K program chunks to here

: END  ( -- addr )
  ORGDP @ C000 < IF HONK CR ." WARNING: missing LOCK directive" THEN
  ORGDP @  ;

\ words to compute Forth system properties
: SYS-SIZE    ( -- n)  'ORG  END  SWAP - ;

: #FILES      ( -- n)  SYS-SIZE 8K /MOD SWAP IF 1+ THEN ;
: CODECHUNK   ( n -- addr)
        DUP 8K * ( -- n addr)
        SWAP IF            \ if n <> 0 ie: 2nd, 3rd, chunks
               3 CELLS  -  \ subtract header space
        THEN 'ORG + ;

: CHUNKSIZE   ( n -- n )
        END SWAP CODECHUNK -     \ compute size
        3 CELLS +                \ add 6 bytes for header
        8K MIN  ;                \ take lesser of size or 8K

: LASTCHAR++  ( Caddr len --)  1- +  1 SWAP C+! ;

: ?PATH    ( addr len -- addr len )
        2DUP  [CHAR] . SCAN NIP 0= ABORT" Path expected" ;

HEX
: SAVESYS ( XT -- <textpath> )
        BOOT !
        BL PARSE-WORD ?PATH  ( caddr len ) PAD PLACE
        #FILES 0
        ?DO
          \ Init file header in VDP RAM
           I 1+ #FILES <>  MULTIFLAG V!
           I CHUNKSIZE     PROGSIZE V!
           I CODECHUNK     LOADADDR V!
          \ Copy to VDP & write to disk"
           CR ." Writing file "  PAD COUNT TYPE
           LOADADDR V@  CODEORG  PROGSIZE V@  VWRITE
           PAD COUNT  VDPBUFF PROGSIZE V@  PROG SAVE-FILE
           PAD COUNT  LASTCHAR++   \ Update file name
        LOOP
        CR ." System size=" DECIMAL SYS-SIZE U. ." bytes"
        CR ." Saved in " #FILES .  ." EA5 files"
        CR
;
HERE SWAP - CR DECIMAL . .( bytes)
