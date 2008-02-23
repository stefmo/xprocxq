xquery version "1.0" encoding "UTF-8";

(: Module Imports :)
import module namespace test = "http://xproc.net/test"
                        at "../../test/xquery/test.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "../../src/xquery/std.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "../../src/xquery/opt.xqm";

declare namespace c="http://www.w3.org/ns/xproc-step";

(: -------------------------------------------------------------------------- :)

<testsuite title="XProc Standard Step XQuery Unit Tests" desc="Test the XProc.xq standard step XQuery functions">

<test>
    <name>run successful p:identity test</name>
    <result>
    {test:assertXMLEqual(std:identity(<test/>),<test/>)}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run failed p:identity test</name>
    <result>
    {test:assertXMLNotEqual(std:identity(<test id="123123"/>),<test/>)}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run successful p:identity test with sequences</name>
    <result>
    {test:assertXMLEqual(std:identity((<test/>,<test2/>)),(<test/>,<test2/>))}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run failed p:identity test with sequences</name>
    <result>
    {test:assertXMLNotEqual(std:identity((<test id="123123"/>,<test/>)),<test/>)}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run successful p:count test</name>
    <result>
    {test:assertIntegerEqual(std:count((<test/>,<test/>)),2)}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run failed p:count test</name>
    <result>
    {test:assertIntegerEqual(std:count((<test/>,<test/>)),10)}
    </result>
    <expected>false</expected>
</test>


<test>
    <name>run failed p:wrap test</name>
    <result>
    {test:assertXMLEqual(std:wrap((<test/>,"wrap","/")),(<a><test/></a>))}
    </result>
    <expected>false</expected>
</test>

<test>
    <name>run failed p:wrap test due to incorrect xpath</name>
    <result>
    {test:assertXMLEqual(std:wrap((<test/>,"a","/a/test/b")),(<a><test/></a>))}
    </result>
    <expected>false</expected>
</test>

<!--
<test>
 TODO: needs some though this one, and highlights the need for a deeper option handling 
    <name>run success p:wrap test with new namespaced wrap element</name>
    <result>
    {test:assertXMLEqual(std:wrap(<test/>,"newnamespace:wrap_el","/"),(<newnamespace:wrap_el><test/></newnamespace:wrap_el>))}
    </result>
    <expected>true</expected>
</test>
//--> 

<test>
    <name>run success p:wrap test</name>
    <result>
        {test:assertXMLEqual(std:wrap((<test/>,"aaaa","/")),(<aaaa><test/></aaaa>))}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run success p:wrap test</name>
    <result>
        {test:assertXMLEqual(std:wrap((<test><a><c>test</c></a></test>,"aaaa","test/a"),(<aaaa><a><c>test</c></a></aaaa>))}
    </result>
    <expected>true</expected>
</test>


<test>
    <name>run success p:compare test</name>
    <result>
    {std:compare(<test>test</test>,<test>test</test>)}
    </result>
    <expected><c:result>true</c:result></expected>
</test>

</testsuite>

(: -------------------------------------------------------------------------- :)
