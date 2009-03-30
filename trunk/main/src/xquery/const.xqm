xquery version "1.0" encoding "UTF-8";
module namespace const = "http://xproc.net/xproc/const";
(: -------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xproc = "http://xproc.net/xproc";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

(: XProc Namespaces :)
declare variable $const:NS_XPROC := "http://www.w3.org/ns/xproc";
declare variable $const:NS_XPROC_STEP := "http://www.w3.org/ns/xproc-step";
declare variable $const:NS_XPROC_ERR := "http://www.w3.org/ns/xproc-error";

(: -------------------------------------------------------------------------- :)

declare variable $const:TRACE_SERIALIZE :=<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" saxon:indent-spaces="1"/>;

(: -------------------------------------------------------------------------- :)

(: XProc Extension Namespaces :)
declare variable $const:NS_XPROC_EXT := "http://xproc.net/ns/xproc/ex";
declare variable $const:NS_XPROC_ERR_EXT := "http://xproc.net/ns/errors";

(: -------------------------------------------------------------------------- :)

(: Module Vars :)
(: doesnt work as intended
declare variable  $const:evalstep := saxon:function("xproc:evalstep", 5);
:)

(: -------------------------------------------------------------------------- :)
(: error dictionaries :)
declare variable  $const:error := doc("etc/error-list.xml");
declare variable  $const:error-xprocxq := doc("etc/error-xprocxq.xml");

(: -------------------------------------------------------------------------- :)

declare variable $const:ext-steps := doc("etc/pipeline-extension.xml")/p:library;
declare variable $const:std-steps := doc("etc/pipeline-standard.xml")/p:library;
declare variable $const:opt-steps := doc("etc/pipeline-optional.xml")/p:library;
declare variable $const:comp-components := doc("etc/xproc-component.xml")/xproc:components;

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

(: Step naming convention init :)
declare variable $const:init_unique_id :="!1";

(: -------------------------------------------------------------------------- :)
(: define default imported modules :)
declare variable $const:default-imports :='

    declare copy-namespaces no-preserve, no-inherit;

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
    import module namespace comp = "http://xproc.net/xproc/comp"
                            at "src/xquery/comp.xqm";';

(: -------------------------------------------------------------------------- :)

declare function const:episode() as xs:string {
   string('some random string')
};

declare function const:product-name() as xs:string {
    $const:product-name
};

declare function const:product-version() as xs:string {
    $const:product-version
};

declare function const:vendor() as xs:string {
    $const:vendor
};

declare function const:vendor-uri() as xs:string {
    $const:vendor-uri
};

declare function const:version() as xs:string {
    $const:version
};

declare function const:xpath-version() as xs:string {
    $const:xpath-version
};