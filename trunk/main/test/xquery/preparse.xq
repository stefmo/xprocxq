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
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "../../src/xquery/opt.xqm";
(: -------------------------------------------------------------------------- :)

<testsuite title="preparse XQuery Unit Tests" desc="Test the parsing and ordering of pipeline steps with XProc.xq">

<test>
    <name>preparse p:group</name>
    <result>
{

let $pipeline :=
<p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:util = "http://xproc.net/xproc/util">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:group name="version">
            <p:identity name="step1"/>    
            <p:count name="step2"/>
        <p:group name="another">
            <p:identity name="step1"/>    
            <p:count name="step2"/>
        </p:group>
    </p:group>
    
</p:pipeline>
 return xproc:preparse($pipeline)

}
</result>
<expected></expected>
</test>

<test>
    <name>preparse p:wrap</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:util = "http://xproc.net/xproc/util">

    <util:step name="pipeline">
        <p:input port="source" primary="true"/>
        <p:output port="result" primary="true"/>
    </util:step>

    <p:identity/>

    <p:wrap name="step1">
        <p:input port="source" primary="true"/>
        <p:with-option name="wrapper" select="aaaaaaaaaaaaa"/>   
        <p:with-option name="match" select="aaaaaaaaaaa"/> 
        <p:output port="result" primary="true"/>
    </p:wrap>

</p:pipeline>
    return xproc:build(xproc:parse(xproc:preparse($pipeline)))

}
</result>
<expected></expected>
</test>


<test>
    <name>preparse p:choose</name>
    <result>
{

let $pipeline :=
<p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:util = "http://xproc.net/xproc/util">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    
    <p:choose name="version">
        <p:when test="//test">
            <p:identity name="step1">
                <p:input port="source" primary="true">
                    <p:document href="file:test/data/alternate_data_1.xml"/>
                </p:input>
                <p:output port="result"/>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:error>
                <p:option name="code" value="error code"/> 
            </p:error>
        </p:otherwise>
    </p:choose>
</p:pipeline>
 return xproc:preparse($pipeline)

}
</result>
<expected></expected>
</test>

<test>
    <name>basic preparse example</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

<p:input port="source" primary="true"/>
<p:output port="result" primary="true"/>

    <p:count/>
    <p:identity/>
    <p:compare name="step1">
        <p:input port="alternate">
              <p:document href="file:test/data/test2.xml"/>
        </p:input>
   </p:compare>

 </p:pipeline>
    return xproc:build(xproc:parse(xproc:preparse($pipeline)))
}

</result>
<expected></expected>
</test>


<test>
    <name>util:pipeline-step-sort 1</name>
    <result>
{

let $pipeline :=
 <p:pipeline name="helloworld"
            xmlns:p="http://www.w3.org/ns/xproc">

<util:step name="helloworld">
  <p:input port="std-input"/>
  <p:output port="std-output"/>
</util:step>


    <p:count name="step3">
        <p:input port="step3-input">
              <p:pipe step="step2" port="step2-output"/>
       </p:input>
    </p:count>

    <p:identity name="step2">
       <p:input port="step2-input">
              <p:pipe step="step1" port="step1-output"/>
       </p:input>
       <p:output port="step2-output"/>
    </p:identity>

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
    <name>util:pipeline-step-sort 2</name>
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
    <name>preparse + parse 1</name>
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
 return xproc:explicitbindings(xproc:explicitnames($pipeline,''))

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
 return xproc:explicitbindings(xproc:explicitnames($pipeline,''))

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
 return xproc:preparse($pipeline)
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
 return xproc:preparse($pipeline)
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
 return xproc:preparse($pipeline)
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
 return xproc:explicitnames($pipeline,'')
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
 return xproc:preparse($pipeline)
}
</result>
<expected></expected>
</test>

</testsuite>

(: -------------------------------------------------------------------------- :)
