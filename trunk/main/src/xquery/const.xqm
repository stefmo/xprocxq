xquery version "1.0" encoding "UTF-8";

module namespace const = "http://xproc.net/xproc/const";

(: XProc Namespaces :)
declare variable $const:NS_XPROC := "http://www.w3.org/ns/xproc";
declare variable $const:NS_XPROC_STEP := "http://www.w3.org/ns/xproc-step";
declare variable $const:NS_XPROC_ERR := "http://www.w3.org/ns/xproc-error";

(: -------------------------------------------------------------------------- :)

(: XProc Extension Namespaces :)
declare variable $const:NS_XPROC_EXT := "http://xproc.net/ns/xproc/ex";
declare variable $const:NS_XPROC_ERR_EXT := "http://xproc.net/ns/errors";

(: -------------------------------------------------------------------------- :)

(: Module Vars :)

(: -------------------------------------------------------------------------- :)
(: error dictionaries :)
declare variable  $const:error-static := doc("../../etc/error-dynamic.xml")/errors/error;
declare variable  $const:error-dynamic := doc("../../etc/error-dynamic.xml")/errors/error;
declare variable  $const:error-step := doc("../../etc/error-step.xml")/errors/error;
declare variable  $const:error-xproc := doc("../../etc/error-xproc.xml");

(: -------------------------------------------------------------------------- :)

(: Version :)
declare variable $const:version :="0.5";

(: Product Version :)
declare variable $const:product-version :="0.5";

(: Product Name :)
declare variable $const:product-name :="xproc.xq";

(: Vendor :)
declare variable $const:vendor :="James Fuller";

(: Language :)
declare variable $const:language :="en";

(: Vendor-uri :)
declare variable $const:vendor-uri :="http://www.xproc.net/xproc.xq";

(: XPATH Version :)
declare variable $const:xpath-version :="2.0";

(: -------------------------------------------------------------------------- :)
(: define default imported modules :)
declare variable $const:default-imports :='
import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "src/xquery/opt.xqm";

';

(: -------------------------------------------------------------------------- :)
