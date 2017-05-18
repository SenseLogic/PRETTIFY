/*
    This file is part of the Prettify distribution.

    https://github.com/senselogic/PRETTIFY

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Prettify is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Prettify is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/

// == LOCAL

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.algorithm : countUntil;
import std.conv : to;
import std.file : dirEntries, readText, write, SpanMode;
import std.path : baseName, dirName, extension;
import std.random : uniform;
import std.stdio : writeln;
import std.string : endsWith, indexOf, replace, startsWith;

// == GLOBAL

// -- TYPES

// .. LANGUAGE_TYPE

enum LANGUAGE_TYPE
{
    // -- CONSTANTS

    None,
    Html,
    Css,
    Cpp,
    Gs,
    Js,
    Php
}

// .. TOKEN_TYPE

enum TOKEN_TYPE
{
    // -- CONSTANTS

    None,
    BeginShortComment,
    ShortComment,
    BeginLongComment,
    LongComment,
    EndLongComment,
    RegularExpressionLiteral,
    BeginCharacterLiteral,
    CharacterLiteral,
    EndCharacterLiteral,
    BeginStringLiteral,
    StringLiteral,
    EndStringLiteral,
    BeginTextLiteral,
    TextLiteral,
    EndTextLiteral,
    Command,
    BeginDeclaration,
    EndDeclaration,
    BeginElement,
    EndElement,
    BeginOpeningTag,
    EndOpeningTag,
    CloseOpeningTag,
    BeginClosingTag,
    EndClosingTag,
    Number,
    Identifier,
    Operator,
    Separator,
    Special
}

// .. INDENTATION_TYPE

enum INDENTATION_TYPE
{
    // -- CONSTANTS

    None,
    Tabulation,
    NextColumn,
    NextLine,
    SameColumn
}

// .. TOKEN

class TOKEN
{
    // -- ATTRIBUTES

    string
        Text;
    LANGUAGE_TYPE
        LanguageType;
    TOKEN_TYPE
        Type;
    int
        LineIndex,
        ColumnIndex,
        PriorSpaceCount,
        BaseColumnIndex,
        BaseTokenIndex,
        BaseColumnOffset;
    bool
        BeginsLine,
        EndsLine,
        BeginsStatement,
        EndsStatement,
        BeginsBlock,
        EndsBlock,
        IsIndented;

    // -- CONSTRUCTORS

    this(
        string text,
        LANGUAGE_TYPE language_type,
        TOKEN_TYPE token_type,
        CODE code
        )
    {
        Text = text;
        LanguageType = language_type;
        Type = token_type;
        LineIndex = code.LineIndex;
        ColumnIndex = code.TokenCharacterIndex - code.LineCharacterIndex;
        PriorSpaceCount = 0;
        BaseColumnIndex = ColumnIndex;
        BaseTokenIndex = -1;
        BaseColumnOffset = 0;
        BeginsLine = false;
        EndsLine = false;
        BeginsStatement = false;
        EndsStatement = false;
        BeginsBlock = false;
        EndsBlock = false;
        IsIndented = false;
    }
}

// .. CONTEXT

class CONTEXT
{
    // -- ATTRIBUTES

    LANGUAGE_TYPE
        LanguageType;
    TOKEN_TYPE
        TokenType;

    // -- CONSTRUCTORS

    this(
        LANGUAGE_TYPE language_type
        )
    {
        LanguageType = language_type;
        TokenType = TOKEN_TYPE.None;
    }
}

// .. BLOCK

class BLOCK
{
    // -- ATTRIBUTES

    int
        SeparatorTokenIndex,
        BaseTokenIndex;
    INDENTATION_TYPE
        BaseIndentationType;
    int
        ColumnIndex;

    // -- CONSTRUCTORS

    this(
        int separator_token_index,
        int base_token_index,
        INDENTATION_TYPE base_indentation_type,
        int column_index
        )
    {
        SeparatorTokenIndex = separator_token_index;
        BaseTokenIndex = base_token_index;
        BaseIndentationType = base_indentation_type;
        ColumnIndex = column_index;
    }
}

// .. CODE

class CODE
{
    // -- ATTRIBUTES

    string
        FileExtension;
    LANGUAGE_TYPE
        FileLanguageType;
    int
        LineCharacterIndex,
        CharacterIndex,
        LineIndex,
        TokenCharacterIndex;
    TOKEN[]
        TokenArray;
    TOKEN
        Token;
    int
        TokenIndex;
    bool
        TokenIsSplit;
    CONTEXT
        BaseContext,
        PhpContext,
        Context;

    // -- CONSTRUCTORS

    this(
        )
    {
        FileExtension = "";
        FileLanguageType = LANGUAGE_TYPE.None;
        LineCharacterIndex = -1;
        CharacterIndex = -1;
        LineIndex = -1;
        TokenCharacterIndex = -1;
        TokenArray = null;
        Token = null;
        TokenIndex = -1;
        TokenIsSplit = false;
        BaseContext = null;
        PhpContext = null;
        Context = null;
    }

    // -- INQUIRIES

    bool IsHtmlFileExtension(
        string file_extension
        )
    {
        return (
            file_extension == ".html"
            || file_extension == ".htm"
            || file_extension == ".xml"
            || file_extension == ".twig"
            );
    }

    // ~~

    bool IsCssFileExtension(
        string file_extension
        )
    {
        return (
            file_extension == ".css"
            || file_extension == ".less"
            || file_extension == ".pepss"
            || file_extension == ".sass"
            || file_extension == ".scss"
            || file_extension == ".styl"
            );
    }

    // ~~

    bool IsGpFileExtension(
        string file_extension
        )
    {
        return (
            file_extension == ".gp"
            || file_extension == ".gpp"
            );
    }

    // ~~

    bool IsCppFileExtension(
        string file_extension
        )
    {
        return (
            file_extension == ".c"
            || file_extension == ".h"
            || file_extension == ".cxx"
            || file_extension == ".hxx"
            || file_extension == ".cpp"
            || file_extension == ".hpp"
            || IsGpFileExtension( file_extension )
            );
    }

    // ~~

    bool IsGsFileExtension(
        string file_extension
        )
    {
        return file_extension == ".gs";
    }

    // ~~

    bool IsJsFileExtension(
        string file_extension
        )
    {
        return (
            file_extension == ".js"
            || file_extension == ".json"
            );
    }

    // ~~

    bool IsPhpFileExtension(
        string file_extension
        )
    {
        return file_extension == ".php";
    }

    // ~~

    LANGUAGE_TYPE GetFileLanguageType(
        string file_extension
        )
    {
        if ( IsHtmlFileExtension( file_extension ) )
        {
            return LANGUAGE_TYPE.Html;
        }
        else if ( IsCssFileExtension( file_extension ) )
        {
            return LANGUAGE_TYPE.Css;
        }
        else if ( IsCppFileExtension( file_extension ) )
        {
            return LANGUAGE_TYPE.Cpp;
        }
        else if ( IsGsFileExtension( file_extension ) )
        {
            return LANGUAGE_TYPE.Gs;
        }
        else if ( IsJsFileExtension( file_extension ) )
        {
            return LANGUAGE_TYPE.Js;
        }
        else if ( IsPhpFileExtension( file_extension ) )
        {
            return LANGUAGE_TYPE.Php;
        }
        else
        {
            return LANGUAGE_TYPE.None;
        }
    }

    // ~~

    bool IsAlphabeticalCharacter(
        char character
        )
    {
        return (
            ( character >= 'a' && character <= 'z' )
            || ( character >= 'A' && character <= 'Z' )
            );
    }

    // ~~

    bool IsNumberCharacter(
        char character,
        char prior_character,
        char next_character
        )
    {
        return (
            ( character >= '0' && character <= '9' )
            || ( character >= 'a' && character <= 'z' )
            || ( character >= 'A' && character <= 'Z' )
            || ( character == '.'
                 && prior_character >= '0' && prior_character <= '9'
                 && next_character >= '0' && next_character <= '9' )
            || ( character == '-'
                 && ( prior_character == 'e' || prior_character == 'E' ) )
            );
    }

    // ~~

    bool IsIdentifierCharacter(
        char character
        )
    {
        return (
            ( character >= 'a' && character <= 'z' )
            || ( character >= 'A' && character <= 'Z' )
            || ( character >= '0' && character <= '9' )
            || character == '_'
            || character == '$'
            );
    }

    // ~~

    bool IsSeparatorCharacter(
        char character
        )
    {
        return (
            character == '{'
            || character == '}'
            || character == '['
            || character == ']'
            || character == '('
            || character == ')'
            || character == ';'
            || character == ','
            || character == '.'
            || character == ':'
            );
    }

    // ~~

    bool IsOperatorCharacter(
        char character
        )
    {
        return (
            character == '='
            || character == '+'
            || character == '-'
            || character == '*'
            || character == '/'
            || character == '%'
            || character == '<'
            || character == '>'
            || character == '~'
            || character == '&'
            || character == '|'
            || character == '^'
            || character == '!'
            || character == '?'
            || character == '@'
            || character == '#'
            );
    }

    // ~~

    bool IsLastTokenPrecedingRegularExpression()
    {
        TOKEN
            token;

        if ( TokenArray.length == 0 )
        {
            return true;
        }
        else
        {
            token = TokenArray[ TokenArray.length - 1 ];

            return (
                ( token.Type == TOKEN_TYPE.Separator
                  && token.Text != "]"
                  && token.Text != ")" )
                || token.Type == TOKEN_TYPE.Operator
                );
        }
    }

    // ~~

    bool StartsLine(
        string text,
        int character_index
        )
    {
        char
            character;

        while ( --character_index >= 0 )
        {
            character = text[ character_index ];

            if ( character == '\n' )
            {
                return true;
            }
            else if ( character != ' ' )
            {
                return false;
            }
        }

        return true;
    }

    // ~~

    string GetTokenDump(
        int token_index
        )
    {
        TOKEN
            token;

        token = TokenArray[ token_index ];

        return
            token_index.to!string() ~ " " ~ token.Text ~ "\n            "
            ~ token.LanguageType.to!string() ~ " "
            ~ token.Type.to!string() ~ "\n            "
            ~ "L:" ~ token.LineIndex.to!string() ~ " "
            ~ "Bc:" ~ token.BaseColumnIndex.to!string() ~ " "
            ~ "Bt:" ~ ( ( token.BaseTokenIndex == -1 ) ? "-" : token.BaseTokenIndex.to!string() ) ~ " "
            ~ "Bo:" ~ token.BaseColumnOffset.to!string() ~ " "
            ~ ( token.BeginsLine ? "[" : "" )
            ~ ( token.EndsLine ? "]" : "" )
            ~ ( token.BeginsStatement ? "(" : "" )
            ~ ( token.EndsStatement ? ")" : "" )
            ~ ( token.BeginsBlock ? "{" : "" )
            ~ ( token.EndsBlock ? "}" : "" )
            ~ ( token.IsIndented ? "^" : "" )
            ~ "\n";
    }

    // ~~

    string GetTokenArrayDump()
    {
        int
            token_index;
        string
            token_array_dump;

        token_array_dump = "";

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token_array_dump ~= GetTokenDump( token_index );
        }

        return token_array_dump;
    }

    // ~~

    void AddToken()
    {
        Token = new TOKEN( "", Context.LanguageType, Context.TokenType, this );
        TokenArray ~= Token;
        TokenIsSplit = false;
    }

    // ~~

    void BeginToken(
        TOKEN_TYPE token_type
        )
    {
        Token = null;
        Context.TokenType = token_type;
    }

    // ~~

    void AddTokenCharacter(
        char token_character
        )
    {
        if ( Token is null
             || TokenIsSplit )
        {
            AddToken();
        }

        Token.Text ~= token_character;
        ++TokenCharacterIndex;
    }

    // ~~

    void EndToken()
    {
        Token = null;
        Context.TokenType = TOKEN_TYPE.None;
    }

    // ~~

    bool SetFileText(
        string file_text,
        string file_path
        )
    {
        char
            character,
            character_2,
            character_3,
            character_4,
            character_5,
            character_6,
            character_7,
            character_8,
            character_9,
            prior_character;
        int
            character_count,
            closing_tag_token_index,
            element_count,
            opening_tag_token_index;
        string
            tag_name;

        file_text = file_text.replace( "\t", "    " ).replace( "\r", "" );

        FileExtension = ( file_path.indexOf( "." ) >= 0 ) ? file_path.extension() : "";
        FileLanguageType = GetFileLanguageType( FileExtension );
        LineCharacterIndex = 0;
        LineIndex = 0;
        TokenArray = [];
        TokenIsSplit = false;

        if ( FileLanguageType == LANGUAGE_TYPE.None )
        {
            return false;
        }
        else if ( FileLanguageType == LANGUAGE_TYPE.Php )
        {
            BaseContext = new CONTEXT( LANGUAGE_TYPE.Html );
            PhpContext = new CONTEXT( LANGUAGE_TYPE.Php );
        }
        else
        {
            BaseContext = new CONTEXT( FileLanguageType );
            PhpContext = null;
        }

        Context = BaseContext;

        EndToken();

        character_count = file_text.length.to!int();
        element_count = 0;
        opening_tag_token_index = -1;
        closing_tag_token_index = -1;

        TokenCharacterIndex = 0;

        while ( TokenCharacterIndex < character_count )
        {
            prior_character = ( TokenCharacterIndex - 1 >= 0 ) ? file_text[ TokenCharacterIndex - 1 ] : 0;
            character = file_text[ TokenCharacterIndex ];
            character_2 = ( TokenCharacterIndex + 1 < character_count ) ? file_text[ TokenCharacterIndex + 1 ] : 0;
            character_3 = ( TokenCharacterIndex + 2 < character_count ) ? file_text[ TokenCharacterIndex + 2 ] : 0;
            character_4 = ( TokenCharacterIndex + 3 < character_count ) ? file_text[ TokenCharacterIndex + 3 ] : 0;
            character_5 = ( TokenCharacterIndex + 4 < character_count ) ? file_text[ TokenCharacterIndex + 4 ] : 0;
            character_6 = ( TokenCharacterIndex + 5 < character_count ) ? file_text[ TokenCharacterIndex + 5 ] : 0;
            character_7 = ( TokenCharacterIndex + 6 < character_count ) ? file_text[ TokenCharacterIndex + 6 ] : 0;
            character_8 = ( TokenCharacterIndex + 7 < character_count ) ? file_text[ TokenCharacterIndex + 7 ] : 0;
            character_9 = ( TokenCharacterIndex + 8 < character_count ) ? file_text[ TokenCharacterIndex + 8 ] : 0;

            if ( character == ' '
                 || character == '\n' )
            {
                ++TokenCharacterIndex;

                if ( character == '\n' )
                {
                    if ( Context.TokenType == TOKEN_TYPE.ShortComment
                         || ( ( Context.TokenType == TOKEN_TYPE.CharacterLiteral
                                || Context.TokenType == TOKEN_TYPE.StringLiteral
                                || Context.TokenType == TOKEN_TYPE.TextLiteral )
                              && Context.LanguageType <= LANGUAGE_TYPE.Php )
                         || ( Context.TokenType == TOKEN_TYPE.RegularExpressionLiteral
                              && Context.LanguageType == LANGUAGE_TYPE.Js ) )
                    {
                        EndToken();
                    }
                    else if ( Context.TokenType == TOKEN_TYPE.Command )
                    {
                        EndToken();

                        if ( prior_character == '\\' )
                        {
                            BeginToken( TOKEN_TYPE.Command );
                        }
                    }

                    ++LineIndex;
                    LineCharacterIndex = TokenCharacterIndex;
                }

                if ( character == ' '
                     && Context.TokenType == TOKEN_TYPE.Command )
                {
                    if ( Token !is null )
                    {
                        Token.Text ~= " ";
                    }
                }
                else
                {
                    TokenIsSplit = true;
                }
            }
            else if ( FileLanguageType == LANGUAGE_TYPE.Php
                      && character == '<'
                      && character_2 == '?'
                      && character_3 == 'p'
                      && character_4 == 'h'
                      && character_5 == 'p'
                      && Context.LanguageType != LANGUAGE_TYPE.Php )
            {
                Context = PhpContext;

                BeginToken( TOKEN_TYPE.BeginDeclaration );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                BeginToken( TOKEN_TYPE.Identifier );
                AddTokenCharacter( character_3 );
                AddTokenCharacter( character_4 );
                AddTokenCharacter( character_5 );
                EndToken();
            }
            else if ( Context.TokenType == TOKEN_TYPE.ShortComment )
            {
                AddTokenCharacter( character );
            }
            else if ( Context.TokenType == TOKEN_TYPE.LongComment )
            {
                if ( character == '-'
                     && character_2 == '-'
                     && character_3 == '>'
                     && Context.LanguageType == LANGUAGE_TYPE.Html )
                {
                    BeginToken( TOKEN_TYPE.EndLongComment );
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                    AddTokenCharacter( character_3 );
                    EndToken();
                }
                else if ( character == '*'
                          && character_2 == '/'
                          && Context.LanguageType >= LANGUAGE_TYPE.Css )
                {
                    BeginToken( TOKEN_TYPE.EndLongComment );
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                    EndToken();
                }
                else
                {
                    AddTokenCharacter( character );
                }
            }
            else if ( Context.TokenType == TOKEN_TYPE.RegularExpressionLiteral )
            {
                AddTokenCharacter( character );

                if ( character == '\\' )
                {
                    AddTokenCharacter( character_2 );
                }
                else if ( character == '/' )
                {
                    EndToken();
                }
            }
            else if ( Context.TokenType == TOKEN_TYPE.CharacterLiteral )
            {
                if ( character == '\'' )
                {
                    BeginToken( TOKEN_TYPE.EndCharacterLiteral );
                    AddTokenCharacter( character );
                    EndToken();
                }
                else if ( character == '\\' )
                {
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                }
                else
                {
                    AddTokenCharacter( character );
                }
            }
            else if ( Context.TokenType == TOKEN_TYPE.StringLiteral )
            {
                if ( character == '\"' )
                {
                    BeginToken( TOKEN_TYPE.EndStringLiteral );
                    AddTokenCharacter( character );
                    EndToken();
                }
                else if ( character == '\\' )
                {
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                }
                else
                {
                    AddTokenCharacter( character );
                }
            }
            else if ( Context.TokenType == TOKEN_TYPE.TextLiteral )
            {
                if ( character == '`' )
                {
                    BeginToken( TOKEN_TYPE.EndStringLiteral );
                    AddTokenCharacter( character );
                    EndToken();
                }
                else if ( character == '\\' )
                {
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                }
                else
                {
                    AddTokenCharacter( character );
                }
            }
            else if ( Context.TokenType == TOKEN_TYPE.Command )
            {
                AddTokenCharacter( character );
            }
            else if ( character == '?'
                      && character_2 == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Php )
            {
                BeginToken( TOKEN_TYPE.EndDeclaration );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                Context = BaseContext;
            }
            else if ( character == '/'
                      && character_2 == '/'
                      && Context.LanguageType >= LANGUAGE_TYPE.Css )
            {
                BeginToken( TOKEN_TYPE.BeginShortComment );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                BeginToken( TOKEN_TYPE.ShortComment );
            }
            else if ( character == '<'
                      && character_2 == '!'
                      && character_3 == '-'
                      && character_4 == '-'
                      && Context.LanguageType == LANGUAGE_TYPE.Html )
            {
                if ( character_5 == '='
                     || character_5 == '#'
                     || character_5 == '.' )
                {
                    BeginToken( TOKEN_TYPE.BeginOpeningTag );
                    AddTokenCharacter( character );
                    EndToken();

                    BeginToken( TOKEN_TYPE.Identifier );

                    while ( TokenCharacterIndex < character_count )
                    {
                        character = file_text[ TokenCharacterIndex ];
                        character_2 = ( TokenCharacterIndex + 1 < character_count ) ? file_text[ TokenCharacterIndex + 1 ] : 0;

                        if ( character_2 != 0
                             && character_2 != '\n' )
                        {
                            AddTokenCharacter( character );
                        }
                        else
                        {
                            break;
                        }
                    }
                    EndToken();

                    BeginToken( TOKEN_TYPE.EndOpeningTag );
                    AddTokenCharacter( character );
                    EndToken();

                    Context.LanguageType = LANGUAGE_TYPE.Css;
                }
                else
                {
                    BeginToken( TOKEN_TYPE.BeginLongComment );
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                    AddTokenCharacter( character_3 );
                    AddTokenCharacter( character_4 );
                    EndToken();

                    BeginToken( TOKEN_TYPE.LongComment );
                }
            }
            else if ( character == '/'
                      && character_2 == '*'
                      && Context.LanguageType >= LANGUAGE_TYPE.Css )
            {
                BeginToken( TOKEN_TYPE.BeginLongComment );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                BeginToken( TOKEN_TYPE.LongComment );
            }
            else if ( character == '/'
                      && Context.LanguageType == LANGUAGE_TYPE.Js
                      && IsLastTokenPrecedingRegularExpression() )
            {
                BeginToken( TOKEN_TYPE.RegularExpressionLiteral );
                AddTokenCharacter( character );
            }

            else if ( character == '\''
                      && ( Context.LanguageType >= LANGUAGE_TYPE.Css
                           || opening_tag_token_index != -1 ) )
            {
                BeginToken( TOKEN_TYPE.BeginCharacterLiteral );
                AddTokenCharacter( character );
                EndToken();

                BeginToken( TOKEN_TYPE.CharacterLiteral );
            }
            else if ( character == '\"'
                      && ( Context.LanguageType >= LANGUAGE_TYPE.Css
                           || opening_tag_token_index != -1 ) )
            {
                BeginToken( TOKEN_TYPE.BeginStringLiteral );
                AddTokenCharacter( character );
                EndToken();

                BeginToken( TOKEN_TYPE.StringLiteral );
            }
            else if ( character == '`'
                      && ( Context.LanguageType >= LANGUAGE_TYPE.Css
                           || opening_tag_token_index != -1 ) )
            {
                BeginToken( TOKEN_TYPE.BeginTextLiteral );
                AddTokenCharacter( character );
                EndToken();

                BeginToken( TOKEN_TYPE.TextLiteral );
            }
            else if ( character == '#'
                      && Context.LanguageType == LANGUAGE_TYPE.Cpp
                      && StartsLine( file_text, TokenCharacterIndex ) )
            {
                BeginToken( TOKEN_TYPE.Command );
                AddTokenCharacter( character );
            }
            else if ( character == '<'
                      && character_2 == '?'
                      && Context.LanguageType == LANGUAGE_TYPE.Html )
            {
                BeginToken( TOKEN_TYPE.BeginDeclaration );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();
            }
            else if ( character == '?'
                      && character_2 == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Html )
            {
                BeginToken( TOKEN_TYPE.EndDeclaration );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();
            }
            else if ( character == '<'
                      && character_2 == '!'
                      && Context.LanguageType == LANGUAGE_TYPE.Html )
            {
                BeginToken( TOKEN_TYPE.BeginElement );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                ++element_count;
            }
            else if ( character == '>'
                      && element_count > 0
                      && Context.LanguageType == LANGUAGE_TYPE.Html )
            {
                BeginToken( TOKEN_TYPE.EndElement );
                AddTokenCharacter( character );
                EndToken();

                --element_count;
            }
            else if ( character == '<'
                      && IsAlphabeticalCharacter( character_2 )
                      && Context.LanguageType == LANGUAGE_TYPE.Html
                      && opening_tag_token_index == -1
                      && closing_tag_token_index == -1 )
            {
                BeginToken( TOKEN_TYPE.BeginOpeningTag );
                AddTokenCharacter( character );
                EndToken();

                opening_tag_token_index = TokenArray.length.to!int();
            }
            else if ( character == '/'
                      && character_2 == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Html
                      && opening_tag_token_index != -1 )
            {
                BeginToken( TOKEN_TYPE.CloseOpeningTag );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                opening_tag_token_index = -1;
            }
            else if ( character == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Html
                      && opening_tag_token_index != -1 )
            {
                BeginToken( TOKEN_TYPE.EndOpeningTag );
                AddTokenCharacter( character );
                EndToken();

                tag_name = TokenArray[ opening_tag_token_index ].Text;

                if ( tag_name == "style" )
                {
                    Context.LanguageType = LANGUAGE_TYPE.Css;
                }
                else if ( tag_name == "script" )
                {
                    Context.LanguageType = LANGUAGE_TYPE.Js;
                }

                opening_tag_token_index = -1;
            }
            else if ( character == '<'
                      && character_2 == '/'
                      && IsAlphabeticalCharacter( character_3 )
                      && Context.LanguageType == LANGUAGE_TYPE.Html
                      && opening_tag_token_index == -1
                      && closing_tag_token_index == -1 )
            {
                BeginToken( TOKEN_TYPE.BeginClosingTag );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                closing_tag_token_index = TokenArray.length.to!int();
            }
            else if ( character == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Html
                      && closing_tag_token_index != -1 )
            {
                BeginToken( TOKEN_TYPE.EndClosingTag );
                AddTokenCharacter( character );
                EndToken();

                closing_tag_token_index = -1;
            }
            else if ( ( character == '='
                        || character == '#'
                        || character == '.' )
                      && character_2 == '-'
                      && character_3 == '-'
                      && character_4 == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Css )
            {
                Context.LanguageType = LANGUAGE_TYPE.Html;

                BeginToken( TOKEN_TYPE.BeginClosingTag );
                AddTokenCharacter( character );
                EndToken();

                BeginToken( TOKEN_TYPE.Identifier );
                AddTokenCharacter( character_2 );
                AddTokenCharacter( character_3 );
                EndToken();

                BeginToken( TOKEN_TYPE.EndClosingTag );
                AddTokenCharacter( character_4 );
                EndToken();
            }
            else if ( character == '<'
                      && character_2 == '/'
                      && character_3 == 's'
                      && character_4 == 't'
                      && character_5 == 'y'
                      && character_6 == 'l'
                      && character_7 == 'e'
                      && character_8 == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Css )
            {
                Context.LanguageType = LANGUAGE_TYPE.Html;

                BeginToken( TOKEN_TYPE.BeginClosingTag );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                BeginToken( TOKEN_TYPE.Identifier );
                AddTokenCharacter( character_3 );
                AddTokenCharacter( character_4 );
                AddTokenCharacter( character_5 );
                AddTokenCharacter( character_6 );
                AddTokenCharacter( character_7 );
                EndToken();

                BeginToken( TOKEN_TYPE.EndClosingTag );
                AddTokenCharacter( character_8 );
                EndToken();
            }
            else if ( character == '<'
                      && character_2 == '/'
                      && character_3 == 's'
                      && character_4 == 'c'
                      && character_5 == 'r'
                      && character_6 == 'i'
                      && character_7 == 'p'
                      && character_8 == 't'
                      && character_9 == '>'
                      && Context.LanguageType == LANGUAGE_TYPE.Js )
            {
                Context.LanguageType = LANGUAGE_TYPE.Html;

                BeginToken( TOKEN_TYPE.BeginClosingTag );
                AddTokenCharacter( character );
                AddTokenCharacter( character_2 );
                EndToken();

                BeginToken( TOKEN_TYPE.Identifier );
                AddTokenCharacter( character_3 );
                AddTokenCharacter( character_4 );
                AddTokenCharacter( character_5 );
                AddTokenCharacter( character_6 );
                AddTokenCharacter( character_7 );
                AddTokenCharacter( character_8 );
                EndToken();

                BeginToken( TOKEN_TYPE.EndClosingTag );
                AddTokenCharacter( character_9 );
                EndToken();
            }
            else if ( IsNumberCharacter( character, prior_character, character_2 )
                      && Context.TokenType == TOKEN_TYPE.Number )
            {
                AddTokenCharacter( character );
            }
            else if ( IsIdentifierCharacter( character )
                      && Context.TokenType == TOKEN_TYPE.Identifier )
            {
                AddTokenCharacter( character );
            }
            else if ( character >= '0' && character <= '9' )
            {
                BeginToken( TOKEN_TYPE.Number );
                AddTokenCharacter( character );
            }
            else if ( IsIdentifierCharacter( character ) )
            {
                BeginToken( TOKEN_TYPE.Identifier );
                AddTokenCharacter( character );
            }
            else if ( IsOperatorCharacter( character )
                      && Context.TokenType == TOKEN_TYPE.Operator )
            {
                AddTokenCharacter( character );

                if ( ( character_2 == '-'
                       || character_2 == '~'
                       || character_2 == '!' )
                     && Context.LanguageType != LANGUAGE_TYPE.Gs )
                {
                    EndToken();
                }
            }
            else if ( IsOperatorCharacter( character ) )
            {
                BeginToken( TOKEN_TYPE.Operator );
                AddTokenCharacter( character );

                if ( ( ( character_2 == '-' && character != '-' )
                       || character_2 == '~'
                       || character_2 == '!' )
                     && Context.LanguageType != LANGUAGE_TYPE.Gs )
                {
                    EndToken();
                }
            }
            else if ( IsSeparatorCharacter( character ) )
            {
                if ( character == ':'
                     && ( character_2 == ':'
                          || character_2 == '=' ) )
                {
                    BeginToken( TOKEN_TYPE.Operator );
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                    EndToken();
                }
                else if ( character == '{'
                          && character_2 == '}' )
                {
                    BeginToken( TOKEN_TYPE.Separator );
                    AddTokenCharacter( character );
                    AddTokenCharacter( character_2 );
                    EndToken();
                }
                else
                {
                    BeginToken( TOKEN_TYPE.Separator );
                    AddTokenCharacter( character );
                    EndToken();
                }
            }
            else
            {
                BeginToken( TOKEN_TYPE.Special );
                AddTokenCharacter( character );
                EndToken();
            }
        }

        return true;
    }

    // ~~

    bool BeginsOpeningTag(
        int token_index,
        string[] tag_name_array
        )
    {
        return (
            TokenArray[ token_index ].Type == TOKEN_TYPE.BeginOpeningTag
            && token_index + 1 < TokenArray.length
            && tag_name_array.countUntil( TokenArray[ token_index + 1 ].Text ) >= 0
            );
    }

    // ~~

    bool BeginsClosingTag(
        int token_index,
        string[] tag_name_array
        )
    {
        return (
            TokenArray[ token_index ].Type == TOKEN_TYPE.BeginClosingTag
            && token_index + 1 < TokenArray.length
            && tag_name_array.countUntil( TokenArray[ token_index + 1 ].Text ) >= 0
            );
    }

    // ~~

    bool EndsOpeningTag(
        int token_index,
        string[] tag_name_array
        )
    {
        TOKEN
            token;

        if ( TokenArray[ token_index ].Type == TOKEN_TYPE.EndOpeningTag )
        {
            while ( --token_index >= 0 )
            {
                token = TokenArray[ token_index ];

                if ( token.Type == TOKEN_TYPE.BeginOpeningTag )
                {
                    return tag_name_array.countUntil( TokenArray[ token_index + 1 ].Text ) >= 0;
                }
            }
        }

        return false;
    }

    // ~~

    bool EndsClosingTag(
        int token_index,
        string[] tag_name_array
        )
    {
        TOKEN
            token;

        if ( TokenArray[ token_index ].Type == TOKEN_TYPE.EndClosingTag )
        {
            while ( --token_index >= 0 )
            {
                token = TokenArray[ token_index ];

                if ( token.Type == TOKEN_TYPE.BeginClosingTag )
                {
                    return tag_name_array.countUntil( TokenArray[ token_index + 1 ].Text ) >= 0;
                }
            }
        }

        return false;
    }

    // ~~

    bool ClosesOpeningTag(
        int token_index,
        string[] tag_name_array
        )
    {
        TOKEN
            token;

        if ( TokenArray[ token_index ].Type == TOKEN_TYPE.CloseOpeningTag )
        {
            while ( --token_index >= 0 )
            {
                token = TokenArray[ token_index ];

                if ( token.Type == TOKEN_TYPE.BeginOpeningTag )
                {
                    return tag_name_array.countUntil( TokenArray[ token_index + 1 ].Text ) >= 0;
                }
            }
        }

        return false;
    }

    // ~~

    int GetNextTokenIndex(
        int token_index
        )
    {
        int
            next_token_index;
        LANGUAGE_TYPE
            language_type;
        TOKEN
            next_token;

        language_type = TokenArray[ token_index ].LanguageType;

        for ( next_token_index = token_index + 1;
              next_token_index < TokenArray.length;
              ++next_token_index )
        {
            next_token = TokenArray[ next_token_index ];

            if ( next_token.LanguageType == language_type
                 && ( next_token.Type < TOKEN_TYPE.BeginShortComment
                      || next_token.Type > TOKEN_TYPE.EndLongComment ) )
            {
                return next_token_index;
            }
        }

        return -1;
    }

    // ~~

    void SetNextStatement(
        int token_index
        )
    {
        int
            next_token_index;
        TOKEN
            next_token;

        for ( next_token_index = token_index + 1;
              next_token_index < TokenArray.length;
              ++next_token_index )
        {
            next_token = TokenArray[ next_token_index ];

            if ( next_token.Type >= TOKEN_TYPE.BeginShortComment
                 && next_token.Type <= TOKEN_TYPE.EndLongComment )
            {
                if ( next_token.Type == TOKEN_TYPE.BeginShortComment
                     || next_token.Type == TOKEN_TYPE.BeginLongComment )
                {
                    next_token.BeginsStatement = true;
                }
            }
            else
            {
                next_token.BeginsStatement = true;

                return;
            }
        }
    }

    // ~~

    int FindMatchingSeparatorTokenIndex(
        int separator_token_index
        )
    {
        int
            level,
            prior_token_index,
            token_index;
        LANGUAGE_TYPE
            separator_language_type;
        TOKEN
            prior_token,
            separator_token,
            token;

        separator_token = TokenArray[ separator_token_index ];

        if ( separator_token.Type == TOKEN_TYPE.Separator )
        {
            separator_language_type = separator_token.LanguageType;

            if ( separator_token.Text == "." )
            {
                level = 0;

                for ( token_index = separator_token_index - 1;
                      token_index >= 0;
                      --token_index )
                {
                    token = TokenArray[ token_index ];

                    if ( token.LanguageType == separator_language_type )
                    {
                        if ( token.Type == TOKEN_TYPE.Separator
                             && token.Text == "."
                             && level == 0 )
                        {
                            if ( !token.BeginsLine )
                            {
                                for ( prior_token_index = token_index - 1;
                                      prior_token_index >= 0;
                                      --prior_token_index )
                                {
                                    prior_token = TokenArray[ prior_token_index ];

                                    if ( prior_token.BeginsLine )
                                    {
                                        if ( prior_token.Type == TOKEN_TYPE.Separator
                                             && prior_token.Text == "." )
                                        {
                                            return prior_token_index;
                                        }

                                        break;
                                    }
                                }
                            }

                            return token_index;
                        }
                        else if ( token.Type == TOKEN_TYPE.Separator
                                  && ( token.Text == ")"
                                       || token.Text == "}" ) )
                        {
                            ++level;
                        }
                        else if ( token.Type == TOKEN_TYPE.Separator
                                  && ( token.Text == "("
                                       || token.Text == "{" ) )
                        {
                            --level;

                            if ( level < 0 )
                            {
                                return -1;
                            }
                        }
                        else if ( token.BeginsLine
                                  && ( token.Type < TOKEN_TYPE.BeginShortComment
                                       || token.Type > TOKEN_TYPE.EndLongComment )
                                  && level == 0 )
                        {
                            return token_index;
                        }
                    }
                }

                return -1;
            }
        }

        return -1;
    }

    // ~~

    void SetPriorSpaceCount(
        )
    {
        int
            token_index;
        TOKEN
            prior_token,
            token;

        prior_token = null;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];

            token.BeginsLine = ( token_index == 0 || token.LineIndex > prior_token.LineIndex );
            token.PriorSpaceCount = token.ColumnIndex;

            if ( !token.BeginsLine )
            {
                token.PriorSpaceCount -= prior_token.ColumnIndex + prior_token.Text.length;
            }

            prior_token = token;
        }
    }

    // ~~

    void SetBaseColumnIndex(
        )
    {
        int
            token_index;
        TOKEN
            prior_token,
            token;

        prior_token = null;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];

            token.BaseColumnIndex = token.PriorSpaceCount;

            if ( !token.BeginsLine )
            {
                token.BaseColumnIndex += prior_token.BaseColumnIndex + prior_token.Text.length;
            }

            prior_token = token;
        }
    }

    // ~~

    void SetTokenText(
        int token_index,
        string token_text,
        int next_space_count = -1
        )
    {
        TokenArray[ token_index ].Text = token_text;

        if ( next_space_count != -1
             && token_index + 1 < TokenArray.length )
        {
            TokenArray[ token_index + 1 ].PriorSpaceCount = next_space_count;
        }
    }

    // ~~

    void AddLines(
        )
    {
        int
            line_offset,
            token_index;
        TOKEN
            next_token,
            token;
        string[]
            inline_tag_name_array = [ "em", "span", "strong", "sub", "sup" ],
            inlined_tag_name_array = [ "em", "span", "strong", "sub", "sup", "textarea" ];

        line_offset = 0;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];
            token.LineIndex += line_offset;

            if ( token_index + 1 < TokenArray.length )
            {
                next_token = TokenArray[ token_index + 1 ];

                if ( token.LineIndex == next_token.LineIndex + line_offset
                     && ( ( token.LanguageType == LANGUAGE_TYPE.Html
                            && ( token.Type == TOKEN_TYPE.EndElement
                                 || ( token.Type == TOKEN_TYPE.EndOpeningTag
                                      && !EndsOpeningTag( token_index, inlined_tag_name_array ) )
                                 || ( token.Type == TOKEN_TYPE.CloseOpeningTag
                                      && !ClosesOpeningTag( token_index, inline_tag_name_array ) )
                                 || ( token.Type == TOKEN_TYPE.EndClosingTag
                                      && !EndsClosingTag(
                                             token_index,
                                             inline_tag_name_array
                                             ) ) ) )
                          || ( next_token.LanguageType == LANGUAGE_TYPE.Html
                               && ( next_token.Type == TOKEN_TYPE.BeginElement
                                    || ( next_token.Type == TOKEN_TYPE.BeginOpeningTag
                                         && !BeginsOpeningTag( token_index + 1, inline_tag_name_array ) )
                                    || ( next_token.Type == TOKEN_TYPE.BeginClosingTag
                                         && !BeginsClosingTag( token_index + 1, inlined_tag_name_array ) ) ) )
                          || ( ( token.LanguageType >= LANGUAGE_TYPE.Css
                                 && token.LanguageType < LANGUAGE_TYPE.Php )
                               && token.Type == TOKEN_TYPE.Separator
                               && ( token.Text == "{"
                                    || ( token.Text == "}"
                                         && ( next_token.Text != ","
                                              && next_token.Text != ";" ) )
                                    || ( token.Text == ";"
                                         && ( next_token.Type != TOKEN_TYPE.BeginShortComment
                                              && next_token.Type != TOKEN_TYPE.BeginLongComment ) ) ) )
                          || ( ( next_token.LanguageType >= LANGUAGE_TYPE.Css
                                 && next_token.LanguageType < LANGUAGE_TYPE.Php )
                               && next_token.Type == TOKEN_TYPE.Separator
                               && ( next_token.Text == "{"
                                    || next_token.Text == "}" ) ) ) )
                {
                    ++line_offset;
                }
            }
        }
    }

    // ~~

    void FindStatements(
        )
    {
        int
            line_index,
            token_index;
        TOKEN
            next_token,
            prior_token,
            token;

        line_index = -1;

        SetNextStatement( -1 );

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            prior_token = ( token_index - 1 >= 0 ) ? TokenArray[ token_index - 1 ] : null;
            token = TokenArray[ token_index ];
            next_token = ( token_index + 1 < TokenArray.length ) ? TokenArray[ token_index + 1 ] : null;

            if ( token.LineIndex > line_index )
            {
                token.BeginsLine = true;
                line_index = token.LineIndex;
            }

            if ( token.Type == TOKEN_TYPE.BeginDeclaration
                 || token.Type == TOKEN_TYPE.BeginElement )
            {
                token.BeginsStatement = true;
                token.BeginsBlock = true;
                SetNextStatement( token_index + 1 );
            }
            else if ( token.Type == TOKEN_TYPE.EndDeclaration
                      || token.Type == TOKEN_TYPE.EndElement )
            {
                token.EndsBlock = true;
                SetNextStatement( token_index );
            }
            else if ( token.Type == TOKEN_TYPE.BeginOpeningTag )
            {
                token.BeginsStatement = true;
            }
            else if ( token.Type == TOKEN_TYPE.EndOpeningTag )
            {
                token.BeginsBlock = true;
                SetNextStatement( token_index );
            }
            if ( token.Type == TOKEN_TYPE.BeginOpeningTag )
            {
                token.BeginsStatement = true;
            }
            else if ( token.Type == TOKEN_TYPE.EndOpeningTag )
            {
                token.BeginsBlock = true;
                SetNextStatement( token_index );
            }
            else if ( token.Type == TOKEN_TYPE.CloseOpeningTag )
            {
                SetNextStatement( token_index );
            }
            else if ( token.Type == TOKEN_TYPE.BeginClosingTag )
            {
                token.BeginsStatement = true;
                token.EndsBlock = true;
            }
            else if ( token.Type == TOKEN_TYPE.EndClosingTag )
            {
                SetNextStatement( token_index );
            }
            else if ( token.Type == TOKEN_TYPE.CloseOpeningTag )
            {
                token.EndsBlock = true;
                SetNextStatement( token_index );
            }
            else if ( token.Type == TOKEN_TYPE.Command )
            {
                if ( token.Text.startsWith( "#if" )
                     || ( token.Text.startsWith( "#define" )
                          && IsGpFileExtension( FileExtension ) ) )
                {
                    token.BeginsBlock= true;
                }
                else if ( token.Text.startsWith( "#end" ) )
                {
                    token.EndsBlock= true;
                }

                if ( prior_token is null
                     || !( prior_token.Type == TOKEN_TYPE.Command
                           && prior_token.Text.endsWith( "\\" ) ) )
                {
                    token.BeginsStatement = true;
                }

                if ( next_token !is null
                     && token.Text.endsWith( "\\" ) )
                {
                    next_token.BeginsStatement = true;
                }
            }
            else if ( token.LanguageType >= LANGUAGE_TYPE.Css )
            {
                if ( token.Type == TOKEN_TYPE.Separator )
                {
                    if ( token.Text == "{" )
                    {
                        token.BeginsStatement = true;
                        token.BeginsBlock = true;
                        SetNextStatement( token_index );
                    }
                    else if ( token.Text == ";" )
                    {
                        SetNextStatement( token_index );
                    }
                    else if ( token.Text == "}" )
                    {
                        token.BeginsStatement = true;
                        token.EndsBlock = true;
                        SetNextStatement( token_index );
                    }
                }
            }
        }

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];
            next_token = ( token_index + 1 < TokenArray.length ) ? TokenArray[ token_index + 1 ] : null;

            if ( next_token is null
                 || next_token.BeginsLine )
            {
                token.EndsLine = true;
            }

            if ( next_token is null
                 || next_token.BeginsStatement )
            {
                token.EndsStatement = true;
            }
        }
    }

    // ~~

    void IndentLines(
        )
    {
        int
            base_token_index,
            statement_token_index,
            token_index;
        TOKEN
            token;

        for ( token_index = 1;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];

            if ( !token.BeginsLine )
            {
                token.BaseTokenIndex = token_index - 1;
                token.BaseColumnOffset = token.ColumnIndex - TokenArray[ token_index - 1 ].ColumnIndex;
            }
        }

        statement_token_index = -1;
        base_token_index = -1;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];

            if ( token.BeginsStatement )
            {
                statement_token_index = token_index;
            }

            if ( token.BeginsLine )
            {
                if ( statement_token_index != -1 )
                {
                    token.BaseTokenIndex = -1;
                    token.BaseColumnOffset = 0;
                    token.IsIndented = true;

                    base_token_index = token_index;
                    statement_token_index = -1;
                }
                else if ( base_token_index != -1
                          && token.BaseTokenIndex == -1 )
                {
                    token.BaseTokenIndex = base_token_index;
                    token.BaseColumnOffset = token.ColumnIndex - TokenArray[ base_token_index ].ColumnIndex;

                    if ( token.BaseColumnOffset < 0 )
                    {
                        token.BaseColumnOffset = 0;
                    }
                }
            }

            if ( token.EndsStatement )
            {
                base_token_index = -1;
            }
        }
    }

    // ~~

    void IndentStrings(
        )
    {
        int
            next_token_index,
            token_index;
        TOKEN
            next_token,
            token;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];

            if ( token.LanguageType == LANGUAGE_TYPE.Php
                 && ( token.Type == TOKEN_TYPE.BeginCharacterLiteral
                      || token.Type == TOKEN_TYPE.BeginStringLiteral
                      || token.Type == TOKEN_TYPE.BeginTextLiteral ) )
            {
                for ( next_token_index = token_index + 1;
                      next_token_index < TokenArray.length;
                      ++next_token_index )
                {
                    next_token = TokenArray[ next_token_index ];

                    if ( ( token.Type == TOKEN_TYPE.BeginCharacterLiteral
                           && ( next_token.Type == TOKEN_TYPE.CharacterLiteral
                                || next_token.Type == TOKEN_TYPE.EndCharacterLiteral ) )
                         || ( token.Type == TOKEN_TYPE.BeginStringLiteral
                              && ( next_token.Type == TOKEN_TYPE.StringLiteral
                                   || next_token.Type == TOKEN_TYPE.EndStringLiteral ) )
                         || ( token.Type == TOKEN_TYPE.BeginTextLiteral
                              && ( next_token.Type == TOKEN_TYPE.TextLiteral
                                   || next_token.Type == TOKEN_TYPE.EndTextLiteral ) ) )
                    {
                        if ( next_token.BeginsLine )
                        {
                            next_token.BaseTokenIndex = token_index;
                            next_token.BaseColumnOffset = next_token.ColumnIndex - TokenArray[ token_index ].ColumnIndex;

                            if ( next_token.BaseColumnOffset < 1 )
                            {
                                next_token.BaseColumnOffset = 1;
                            }
                        }
                    }
                    else
                    {
                        break;
                    }
                }

                token_index = next_token_index - 1;
            }
        }
    }

    // ~~

    void AddSpaces(
        )
    {
        int
            token_index;
        TOKEN
            next_token,
            prior_token,
            token;

        for ( token_index = 0;
              token_index < TokenArray.length - 1;
              ++token_index )
        {
            prior_token = ( token_index > 0 ) ? TokenArray[ token_index - 1 ] : null;
            token = TokenArray[ token_index ];
            next_token = TokenArray[ token_index + 1 ];

            if ( token.LanguageType >= LANGUAGE_TYPE.Css
                 && next_token.LanguageType >= LANGUAGE_TYPE.Css
                 && token.LineIndex == next_token.LineIndex
                 && next_token.BaseTokenIndex == token_index )
            {
                if ( next_token.Type == TOKEN_TYPE.BeginShortComment
                     || next_token.Type == TOKEN_TYPE.BeginLongComment )
                {
                    next_token.BaseColumnOffset = ( token.Text.length + 4 ).to!int();
                }
                else if ( ( token.Type == TOKEN_TYPE.Separator
                            && ( ( token.Text == "{" && next_token.Text != "}" )
                                 || ( token.Text == "[" && next_token.Text != "]" )
                                 || ( token.Text == "(" && next_token.Text != ")" )
                                 || token.Text == ";"
                                 || token.Text == ","
                                 || ( token.Text == ":" && token.LanguageType > LANGUAGE_TYPE.Css ) ) )
                          || ( next_token.Type == TOKEN_TYPE.Separator
                               && ( ( next_token.Text == "}" && token.Text != "{" )
                                    || ( next_token.Text == "]" && token.Text != "[" )
                                    || ( next_token.Text == ")" && token.Text != "(" )
                                    || ( next_token.Text == ":" && token.LanguageType > LANGUAGE_TYPE.Css ) ) )
                          || ( token.LanguageType > LANGUAGE_TYPE.Css
                               && next_token.LanguageType > LANGUAGE_TYPE.Css
                               && ( ( token.Type == TOKEN_TYPE.Operator
                                      && next_token.Type != TOKEN_TYPE.Operator
                                      && next_token.Type != TOKEN_TYPE.Separator
                                      && token.Text != "#"
                                      && token.Text != "~"
                                      && token.Text != "!"
                                      && token.Text != "-"
                                      && token.Text != "--"
                                      && token.Text != "++"
                                      && token.Text != "::"
                                      && token.Text != "->"
                                      && ( token.Text != "<" || token.LanguageType != LANGUAGE_TYPE.Cpp )
                                      && ( token.Text != ">" || token.LanguageType != LANGUAGE_TYPE.Cpp )
                                      && !( ( ( token.Text == "&"
                                                && ( token.LanguageType == LANGUAGE_TYPE.Cpp
                                                     || token.LanguageType == LANGUAGE_TYPE.Php ) )
                                              || ( token.Text == "*"
                                                   && token.LanguageType == LANGUAGE_TYPE.Cpp )
                                              || ( ( token.Text == "?"
                                                     || token.Text == "@" )
                                                   && token.LanguageType == LANGUAGE_TYPE.Gs ) )
                                            && ( next_token.Type == TOKEN_TYPE.Identifier
                                                 || next_token.Text == "("
                                                 || next_token.Text == "[" ) ) )
                                    || ( token.Type != TOKEN_TYPE.Operator
                                         && ( token.Text != "operator" || token.LanguageType != LANGUAGE_TYPE.Cpp )
                                         && next_token.Type == TOKEN_TYPE.Operator
                                         && next_token.Text != "--"
                                         && next_token.Text != "++"
                                         && next_token.Text != "::"
                                         && next_token.Text != "->"
                                         && ( next_token.Text != "<" || token.LanguageType != LANGUAGE_TYPE.Cpp )
                                         && ( next_token.Text != ">" || token.LanguageType != LANGUAGE_TYPE.Cpp ) )
                                    || ( token.Type == TOKEN_TYPE.Operator
                                         && next_token.Type == TOKEN_TYPE.Operator ) ) ) )
                {
                    next_token.BaseColumnOffset = ( token.Text.length + 1 ).to!int();
                }
            }
        }
    }

    // ~~

    void IndentBlocks(
        )
    {
        int
            base_token_index,
            column_index,
            line_token_index,
            matching_separator_token_index,
            next_column_index,
            next_token_index,
            separator_token_index,
            token_index;
        BLOCK
            block;
        BLOCK[]
            block_array;
        TOKEN
            next_token,
            prior_token,
            token;
        INDENTATION_TYPE
            base_indentation_type;

        void PushBlock(
            )
        {
            block_array
                ~= new BLOCK(
                       separator_token_index,
                       base_token_index,
                       base_indentation_type,
                       column_index
                       );
        }

        void PopBlock(
            )
        {
            separator_token_index = -1;
            base_token_index = -1;
            base_indentation_type = INDENTATION_TYPE.Tabulation;

            if ( block_array.length > 0 )
            {
                block = block_array[ $ - 1 ];
                block_array = block_array[ 0 .. $ - 1 ];
                separator_token_index = block.SeparatorTokenIndex;
                base_token_index = block.BaseTokenIndex;
                base_indentation_type = block.BaseIndentationType;
                column_index = block.ColumnIndex;
            }

            next_column_index = column_index;
        }

        block_array = [];
        line_token_index = 0;
        separator_token_index = -1;
        base_token_index = -1;
        base_indentation_type = INDENTATION_TYPE.Tabulation;
        column_index = 0;
        next_column_index = 0;

        token = null;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            prior_token = token;
            token = TokenArray[ token_index ];

            if ( token.BaseTokenIndex != -1
                 && TokenArray[ token.BaseTokenIndex ].BaseColumnIndex != -1 )
            {
                token.BaseColumnIndex = TokenArray[ token.BaseTokenIndex ].BaseColumnIndex + token.BaseColumnOffset;
            }

            if ( token.BeginsLine )
            {
                line_token_index = token_index;
            }

            if ( token.BeginsBlock )
            {
                PushBlock();

                separator_token_index = token_index;
                next_column_index += 4;

                if ( token.LanguageType > LANGUAGE_TYPE.Css
                     && token.Text == "{"
                     && token.BaseTokenIndex != -1 )
                {
                    next_column_index = token.BaseColumnIndex + 4;
                }
            }

            if ( token.EndsBlock )
            {
                PopBlock();
            }

            if ( token.IsIndented )
            {
                token.BaseColumnIndex = column_index;

                if ( token.LanguageType == LANGUAGE_TYPE.Php
                     && token.Type == TOKEN_TYPE.BeginDeclaration )
                {
                    for ( next_token_index = token_index + 2;
                          next_token_index < TokenArray.length
                          && TokenArray[ next_token_index ].Text == "}";
                          ++next_token_index )
                    {
                        token.BaseColumnIndex -= 4;
                    }
                }
            }

            if ( token.LanguageType > LANGUAGE_TYPE.Css )
            {
                if ( token.BeginsLine
                     && token.Type != TOKEN_TYPE.CharacterLiteral
                     && token.Type != TOKEN_TYPE.StringLiteral
                     && token.Type != TOKEN_TYPE.TextLiteral
                     && base_indentation_type > INDENTATION_TYPE.Tabulation
                     && token_index != base_token_index )
                {
                    token.BaseTokenIndex = base_token_index;

                    if ( base_indentation_type == INDENTATION_TYPE.NextColumn )
                    {
                        token.BaseColumnOffset = 2;
                    }
                    else
                    {
                        token.BaseColumnOffset = 0;
                    }

                    if ( token.BeginsBlock
                         && token.BaseTokenIndex != -1 )
                    {
                        next_column_index = TokenArray[ token.BaseTokenIndex ].BaseColumnIndex + token.BaseColumnOffset + 4;
                    }
                }

                if ( token.Type == TOKEN_TYPE.Separator )
                {
                    if ( token.Text == "("
                         || token.Text == "[" )
                    {
                        PushBlock();

                        separator_token_index = token_index;
                        next_token_index = GetNextTokenIndex( token_index );

                        if ( next_token_index != -1
                             && TokenArray[ next_token_index ].BeginsLine )
                        {
                            base_token_index = next_token_index;
                            base_indentation_type = INDENTATION_TYPE.NextLine;

                            next_token = TokenArray[ next_token_index ];
                            next_token.BaseTokenIndex = line_token_index;
                            next_token.BaseColumnOffset = next_token.ColumnIndex - TokenArray[ line_token_index ].ColumnIndex;

                            if ( next_token.BaseColumnOffset < 4 )
                            {
                                next_token.BaseColumnOffset = 4;
                            }

                            if ( token.BeginsLine )
                            {
                                base_indentation_type = INDENTATION_TYPE.SameColumn;
                            }
                        }
                        else
                        {
                            base_token_index = separator_token_index;
                            base_indentation_type = INDENTATION_TYPE.NextColumn;
                        }

                        next_column_index += 4;
                    }
                    else if ( token.Text == ")"
                              || token.Text == "]" )
                    {
                        if ( token.BeginsLine
                             && base_indentation_type == INDENTATION_TYPE.SameColumn )
                        {
                            token.BaseTokenIndex = separator_token_index;
                            token.BaseColumnOffset = 0;
                        }

                        PopBlock();
                    }
                    else if ( token.Text == "."
                              && token.BeginsLine
                              && token.LanguageType != LANGUAGE_TYPE.Php )
                    {
                        matching_separator_token_index = FindMatchingSeparatorTokenIndex( token_index );

                        if ( matching_separator_token_index != -1 )
                        {
                            token.BaseTokenIndex = matching_separator_token_index;

                            if ( TokenArray[ matching_separator_token_index ].Text == "." )
                            {
                                token.BaseColumnOffset = 0;
                            }
                            else
                            {
                                token.BaseColumnOffset = 4;
                            }
                        }
                    }
                }
            }

            if ( token.BeginsBlock )
            {
                separator_token_index = -1;
                base_token_index = -1;
                base_indentation_type = INDENTATION_TYPE.Tabulation;
            }

            column_index = next_column_index;

            if ( token.BaseTokenIndex != -1
                 && TokenArray[ token.BaseTokenIndex ].BaseColumnIndex != -1 )
            {
                token.BaseColumnIndex = TokenArray[ token.BaseTokenIndex ].BaseColumnIndex + token.BaseColumnOffset;
            }

            if ( token.Type == TOKEN_TYPE.Command )
            {
                if ( token.Text.startsWith( "#el" ) )
                {
                    token.BaseColumnIndex -= 4;
                }
            }
        }
    }

    // ~~

    void IndentTokenArray(
        )
    {
        AddLines();
        FindStatements();
        IndentLines();
        IndentStrings();
        AddSpaces();
        IndentBlocks();
    }

    // ~~

    string GetFileText(
        )
    {
        int
            column_index,
            line_index,
            token_index;
        string
            file_text;
        TOKEN
            token;

        file_text = "";
        line_index = 0;
        column_index = 0;

        for ( token_index = 0;
              token_index < TokenArray.length;
              ++token_index )
        {
            token = TokenArray[ token_index ];

            while ( token.LineIndex > line_index )
            {
                file_text ~= "\n";
                ++line_index;
                column_index = 0;
            }

            while ( column_index < token.BaseColumnIndex )
            {
                file_text ~= " ";
                ++column_index;
            }

            file_text ~= token.Text;
            column_index += token.Text.length;
        }

        file_text ~= "\n";

        return file_text;
    }

    // ~~

    string GetFixedFileText(
        string file_text,
        string file_path
        )
    {
        SetFileText( file_text, file_path );
        IndentTokenArray();

        return GetFileText();
    }
}

// -- VARIABLE

bool
    ItHasBackupFolder,
    ItHasOutputFolder;
string
    BackupFolderPath,
    OutputFolderPath;

// -- FUNCTIONS

// .. APPLICATION

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );
    
    exit( -1 );
}

// ~~

void FixFile(
    string file_path
    )
{
    string
        backup_file_path,
        file_text;
    CODE
        code;

    code = new CODE();

    writeln( "Reading file : ", file_path );

    file_text = file_path.readText();

    if ( ItHasBackupFolder )
    {
        backup_file_path = BackupFolderPath ~ file_path.baseName();

        writeln( "Copying file : ", backup_file_path );

        backup_file_path.write( file_text );
    }

    file_text = code.GetFixedFileText( file_text, file_path );

    if ( ItHasOutputFolder )
    {
        file_path = OutputFolderPath ~ file_path.baseName();
    }

    writeln( "Writing file : ", file_path );

    file_path.write( file_text );
}

// ~~

void FixFiles(
    string file_path_filter
    )
{
    writeln( "Fixing files : ", file_path_filter );

    foreach ( folder_entry; dirEntries( file_path_filter.dirName(), file_path_filter.baseName(), SpanMode.shallow ) )
    {
        if ( folder_entry.isFile() )
        {
            FixFile( folder_entry.name() );
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    bool
        it_has_output_folder;
    string
        file_path_filter,
        option;

    ItHasBackupFolder = false;
    BackupFolderPath = "";
    
    ItHasOutputFolder = false;
    OutputFolderPath = "";

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--backup"
             && argument_array.length >= 1
             && argument_array[ 0 ].endsWith( '/' ) )
        {
            ItHasBackupFolder = true;
            BackupFolderPath = argument_array[ 0 ];
            
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--output"
                  && argument_array.length >= 1
                  && argument_array[ 0 ].endsWith( '/' ) )
        {
            ItHasOutputFolder = true;
            OutputFolderPath = argument_array[ 0 ];
            
            argument_array = argument_array[ 1 .. $ ];
        }
        else 
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length == 1 )
    {
        file_path_filter = argument_array[ 0 ];

        FixFiles( file_path_filter );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    prettify [options] file_path_filter" );
        writeln( "Options :" );
        writeln( "    --backup BACKUP_FOLDER/" );
        writeln( "    --output OUTPUT_FOLDER/" );
        writeln( "Example :" );
        writeln( "    prettify --backup BACKUP_FOLDER/ \"*.php\"" );
        writeln( "    prettify --output OUTPUT_FOLDER/ \"*.js\"" );
        
        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
