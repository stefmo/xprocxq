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
declare variable $opt:exec :=saxon:function("opt:exec", 1);
declare variable $opt:hash :=saxon:function("opt:hash", 1);
declare variable $opt:uuid :=saxon:function("opt:uuid", 1);
declare variable $opt:www-form-urldecode :=saxon:function("opt:www-form-urldecode", 1);
declare variable $opt:www-form-urlencode :=saxon:function("opt:www-form-urlencode", 1);
declare variable $opt:validate-with-xml-schema :=saxon:function("opt:validate-with-xml-schema",1);
declare variable $opt:validate-with-schematron :=saxon:function("opt:validate-with-schematron",1);
declare variable $opt:validate-with-relax-ng :=saxon:function("opt:validate-with-relax-ng",1);
declare variable $opt:xquery :=saxon:function("opt:xquery", 1);
declare variable $opt:xsl-formatter :=saxon:function("opt:xsl-formatter", 1);

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
declare function opt:hash($seq) {
 $seq[1]
};

(: -------------------------------------------------------------------------- :)
declare function opt:uuid($seq) {
 $seq[1]
};


(: -------------------------------------------------------------------------- :)
declare function opt:www-form-urldecode($seq) {
 $seq[1]
};

(: -------------------------------------------------------------------------- :)
declare function opt:www-form-urlencode($seq) {
 $seq[1]
};

(: -------------------------------------------------------------------------- :)
declare function opt:validate-with-xml-schema($seq) {
    util:validate("test")
};

(: -------------------------------------------------------------------------- :)
declare function opt:validate-with-schematron($seq) {
    util:validate("test")
};

(: -------------------------------------------------------------------------- :)
declare function opt:validate-with-relax-ng($seq) {
    util:validate("test")
};

(: -------------------------------------------------------------------------- :)
declare function opt:xsl-formatter($seq) {
 $seq[1]
};

(: -------------------------------------------------------------------------- :)
