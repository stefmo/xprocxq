xquery version "1.0" encoding "UTF-8";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Module Imports :)
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

(: -------------------------------------------------------------------------- :)

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
    {xproc:parse( xproc:preparse(<p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:util = "http://xproc.net/xproc/util">

<util:step name="helloworld">
  <p:input port="std-input"/>
  <p:output port="std-output"/>
</util:step>

    <p:identity name="step2">
       <p:input port="step2-input">
              <p:pipe step="step1" port="step1-output"/>
       </p:input>
       <p:output port="step2-output"/>
    </p:identity>

    <p:count name="step3">
        <p:input port="step3-input">
              <p:pipe step="step2" port="step2-output"/>
       </p:input>
    </p:count>

    <p:count name="step1">
        <p:input port="step1-input">
              <p:pipe step="helloworld" port="std-input"/>
        </p:input>
        <p:output port="step1-output"/>
    </p:count>


 </p:pipeline>
 ))}
    </result>
    <expected>import module namespace xproc = "http://xproc.net/xproc" at "src/xquery/xproc.xqm"; import module namespace comp = "http://xproc.net/xproc/comp" at "src/xquery/comp.xqm"; import module namespace util = "http://xproc.net/xproc/util" at "src/xquery/util.xqm"; import module namespace std = "http://xproc.net/xproc/std" at "src/xquery/std.xqm"; import module namespace ext = "http://xproc.net/xproc/ext" at "src/xquery/ext.xqm"; let $O0 := <test/> let $steps := ("pre step",$ext:pre, "step1", $std:count, "step2", $std:identity, "step3", $std:count, "post-step",$ext:post) return util:step-fold($steps, saxon:function("xproc:evalstep", 3),($O0,""))</expected>
</test>


<test>
    <name>simple util:xquery test</name>
    <result>
    {util:xquery('let $a := 1 return $a')}
    </result>
    <expected>1</expected>
</test>


<test>
    <name>complex util:xquery test</name>
    <result>
    {util:xquery('import module namespace xproc = "http://xproc.net/xproc"&#xD;
                        at "src/xquery/xproc.xqm";&#xD;
import module namespace util = "http://xproc.net/xproc/util"&#xD;
                        at "src/xquery/util.xqm";&#xD;
import module namespace std = "http://xproc.net/xproc/std"&#xD;
                        at "src/xquery/std.xqm";&#xD;
import module namespace ext = "http://xproc.net/xproc/ext"&#xD;
                        at "src/xquery/ext.xqm";&#xD;
let $I0 := <test>aaaaa</test>&#xD;
let $pipeline := &lt;p:pipeline xmlns:xproc="http://xproc.net/xproc" xmlns:p="http://www.w3.org/ns/xproc" xproc:preparsed="true" name="main"&gt;&lt;p:input port="source" primary="true" xproc:stdin="true"&gt;&lt;p:pipe step="main" port="xproc:stdin"/&gt;&lt;/p:input&gt;&lt;p:output port="result" primary="true" xproc:stdout="true"&gt;&lt;p:pipe step="!0:main" port="result"/&gt;&lt;/p:output&gt;&lt;p:identity name="" xproc:defaultname="!3:main:"&gt;&lt;p:input port="source" primary="true"&gt;&lt;p:pipe step="main" port="source"/&gt;&lt;/p:input&gt;&lt;p:output port="result" primary="true"/&gt;&lt;/p:identity&gt;&lt;p:identity name="" xproc:defaultname="!4:main:"&gt;&lt;p:input port="source" primary="true"&gt;&lt;p:pipe step="!3:main:" port="result"/&gt;&lt;/p:input&gt;&lt;p:output port="result" primary="true"/&gt;&lt;/p:identity&gt;&lt;/p:pipeline&gt; &#xD;
let $steps := ("!3:main:","!4:main:") 
return util:step-fold($pipeline,
                      $steps, 
                      saxon:function("xproc:evalstep", 3),
                      ($I0,""))
')
}
    </result>
    <expected><test>aaaaa</test></expected>
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

<test>
    <name>testing fn:trace</name>
    <result>false</result>
    <expected>false</expected>
</test>


<test>
    <name>testing util:try</name>
    <result>false</result>
    <expected>false</expected>
</test>


</testsuite>

(: -------------------------------------------------------------------------- :)
