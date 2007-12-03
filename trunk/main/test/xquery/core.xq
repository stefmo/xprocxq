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
    <name>run xproc parse entrypoint</name>
    <result>
    {xproc:parse(<p:pipeline name="helloworld"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error"/>)}
    </result>
    <expected>import module namespace xproc = "http://xproc.net/xproc" at "src/xquery/xproc.xqm"; import module namespace comp = "http://xproc.net/xproc/comp" at "src/xquery/comp.xqm"; import module namespace util = "http://xproc.net/xproc/util" at "src/xquery/util.xqm"; import module namespace std = "http://xproc.net/xproc/std" at "src/xquery/std.xqm"; import module namespace ext = "http://xproc.net/xproc/ext" at "src/xquery/ext.xqm"; let $O0 := <test/> let $I0 := $O2 return $I0</expected>
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
    <name>test parsing xproc and building run tree</name>
    <result>
    {let $parsetree := xproc:parse(fn:doc('../xproc/basic/helloworld_1.xml'))
     let $runtree := xproc:build($parsetree)
     return
         $runtree
    }
    </result>
    <expected>


     </expected>
</test>


<test>
    <name>test runtree variation I</name>
    <result>
    {
        let $I0 := <test/>
        let $O2 := std:identity($I0)
        let $O3 := std:count($O2)
        let $I1 := $O3
        return $I1
    }
    </result>
    <expected>1</expected>
</test>


<test>
    <name>test runtree variation II</name>
    <result>
    {
        let $I0 := <test/>
        return std:count(std:identity($I0))

    }
    </result>
    <expected>1</expected>
</test>


<test>
    <name>test runtree variation III</name>
    <result>
    {
        let $I0 := <test/>
        return std:count(std:identity($I0))

    }
    </result>
    <expected>1</expected>
</test>


<test>
    <name>test runtree variation IV</name>
    <result>
    {

    let $O0 := <test/>

    let $I0 := $O0
    let $I2 := $O0
    let $O1 := $I0     

    let $O2 := std:identity($I2) 

    let $I3 := $O2  

    let $O3 := std:count($I3)

    let $I1 := $O3
	
    return $I1 

    }
    </result>
    <expected>1</expected>
</test>

<test>
    <name>test runtree variation V</name>
    <result>
    {

    let $O0 := <test/>

    let $I0 := $O0
    let $I2 := $O0
    let $O1 := $I0     

    let $O2 := util:call(saxon:function('std:identity', 1),$I2)

    let $I3 := $O2  

    let $O3 := util:call(saxon:function('std:count',1),$I3)

    let $I1 := $O3
	
    return $I1 

    }
    </result>
    <expected>1</expected>
</test>


<test>
    <name>test runtree variation VI</name>
    <result>
    {

    let $I1 := document{ <test/> }            (: bind primary input I1 to inline document :)  
    let $O0 := $I1                            (: bind I1 to system output O0 for use by 1st step :)

    let $I2 := $O0                            (: bind I2 to O0 :)
    let $O2 := util:call(saxon:function('std:identity', 1),$I2)                  (: bind process from step to O2 :)

    let $I3 := $O2                            (: bind I3 to O2 :)
    let $O3 := util:call(saxon:function('std:count', 1),$I3)                  (: bind process from step to O3 :)

    let $I0 := $O3                            (: bind system input I0 to O3 for use by last step :)

    let $O1 := $I0                            (: bind primary output O1 to I0 :)

    return $O1                                (: bind primary output O1 to serialize :)
}
   </result>
    <expected>1</expected>
</test>


<test>
    <name>cut n paste result from xproc:parse helloworld 1 </name>
    <result>
    {let $O0 := <test/> let $I1 := $O0 let $O1 := util:call( saxon:function("std:identity", 1),$I1) let $I2 := $O1 let $O2 := util:call( saxon:function("std:count", 1),$I2) let $I0 := $O2 return $I0}
   </result>
    <expected>1</expected>
</test>

<test>
    <name>cut n paste result from xproc:parse helloworld 2 </name>
    <result>
    {let $O0 := <test/> let $PI1 := "primary input" let $I1 := $O0 let $O1 := util:call( saxon:function("std:identity", 1),$I1) let $I2 := $O1 let $O2 := saxon:call( saxon:function("std:count", 1),$I2) let $PO1 := "primary output" let $I0 := $O2 return $I0}
   </result>
    <expected>1</expected>
</test>


<test>
    <name>cut n paste result from xproc:parse helloworld 3 </name>
    <result>
    {let $O0 := <test/> let $PI1 := "primary input" let $I1 := $O0 let $O1 := util:call( saxon:function("std:identity", 1),$I1) let $I2 := $O1 let $O2 := util:call( saxon:function("std:count", 1),$I2) let $PO1 := "primary output" let $I0 := $O2 return $I0}
   </result>
    <expected>1</expected>
</test>

<!--
<test>
    <name>testing util:function</name>
    <result>
    {
        util:call(util:function('std:count', 1),<test/>)
    }
    </result>
    <expected>1</expected>
</test>
//-->

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

</testsuite>