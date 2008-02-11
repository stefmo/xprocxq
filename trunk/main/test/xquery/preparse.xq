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

<testsuite title="preparse XQuery Unit Tests" desc="Test the parsing and ordering of pipeline steps with XProc.xq">

<test>
    <name>pipeline sort 1: fix natural ordering</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">

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
let $sortsteps := <p:pipeline>{util:pipeline-step-sort($pipeline/node(),())}</p:pipeline>
return $sortsteps

}

</result>
<expected><p:pipeline xmlns:p="http://www.w3.org/ns/xproc">
            <util:step xmlns:util="http://xproc.net/xproc/util" name="helloworld">
               <p:input port="std-input"/>
               <p:output port="std-output"/>
            </util:step>
            <p:count name="step1">
               <p:input port="step1-input">
                  <p:pipe step="helloworld" port="std-input"/>
               </p:input>
               <p:output port="step1-output"/>
            </p:count>
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
         </p:pipeline></expected>
</test>


<test>
    <name>pipeline sort 2: strange input and output ports </name>
    <result>
{

let $pipeline :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">

<util:step name="helloworld">
  <p:input name="std-input" port="std-input"/>
  <p:output name="std-output" port="std-output"/>
</util:step>

    <p:identity name="step1">
       <p:input port="step1"/>
       <p:output port="step2-output"/>
    </p:identity>

    <p:count name="step2">
        <p:input port="step2"/>
    </p:count>

    <p:count name="step3">
        <p:input port="std-input"/>
        <p:output port="test1-output"/>
    </p:count>

 </p:pipeline>
let $sortsteps := <p:pipeline>{util:pipeline-step-sort($pipeline/node(),())}</p:pipeline>
return $sortsteps

}

</result>
<expected></expected>
</test>

<test>
    <name>pipeline parse test: test parsing</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">

<util:step name="helloworld">
  <p:input name="std-input" port="std-input"/>
  <p:output name="std-output" port="std-output"/>
</util:step>

    <p:identity name="step1">
       <p:input port="step1"/>
       <p:output port="step2-output"/>
    </p:identity>

    <p:count name="step2">
        <p:input port="step2"/>
    </p:count>

    <p:count name="step3">
        <p:input port="std-input"/>
        <p:output port="test1-output"/>
    </p:count>

 </p:pipeline>
return xproc:parse($pipeline)

}

</result>
<expected></expected>
</test>

<test>
    <name>pipeline full eval test: now eval parse and built code</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">

<util:step name="helloworld">
  <p:input port="std-input"/>
  <p:output port="std-output"/>
</util:step>

    <p:count name="step2">
       <p:input port="step2-input">
              <p:pipe step="step1" port="step1-output"/>
       </p:input>
       <p:output port="step2-output"/>
    </p:count>


    <p:identity name="step1">
        <p:input port="step1-input">
              <p:pipe step="helloworld" port="std-input"/>
        </p:input>
        <p:output port="step1-output"/>
    </p:identity>

 </p:pipeline>
return xproc:eval(xproc:build(xproc:parse(xproc:preparse($pipeline))),<test/>)

}

</result>
<expected></expected>
</test>




<test>
    <name>eval explicit binding prepares</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source"/>
  <p:output port="std-output"/>

    <p:count name="step2">
       <p:input port="step2-input">
              <p:pipe step="step1" port="step1-output"/>
       </p:input>
       <p:output port="step2-output"/>
    </p:count>


    <p:identity name="step1">
        <p:input port="step1-input">
              <p:pipe step="helloworld" port="std-input"/>
        </p:input>
        <p:output port="step1-output"/>
    </p:identity>

 </p:pipeline>
return xproc:explicitbinding($pipeline)

}

</result>
<expected></expected>
</test>


















<!--
<test>
    <name>pipeline sort 3: fix natural ordering</name>
    <result>
{

let $graph :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">
 
    <p:identity name="step2"/>

    <p:count name="step3"/>

    <p:count name="step1"/>

 </p:pipeline>
let $sortsteps := <p:pipeline>{util:pipeline-step-sort($graph/node(),())}</p:pipeline>
return $sortsteps

}

</result>
<expected></expected>
</test>


<test>
    <name>pipeline sort 4: fix natural ordering</name>
    <result>
{<p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:err="http://www.w3.org/ns/xproc-error">
    
    <p:input port="src">
        <p:document href = "file://../data/test.xml" />
    </p:input>
    
    <p:output port="result"/>
    
    <p:identity/>
    
    <p:count/>
    
</p:pipeline>
}

</result>
<expected></expected>
</test>

//-->

</testsuite>

(: -------------------------------------------------------------------------- :)
