#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "semant.h"
#include "utilities.h"

extern int semant_debug;
extern char *curr_filename;

static ostream& error_stream = cerr;
static int semant_errors = 0;
static Decl curr_decl = 0;
static bool is_in_loop = 0; 
static bool is_returned = 0;
typedef SymbolTable<Symbol, Symbol> ObjectEnvironment; // name, type
ObjectEnvironment objectEnv;
typedef SymbolTable<Symbol, Decl> funcitonTable; //函数表，由于不会在函数里声明函数，只用enter一次
funcitonTable functbl;
//3个新变量

///////////////////////////////////////////////
// helper func
///////////////////////////////////////////////


static ostream& semant_error() {
    semant_errors++;
    return error_stream;
}

static ostream& semant_error(tree_node *t) {
    error_stream << t->get_line_number() << ": ";
    return semant_error();
}

static ostream& internal_error(int lineno) {
    error_stream << "FATAL:" << lineno << ": ";
    return error_stream;
}

//////////////////////////////////////////////////////////////////////
//
// Symbols
//
// For convenience, a large number of symbols are predefined here.
// These symbols include the primitive type and method names, as well
// as fixed names used by the runtime system.
//
//////////////////////////////////////////////////////////////////////

static Symbol 
    Int,
    Float,
    String,
    Bool,
    Void,
    Main,
    print
    ;

bool isValidCallName(Symbol type) {
    return type != (Symbol)print;
}

bool isValidTypeName(Symbol type) {
    return type != Void;
}

//
// Initializing the predefined symbols.
//

static void initialize_constants(void) {
    // 4 basic types and Void type
    Bool        = idtable.add_string("Bool");
    Int         = idtable.add_string("Int");
    String      = idtable.add_string("String");
    Float       = idtable.add_string("Float");
    Void        = idtable.add_string("Void");  
    // Main function
    Main        = idtable.add_string("main");
    // classical function to print things, so defined here for call.
    print        = idtable.add_string("printf");
}

/*
    TODO :
    you should fill the following function defines, so that semant() can realize a semantic 
    analysis in a recursive way. 
    Of course, you can add any other functions to help.
*/

static bool sameType(Symbol name1, Symbol name2) {
    return strcmp(name1->get_string(), name2->get_string()) == 0;
}

static void install_calls(Decls decls) {
    objectEnv.enterscope();
    functbl.enterscope();
    functbl.addid(print,new Decl());
    for (int i = 0; decls->more(i); i++){//这样也可以 但是封装性不好
        curr_decl = decls->nth(i);
        if (curr_decl->isCallDecl()){
            if (functbl.probe(curr_decl->getName()) != NULL) semant_error(curr_decl)<<"function "<<curr_decl->getName()<<" has been defined."<< endl;
            else functbl.addid(curr_decl->getName(), new Decl(curr_decl));
        }
    }
}

static void install_globalVars(Decls decls) {
    for (int i = decls->first(); decls->more(i); i = decls->next(i)){
        curr_decl = decls->nth(i);
        if (!curr_decl->isCallDecl()){//检查变量声明
            if (objectEnv.probe(curr_decl->getName()) != NULL) semant_error(curr_decl)<<"var "<<curr_decl->getName()<<" has been defined."<< endl;
            else if (!isValidTypeName(curr_decl->getType()))semant_error(curr_decl)<<"var "<<curr_decl->getName()<<" cannot be of type Void. Void can just be used as return type."<< endl;
            else objectEnv.addid(curr_decl->getName(), new Symbol(curr_decl->getType()));
        }
    }
}

static void check_calls(Decls decls) {
    for (int i = decls->first(); decls->more(i); i = decls->next(i)){
        curr_decl = decls->nth(i);
        if (curr_decl->isCallDecl())curr_decl->check();//检查函数声明
    }
}

static void check_main() {
    if (functbl.lookup(Main) == NULL){
        semant_error()<<"main function is not defined."<< endl;
        return;
    }
    if (((*functbl.lookup(Main))->getVariables())->more(0)) semant_error(*(functbl.lookup(Main)))<<"main function should not have any parameters."<< endl;
    if (isValidTypeName((*functbl.lookup(Main))->getType())) semant_error(*(functbl.lookup(Main)))<<"main function should have return type Void."<< endl;
}

void VariableDecl_class::check() {
    if (objectEnv.probe(variable->getName()) != NULL) semant_error(variable)<<"var "<<variable->getName()<<" has been defined."<< endl;
    else if (!isValidTypeName(variable->getType())) semant_error(variable)<<"invalid type void."<< endl;
    else objectEnv.addid(variable->getName(), new Symbol(variable->getType()));
}

void CallDecl_class::check() {
    objectEnv.enterscope();
    is_returned = false;
    for (int i = paras->first(); paras->more(i); i = paras->next(i)){
        Variable curr_var = paras->nth(i);
        if (!isValidTypeName(curr_var->getType()))semant_error(curr_var)<<"function "<<this->getName()<<"'s parameter type is invalid."<< endl;
        if (objectEnv.probe(curr_var->getName()) != NULL)semant_error(curr_var)<<"parameter name confilct."<< endl;
        else objectEnv.addid(curr_var->getName(), new Symbol(curr_var->getType()));//好像只能这么传，c++基础太差……好不容易把sementflaut解决了
        if (i >= 6)semant_error(this)<<"function "<<this->getName()<<" has too many parameters."<< endl;
    }
    (this->getBody())->check(this->getType());
    if (!is_returned) semant_error(this)<<"Function "<<this->getName()<<" must have an overall return statement."<< endl;
    objectEnv.exitscope();
}

void StmtBlock_class::check(Symbol type) {
    objectEnv.enterscope();//这里可能要修改
    for (int i = vars->first(); vars->more(i); i = vars->next(i)) vars->nth(i)->check();
    for (int i = stmts->first(); stmts->more(i); i = stmts->next(i)){       
        stmts->nth(i)->check(type);        
    }
    objectEnv.exitscope();
}

void IfStmt_class::check(Symbol type) {//last time here
    if (!sameType(condition->checkType(), Bool))semant_error(this)<<"condition must be Bool"<< endl;
    objectEnv.enterscope();
    thenexpr->check(type);
    objectEnv.exitscope();
    objectEnv.enterscope();
    elseexpr->check(type);
    objectEnv.exitscope();
}

void WhileStmt_class::check(Symbol type) {
    is_in_loop = true;
    if (!sameType(condition->checkType(), Bool))semant_error(this)<<"condition must be Bool"<< endl;
    objectEnv.enterscope();
    body->check(type);
    objectEnv.exitscope();
    is_in_loop = false;
}

void ForStmt_class::check(Symbol type) {
    is_in_loop = true;
    if (!initexpr->is_empty_Expr())initexpr->checkType();
    if (!condition->is_empty_Expr())if (!sameType(condition->checkType(), Bool))semant_error(this)<<"condition must be Bool"<< endl;
    if (!loopact->is_empty_Expr())loopact->checkType();
    objectEnv.enterscope();
    body->check(type);
    objectEnv.exitscope();
    is_in_loop = false;
}

void ReturnStmt_class::check(Symbol type) {
    is_returned = true;
    if (!sameType(value->checkType(), type)) semant_error(this)<<"Returns "<<value->checkType()<<" , but need "<<type<<"."<< endl;
}

void ContinueStmt_class::check(Symbol type) {
    if (!is_in_loop) semant_error(this)<<"continue statement is only used in a loop."<< endl;
}

void BreakStmt_class::check(Symbol type) {
    if (!is_in_loop) semant_error(this)<<"break statement is only used in a loop."<< endl;
}

Symbol Call_class::checkType(){
    if (!isValidCallName(name)) {//有关内置函数printf的限制
        if (!actuals->more(0))semant_error(this)<<"function printf must have at least one parameter."<< endl;
        else{
            for (int i = actuals->first(); actuals->more(i); i = actuals->next(i)) actuals->nth(i)->checkType();
            if (!sameType((actuals->nth(0))->getType(), String)) semant_error(this)<<"function printf must have string as first parameter."<< endl;
        }
        setType(Void);
        return type;
    }
    if (functbl.probe(name) == NULL){
        semant_error(this)<<"Function "<<name<<" has not been defined."<< endl;
        setType(Void);
        return type;
    }
    Decl curr_decl = *(functbl.probe(name));
    Variables curr_parameters = curr_decl->getVariables();
    if (actuals->more(0) ^ curr_parameters->more(0)) semant_error(this)<<"Function "<<name<<" call parameters wrong."<< endl;  
    for (int i = 0; actuals->more(i) && curr_parameters->more(i); i++){
        if (!sameType(actuals->nth(i)->checkType(),curr_parameters->nth(i)->getType())){
            semant_error(this)<<"Function "<<name<<", type "<< actuals->nth(i)->checkType() <<" of parameter "<<curr_parameters->nth(i)->getName() << " does not conform to declared type "<<curr_parameters->nth(i)->getType()<<"."<< endl;
            break;
        }
        if (actuals->more(i+1) ^ curr_parameters->more(i+1)) {
            semant_error(this)<<"Function "<<name<<" call parameters wrong."<< endl;
            break;
        }
    }
    setType(curr_decl->getType());
    return type;
}

Symbol Actual_class::checkType(){
    setType(expr->checkType());
    return type;
}

Symbol Assign_class::checkType(){//不考察浮点数和整数相互赋值
    if (objectEnv.probe(lvalue) != NULL) setType(*(objectEnv.probe(lvalue)));
    else if (objectEnv.lookup(lvalue) != NULL)setType(*(objectEnv.lookup(lvalue)));
    else{
        semant_error(this)<<"variable "<<lvalue->get_string()<<" not defined."<< endl;
        setType(Void);
        return type;
    }
    Symbol righttype = value->checkType();//使用新变量可以提前报错，否则直接用value->checkType()会导致报错输出极为奇怪
    /*example:23: can`t assign 23: s is not defined.
Void to Float.*/
    if (!sameType(righttype, type))semant_error(this)<<"can`t assign "<<righttype<<" to "<<type<<"."<< endl;
    return type;
}

Symbol Add_class::checkType(){
    if ((sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Float);
        return type;
    }
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for add(+) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Minus_class::checkType(){
    if ((sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Float);
        return type;
    }
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for minus(-) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Multi_class::checkType(){
    if ((sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Float);
        return type;
    }
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for mutilple(*) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Divide_class::checkType(){
    if ((sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Float);
        return type;
    }
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);//此处有疑问，两整数整除结果是否为整数
        return type;
    }
    semant_error(this)<<"invalid type for divide(/) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Mod_class::checkType(){
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)) {
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for mod(%) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Neg_class::checkType(){
    if (sameType(e1->checkType(), Int) || sameType(e1->checkType(), Float)){
        setType(e1->checkType());//此处有小坑
        return type;
    }
    semant_error(this)<<"invalid type for neg(!) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Lt_class::checkType(){
    if ((sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int))||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for lt(<) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Le_class::checkType(){
    if ((sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int))||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for le(<=) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Equ_class::checkType(){
    if ((sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int))||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Bool);
        return type;
    }
    if (sameType(e1->checkType(), Bool) && sameType(e2->checkType(), Bool)){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for eq(==) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Neq_class::checkType(){
    if ((sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int))||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Bool);
        return type;
    }
    if (sameType(e1->checkType(), Bool) && sameType(e2->checkType(), Bool)){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for neq(!=) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Ge_class::checkType(){
    if ((sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int))||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for ge(>=) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Gt_class::checkType(){
    if ((sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int))||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Int)) ||(sameType(e1->checkType(), Int) && sameType(e2->checkType(), Float)) ||(sameType(e1->checkType(), Float) && sameType(e2->checkType(), Float))){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for gt(>) operation."<< endl;
    setType(Void);
    return type;
}

Symbol And_class::checkType(){
    if (sameType(e1->checkType(), Bool) && sameType(e2->checkType(), Bool)){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for or(||) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Or_class::checkType(){
    if (sameType(e1->checkType(), Bool) && sameType(e2->checkType(), Bool)){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for or(||) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Xor_class::checkType(){
    if (sameType(e1->checkType(), Bool) && sameType(e2->checkType(), Bool)){
        setType(Bool);
        return type;
    }
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for xor(^) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Not_class::checkType(){
    if (sameType(e1->checkType(), Bool)){
        setType(Bool);
        return type;
    }
    semant_error(this)<<"invalid type for not(!) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Bitand_class::checkType(){
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for bitand(&) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Bitor_class::checkType(){
    if (sameType(e1->checkType(), Int) && sameType(e2->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for bitor(|) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Bitnot_class::checkType(){
    if (sameType(e1->checkType(), Int)){
        setType(Int);
        return type;
    }
    semant_error(this)<<"invalid type for bitnot(~) operation."<< endl;
    setType(Void);
    return type;
}

Symbol Const_int_class::checkType(){
    setType(Int);
    return type;
}

Symbol Const_string_class::checkType(){
    setType(String);
    return type;
}

Symbol Const_float_class::checkType(){
    setType(Float);
    return type;
}

Symbol Const_bool_class::checkType(){
    setType(Bool);
    return type;
}

Symbol Object_class::checkType(){
    if (objectEnv.probe(var) != NULL){//先找局部变量，再找全局变量
        setType(*(objectEnv.probe(var)));
        return type;
    }
    else if (objectEnv.lookup(var) != NULL){
        setType(*(objectEnv.lookup(var)));
        return type;
    }
    else semant_error(this)<<var<<" is not defined."<< endl;
    setType(Void);
    return type;
}

Symbol No_expr_class::checkType(){
    setType(Void);
    return getType();
}

void Program_class::semant() {
    initialize_constants();
    install_calls(decls);
    check_main();
    install_globalVars(decls);
    check_calls(decls);
    if (semant_errors > 0) {
        cerr << "Compilation halted due to static semantic errors." << endl;
        exit(1);
    }
    objectEnv.exitscope();
    functbl.exitscope();
}
