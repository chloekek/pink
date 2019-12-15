unit grammar Pink::Parse;

use Pink::Parse::Actions;
use Pink::Parse::Grammar;

multi parse-source-file(IO() $path)
    is export
{
    parse-source-file($path, $path.slurp);
}

multi parse-source-file(IO() $path, Str() $contents)
    is export
{
    Pink::Parse::Grammar.parse($contents, actions => Pink::Parse::Actions).made;
}
