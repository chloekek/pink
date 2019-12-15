unit module Pink::Vm::Es;

use Pink::Anf;

################################################################################
# Mangling

sub mangle(Str:D $_ --> Str:D)
{
    constant %safe := set(|(‘A’ .. ‘Z’), |(‘a’ .. ‘z’), |(‘0’ .. ‘9’));
    .comb.map({$_ ∈ %safe ?? $_ !! .encode.list.map(*.fmt(‘$%02x’))}).flat.join;
}

sub mangle-id(Int:D $_ --> Str:D)
{
    “id_$_”;
}

sub mangle-method(Str:D $_ = $*PINK-METHOD-NAME --> Str:D)
{
    “method_{mangle($_)}”;
}

sub mangle-package(Str:D $_ = $*PINK-PACKAGE-NAME --> Str:D)
{
    “package_{mangle($_)}”;
}

sub mangle-sub(Str:D $_ = $*PINK-SUB-NAME --> Str:D)
{
    “sub_{mangle($_)}”;
}

################################################################################
# Compilation units

sub es-compilation-unit(AnfCompilationUnit:D $node --> Nil)
    is export
{
    put ‘"use strict";’;

    # First, declare the packages and subs, so that they are in scope
    # everywhere. Methods need not be declared, since they are always looked up
    # on the package objects. At runtime, subs are not associated with
    # packages, since they are not looked up with dynamic dispatch.
    put “const {mangle-package($_)} = \{\};” for $node.packages.keys.sort;
    put “let {mangle-sub($_)};”              for $node.subs.keys.sort;

    # Then, define the methods of the packages.
    for $node.packages.sort -> (:key($package-name), :value($package)) {
        my $*PINK-PACKAGE-NAME := $package-name;
        for $package.methods.sort -> (:key($method-name), :value($method)) {
            my $*PINK-METHOD-NAME := $method-name;
            es-definition($method);
        }
    }

    # Finally, define the subs.
    for $node.subs.sort -> (:key($sub-name), :value($sub)) {
        my $*PINK-SUB-NAME := $sub-name;
        es-definition($sub);
    }
}

################################################################################
# Definitions

multi es-definition(AnfMethodDefinition:D $node --> Nil)
{
    put “{mangle-package}.{mangle-method} = async (self) => \{”;
    my $result := es-block($node.body);
    put “return $result;”;
    put ‘};’;
}

multi es-definition(AnfPackageDefinition:D $node --> Nil)
{
    die ‘Invalid call with AnfPackageDefinition; ’ ~
        ‘this type of node should be handled by es-compilation-unit’;
}

multi es-definition(AnfSubDefinition:D $node --> Nil)
{
    put “{mangle-sub} = async (self) => \{”;
    my $result := es-block($node.body);
    put “return $result;”;
    put ‘};’;
}

################################################################################
# Blocks

multi es-block(AnfBlock:D $node --> Str:D)
{
    es-binding($_) for $node.bindings;
    es-value($node.result);
}

################################################################################
# Bindings

sub es-binding(MethodCallAnfBinding:D $node --> Nil)
{
    my $id          := mangle-id($node.id);
    my $receiver    := es-value($node.receiver);
    my $method-name := mangle-method($node.method-name);
    put “const $id = await {$receiver}.class.{$method-name}($receiver);”;
}

################################################################################
# Values

multi es-value(BoolLiteralAnfValue:D $node --> Str:D)
{
    my $class  := mangle-package(‘::Bool’);
    my $native := $node.value ?? ‘true’ !! ‘false’;
    “\{ class: $class, native: $native \}”;
}

multi es-value(IdAnfValue:D $node --> Str:D)
{
    mangle-id($node.id);
}

multi es-value(SelfAnfValue:D $node --> Str:D)
{
    ‘self’;
}

multi es-value(StrLiteralAnfValue:D $node --> Str:D)
{
    my $class  := mangle-package(‘::Str’);
    my $native := “"{$node.value}"”;
    “\{ class: $class, native: $native \}”;
}

multi es-value(UndefLiteralAnfValue:D $node --> Str:D)
{
    my $class := mangle-package(‘::Undef’);
    “\{ class: $class \}”;
}
