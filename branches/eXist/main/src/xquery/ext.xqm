xquery version "1.0" encoding "UTF-8";
module namespace ext = "http://xproc.net/xproc/ext";
(: ------------------------------------------------------------------------------------- 

	ext.xqm - implements all xprocxq specific extension steps.
	
---------------------------------------------------------------------------------------- :)


declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace u = "http://xproc.net/xproc/util";

(: -------------------------------------------------------------------------- :)

(: Module Vars :)
declare variable $ext:pre :=util:function(xs:QName("ext:pre"), 3);
declare variable $ext:post :=util:function(xs:QName("ext:post"), 3);
declare variable $ext:test :=util:function(xs:QName("ext:test"), 3);
declare variable $ext:step :=util:function(xs:QName("ext:step"), 3);

(: -------------------------------------------------------------------------- :)
declare function ext:pre($primary,$secondary,$options){
   $primary/*[1]
};
declare function ext:step($primary,$secondary,$options){
    $primary
};
declare function ext:post($primary,$secondary,$options){
    $primary
};
declare function ext:test($primary,$secondary,$options){
    $primary
};
(: -------------------------------------------------------------------------- :)



(: -------------------------------------------------------------------------- :)