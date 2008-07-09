xquery version "1.0" encoding "UTF-8";

module namespace std = "http://xproc.net/xproc/std";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";

(: Module Vars :)
declare variable $std:steps := doc("../../etc/pipeline-standard.xml")/p:library;

(: TODO: generate these declarations :)
declare variable $std:identity :=saxon:function("std:identity", 1);
declare variable $std:count :=saxon:function("std:count", 1);
declare variable $std:compare :=saxon:function("std:compare",1);
declare variable $std:delete :=saxon:function("std:delete",1);
declare variable $std:error :=saxon:function("std:error",1);
declare variable $std:filter :=saxon:function("std:filter",1);
declare variable $std:wrap :=saxon:function("std:wrap", 1);
declare variable $std:wrap-sequence :=saxon:function("std:wrap-sequence", 1);
declare variable $std:unwrap :=saxon:function("std:unwrap", 1);
declare variable $std:xslt :=saxon:function("std:xslt", 1);


(: -------------------------------------------------------------------------- :)
declare function std:identity($seq) as item() {
    $seq[1]
};


(: -------------------------------------------------------------------------- :)
declare function std:count($seq) as item() {
   util:outputResultElement(fn:count($seq[1]/node()))
};


(: -------------------------------------------------------------------------- :)
declare function std:compare($seq) as item() {

(: this should be caught as a static error someday ... will do it in refactoring  :)
util:assert(fn:exists($seq[2]/p:input[@port='alternate']),'p:compare alternate port does not exist'),

let $result := fn:deep-equal($seq[1],$seq[2]/p:input[@port='alternate']/*)
let $option := fn:boolean($seq[4]/p:option[@name='fail-if-not-equal']/@select)
    return
        if($option eq fn:true()) then
            if ( $result eq fn:true())then
                (util:outputResultElement($result))
            else
                (util:dynamicError('err:XC0020','p:compare fail-if-not-equal option is enabled and documents were not equal'))
        else
            (util:outputResultElement($result))
        
};


(: -------------------------------------------------------------------------- :)
declare function std:delete($seq) as item() {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(fn:exists($seq[4]/p:option[@name='match']/@select),'p:option match is required'),

let $v :=document{$seq[1]}
    return (
      $v 
    )
};


(: -------------------------------------------------------------------------- :)
declare function std:error($seq) as item() {
(:TODO: this should be generated to the error port:)

<c:errors xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:p="http://www.w3.org/ns/xproc"
          xmlns:my="http://www.example.org/error">
<!-- WARNING: this output should be generated to std error and/or error port //-->
<c:error href="" column="" offset="" 
         name="step-name" type="p:error" 
         code="{$seq[4]/p:option[@name='code']/@value}">
    <message>{$seq[1]}</message>
</c:error>
</c:errors>

};


(: -------------------------------------------------------------------------- :)
declare function std:filter($seq) as item() {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(fn:exists($seq[4]/p:option[@name='select']/@select),'p:option match is required'),

let $v :=document{$seq[1]}
let $xpath := util:evalXPATH(fn:string($seq[4]/p:option[@name='select']/@select),$v)
let $result := util:evalXPATH(fn:string($xpath),$v)
    return 
    if(fn:exists($result)) then
        $result
    else 
        $xpath
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap($seq) as item() {
(: TODO - The match option must only match element, text, processing instruction, and comment nodes. It is a dynamic error (err:XC0041) if the match pattern matches any other kind of node. :)
(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(fn:exists($seq[4]/p:option[@name='match']/@select),'p:option match is required'),

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(fn:exists($seq[4]/p:option[@name='wrapper']/@select),'p:option wrapper is required'),

    let $v :=document{$seq[1]}
    return
       document 
       {
        element {fn:string($seq[4]/p:option[@name='wrapper']/@select)} {
            util:evalXPATH($seq[4]/p:option[@name='match']/@select,$v)
        }
       } 
};


(: -------------------------------------------------------------------------- :)
declare function std:unwrap($seq) as item() {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(fn:exists($seq[4]/p:option[@name='match']/@select),'p:option match is required'),

(: TODO - The value of the match option must be an XSLTMatchPattern. It is a dynamic error (err:XC0023) if that pattern matches anything other than element nodes. :)
let $v :=document{$seq[1]}
    return
         util:evalXPATH($seq[4]/p:option[@name='match']/@select,$v)
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap-sequence($seq){
    $seq[1]
};


(: -------------------------------------------------------------------------- :)
declare function std:xslt($seq){
    util:xslt($seq[2]/p:input[@port='stylesheet']/*,$seq[1])
};


(: -------------------------------------------------------------------------- :)