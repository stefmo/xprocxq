xquery version "1.0" encoding "UTF-8";
module namespace ext = "http://xproc.net/xproc/ext";
(: -------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "util.xqm";

(: -------------------------------------------------------------------------- :)

(: Module Vars :)
declare variable $ext:pre :=saxon:function("ext:pre", 3);
declare variable $ext:post :=saxon:function("ext:post", 3);
declare variable $ext:test :=saxon:function("ext:test", 3);
declare variable $ext:step :=saxon:function("ext:step", 3);
declare variable $ext:xproc :=saxon:function("xproc:run-step", 3);

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