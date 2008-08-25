xquery version "1.0" encoding "UTF-8";

module namespace comp = "http://xproc.net/xproc/comp";
declare copy-namespaces no-preserve,inherit;

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "../xquery/const.xqm";

import module namespace util = "http://xproc.net/xproc/util"
                        at "../../src/xquery/util.xqm";

declare variable $comp:components := doc("../../etc/xproc-component.xml");

(: -------------------------------------------------------------------------- :)

declare function comp:episode() as xs:string {
   fn:string(util:random())
};

declare function comp:product-name() as xs:string {
    $const:product-name
};

declare function comp:product-version() as xs:string {
    $const:product-version
};

declare function comp:vendor() as xs:string {
    $const:vendor
};

declare function comp:vendor-uri() as xs:string {
    $const:vendor-uri
};

declare function comp:version() as xs:string {
    $const:version
};

declare function comp:xpath-version() as xs:string {
    $const:xpath-version
};

(: -------------------------------------------------------------------------- :)
