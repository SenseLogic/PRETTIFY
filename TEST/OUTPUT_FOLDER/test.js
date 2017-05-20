window.onload = function()
{
    "use strict";

    $( 'html *[class$="_container"]' )
        .contents()
        .filter(
            function()
            {
                return this.nodeType == 3 && this.nodeValue.match( /^s*$/ );
            }
            )
        .remove();

    Crafty.init( 600, 300 );
    Crafty.background( 'rgb(127,127,127)' );

    Crafty.scene(
        "game",
        function()
        {
            // Paddles

            Crafty.e( "Paddle, 2D, DOM, Color, Multiway" )
                  .color( 'rgb(255,0,0)' )
                  .attr(
                      {
                          x : 20,
                          y : 100,
                          w : 10,
                          h : 100
                      }
                      )
                  .multiway( 4,
                             {
                                 Q : -90,
                                 W : 90
                             }
                             );

            Crafty.e( "Paddle, 2D, DOM, Color, Multiway" )
                  .color( 'rgb(0,255,0)' )
                  .attr(
                      {
                          x : 580,
                          y : 100,
                          w : 10,
                          h : 100
                      }
                      )
                  .multiway(
                      4,
                      {
                          UP_ARROW : -90,
                          DOWN_ARROW : 90
                      }
                      );

            // Ball

            Crafty.e( "2D, DOM, Color, Collision" )
                  .color( 'rgb(0,0,255)' )
                  .attr(
                      {
                          x : 300,
                          y : 150,
                          w : 10,
                          h : 10,
                          dX : Crafty.math.randomInt( 2, 5 ),
                          dY : Crafty.math.randomInt( 2, 5 )
                      }
                      )
                  .bind(
                      'EnterFrame',
                      function()
                      {
                          // Hit floor or roof

                          if ( this.y <= 0 || this.y >= 290 )
                          this.dY *= -1;

                          if ( this.x > 600 )
                          {
                              this.x = 300;
                              Crafty( "LeftPoints" ).each( function()
                                                           {
                                                               this.text( ++this.points + " Points" )
                                                           }
                                                           );
                          }

                          if ( this.x < 10 )
                          {
                              this.x = 300;
                              Crafty( "RightPoints" ).each( function()
                                                            {
                                                                this.text( ++this.points + " Points" )
                                                            }
                                                            );
                          }

                          this.x += this.dX;
                          this.y += this.dY;
                      }
                      )
                  .onHit(
                      'Paddle',
                      function()
                      {
                          this.dX *= -1;
                      }
                      )

                      // Score boards

                      Crafty.e( "LeftPoints, DOM, 2D, Text" )
                            .attr(
                                {
                                    x : 20,
                                    y : 20,
                                    w : 100,
                                    h : 20,
                                    points : 0
                                }
                                )
                            .text( "0 Points" );

            Crafty.e( "RightPoints, DOM, 2D, Text" )
                  .attr(
                      {
                          x : 515,
                          y : 20,
                          w : 100,
                          h : 20,
                          points : 0
                      }
                      )
                  .text( "0 Points" );
        }
        );

    Crafty.e( "2D, DOM, Text" ).attr(
        {
            x : 250,
            y : 130,
            w : 300
        }
        ).text( "Click to play..." );

    Crafty.e( "2D, DOM, Mouse" )
          .attr(
              {
                  x : 0,
                  y : 0,
                  h : 300,
                  w : 600
              }
              ).bind(
                  "Click",
                  function()
                  {
                      Crafty.scene( "game" );
                  }
                  );
}

function SetTimer()
{
    if ( timer === undefined )
    {
        timer =
            setInterval(
                function()
                {
                    Next();
                },
                1000
                );
    }
}

for ( var i = 0;
      i < 10;
      ++i )
{
    for ( var j = 0;
          j < 10;
          ++j )
    {
        if ( i > j
             && i <= j + 2
             && !( i == 0
                   || j == 0 ) )
        {
            console.log( i + j );
        }
    }
}

define(
    function( require, exports, module )
    {
        "use strict";

        var CommandManager = brackets.getModule( "command/CommandManager" );
        var DocumentManager = brackets.getModule( "document/DocumentManager" );
        var EditorManager = brackets.getModule( "editor/EditorManager" );
        var Menus = brackets.getModule( "command/Menus" );

        CommandManager.register( "Standardize", COMMAND_ID, Standardize );

        function Standardize()
        {
            var document = DocumentManager.getCurrentDocument();
            var editor = EditorManager.getActiveEditor();

            if ( document != null
                 && editor != null )
            {
                var cursor_position = editor.getCursorPos();
                var scroll_position = editor.getScrollPos();
                var code =
                {
                    FileText : document.getText(),
                    FilePath : document.file.fullPath
                };

                StandardizeCode( code );

                document.setText( code.FileText );
                editor.setCursorPos( cursor_position );
                editor.setScrollPos( scroll_position.x, scroll_position.y );
            }
        }

        var menu = Menus.getMenu( Menus.AppMenuBar.EDIT_MENU );

        menu.addMenuItem(
            COMMAND_ID,
            [
                {
                    key : "Ctrl-Alt-S", platform : "win"
                },
                {
                    key : "Ctrl-Alt-S", platform : "mac"
                }
            ]
            );
    }
    );

var LANGUAGE_TYPE_NameTable =
    [
        "HTML",
        "CSS",
        "CPP",
        "JS",
        "PHP"
        "PHP"
    ];

var x = 123.345345e-10;
var y = text
            .split( 'x' )
            .join( 'X' )
            .split( 'x' ).join( 'X' )
                         .split( 'y' ).join( 'Y' );
