unit class Pink::Parse::Actions;

use Pink::Ast;

################################################################################
# Source files

method TOP($/)
{
    my @definitions := $<definitions>».made;
    make SourceFile.new(:@definitions);
}

################################################################################
# Definitions

method definition:sym<method>($/)
{
    my $name := $<name>.made;
    my $body := $<body>.made;
    make MethodDefinition.new(:$name, :$body);
}

method definition:sym<package>($/)
{
    my $name    := $<name>.made;
    my @members := $<members>».made;
    make PackageDefinition.new(:$name, :@members);
}

method definition:sym<sub>($/)
{
    my $name := $<name>.made;
    my $body := $<body>.made;
    make SubDefinition.new(:$name, :$body);
}

################################################################################
# Blocks

method block($/)
{
    my @body := $<body>».made;
    make Block.new(:@body);
}

################################################################################
# Statements

method statement:sym<expression>($/)
{
    my $expression := $<expression>.made;
    make ExpressionStatement.new(:$expression);
}

################################################################################
# Expressions

method expression($/)
{
    make $<inner>.made;
}

########################################
# Level 2

method expression2:sym<method-call>($/)
{
    my $receiver     := $<receiver>.made;
    my @method-names := $<method-names>».made;
    make reduce({ MethodCallExpression.new(receiver => $^a,
                                           method-name => $^b); },
                $receiver, |@method-names);
}

########################################
# Level 1

method expression1:sym<bool-literal>($/)
{
    my $value := ~$/ eq ‘true’;
    make BoolLiteralExpression.new(:$value);
}

method expression1:sym<self>($/)
{
    make SelfExpression.new;
}

method expression1:sym<str-literal>($/)
{
    my $value := $<value>.made;
    make StrLiteralExpression.new(:$value);
}

method expression1:sym<undef-literal>($/)
{
    make UndefLiteralExpression.new;
}

################################################################################
# Terminals

method identifier($/)
{
    make ~$/;
}

method str-literal($/)
{
    make ~$<value>;
}
