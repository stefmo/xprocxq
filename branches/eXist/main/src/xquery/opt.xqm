xquery version "1.0" encoding "UTF-8";
module namespace opt = "http://xproc.net/xproc/opt";
(: -------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace comp="http://xproc.net/xproc/comp";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace u = "http://xproc.net/xproc/util";
import module namespace const = "http://xproc.net/xproc/const";


(: Module Vars :)
declare variable $opt:exec :=util:function("opt:exec", 3);
declare variable $opt:hash :=util:function("opt:hash", 3);
declare variable $opt:uuid :=util:function("opt:uuid", 3);
declare variable $opt:www-form-urldecode :=util:function("opt:www-form-urldecode", 3);
declare variable $opt:www-form-urlencode :=util:function("opt:www-form-urlencode", 3);
declare variable $opt:validate-with-xml-schema :=util:function("opt:validate-with-xml-schema", 3);
declare variable $opt:validate-with-schematron :=util:function("opt:validate-with-schematron", 3);
declare variable $opt:validate-with-relax-ng :=util:function("opt:validate-with-relax-ng", 3);
declare variable $opt:xquery :=util:function("opt:xquery", 3);
declare variable $opt:xsl-formatter :=util:function("opt:xsl-formatter", 3);

declare variable $opt:default-imports :='

    declare copy-namespaces no-preserve, no-inherit;

    import module namespace p = "http://xproc.net/xproc/functions"
                            at "src/xquery/functions.xqm";
';


(: -------------------------------------------------------------------------- :)
declare function opt:xquery($primary,$secondary,$options) {

u:assert(exists($secondary/xproc:input[@port='query']/c:query),'p:input query is required'),
(:TODO: need to sort out multiple c:query elements :)

    let $xquery := $secondary/xproc:input[@port='query']/c:query/.
    let $xqueryfunc := concat($opt:default-imports,$xquery)
    let $result := data(u:xquery($xqueryfunc))
        return
            u:outputResultElement($result)
};

(: -------------------------------------------------------------------------- :)
declare function opt:exec($primary,$secondary,$options) {
    u:outputResultElement(<test/>)
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
