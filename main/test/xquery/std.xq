xquery version "1.0" encoding "UTF-8";

(: Module Imports :)

import module namespace std = "http://xproc.net/xproc/std"
                        at "../../src/xquery/std.xqm";

(:
declare namespace c="http://www.w3.org/ns/xproc-step";
:)

(: :)
declare variable $source := document{*};

(: -------------------------------------------------------------------------- :)

<testsuite>
 
<test>
    <name>run successful p:identity test</name>
    <result>
        {std:identity(<test/>,(),())}
    </result>
    <expected>true</expected>
</test>

</testsuite>

(: -------------------------------------------------------------------------- :)
