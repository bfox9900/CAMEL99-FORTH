\ NOCASE.FTH  make Camel99 case insensitive   Jun 5 2022    Brian Fox

: LOWER?  ( char -- ?) [CHAR] a  [CHAR] z  1+ WITHIN ;
HEX
: UCASE   ( char -- char ) DUP LOWER? IF  05F AND  THEN ;

DECIMAL
: UCASE!  ( byte-addr -- ) DUP C@  UCASE  SWAP C! ;
: TOUPPER ( addr len -- ) BOUNDS ?DO  I UCASE!  LOOP ;

\ new interpreter loop process SOURCE string first
: <CASEINTERP> ( addr u -- )  2DUP TOUPPER  <INTERP> ;

\ replace interpreter vector with the new one
: NOCASE     ['] <CASEINTERP>  'IV ! ;
: CAPS       ['] <INTERP>      'IV ! ;
