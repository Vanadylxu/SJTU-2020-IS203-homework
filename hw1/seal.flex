 /*
  *  The scanner definition for seal.
  */

 /*
  *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
  *  output, so headers and global definitions are placed here to be visible
  * to the code in the file.  Don't remove anything that was here initially
  */
%{

#include <seal-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <vector> 
/* The compiler assumes these identifiers. */
#define yylval seal_yylval
#define yylex  seal_yylex

/* Max size of string constants */
#define MAX_STR_CONST 256
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the seal compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;
int num;
int numlen;
extern int curr_lineno;
extern int verbose_flag;
char numtext[101];
extern YYSTYPE seal_yylval;
static std::vector<char> stringArray;
int char_to_num(char ch){
if(ch>='0' && ch<='9')
  {return ch-'0';}
else{
  if (ch>='a'&&ch<='z')
  return ch-'a'+10; 
  else if (ch>='A'&&ch<='Z')
  return ch-'A'+10; 
} 
}
 /*
  *  Add Your own definitions here
  */
char* itoa(int num,char* str,int radix)
{
    char index[]="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    unsigned unum;
    int i=0,j,k;
    
    if(radix==10&&num<0)
    {
        unum=(unsigned)-num;
        str[i++]='-';
    }
    else unum=(unsigned)num;
    do
    {
        str[i++]=index[unum%(unsigned)radix];
        unum/=radix;
 
    }while(unum);
 
    str[i]='\0';
 
    //将顺序调整过来
    if(str[0]=='-') k=1;
    else k=0;
 
    char temp;
    for(j=k;j<=(i-1)/2;j++)
    {
        temp=str[j];
        str[j]=str[i-1+k-j];
        str[i-1+k-j]=temp;
    }
 
    return str;
 
}

%}
%option noyywrap
%x COMMENTS 
%x STRING1
%x STRING1_ESCAPE  
  /*remain for ESCAPE character"\",but abandoned */
%x STRING2

/* ----- Declarations end. */

 /*
  * Define names for regular expressions here.
  */


%%

 /*	
  *	Add Rules here. Error function has been given.
  */
var {
  return VAR;
}
struct {return STRUCT;}
if { return (IF); }

else {return ELSE;}

while {return WHILE;}
for {return FOR;}
break {return BREAK;}
continue {return CONTINUE;}

func {return FUNC;}
return {return RETURN;}



(true) {
  seal_yylval.boolean = 1;
  return(CONST_BOOL);
}
(false) {
  seal_yylval.boolean = 0;
  return(CONST_BOOL);
}
(Float|Bool|Int|String|Void)  {
  seal_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (TYPEID);
}
[a-z][A-Za-z0-9_]*  {
  seal_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (OBJECTID);
}

(0x|0X)[0-9a-fA-F][0-9a-fA-F]* {
  for(int i =2;i<yyleng;i++)
  {
    num*=16;
    num+=char_to_num(yytext[i]);
  }
  itoa(num,numtext,10);
  seal_yylval.symbol = inttable.add_string(numtext, strlen(numtext));
  num=0;
  return (CONST_INT);
}

[0-9][0-9]* {

  seal_yylval.symbol = inttable.add_string(yytext, yyleng);
  return (CONST_INT);
}
(`) {
  // stringArray.clear();
  BEGIN (STRING2);
  yymore();
  } 
<STRING2>[^\n`]* { yymore(); }
<STRING2>\n {
    curr_lineno++;
    yymore();
}
<STRING2>` {
    std::string input(yytext, yyleng);
    input = input.substr(1, input.length() - 2);

    std::string output = "";
    std::string::size_type pos;
    
    if (input.find_first_of('\0') != std::string::npos) {
        strcpy(seal_yylval.error_msg,"String contains null character");
        BEGIN 0;
        return ERROR;    
    }

    while ((pos = input.find_first_of("\\")) != std::string::npos) {
        output += input.substr(0, pos);

        switch (input[pos + 1]) {
        default:
            output += "\\";
            output += input[pos + 1];
            break;
        }

        input = input.substr(pos + 2, input.length() - 2);
    }

    output += input;

    if (output.length() > 256) {
      strcpy(seal_yylval.error_msg , "String constant too LONG");
        BEGIN 0;
        return (ERROR);    
    }

    seal_yylval.symbol = stringtable.add_string((char*)output.c_str());
    BEGIN 0;
    return (CONST_STRING);
}
<STRING2><<EOF>> {
    strcpy(seal_yylval.error_msg , "EOF in string` constant");
    BEGIN 0;
    yyrestart(yyin);
    return ERROR;
}

(\") {
  BEGIN (STRING1);
  yymore();
}
<STRING1>[^\\\"\n]* { yymore(); }
<STRING1>\\[^\n] { yymore(); }
<STRING1>\" {
    std::string input(yytext, yyleng);
    // remove the '\"'s on both sizes.
    input = input.substr(1, input.length() - 2);

    std::string output = "";
    std::string::size_type pos;
    
    if (input.find_first_of('\\0') != std::string::npos) {
        strcpy(seal_yylval.error_msg,"String contains null character \'\\0\'");
        BEGIN 0;
        return ERROR;    
    }

    while ((pos = input.find_first_of("\\")) != std::string::npos) {
        output += input.substr(0, pos);

        switch (input[pos + 1]) {
        case 'b':
            output += "\b";
            break;
        case 't':
            output += "\t";
            break;
        case 'n':
            output += "\n";
            break;
        case 'f':
            output += "\f";
            break;
        default:
            output += input[pos + 1];
            break;
        }

        input = input.substr(pos + 2, input.length() - 2);
    }

    output += input;

    if (output.length() > MAX_STR_CONST) {
      strcpy(seal_yylval.error_msg , "String constant too LONG");
        BEGIN 0;
        return (ERROR);    
    }

    seal_yylval.symbol = stringtable.add_string((char*)output.c_str());
    BEGIN 0;
    return (CONST_STRING);
}
<STRING1>\\\n {
    curr_lineno++;
    yymore();
}
<STRING1><<EOF>> {
    strcpy(seal_yylval.error_msg , "EOF in string\" constant");
    BEGIN 0;
    yyrestart(yyin);
    return ERROR;
}
<STRING1>\n {
    strcpy(seal_yylval.error_msg , "Unterminated string constant");
    BEGIN 0;
    curr_lineno++;
    return (ERROR);
}
<STRING1>\\0 {
    strcpy(seal_yylval.error_msg , "Unterminated string constant");
    BEGIN 0;
    return (ERROR);
}

  /*
   CONST_STRING = 269,
    */

\/\/.*$ {}

[0-9]+\.?[0-9]+ {
  seal_yylval.symbol = floattable.add_string(yytext, yyleng);
  return (CONST_FLOAT);
}

"/*" {
    BEGIN(COMMENTS);
}
"~" {
  return int('~');
}
"^" {
  return int('^');
}
[ \t\f\r\v]  {}
"|" {
  return int('|');
}
"!" {
  return int('!');
}
"||" {
  return OR;
}
"&&" {
  return AND;
}
"&" {
  return int('&');
}
"<" {
  return int('<');
}
">" {
  return int('>');
}
"!=" {
  return (NE);
}
">=" {
  return (GE);
}
"<=" {
  return (LE);
}
"=" {
 return int('=');
}
"==" {
 return (EQUAL);
}
"(" {
 return int('(');
}
")" {
 return int(')');
}
"+" {
 return int('+');
}
"*" {
  return int('*');
}
"-" {
  return int('-');
}
"\%" {
  return int('%');
}
"," { return int(','); }
";" { return int(';'); }

<COMMENTS>"*/" {
    BEGIN 0;
}

<COMMENTS>[^(\*\\)] {
    if (yytext[0] == '\n') {
        ++curr_lineno;
    }
}

<COMMENTS><<EOF>> {
    strcpy(seal_yylval.error_msg,"EOF in comment");
    return (ERROR);
}

"{" {
  return int('{');
}
"}" {
  return int('}');
}
\n { ++curr_lineno; }

\*\\ {
    strcpy(seal_yylval.error_msg,"Unmatched *\\");
    return (ERROR);
}

[\[\]\'>] {
    strcpy(seal_yylval.error_msg, yytext);
    return (ERROR);
}
.	{
	strcpy(seal_yylval.error_msg, yytext); 
	return (ERROR); 
}

%%

