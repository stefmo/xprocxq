xquery version "1.0" encoding "UTF-8";

(: example test for xprocxq:)

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_INSTALL := "/db/xproctest";   (: CHANGE ME :)

(: define standard input port :)
let $stdin :=document {<test><a><b/></a></test>}

(: external bindings for when we have a commandline equiv. Takes in
either xml fragments or file://, http:// or relative path in the
database :)
let $external-bindings
:=('source2=<test/>','source3=<a>test</a>',concat('source4=',$local:XPROCXQ_INSTALL, '/test.xml'))


let $pipeline :=document{<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
               name="pipeline">

  <p:http-request name="http-get">  (: http get test step :)
    <p:input port="source">
      <p:inline>
	    <c:request xmlns:c="http://www.w3.org/ns/xproc-step" href="http://tests.xproc.org/service/fixed-xml" method="get"/>
      </p:inline>
    </p:input>
  </p:http-request>

       <p:identity name="test">                          (: identity test step :)
           <p:input port="source">
               <p:pipe port="source4" step="pipeline"/>  (: use external binding port :)
           </p:input>
       </p:identity>

       <p:xslt>                                          (: xslt test step:)
           <p:input port="stylesheet">
               <p:document
href="{$local:XPROCXQ_INSTALL}/stylesheet.xml"/>
           </p:input>
       </p:xslt>
  
       <p:compare name="compare">                        (: compare step :)
           <p:input port="source" select="/success"/>    (: example of select attribute on input binding :)
           <p:input port="alternate">
               <p:document href="{$local:XPROCXQ_INSTALL}/test.xml"/> (: example of using p:document :)
           </p:input>
       </p:compare>


        <p:choose name="mychoosestep">
               <p:when test=".//c:result[.='false']">      (: note the eXist specific path convention with root :)
                   <p:output port="result"/>
                   <p:identity>
                       <p:input port="source">
                           <p:inline>
                               <p>This pipeline failed.</p>
                           </p:inline>
                       </p:input>
                   </p:identity>
               </p:when>
               <p:when test=".//c:result[.='true']">  (: success :)
                   <p:output port="result"/>
                   <p:xquery name='myexquerystep'>
                       <p:input port="query">
                           <p:inline>
                               <c:query xmlns:c="http://www.w3.org/ns/xproc-step" xproc:escape="false">
                                   let $r := 'this pipeline successfully processed' return concat('&lt;test&gt;',$r,'&lt;/test&gt;')   (: for now default context goes to a var, changing this soon :)
                               </c:query>
                           </p:inline>
                       </p:input>
                   </p:xquery>

               </p:when>
               <p:otherwise>
                   <p:output port="result"/>
                   <p:identity>
                       <p:input port="source">
                           <p:inline>
                               <p>This pipeline failed.</p>
                           </p:inline>
                       </p:input>
                   </p:identity>
               </p:otherwise>
           </p:choose>
       
       </p:pipeline>}


let $external-options :=() (: disabled :)
let $debug-flag :="1"  (: change value to 1 to see p:log trace :)
let $timing-flag :="0"  (: deprecated :)
let $test-debug :=0

return

    if ($test-debug eq 1) then
        xproc:explicitbindings(
            naming:explicitnames(
                naming:fixup($pipeline,$stdin)
            )
        ,$const:init_unique_id
        )
    else if ($test-debug eq 2) then
            naming:explicitnames(
                naming:fixup($pipeline,$stdin)
            )    
    else
        xproc:run($pipeline,$stdin,$debug-flag,$timing-flag,$external-bindings,$external-options) 
 
