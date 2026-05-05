fn main()
{
    let name = "world";

    let raw = r#"Line1 "quoted"
    Line2 \ not -escaped
    "#;

    let raw2 = r###"Delim ### inside ok" ###;

    println !( "Hello {name} {raw} {raw2}" );
}
