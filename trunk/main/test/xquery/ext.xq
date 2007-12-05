xquery version "1.0" encoding "UTF-8";

(: Module Imports :)
import module namespace test = "http://xproc.net/test"
                        at "../../test/xquery/test.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "../../src/xquery/ext.xqm";

(: -------------------------------------------------------------------------- :)

<testsuite title="XProc Extension Step XQuery Unit Tests" desc="Test the XProc.xq extension step XQuery functions">

<test>
    <name>run ext entrypoint</name>
    <result>
    {ext:main()}
    </result>
    <expected>ext entry point executed</expected>
</test>

<test>
    <name>run successful ext:pre-step test</name>
    <result>
    {test:assertXMLEqual(ext:pre-step(<test/>),<test/>)}
    </result>
    <expected>true</expected>
</test>

<test>
    <name>run successful ext:post-step test</name>
    <result>
    {test:assertXMLEqual(ext:post-step(<test/>),<test/>)}
    </result>
    <expected>true</expected>
</test>

</testsuite>

(: -------------------------------------------------------------------------- :)