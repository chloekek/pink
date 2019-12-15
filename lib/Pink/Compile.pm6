unit module Pink::Compile;

use Pink::Anf;
use Pink::Ast;

################################################################################
# Identifiers

my &fresh-id = { $++; };

################################################################################
# Source files

sub compile-source-files(*@nodes --> AnfCompilationUnit:D)
    is export
{
    my AnfPackageDefinition:D %*PINK-PACKAGES;
    my AnfSubDefinition:D     %*PINK-SUBS;
    my                        $*PINK-PACKAGE-NAME := '';

    compile-source-file($_) for @nodes;
    AnfCompilationUnit.new(packages => %*PINK-PACKAGES, subs => %*PINK-SUBS);
}

sub compile-source-file(SourceFile:D $node --> Nil)
{
    compile-definition($_) for $node.definitions;
}

################################################################################
# Definitions

multi compile-definition(MethodDefinition:D $node --> Nil)
{
    my $package := $*PINK-PACKAGE // die ｢Method definition outside package｣;
    my $name    := $node.name;

    if $package.methods{$name}:exists {
        die qq｢Redefinition of method ‘$name’｣;
    }

    my $body   := compile-block($node.body);
    my $method := AnfMethodDefinition.new(:$body);

    $package.methods{$name} := $method;
}

multi compile-definition(PackageDefinition:D $node --> Nil)
{
    my $qualified-name := “{$*PINK-PACKAGE-NAME}::{$node.name}”;
    {
        my $*PINK-PACKAGE :=
            %*PINK-PACKAGES{$qualified-name}
            // (%*PINK-PACKAGES{$qualified-name} := AnfPackageDefinition.new);

        my $*PINK-PACKAGE-NAME := $qualified-name;
        compile-definition($_) for $node.members;
    }
}

multi compile-definition(SubDefinition:D $node --> Nil)
{
    my $qualified-name := “{$*PINK-PACKAGE-NAME}::{$node.name}”;
    my $*PINK-SUB-NAME := $qualified-name;

    if $*PINK-SUBS{$qualified-name}:exists {
        die qq｢Redefinition of sub ‘$qualified-name’｣;
    }

    my $body := compile-block($node.body);
    my $sub  := AnfSubDefinition.new(:$body);

    %*PINK-SUBS{$qualified-name} := $sub;
}

################################################################################
# Blocks

sub compile-block(Block:D $node --> AnfBlock:D)
{
    my @*PINK-BINDINGS;
    my @values  = $node.body.map(&compile-statement);
    my $result := (UndefLiteralAnfValue.new, |@values)[* - 1];
    AnfBlock.new(bindings => @*PINK-BINDINGS, :$result);
}

################################################################################
# Statements

multi compile-statement(ExpressionStatement:D $node --> AnfValue:D)
{
    compile-expression($node.expression);
}

################################################################################
# Expressions

multi compile-expression(BoolLiteralExpression:D $node --> AnfValue:D)
{
    my $value := $node.value;
    BoolLiteralAnfValue.new(:$value);
}

multi compile-expression(MethodCallExpression:D $node --> AnfValue:D)
{
    my $id          := fresh-id;
    my $receiver    := compile-expression($node.receiver);
    my $method-name := $node.method-name;
    my $binding     := MethodCallAnfBinding.new(:$id, :$receiver, :$method-name);
    push(@*PINK-BINDINGS, $binding);
    IdAnfValue.new(:$id);
}

multi compile-expression(SelfExpression:D $node --> AnfValue:D)
{
    # TODO: Assert this is inside a method definition.
    SelfAnfValue.new;
}

multi compile-expression(StrLiteralExpression:D $node --> AnfValue:D)
{
    my $value := $node.value;
    StrLiteralAnfValue.new(:$value);
}

multi compile-expression(UndefLiteralExpression:D $node --> AnfValue:D)
{
    UndefLiteralAnfValue.new;
}
