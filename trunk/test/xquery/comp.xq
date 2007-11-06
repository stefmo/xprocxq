xquery version "1.0" encoding "UTF-8";

import module namespace test = "http://xproc.net/test"
                        at "../../test/xquery/test.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "../../src/xquery/comp.xqm";


<testsuite title="XProc Component XQuery Unit Tests" desc="Test the XProc.xq components XQuery functions">

<test>
    <name>run comp entrypoint</name>
    <result>
    {comp:main()}
    </result>
    <expected>comp entry executed</expected>
</test>

<test>
    <name>run p:episode</name>
    <result>
    {comp:episode()}
    </result>
    <expected>A23afe23r2q34fq</expected>
</test>

<test>
    <name>run p:product-name</name>
    <result>
    {comp:product-name()}
    </result>
    <expected>xproc.xq</expected>
</test>

<test>
    <name>run p:product-version</name>
    <result>
    {comp:product-version()}
    </result>
    <expected>0.0.01</expected>
</test>

<test>
    <name>run p:vendor</name>
    <result>
    {comp:vendor()}
    </result>
    <expected>James Fuller</expected>
</test>

<test>
    <name>run p:vendor-uri</name>
    <result>
    {comp:vendor-uri()}
    </result>
    <expected>http://www.xproc.net/xproc.xq</expected>
</test>

<test>
    <name>run p:version</name>
    <result>
    {comp:version()}
    </result>
    <expected>0.0.01</expected>
</test>

</testsuite>