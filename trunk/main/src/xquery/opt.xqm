xquery version "1.0" encoding "UTF-8";
module namespace opt = "http://xproc.net/xproc/opt";
(: -------------------------------------------------------------------------- :)

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace runtime="java:net.xproc.opt.runtimeExec";
declare namespace comp="http://xproc.net/xproc/comp";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "util.xqm";

(: Module Vars :)
declare variable $opt:steps := doc("etc/pipeline-optional.xml")/p:library;
declare variable $opt:exec :=saxon:function("opt:exec", 3);
declare variable $opt:hash :=saxon:function("opt:hash", 3);
declare variable $opt:uuid :=saxon:function("opt:uuid", 3);
declare variable $opt:www-form-urldecode :=saxon:function("opt:www-form-urldecode", 3);
declare variable $opt:www-form-urlencode :=saxon:function("opt:www-form-urlencode", 3);
declare variable $opt:validate-with-xml-schema :=saxon:function("opt:validate-with-xml-schema", 3);
declare variable $opt:validate-with-schematron :=saxon:function("opt:validate-with-schematron", 3);
declare variable $opt:validate-with-relax-ng :=saxon:function("opt:validate-with-relax-ng", 3);
declare variable $opt:xquery :=saxon:function("opt:xquery", 3);
declare variable $opt:xsl-formatter :=saxon:function("opt:xsl-formatter", 3);


(: -------------------------------------------------------------------------- :)
declare function opt:xquery($primary,$secondary,$options) {

util:assert(exists($secondary/xproc:input[@port='query']/c:query),'p:input query is required'),

(:TODO: need to sort out multiple c:query elements :)
    let $xquery := $secondary/xproc:input[@port='query']/c:query/text()
    let $result := data(util:xquery($xquery))
        return
            (util:outputResultElement($result))
};

(: -------------------------------------------------------------------------- :)
declare function opt:exec($primary,$secondary,$options) {
    util:outputResultElement(

(:        runtime:main(string($options/p:with-option[@name='command']/@select))

:)
runtime:main("/bin/ls")

    )
};

(: -------------------------------------------------------------------------- :)
declare function opt:hash($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:uuid($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:www-form-urldecode($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:www-form-urlencode($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:validate-with-xml-schema($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:validate-with-schematron($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:validate-with-relax-ng($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
declare function opt:xsl-formatter($primary,$secondary,$options) {
 $primary
};

(: -------------------------------------------------------------------------- :)
