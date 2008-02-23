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
    <name>simple preparse and parse example</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:identity/>
  <p:identity/>

   <p:compare name="step1">
        <p:input port="source" primary="true"/>
        <p:input port="alternate">
              <p:document href="../../data/alternate_data_1.xml"/>
        </p:input>
        <p:output port="result"/>
   </p:compare>

 </p:pipeline>
 return xproc:parse(xproc:preparse($pipeline))

}

</result>
<expected></expected>
</test>



<test>
    <name>simple preparse and parse example</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

<p:input port="source" primary="true"/>
<p:output port="result" primary="true"/>

    <p:count/>
    <p:identity/>

 </p:pipeline>
    return xproc:preparse($pipeline)
}

</result>
<expected></expected>
</test>

<test>
    <name>eval explicit naming and binding preprocess</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:identity/>

  <p:count>
    <p:input port="source">
        <p:pipe step="test1" port="result"/>
    </p:input>
  </p:count>

  <p:wrap>
    <p:option name="wrapper" value="test"/>
  </p:wrap>

  <p:identity name="test1"/>

  <p:identity>
    <p:input port="source" primary="true">
        <p:pipe step="test1" port="result"/>
    </p:input>
    <p:output port="result" primary="true"/>
  </p:identity>

 </p:pipeline>
 return xproc:explicitnames($pipeline)

}

</result>
<expected></expected>
</test>


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
return xproc:parse(xproc:preparse($pipeline))

}

</result>
<expected></expected>
</test>



<test>
    <name>eval explicit binding prepares 1a</name>
    <desc>test implicit stdin and stdout to top level bindings</desc>
    <result>
{

let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:count/>
  <p:identity/>

 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))

}

</result>
<expected></expected>
</test>


<test>
    <name>eval explicit binding prepares 1b</name>
    <desc>test implicit stdin and stdout to top level bindings</desc>
    <result>
{

let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source"/>
  <p:output port="result"/>

  <p:count name="step1"/>
  <p:identity name="step2"/>

 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))

}

</result>
<expected></expected>
</test>


<test>
    <name>eval explicit binding prepares 1c</name>
    <result>
{
let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source"/>
  <p:output port="result"/>

    <p:identity>
      <p:input port="source"/>
      <p:output port="result"/>
    </p:identity>

    <p:count>
      <p:input port="source"/>
      <p:output port="result"/>
    </p:count>

 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))
}
</result>
<expected></expected>
</test>

<test>
    <name>eval explicit binding prepares 1d</name>
    <result>
{
let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source"/>
  <p:output port="result"/>

    <p:identity name="step1">
      <p:input port="source"/>
      <p:output port="result"/>
    </p:identity>

    <p:count name="step2">
      <p:input port="source"/>
      <p:output port="result"/>
    </p:count>

 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))
}
</result>
<expected></expected>
</test>

<test>
    <name>eval explicit binding prepares 1e</name>
    <result>
{
let $pipeline :=
 <p:pipeline name="main"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source" primary="true">
    <p:pipe/>
  </p:input>
    
  <p:output port="result" primary="true">
    <p:pipe/>
  </p:output>

    <p:identity name="step1">
      <p:input port="source"/>
      <p:output port="result"/>
    </p:identity>

    <p:count name="step2">
      <p:input port="source"/>
      <p:output port="result"/>
    </p:count>

 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))
}
</result>
<expected></expected>
</test>


<test>
    <name>eval explicit binding prepares 2: non-existent step should throw error</name>
    <result>
{
let $pipeline :=
 <p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source"/>
  <p:output port="result"/>

    <p:identity/>
    <p:count/>
    <p:thisstepdoesnotexist/>
 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))
}
</result>
<expected>error</expected>
</test>



<test>
    <name>eval explicit binding prepares 3 with optional and extension step</name>
    <result>
{
let $pipeline :=
 <p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

  <p:input port="source"/>
  <p:output port="result"/>

    <p:uuid/>
    <ext:test/>
 </p:pipeline>
 return xproc:explicitbindings(xproc:explicitnames($pipeline))
}
</result>
<expected></expected>
</test>

</testsuite>

(: -------------------------------------------------------------------------- :)
