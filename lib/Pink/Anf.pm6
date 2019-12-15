unit module Pink::Anf;

class AnfPackageDefinition { … }
class AnfSubDefinition { … }
class AnfBlock { … }
class AnfBinding { … }
class AnfValue { … }

################################################################################
# Compilation units

class AnfCompilationUnit
    is export
{
    has AnfPackageDefinition:D %.packages;
    has AnfSubDefinition:D     %.subs;
}

################################################################################
# Definitions

class AnfMethodDefinition
    is export
{
    has AnfBlock $.body;
}

class AnfPackageDefinition
    is export
{
    has AnfMethodDefinition:D %.methods;
}

class AnfSubDefinition
    is export
{
    has AnfBlock $.body;
}

################################################################################
# Blocks

class AnfBlock
    is export
{
    has AnfBinding:D @.bindings;
    has AnfValue     $.result;
}

################################################################################
# Bindings

class AnfBinding
    is export
{
}

class MethodCallAnfBinding
    is export
    is AnfBinding
{
    has Int      $.id;
    has AnfValue $.receiver;
    has Str      $.method-name;
}

################################################################################
# Values

class AnfValue
    is export
{
}

class BoolLiteralAnfValue
    is export
    is AnfValue
{
    has Bool $.value;
}

class IdAnfValue
    is export
    is AnfValue
{
    has Int $.id;
}

class SelfAnfValue
    is export
    is AnfValue
{
}

class StrLiteralAnfValue
    is export
    is AnfValue
{
    has Str $.value;
}

class UndefLiteralAnfValue
    is export
    is AnfValue
{
}
