xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<doc>
                    	<title>Title</title>
                    	<p>Some paragraph.</p>
                      </doc>
                      }

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:directory-list path="/usr/local/bin" include-filter='*.*'/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'0')