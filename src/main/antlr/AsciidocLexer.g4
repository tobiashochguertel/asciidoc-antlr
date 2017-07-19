lexer grammar AsciidocLexer;

@lexer::members {

  public boolean isBOL() { return _input.LA(-1) == '\n'; }

}

///////////////////
// default mode 

H0  
  : {isBOL()}?  
      EQUAL WS                    -> pushMode(DOCTITLE)
  ;

ATTR_BEGIN
  : { isBOL() }?  
      COLON                       -> pushMode(ATTR)
  ;

PPD_START
  : { isBOL() }? 
      ( 'ifdef' 
      | 'ifndef' 
      | 'ifeval' ) '::' WS_CHAR*  -> pushMode(PPMODE)
  ;

COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

END_OF_HEADER
  : { isBOL() }? 
      EOLF+                       -> pushMode(CONTENT)
  ;

EOL
  : EOLF                          -> channel(HIDDEN)
  ;

WS 
  : WS_CHAR+                      -> channel(HIDDEN) 
  ;

fragment
COMMENT_F
  : '//' ~[\r\n]*                 
  ;

fragment
SEC_TITLE_START_F
  : { isBOL() }? 
      ( '==' | '######' 
      | '===' | '#####'
      | '====' | '####'
      | '=====' | '###'
      | '======' | '##' ) WS_CHAR+
    ;

fragment
EOLF
  : '\r'? '\n'
  ;

fragment
GT
  : '>'               
  ;

fragment
LT
  : '<'                
  ;

fragment
SEMI
  : ';'               
  ;

fragment
ESC
  : '\\'               
  ;

fragment
SINGLE_QUOTE
  : '\''               
  ;

fragment
DOUBLE_QUOTE
  : '"'               
  ;

fragment
COMMA
  : ','               
  ;

fragment
EQUAL
  : '='               
  ;

fragment
HASH
  : '#'               
  ;

fragment
PERCENT
  : '%'               
  ;

fragment
PERIOD
  : '.'               
  ;

fragment
COLON
  : ':'               
  ;

fragment
BANG
  : '!'               
  ;

fragment
WS_CHAR
  : [ \t]
  ;

fragment
SPACE
  : ' '
  ;

fragment 
DIGIT 
  : [0-9] 
  ; 

fragment
ATTR_ID_F
  : [_a-zA-Z0-9] [-_a-zA-Z0-9]*
  ;

///////////////////
mode DOCTITLE;

DOCTITLE_CSP
  : COLON SPACE 
  ;

DOCTITLE_PART
  : ((':' + ~' ') | ~[:\r\n])+
  ;

DOCTITLE_EOL
  : EOLF                            -> mode(DOCAUTHOR)
  ;

///////////////////
mode DOCAUTHOR;

// any non-whitespace char 
DOCAUTHOR_NAME
  : ~[ <>;\r\n]+
  ;

DOCAUTHOR_CONTACT
  : LT .*? GT 
  ;

DOCAUTHOR_SEP
  : SEMI               
  ;

DOCAUTHOR_EOL
  : EOLF                          -> mode(DOCREV)
  ;

DOCAUTHOR_WS 
  : WS                            -> channel(HIDDEN) 
  ;


///////////////////
mode DOCREV;


DOCREV_NUMPREFIX
  : [vV] 
  ;

DOCREV_NUMBER
  : DIGIT+ (PERIOD DIGIT+)*
  ;

DOCREV_COMMA
  : COMMA WS_CHAR*                -> mode(DOCREV_DATE_MODE)
  ;

DOCREV_COLON
  : COLON WS_CHAR*                -> mode(DOCREV_REM)
  ;

DOCREV_EOL
  : EOLF                          -> popMode
  ;

///////////////////
mode DOCREV_DATE_MODE;

DOCREV_DATE
  : ~[:\r\n]+
  ;

DOCREV_DATE_COLON
  : COLON WS_CHAR*               -> type(DOCREV_COLON), mode(DOCREV_REM)
  ;

DOCREV_DATE_EOL
  : EOLF                         -> type(DOCREV_EOL), popMode
  ;

///////////////////
mode DOCREV_REM;

DOCREV_REMARK
  : ~[\r\n]+  
  ;

DOCREV_REMARK_EOL
  : EOLF                          -> type(DOCREV_EOL), popMode
  ;

///////////////////
mode ATTR;

ATTR_ID
  : ATTR_ID_F                       
  ;

ATTR_UNSET
  : BANG 
  ;

ATTR_SEP
  : COLON WS_CHAR*                  -> mode(ATTR_VALUE_MODE)
  ;


///////////////////
mode ATTR_VALUE_MODE;

ATTR_VALUE
  : (~[\\\r\n] | (ESC EOLF) )+      
  ;

ATTR_EOL
  : WS_CHAR* EOLF                            -> popMode
  ;

///////////////////
mode SECTION_TITLE;

SECTITLE_TEXT
  : ~[\r\n]+
  ;

SECTITLE_EOL
  : EOLF+                           -> mode(CONTENT)
  ;


///////////////////
mode CONTENT;


CONTENT_SEC_TITLE_START  
  : SEC_TITLE_START_F               -> mode(SECTION_TITLE)
  ;

CONTENT_ATTR_START
  : {isBOL()}? 
     '[' WS_CHAR*                   -> pushMode(ELEMENT_ATTR)
  ;

//CONTENT_TITLE_START
  //: {isBOL()}? 
     //'.'                            -> pushMode(CONTENT_TITLE_MODE)
  //;

CONTENT_PARA                     
  : {isBOL()}? 
      ~[=[] .*? CONTENT_EOP 
  ;

CONTENT_COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

CONTENT_EOP
  : EOLF EOLF+                    
  ;


///////////////////
mode ELEMENT_ATTR;

ELEMENT_ATTR_ID
  : ATTR_ID_F
  ;

ELEMENT_ATTR_COMMA
  :  WS_CHAR* COMMA WS_CHAR*
  ;

ELEMENT_ATTR_ASSIGN
  :  WS_CHAR* EQUAL                        -> pushMode(ELEMENT_ATTR_VAL)
  ;

ELEMENT_ATTR_TYPE_ROLE
  :  WS_CHAR* PERIOD                        
  ;

ELEMENT_ATTR_TYPE_OPTION
  :  WS_CHAR* PERCENT                        
  ;

ELEMENT_ATTR_TYPE_ID
  :  WS_CHAR* HASH                       
  ;

ELEMENT_ATTR_UNSET
  : WS_CHAR* BANG  
  ;

ELEMENT_ATTR_END
  :  WS_CHAR* ']'                        
  ;

ELEMENT_ATTR_EOL
  :  WS_CHAR* EOLF                        -> popMode
  ;

///////////////////
mode ELEMENT_ATTR_VAL;

fragment 
ELEMENT_ATTR_VALUE_QUOTED_SINGLE
  : SINGLE_QUOTE (~['\r\n] | (ESC SINGLE_QUOTE))*? SINGLE_QUOTE
  ;

fragment 
ELEMENT_ATTR_VALUE_QUOTED_DOUBLE
  : DOUBLE_QUOTE (~["\r\n] | (ESC DOUBLE_QUOTE))*? DOUBLE_QUOTE
  ;

fragment 
ELEMENT_ATTR_VALUE_UNQUOTED
  : ~['"\],\r\n ]*?
  ;

ELEMENT_ATTR_VALUE
  : ( ELEMENT_ATTR_VALUE_QUOTED_SINGLE                               
    | ELEMENT_ATTR_VALUE_QUOTED_DOUBLE
    | ELEMENT_ATTR_VALUE_UNQUOTED )           -> popMode
  ;

///////////////////
mode CONTENT_TITLE_MODE;

CONTENT_TITLE_TEXT
  : ~[\r\n]+                               
  ;

CONTENT_TITLE_EOL
  : EOLF                                  -> popMode
  ;


///////////////////
mode PPMODE;

PPD_ATTR_ID
  : ATTR_ID_F
  ;

PPD_ATTR_SEP
  : WS_CHAR* [+,] WS_CHAR*
  ;

PPD_CONTENT_SINGLELINE
  :  '[' ~[\]\r\n]+ ']' EOLF                     -> popMode
  ;

PPD_CONTENT_START
  :  '[]' EOLF                                   -> mode(PPCONTENT)
  ;

///////////////////
mode PPCONTENT;

PPD_CONTENT
  : .*? EOLF 'endif::[]' EOLF                    -> popMode
  ;


