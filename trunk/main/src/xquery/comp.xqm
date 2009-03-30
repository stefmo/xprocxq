xquery version "1.0" encoding "UTF-8";
module namespace comp = "http://xproc.net/xproc/comp";
(: -------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)

import module namespace util = "http://xproc.net/xproc/util"
                        at "util.xqm";

(: -------------------------------------------------------------------------- :)

declare variable $comp:declare-step :=saxon:function("comp:declare-step", 3);
declare variable $comp:choose :=saxon:function("comp:choose", 3);
declare variable $comp:when :=saxon:function("comp:when", 3);
declare variable $comp:otherwise :=saxon:function("comp:otherwise", 3);
declare variable $comp:for-each :=saxon:function("comp:for-each", 3);


(: -------------------------------------------------------------------------- :)
declare function comp:choose($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function comp:when($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:otherwise($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:for-each($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:declare-step($primary,$secondary,$options) {
    $primary
};

