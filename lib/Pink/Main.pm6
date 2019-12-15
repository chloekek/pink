unit module Pink::Main;

use Pink::Compile;
use Pink::Parse;
use Pink::Vm::Es;

sub MAIN(*@source-files)
    is export
{
    my @asts = hyper for @source-files { parse-source-file($_.IO) };
    my $anf := compile-source-files(@asts);
    es-compilation-unit($anf);
}
