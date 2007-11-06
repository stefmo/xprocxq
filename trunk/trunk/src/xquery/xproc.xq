xquery version "1.0" encoding "UTF-8";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

import module namespace xproc = "http://xproc.net/xproc"
                        at "../xquery/xproc.xqm";

(: load in xproc xml :)
declare variable $xproc as item() external;

(: load in stdin xml :)
declare variable $stdin as item() external;

<c:result ts="{current-dateTime()}">
{
(: STEP I: run parse tree, report any static errors :)
let $parsetree := xproc:parse($xproc)

(: STEP II: build run tree, continue reporting any static errors :)
let $runtree := xproc:build($parsetree)

(: STEP III: execute run tree, reporting any dynamic errors :)
let $eval_result := xproc:eval($runtree,$stdin)

(: STEP IV: serialize and return results :)
let $serialized_result := xproc:output($eval_result)

return
    $serialized_result

}
</c:result>