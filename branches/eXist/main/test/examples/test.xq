xquery version "1.0" encoding "UTF-8";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace fn ="http://www.w3.org/TR/xpath-functions/";

(: Module Imports :)
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace const = "http://xproc.net/xproc/const";
import module namespace u = "http://xproc.net/xproc/util";
import module namespace opt = "http://xproc.net/xproc/opt";
import module namespace std = "http://xproc.net/xproc/std";
import module namespace ext = "http://xproc.net/xproc/ext";

let $stdin := <test><a/><b/><b/></test>

let $pipeline3 := document{<p:pipeline name="pipeline" xmlns:p="http://www.w3.org/ns/xproc">
<p:identity/>
<p:identity/>
<p:identity/>
<p:identity/>
</p:pipeline>
}

let $pipeline1 := document{<p:pipeline name="pipeline" xmlns:p="http://www.w3.org/ns/xproc">

<p:identity name="test1"/>
<p:group>
    <p:identity/>
    <p:wrap/>
</p:group>
<p:identity name="test1"/>

</p:pipeline>
}

let $pipeline4 := document{<p:pipeline name="pipeline" xmlns:p="http://www.w3.org/ns/xproc">

<p:for-each>
    <p:identity/>
</p:for-each>

</p:pipeline>
}

let $pipeline := document {<p:pipeline name="pipeline" xmlns:p="http://www.w3.org/ns/xproc">
<p:choose name="mychoosetest">
  <p:when test=".//b">
    <p:identity>
      <p:input port="source">
	<p:inline><p>true result</p></p:inline>
      </p:input>
    </p:identity>
  </p:when>
  <p:otherwise>
    <p:identity>
      <p:input port="source">
	<p:inline><p>false result</p></p:inline>
      </p:input>
    </p:identity>
  </p:otherwise>
</p:choose>

<p:xquery>
     <p:input port="query" >
         <p:inline>
             <c:query xmlns:c="http://www.w3.org/ns/xproc-step">
                 let $s:=1
                    return
                        $s
             </c:query>
         </p:inline>
     </p:input>
</p:xquery>

</p:pipeline>
}

let $bindings :=()
let $options :=()
let $dflag :="1"
let $tflag :="0"
let $internaldbg :=0

return
 if ($internaldbg eq 1) then
                xproc:explicitbindings(
                  naming:explicitnames(
                        naming:fixup($pipeline,$stdin)
                  )
                ,$const:init_unique_id
                )
    else if ($internaldbg eq 2) then
                  naming:explicitnames(
                       naming:fixup($pipeline,$stdin)
                  )
    else if ($internaldbg eq 3) then
        $stdin
    else
            xproc:run($pipeline,$stdin,$dflag,$tflag,$bindings,$options)
