xquery version "1.0" encoding "UTF-8";

module namespace ext = "http://xproc.net/xproc/ext";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: -------------------------------------------------------------------------- :)

declare function ext:main() as xs:string {
    "ext entry point executed"
};


(: -------------------------------------------------------------------------- :)

declare variable $ext:pre :=saxon:function("ext:pre-step", 1);
declare variable $ext:post :=saxon:function("ext:post-step", 1);

declare function ext:pre-step($seq as item()* ) as item()* {
    $seq
};

declare function ext:post-step($seq as item()* ) as item()* {
    $seq
};

(: -------------------------------------------------------------------------- :)