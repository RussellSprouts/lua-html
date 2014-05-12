# lua-html

Simple templating in Lua 5.2+

This module provides an easy way to write html from Lua code.

        local html = require'html'

        local myTemplate = html.div {
            html.p "paragraph",
            html.a.href"#anchor" [[Text]],
            html.img.href'file.jpg'.class'big'
        }

        --Or:
        local myTemplate = html(function(_ENV)
            return div {
                p "paragraph",
                a.href'#anchor' "Text",
                img.href'file.jpg'.class'big'
            }
        end)

## Usage

The `html` table contains an HtmlElement object for every valid html5 element, as well as a special
element called `group`, which acts as an HtmlElement with no start or end tag -- it simply has content.
Because `table` is a Lua global, the `table` element is known as html.tab

An HtmlElement object has the following properties:

- Calling an HtmlElement with a value or list of values will return a new HtmlElement with
  the values appended to its content property.

        div {"hello"} --> <div>hello</div>

        div {1,2,3} {4,5,6} '7' --> <div>1234567</div>


- Concat-ing an HtmlElement with something else will return an html.group of the elements
  (If one of the elements is already a group, it will return a new group with the other element added)

        p "paragraph1" .. p "paragraph2" --> <p>paragraph1</p><p>paragraph2</p>

        p{"Hello "..strong"there".."!"} --> <p>Hello <strong>there</strong>!</p> 

- Indexing an HtmlElement will return a function that accepts a value, and returns a new element with the
  attribute of the index set.

        div.class'hello' --> <div class="hello"></div>

- Calling `tostring` on an HtmlElement will return the html as a string

- HtmlElements also have to following properties:

    - **tag**: the tag name
    - **content**: a list of child nodes - can be other HtmlElements or strings
    - **attrs**: a map of attribute names to values

    These properties should be treated as read-only

## _ENV shortcut

html does not pollute the global namespace. However, sometimes it is useful to have access to all html elements
unprefixed by `html`. You could do something like this:

        ;(function(_ENV)
            print'Making template!'
            return div.class'greeting' {
                'hi'
            }
        end)(html)

This code would set the _ENV of the code fragment to lookup globals in the `html` table.
A metatable is set so that unknown tags are checked in the global _ENV. This allows access to the
Lua standard library -- print, string, coroutine, etc. are all still available. However, the Lua global
`table` conflicts with the html element `table`. Because of this, the html element is known as `tab`.

Templating is much easier without prefixes, so as a shortcut, calling `html` with a function will
call that function with `html` as an argument. This allows this:

        html(function(_ENV)
            print'Making template!'

            return div.class'greeting' {
                'hi'
            }
        end)