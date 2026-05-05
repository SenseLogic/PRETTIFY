namespace Prettify.Test
{
public class Strings
{
public static string GetPaths(
string root
)
{
var verbatim
= @"C:\temp\foo
C:\temp\bar";

var name = "world";
var x = 1;
var y = 2;

var interpolated = $"Hello {name}, sum={x+y}";
var interpolatedVerbatim = $@"{root}\{name}
line2";

var escapedBraces = $"{{ literal }} and value={x}";

return verbatim + interpolated + interpolatedVerbatim + escapedBraces;
}
}
}
