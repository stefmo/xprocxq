xquery version "1.0" encoding "UTF-8";

module namespace std = "http://xproc.net/xproc/std";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

declare function std:identity($seq as item()* ) as item()* {
    $seq
};

declare function std:count($seq as item()* ) as xs:integer {
    fn:count($seq)
};


