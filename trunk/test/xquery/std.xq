xquery version "1.0" encoding "UTF-8";

import module namespace test = "http://xproc.net/test"
                        at "../../test/xquery/test.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "../../src/xquery/std.xqm";


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

</testsuite>