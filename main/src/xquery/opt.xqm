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
(:TODO: need to sort out multiple c:query elements :)
    util:xquery($seq[2]/c:query[1]/text())
};

(: -------------------------------------------------------------------------- :)
declare function opt:exec($seq) {
 $seq[1]
};

(: -------------------------------------------------------------------------- :)
