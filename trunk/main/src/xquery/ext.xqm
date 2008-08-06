xquery version "1.0" encoding "UTF-8";

module namespace ext = "http://xproc.net/xproc/ext";

declare namespace comp = "http://xproc.net/xproc/comp";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Module Vars :)
declare variable  $ext:steps := doc("../../etc/pipeline-extension.xml")/p:library;


(: -------------------------------------------------------------------------- :)

declare variable $ext:pre :=saxon:function("ext:pre", 1);
declare variable $ext:post :=saxon:function("ext:post", 1);
declare variable $ext:test :=saxon:function("ext:test", 1);
declare variable $ext:step :=saxon:function("ext:step", 1);


(: -------------------------------------------------------------------------- :)
declare function ext:pre($seq ) as item()* {
    $seq
};

(: -------------------------------------------------------------------------- :)
declare function ext:step($seq ) as item()* {
    $seq
};

declare function ext:post($seq ) as item()* {
    $seq
};

declare function ext:test($seq ) as item()* {
    $seq
};

(: -------------------------------------------------------------------------- :)