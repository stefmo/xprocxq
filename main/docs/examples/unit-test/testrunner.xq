xquery version "1.0" encoding "UTF-8";

declare namespace t="http://xproc.org/ns/testsuite";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";
import module namespace naming = "http://xproc.net/xproc/naming";

let $files := file:directory-list('/Users/jimfuller/Source/Webcomposite/xprocxq-exist/main/test/tests.xproc.org/required/','identity-*.xml')
return

<result>
{
for $file in $files/file:file

let $path := concat('file:///Users/jimfuller/Source/Webcomposite/xprocxq-exist/main/test/tests.xproc.org/required/',string($file/@name))
let $stdin :=doc($path)/t:test

let $pipeline := if (count($stdin//t:input) = 1) then
        doc('/db/examples/test-runner.xml')
    else
        doc('/db/examples/test-runner1.xml')
let $debug := 0
let $runtime-debug := '0'
    return
        util:catch('java.lang.Exception', xproc:run($pipeline,$stdin,$runtime-debug), concat('<fail name="',$file,'"/>')) 
        }
</result>
