xquery version "1.0" encoding "UTF-8";
(: ///////////////////////////////////////////////////

    test.xq is used to see if xprocxq is running properly 
    
    make sure you have read the README.eXist for installation
    instructions
    
    :)

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace fn ="http://www.w3.org/TR/xpath-functions/";

(: Module Imports - these are all static xquery imports from xproxq.jar :)
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace const = "http://xproc.net/xproc/const";
import module namespace u = "http://xproc.net/xproc/util";
import module namespace opt = "http://xproc.net/xproc/opt";
import module namespace std = "http://xproc.net/xproc/std";
import module namespace ext = "http://xproc.net/xproc/ext";

(: standard source input :)
let $stdin := <test>
                   <a/>
                   <b/>
                   <b/>
              </test>

(: here are a few pipeline examples to supply to xproc:run :)
let $pipeline := document{<p:pipeline name="pipeline" xmlns:p="http://www.w3.org/ns/xproc">
    <p:identity/>
    <p:identity/>
    <p:identity/>
    <p:identity/>
</p:pipeline>
}

(: this pipeline demonstrates how a p:choose works, note that we have a limitation with @test xpath 
as eXist converts root document to './' :)
let $pipeline1 := document {<p:pipeline name="pipeline" xmlns:p="http://www.w3.org/ns/xproc">
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

</p:pipeline>
} (: amend xproc:run below to use this pipeline, e.g. supply with $pipeline1:)

(: disabled params :)
let $external-bindings :=() (: external bindings is disabled for the time being :)
let $external-options :=() (: external options is disabled for the time being :)
let $timing-flag :="0" (: timing flag is disabled for the time being :)

(: debug flags:)
let $debug-flag :="0" (: to get a trace of preparsed pipeline, all generated port bindings and result switch this to 1 :)
let $test-debug :=0  (: to see only the preparsed pipeline, switch this to 1 :)

return

 if ($test-debug eq 1) then
    xproc:explicitbindings(
      naming:explicitnames(
            naming:fixup($pipeline,$stdin)
      )
    ,$const:init_unique_id
    )
  else
    (: xprocxq entry point - this is what you would use in your own programs:)
    xproc:run($pipeline,$stdin,$debug-flag,$timing-flag,$external-bindings,$external-options)
    
