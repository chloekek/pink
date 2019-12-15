unit grammar Pink::Parse::Grammar;

################################################################################
# Errors

method die-expected(Str() $context)
{
    die qq｢expected $context｣;
}

################################################################################
# Source files

rule TOP
{
    [$<definitions>=<definition>] *
}

################################################################################
# Definitions

proto rule definition {*}

rule definition:sym<method>
{
    ‘method’
        [  $<name>=<identifier>
        || <.die-expected(‘method name’)> ]
    <signature>
    $<body>=<block>
}

rule definition:sym<package>
{
    ‘package’
        [  $<name>=<identifier>
        || <.die-expected(‘package name’)> ]
    “\x7B”
        [$<members>=<definition>] *
    “\x7D”
}

rule definition:sym<sub>
{
    ‘sub’
        [  $<name>=<identifier>
        || <.die-expected(‘sub name’)> ]
    <signature>
    $<body>=<block>
}

################################################################################
# Signatures

rule signature
{
    ‘(’
        [ <type> <variable> ] * %% ‘,’
    ‘-->’
        $<return-type>=<type>
    ‘)’
}

################################################################################
# Blocks

rule block
{
    “\x7B”
        [  [$<body>=<statement>] *
        || <.die-expected(‘statements’)> ]
    “\x7D”
}

################################################################################
# Statements

proto rule statement {*}

rule statement:sym<expression>
{
    <expression> ‘;’
}

################################################################################
# Expressions

rule expression
{
    $<inner>=<expression2>
}

########################################
# Level 2

proto rule expression2 {*}

rule expression2:sym<method-call>
{
    $<receiver>=<expression1>
    [ ‘.’ [  $<method-names>=<identifier>
          || <.die-expected(‘method name’)> ] ] *
}

########################################
# Level 1

proto rule expression1 {*}

rule expression1:sym<bool-literal>
{
    ‘true’ || ‘false’
}

rule expression1:sym<self>
{
    ‘self’
}

rule expression1:sym<str-literal>
{
    $<value>=<str-literal>
}

rule expression1:sym<undef-literal>
{
    ‘undef’
}

################################################################################
# Types

proto rule type {*}

rule type:sym<named>
{
    <qualified-identifier>
}

################################################################################
# Terminals

token identifier
{
    <:L> <:L+:N> *
}

token qualified-identifier
{
    ‘::’? <identifier> + % ‘::’
}

token sigil
{
    <[$@%&*]>
}

token variable
{
    <sigil> <identifier>
}

token str-literal
{
    ｢‘｣ $<value>=[<-[’]> *] ｢’｣
}
