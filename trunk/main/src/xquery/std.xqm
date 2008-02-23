xquery version "1.0" encoding "UTF-8";

module namespace std = "http://xproc.net/xproc/std";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";

(: Module Vars :)
declare variable $std:steps := doc("../../etc/pipeline-standard.xml")/p:library;

declare variable $std:identity :=saxon:function("std:identity", 1);
declare variable $std:count :=saxon:function("std:count", 1);
declare variable $std:wrap :=saxon:function("std:wrap", 1);
declare variable $std:unwrap :=saxon:function("std:unwrap", 1);
declare variable $std:compare :=saxon:function("std:compare",1);
declare variable $std:delete :=saxon:function("std:delete",1);
declare variable $std:error :=saxon:function("std:error",1);

(: -------------------------------------------------------------------------- :)

declare function std:identity($seq) as item() {
    $seq[1]
};

(: -------------------------------------------------------------------------- :)
declare function std:count($seq) as item() {
    <c:result>{fn:count($seq[1])}</c:result>
};

(: -------------------------------------------------------------------------- :)
declare function std:compare($seq) as item() {
        <c:result>{fn:deep-equal($seq[1],$seq[2])}</c:result>
};

(: -------------------------------------------------------------------------- :)
declare function std:wrap($seq) as item() {

let $v :=document{$seq[1]}
    return
    element {$seq[4]/p:option[@name='wrapper']/@value} {
         util:evalXPATH(fn:string($seq[4]/p:option[@name='match']/@value),$v)
    }
};

(: -------------------------------------------------------------------------- :)
declare function std:unwrap($seq) as item() {
let $v :=document{$seq[1]}
    return
         util:evalXPATH(fn:string($seq[4]/p:option[@name='match']/@value),$v)
};

(: -------------------------------------------------------------------------- :)
declare function std:delete($seq) as item() {

let $v :=document{$seq[1]}
let $delete := util:evalXPATH(fn:string($seq[4]/p:option[@name='match']/@value),$v)
return
   $v/* except $delete
};

(: -------------------------------------------------------------------------- :)
declare function std:error($seq) as item() {
(:TODO: this should be generated to the error port:)

<c:errors xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:p="http://www.w3.org/ns/xproc"
          xmlns:my="http://www.example.org/error">
<!-- WARNING: this output should be generated to std error and/or error port //-->
<c:error name="step-name" type="p:error" code="{$seq[4]/p:option[@name='code']/@value}">
    <message>{$seq[1]}</message>
</c:error>
</c:errors>

};

(: -------------------------------------------------------------------------- :)