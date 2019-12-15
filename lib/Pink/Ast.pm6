unit module Pink::Ast;

class Definition { … }
class Block { … }
class Statement { … }
class Expression { … }

################################################################################
# Source files

class SourceFile
    is export
{
    has Definition:D @.definitions;
}

################################################################################
# Definitions

class Definition
    is export
{
}

class MethodDefinition
    is export
    is Definition
{
    has Str   $.name;
    has Block $.body;
}

class PackageDefinition
    is export
    is Definition
{
    has Str          $.name;
    has Definition:D @.members;
}

class SubDefinition
    is export
    is Definition
{
    has Str   $.name;
    has Block $.body;
}

################################################################################
# Blocks

class Block
    is export
{
    has Statement:D @.body;
}

################################################################################
# Statements

class Statement
    is export
{
}

class ExpressionStatement
    is export
    is Statement
{
    has Expression $.expression;
}

################################################################################
# Expressions

class Expression
    is export
{
}

class BoolLiteralExpression
    is export
    is Expression
{
    has Bool $.value;
}

class MethodCallExpression
    is export
    is Expression
{
    has Expression $.receiver;
    has Str        $.method-name;
}

class SelfExpression
    is export
    is Expression
{
}

class StrLiteralExpression
    is export
    is Expression
{
    has Str $.value;
}

class UndefLiteralExpression
    is export
    is Expression
{
}
