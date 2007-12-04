xquery version "1.0" encoding "UTF-8";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

import module namespace test = "http://xproc.net/test"
                        at "../../test/xquery/test.xqm";
import module namespace xproc = "http://xproc.net/xproc"
                        at "../../src/xquery/xproc.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "../../src/xquery/comp.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "../../src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "../../src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "../../src/xquery/ext.xqm";

<testsuite title="Core XQuery Unit Tests" desc="Test the core XProc.xq XQuery functions">


<test>
    <name>run xproc main entrypoint</name>
    <result>
    {xproc:main()}
    </result>
    <expected>main xproc.xq executed</expected>
</test>


<test>
    <name>run xproc util:help</name>
    <result>
    {util:help()}
    </result>
    <expected>help util executed</expected>
</test>


<test>
    <name>run xproc util:eval which evals to true</name>
    <result>
    {util:eval('fn:boolean(1)')}
    </result>
    <expected>true</expected>
</test>


<test>
    <name>run xproc util:eval which evals to false</name>
    <result>
    {util:eval('fn:boolean(0)')}
    </result>
    <expected>false</expected>
</test>


<test>
    <name>run saxon:evaluate which evals to true</name>
    <result>
    {
        let $v :=document{<test><c>true</c></test>}
        return $v/saxon:evaluate("//c/text()")
    }
    </result>
    <expected>true</expected>
</test>


<test>
    <name>run util:evalXPATH which evals to true</name>
    <result>
    {
        let $v :=document{<test><c>true</c></test>}
        return util:evalXPATH("//c/text()",$v)
    }
    </result>
    <expected>true</expected>
</test>


<test>
    <name>testing util:call</name>
    <result>
    {
        util:call(saxon:function('std:count', 1),<test/>)
    }
    </result>
    <expected>1</expected>
</test>


<test>
    <name>directly testing saxon:call</name>
    <result>
    {
        saxon:call(saxon:function('std:count', 1),<test/>)
    }
    </result>
    <expected>1</expected>
</test>


<test>
    <name>run xproc parse function</name>
    <result>
    {xproc:parse(document { <p:pipeline name="helloworld"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error">

    <p:identity/>
    <p:count/>

</p:pipeline> })}
    </result>
    <expected>import module namespace xproc = "http://xproc.net/xproc"
               at "src/xquery/xproc.xqm";
               import module namespace comp = "http://xproc.net/xproc/comp"
               at "src/xquery/comp.xqm";
               import module namespace util = "http://xproc.net/xproc/util"
               at "src/xquery/util.xqm";
               import module namespace std = "http://xproc.net/xproc/std"
               at "src/xquery/std.xqm";
               import module namespace ext = "http://xproc.net/xproc/ext"
               at "src/xquery/ext.xqm";
               let $O0 := &lt;test/&gt;  let $I1 := $O0  let $O1 := util:call( saxon:function("std:identity", 1),$I1)  let $I2 := $O1  let $O2
               := util:call( saxon:function("std:count", 1),$I2)  let $I0 := $O2 return $I0</expected>
</test>


<test>
    <name>simple util:xquery test</name>
    <result>
    {util:xquery('let $a := 1 return $a')}
    </result>
    <expected>1</expected>
</test>


<test>
    <name>more representative util:xquery test</name>
    <result>
    {util:xquery('import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "src/xquery/comp.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
let $O0 := <test/> let $PI1 := "primary input" let $I1 := $O0 let $O1 := util:call( saxon:function("std:identity", 1),$I1) let $I2 := $O1 let $O2 := util:call( saxon:function("std:count", 1),$I2) let $PO1 := "primary output" let $I0 := $O2 return $I0')}
    </result>
    <expected>1</expected>
</test>


<test>
    <name>testing subsequence</name>
    <result>
    {let $steps := (<step><name>test1</name><func>saxon:function("std:identity", 1)</func></step>,<step><name>test2</name><func>saxon:function("std:count", 1)</func></step>) 
     return $steps[1]/func/text()}
    </result>
    <expected></expected>
</test>

<test>
    <name>testing util:timing</name>
    <result>
    {test:assertIsInteger(util:timing())} 
    </result>
    <expected>true</expected>
</test>

</testsuite>