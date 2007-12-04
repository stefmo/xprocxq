xquery version "1.0" encoding "UTF-8";

module namespace std = "http://xproc.net/xproc/std";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";

declare variable $std:identity :=saxon:function("std:identity", 1);
declare variable $std:count :=saxon:function("std:count", 1);
declare variable $std:wrap :=saxon:function("std:wrap", 3);

declare function std:identity($seq as item()* ) as item()* {
    $seq
};

declare function std:count($seq as item()* ) as xs:integer {
    fn:count($seq)
};

declare function std:wrap($seq as item(),$option-wrap as xs:string,$option-match as xs:string ) as item() {
    let $v :=document{$seq}
    return
    element {$option-wrap} {
         util:evalXPATH($option-match,$v)
    }
};


