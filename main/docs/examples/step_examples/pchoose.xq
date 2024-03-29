xquery version "1.0" encoding "UTF-8";

(: example test for xprocxq:)

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=doc(concat($local:XPROCXQ_EXAMPLES,'/xml/test.xml'))

let $pipeline :=document{<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
                                     xmlns:c="http://www.w3.org/ns/xproc-step"
                           name="pipeline">

<p:compare name="compare">                       (: compare test step :)
   <p:input port="alternate">
       <p:document href="{$local:XPROCXQ_EXAMPLES}/xml/test.xml"/> (: example of using p:document :)
   </p:input>
</p:compare>

<p:choose name="mychoosestep">
       <p:when test=".//c:result[.='false']">      (: note the eXist specific path convention with root :)
           <p:identity>
               <p:input port="source">
                   <p:inline>
                       <p>This pipeline failed.</p>
                   </p:inline>
               </p:input>
           </p:identity>
       </p:when>
       <p:when test=".//c:result[.='true']">  (: success :)
       <p:identity>
           <p:input port="source">
               <p:inline>
                   <p>This pipeline successfully processed.</p>
               </p:inline>
           </p:input>
       </p:identity>
       </p:when>
       <p:otherwise>
           <p:identity>
               <p:input port="source">
                   <p:inline>
                       <p>This pipeline failed.</p>
                   </p:inline>
               </p:input>
           </p:identity>
       </p:otherwise>
   </p:choose>

   <p:identity>        (: need to explicitly define p:step to get multi container step output :)
       <p:input port="source">
           <p:step port="result" step="mychoosestep"/>
       </p:input>
   </p:identity>

</p:pipeline>}

return
    xproc:run($pipeline,$stdin)
    