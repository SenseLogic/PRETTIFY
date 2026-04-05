// -- IMPORTS

import 'dart:core';

// -- CONSTANTS

const int
minimumPassCount = 0,
maximumPassCount = 5;

// -- TYPES

class Being
{
    // -- ATTRIBUTES

    String
    name;
    int
    age;

    // -- CONSTRUCTORS

    Being(
        this.name,
        this.age
        );
}

// ~~

class Person
extends Being
{
    // -- ATTRIBUTES

    double
    weight,
    dogCount;

    // -- CONSTRUCTORS

    Person(
        String name,
        int age,
        this.weight,
        this.dogCount
        ) : super( name, age );

    // -- INQUIRIES

    int getAge(
        )
    {
        return age;
    }

    // ~~

    int getAgeOffset(
        int otherAge
        )
    {
        return otherAge - age;
    }

    // ~~

    String getHelloMessage(
        )
    {
        return 'Hello, my name is ${ name }, I\'m ${ age } years old and I weight ${ weight } kilograms.';
    }

    // -- OPERATIONS

    void setAge(
        int age
        )
    {
        this.age = age;
    }

    // ~~

    void setFakeAge(
        int age
        )
    {
        if ( age > 0
             && age < 50
             && ( age < 20
                  || age > 40 ) )
        {
            this.age
                += ( age
                     + ( age - 2 )
                     + ( age
                         * ( age + 10 )
                         * ( age + 20 ) ) )
                   + this.getAgeOffset(
                       age * 2
                       - 20
                       );
        }
        else if ( age > 20
                  && age < 40
                  && ( age < 25
                       || age > 35 ) )
        {
            this.age = ( age * 0.5 ).round();
        }
        else
        {
            this.age = age + 10;
        }
    }
}

// -- FUNCTIONS

Map<String, int >? getAgeInterval(
    List<Person> sortedPersonList
    )
{
    if ( sortedPersonList.isEmpty )
    {
        return null;
    }
    else
    {
        return
        {
            'firstAge': sortedPersonList[ 0 ].age,
            'lastAge': sortedPersonList[ sortedPersonList.length - 1 ].age
        };
    }
}

// -- STATEMENTS

void main(
    )
{
    var passIndex = 0;

    while ( passIndex < 5 )
    {
        ++passIndex;
    }

    do
    {
        ++passIndex;
    }
    while ( passIndex < 10 );

    var personList
    = [
        Person( 'Mike', 49, 85, 1 ),
        Person( 'Luke', 30, 77, 0 ),
        Person( 'John', 30, 72, 3 )
      ];

    personList.sort(
        ( firstPerson, secondPerson )
        {
            try
            {
                if ( firstPerson.age != secondPerson.age )
                {
                    return firstPerson.age - secondPerson.age;
                }
                else
                {
                    return firstPerson.weight.compareTo( secondPerson.weight );
                }
            }
            catch ( error )
            {
                print( error.toString() );
            }

            return 0;
        }
        );

    var ageInterval = getAgeInterval( personList );

    if ( ageInterval != null )
    {
        print( 'First age: ${ ageInterval[ 'firstAge' ] }' );
        print( 'Last age: ${ ageInterval[ 'lastAge' ] }' );
    }
    else
    {
        print( 'No age interval' );
    }
}
