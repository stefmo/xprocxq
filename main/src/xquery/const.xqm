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