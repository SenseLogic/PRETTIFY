bool IsSeparatorCharacterIndex(
    string text,
    int character_index
    )
{
    char
        character;

    if ( character_index >= 0
         && character_index < text.length )
    {
        character = text[ character_index ];

        if ( character.isAlphaNum()
             || character == '_' )
        {
            return false;
        }
    }

    return true;
}

// ~~

bool StartsByVowel(
    string text
    )
{
    return (
        text != ""
             && IsVowelCharacter( text[ 0 ] )
        );
}

// ~~

value.Text
    = ( ( table.PriorFirstName != "" ) ? table.PriorFirstName : Random.MakeFirstName() ).toLower()
      ~ "."
      ~ ( ( table.PriorLastName != "" ) ? table.PriorLastName : Random.MakeLastName() ).toLower()
      ~ [
          "@gmail.com",
          "@yahoo.com",
          "@outlook.com",
          "@live.com",
          "@hotmail.com",
          "@mail.com"
        ][ Random.MakeIndex( 6 ) ];
