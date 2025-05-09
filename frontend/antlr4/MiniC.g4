grammar MiniC;

// 词法规则名总是以大写字母开头

// 语法规则名总是以小写字母开头

// 每个非终结符尽量多包含闭包、正闭包或可选符等的EBNF范式描述

// 若非终结符由多个产生式组成，则建议在每个产生式的尾部追加# 名称来区分，详细可查看非终结符statement的描述

// 语法规则描述：EBNF范式

// 源文件编译单元定义
compileUnit: (funcDef | varDecl)* EOF;

// 函数定义，目前不支持形参，也不支持返回void类型等
funcDef: T_INT T_ID T_L_PAREN T_R_PAREN block;

// 语句块看用作函数体，这里允许多个语句，并且不含任何语句
block: T_L_BRACE blockItemList? T_R_BRACE;

// 每个ItemList可包含至少一个Item
blockItemList: blockItem+;

// 每个Item可以是一个语句，或者变量声明语句
blockItem: statement | varDecl;

// 变量声明，目前不支持变量含有初值
varDecl: basicType varDef (T_COMMA varDef)* T_SEMICOLON;

// 基本类型
basicType: T_INT;

// 变量定义
varDef: T_ID;

// 目前语句支持return和赋值语句
statement:
	T_RETURN expr T_SEMICOLON			# returnStatement
	| lVal T_ASSIGN expr T_SEMICOLON	# assignStatement
	| block								# blockStatement
	| expr? T_SEMICOLON					# expressionStatement;

// 表达式文法 expr : RelExp 表达式现在以关系表达式为入口
expr: relExp;

// 关系表达式 (二目运算符 <, <=, >, >=, ==, !=) 操作数是加减表达式 (addExp)，优先级低于加减
relExp: addExp (relOp addExp)*;

// 关系运算符
relOp: T_EQ | T_NE | T_LE | T_LT | T_GE | T_GT;

// 加减表达式 (二目运算符 + 和 -) 操作数现在是乘法表达式 (mulExp)，优先级低于乘法、除法、求余
addExp: mulExp (addOp mulExp)*;

// 加减运算符
addOp: T_ADD | T_SUB;

// 乘法、除法、求余表达式 (二目运算符 *, /, %) 操作数是 unaryExp，优先级低于单目运算符
mulExp: unaryExp (mulOp unaryExp)*;

// 乘法、除法、求余运算符 (二目)
mulOp: T_MUL | T_DIV | T_MOD;

// 一元表达式:单目求负运算、基本表达式
unaryExp:
	T_SUB unaryExp
	| primaryExp
	| T_ID T_L_PAREN realParamList? T_R_PAREN;

// 基本表达式：括号表达式、整数、左值表达式
primaryExp: T_L_PAREN expr T_R_PAREN | T_DIGIT | lVal;

// 实参列表
realParamList: expr (T_COMMA expr)*;

// 左值表达式
lVal: T_ID;

// 用正规式来进行词法规则的描述

T_L_PAREN: '(';
T_R_PAREN: ')';
T_SEMICOLON: ';';
T_L_BRACE: '{';
T_R_BRACE: '}';

T_ASSIGN: '=';
T_EQ: '==';
T_NE: '!=';
T_LE: '<=';
T_LT: '<';
T_GE: '>=';
T_GT: '>';
T_COMMA: ',';

T_ADD: '+';
T_SUB: '-';
T_MUL: '*';
T_DIV: '/';
T_MOD: '%';

// 要注意关键字同样也属于T_ID，因此必须放在T_ID的前面，否则会识别成T_ID
T_RETURN: 'return';
T_INT: 'int';
T_VOID: 'void';

T_ID: [a-zA-Z_][a-zA-Z0-9_]*;
// 无符号整数定义，支持十进制、八进制和十六进制 十六进制以 0x 或 0X 开头，后跟十六进制数字 [0-9a-fA-F]+ 八进制以 0 开头，后跟零个或多个八进制数字 [0-7]*

T_DIGIT:
	'0' [xX] [0-9a-fA-F]+ // 十六进制
	| '0' [0-7]* // 八进制，0被八进制匹配
	| [1-9] [0-9]*; // 十进制

/* 空白符丢弃 */
WS: [ \r\n\t]+ -> skip;