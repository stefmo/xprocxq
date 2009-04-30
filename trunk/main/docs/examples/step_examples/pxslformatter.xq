xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

import module namespace xslfo = "http://exist-db.org/xquery/xslfo"; (: required for p:xsl-formatter :)

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=doc('/db/xqdocs/index.xml')//body             (: need eXist index page as example :)
  
let $pipeline :=document{<p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

<p:xslt>                                         
   <p:input port="stylesheet">
       <p:document href="{$local:XPROCXQ_EXAMPLES}/xslt/existdoc2pdf.xsl"/>
   </p:input>
</p:xslt>
<p:xsl-formatter href='{$local:XPROCXQ_EXAMPLES}/result/existdocs.pdf'/>

</p:pipeline>}

return
    xproc:run($pipeline,$stdin)
        