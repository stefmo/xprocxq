xquery version "1.0" encoding "UTF-8";

module namespace comp = "http://xproc.net/xproc/comp";
declare copy-namespaces no-preserve,inherit;

(: Module Imports :)

import module namespace util = "http://xproc.net/xproc/util"
                        at "util.xqm";

(: -------------------------------------------------------------------------- :)

declare variable $comp:components := doc("../../etc/xproc-component.xml");
declare variable $comp:choose :=saxon:function("comp:choose", 3);
declare variable $comp:for-each :=saxon:function("comp:for-each", 3);

(: -------------------------------------------------------------------------- :)
declare function comp:choose($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:for-each($primary,$secondary,$options) {
    $primary
};

