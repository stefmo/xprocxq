xquery version "1.0" encoding "UTF-8";
module namespace const = "http://xproc.net/xproc/const";
(: ------------------------------------------------------------------------------------- 
 
	const.xqm - contains all constants used by xprocxq.
	
---------------------------------------------------------------------------------------- :)

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xproc = "http://xproc.net/xproc";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";


(: -------------------------------------------------------------------------- :)
(: XProc Namespace Constants :)
declare variable $const:NS_XPROC := "http://www.w3.org/ns/xproc";
declare variable $const:NS_XPROC_STEP := "http://www.w3.org/ns/xproc-step";
declare variable $const:NS_XPROC_ERR := "http://www.w3.org/ns/xproc-error";


(: -------------------------------------------------------------------------- :)

declare variable $const:DEFAULT_SERIALIZE := 'method=xml indent=yes';
declare variable $const:TRACE_SERIALIZE := 'method=xml';
declare variable $const:XINCLUDE_SERIALIZE := 'expand-xincludes=yes';
declare variable $const:TEXT_SERIALIZE := 'method=text';
declare variable $const:ESCAPE_SERIALIZE := 'method=xml';


(: -------------------------------------------------------------------------- :)

(: XProc Extension Namespaces :)
declare variable $const:NS_XPROC_EXT := "http://xproc.net/ns/xproc/ex";
declare variable $const:NS_XPROC_ERR_EXT := "http://xproc.net/ns/errors";

(: -------------------------------------------------------------------------- :)

(: -------------------------------------------------------------------------- :)
(: error dictionaries :)
declare variable $const:error := doc("resource:net/xproc/xprocxq/etc/error-list.xml");
declare variable  $const:xprocxq-error := doc("resource:net/xproc/xprocxq/etc/xproc-error-list.xml");

(: -------------------------------------------------------------------------- :)

declare variable $const:ext-steps := doc("resource:net/xproc/xprocxq/etc/pipeline-extension.xml")/p:library;
declare variable $const:std-steps := doc("resource:net/xproc/xprocxq/etc/pipeline-standard.xml")/p:library;
declare variable $const:opt-steps := doc("resource:net/xproc/xprocxq/etc/pipeline-optional.xml")/p:library;
declare variable $const:comp-steps := doc("resource:net/xproc/xprocxq/etc/xproc-component.xml")/xproc:components;

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

(: PSVI supported :)
declare variable $const:psvi-supported :="false";

(: Episode :)
declare variable $const:episode :="somerandomnumber";

(: -------------------------------------------------------------------------- :)

(: Step naming convention init :)
declare variable $const:init_unique_id :="!1";

(: -------------------------------------------------------------------------- :)
(: define default imported modules :)
declare variable $const:default-imports :='

	(: const:default-imports :)
    declare copy-namespaces no-preserve, no-inherit;

    import module namespace const = "http://xproc.net/xproc/const";
    import module namespace xproc = "http://xproc.net/xproc";
    import module namespace u = "http://xproc.net/xproc/util";
    import module namespace std = "http://xproc.net/xproc/std";
    import module namespace ext = "http://xproc.net/xproc/ext";
    import module namespace opt = "http://xproc.net/xproc/opt";

	declare option exist:serialize "expand-xincludes=no";

';


declare variable $const:alt-imports :=' declare copy-namespaces no-preserve, no-inherit; import module namespace p = "http://xproc.net/xproc/functions";';

(: -------------------------------------------------------------------------- :)

