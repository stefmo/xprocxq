xquery version "1.0" encoding "UTF-8";

(: Module Imports :)
import module namespace test = "http://xproc.net/test"
                        at "../../test/xquery/test.xqm";
import module namespace ant = "http://xproc.net/xproc/ant"
                        at "../../src/xquery/ant.xqm";

(: :)
declare variable $source := document{*};


(: -------------------------------------------------------------------------- :)

<testsuite title="XProc Ant Step XQuery Unit Tests" desc="Test the XProc.xq ant step XQuery functions">

<test>
    <name>run successful ant:test step test</name>
    <result>
        {ant:test("test")}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run successful ant:build-target step test</name>
    <result>
        {ant:build-target()}
    </result>
    <expected>true</expected>
</test>

</testsuite>

(: -------------------------------------------------------------------------- :)