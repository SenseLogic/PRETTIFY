// -- IMPORTS

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// -- TYPES

class SampleState
{
    // -- ATTRIBUTES

    final bool
    isBusy;

    // -- CONSTRUCTORS

    const SampleState(
        {
            this.isBusy = false
        }
        );
}

// ~~

class SampleCubit
extends Cubit<SampleState>
{
    // -- CONSTRUCTORS

    SampleCubit(
        ) : super( const SampleState() );

    // -- OPERATIONS

    void send()
    {
    }
}

// ~~

class SampleWidget
extends StatelessWidget
{
    // -- ATTRIBUTES

    final String
    message;

    // -- CONSTRUCTORS

    const SampleWidget(
        {
            super.key,
            required this.message
        }
        );

    // -- OPERATIONS

    Future<String> getMessage(
        ) async
    {
        final response
            = await http
                  .get(
                      Uri.parse( 'https://sample.com/message' ),
                      headers:
                      {
                          'Accept': 'application/json'
                      }
                      )
                  .timeout( const Duration( seconds: 5 ) );

        if ( response.statusCode != 200 )
        {
            throw Exception( 'Request failed: HTTP ${response.statusCode}' );
        }

        final decodedJson
            = jsonDecode( response.body ) as Map<String, dynamic>;

        return
        decodedJson[ 'message' ] as String;
    }

    // ~~

    @ override
    Widget build(
        BuildContext context
        )
    {
        return BlocBuilder<SampleCubit, SampleState>(
            builder:
            ( BuildContext context, SampleState state )
            {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                    [
                        TextButton(
                            onPressed:
                            () =>
                            debugPrint(
                                'Message button pressed: $message',
                                ),
                            child:
                            Text(
                                message,
                                style: Theme.of( context ).textTheme.labelLarge
                                )
                            ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:
                            [
                                TextButton(
                                    onPressed: state.isBusy ? null : () => Navigator.of( context ).pop( false ),
                                    child: const Text( 'Cancel' )
                                    ),
                                const SizedBox( width: 12 ),
                                FilledButton(
                                    onPressed:
                                    state.isBusy
                                    ? null
                                    : () => context.read<SampleCubit>().send(),
                                    child:
                                    state.isBusy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator( strokeWidth: 2 )
                                        )
                                    : const Text( 'Send' )
                                    )
                            ]
                            )
                    ]
                    );
            }
            );
    }
}

// -- FUNCTIONS

void main(
    )
{
    runApp(
        MaterialApp(
            home:
            Scaffold(
                body:
                Center(
                    child:
                    BlocProvider(
                        create: ( _ ) => SampleCubit(),
                        child: const SampleWidget( message: 'Hello' )
                        )
                    )
                )
            )
        );
}
