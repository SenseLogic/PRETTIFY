#ifndef ARTICLE_H
    #define ARTICLE_H

    #include <string>
    #include <vector>

    class ArticleManager;

    class Article
    {
        friend class ArticleManager;

        public :

        Article()
        {
        }

        Article(
            const std::string & id,
            const std::string & title,
            const std::string & text
            ) :
            _id( id ),
            _title( title ),
            _text( text )
        {
        }

        const std::string & id() const
        {
            return &_id;
        }

        const std::string & title() const
        {
            return &_title;
        }

        const std::string & text() const
        {
            return &_text;
        }

        private :

        std::string
            _id,
            _title,
            _text;
    };

    inline bool operator==(
        const Article & article,
        const Article & other_article
        )
    {
        return article.id() == other_article.id();
    }

    typedef std::vector<Article>
        Articles;
#endif

#ifndef __TEST_H__
    #define __TEXT_H__

    #include <stdio.h>
    #include "integer_32.hpp"

    #define TEST_Text \
    "Some" \
    "Text"

    class TEST
    {
        public :

        TEST(
            VOID
            ) :
            Integer( 0 )
        {
            if ( Integer == 0 )
            {
                ++Integer;
            }
        }

        INTEGER_32
            Integer;
    };
#elif defined( __TEST_HPP__ )
    #pragma message( "In file : " __FILE__ )

    #ifndef __TEST_H__
        #define TEST_Text \
        "Some" \
        "Text"
    #else
        #define TEST_Text \
        "Some" \
        "Text"

        #define TEST_Text \
        "Some" \
        "Text"
    #endif

    #ifndef __TEST_H__
        #define __TEXT_H__
    #else
        #define TEST_Text \
        "Some" \
        "Text"
    #endif
#else
    #error Error
#endif;

// ~~

#ifndef __TEST_H__
    #define __TEXT_H__

    #include <stdio.h>
    #include "integer_32.hpp"

    #define TEST_Text \
    "Some" \
    "Text"

    class TEST
    {
        public :

        TEST(
            VOID
            ) :
            Integer( 0 )
        {
            if ( Integer == 0
                 || Integer * 2
                    != Integer -1
                    && Integer != -1
                    && Func(
                          Integer * 2, X
                                       + 2 ) )
            {
                ++Integer;
            }
        }

        INTEGER_32
            Integer;
    };
#elif defined( __TEST_HPP__ )
    #pragma message( "In file : " __FILE__ )

    #ifndef __TEST_H__
        #define TEST_Text \
        "Some" \
        "Text"
    #else
        #define TEST_Text \
        "Some" \
        "Text"

        #define TEST_Text \
        "Some" \
        "Text"
    #endif

    #ifndef __TEST_H__
        #define __TEXT_H__
    #else
        #define TEST_Text \
        "Some" \
        "Text"
    #endif
#else
    #error Error
#endif
