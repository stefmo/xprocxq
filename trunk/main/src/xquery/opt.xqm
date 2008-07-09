xquery version "1.0" encoding "UTF-8";

module namespace opt = "http://xproc.net/xproc/opt";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";

(: Module Vars :)
declare variable $opt:steps := doc("../../etc/pipeline-optional.xml")/p:library;
declare variable $opt:xquery :=saxon:function("opt:xquery", 1);
declare variable $opt:exec :=saxon:function("opt:exec", 1);

(: -------------------------------------------------------------------------- :)


(: -------------------------------------------------------------------------- :)
declare function opt:xquery($seq) {

(: this should be caught as a static error someday ... will do it in refactoring 
util:assert(fn:exists($seq[2]/p:input[@port='query']/c:query),'p:input query is required'),
:)

(:TODO: need to sort out multiple c:query elements :)
let $xquery := $seq[2]/p:input[@port='query']/c:query/text()
return
    util:xquery($xquery)

};


(: -------------------------------------------------------------------------- :)
declare function opt:exec($seq) {
 $seq[1]
};


(: -------------------------------------------------------------------------- :)
