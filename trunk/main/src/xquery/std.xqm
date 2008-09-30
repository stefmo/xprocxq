xquery version "1.0" encoding "UTF-8";

module namespace std = "http://xproc.net/xproc/std";
declare copy-namespaces no-preserve,inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";

(: Module Vars :)
declare variable $std:steps := doc("../../etc/pipeline-standard.xml")/p:library;
declare variable $std:add-attribute :=saxon:function("std:add-attribute", 3);
declare variable $std:add-xml-base :=saxon:function("std:add-xml-base", 3);
declare variable $std:count :=saxon:function("std:count", 3);
declare variable $std:compare :=saxon:function("std:compare",3);
declare variable $std:delete :=saxon:function("std:delete",3);
declare variable $std:declare-step :=saxon:function("std:declare-step",3);
declare variable $std:error :=saxon:function("std:error",3);
declare variable $std:filter :=saxon:function("std:filter",3);
declare variable $std:directory-list :=saxon:function("std:directory-list", 3);
declare variable $std:escape-markup :=saxon:function("std:escape-markup", 3);
declare variable $std:http-request :=saxon:function("std:http-request", 3);
declare variable $std:identity :=saxon:function("std:identity", 3);
declare variable $std:label-elements :=saxon:function("std:label-elements", 3);
declare variable $std:load :=saxon:function("std:load", 3);
declare variable $std:make-absolute-uris :=saxon:function("std:make-absolute-uris", 3);
declare variable $std:namespace-rename :=saxon:function("std:namespace-rename", 3);
declare variable $std:pack :=saxon:function("std:pack", 3);
declare variable $std:parameters :=saxon:function("std:parameters", 3);
declare variable $std:rename :=saxon:function("std:rename", 3);
declare variable $std:replace :=saxon:function("std:replace", 3);
declare variable $std:set-attributes :=saxon:function("std:set-attributes", 3);
declare variable $std:sink :=saxon:function("std:sink", 3);
declare variable $std:split-sequence :=saxon:function("std:split-sequence", 3);
declare variable $std:store :=saxon:function("std:store", 3);
declare variable $std:string-replace :=saxon:function("std:string-replace", 3);
declare variable $std:unescape-markup :=saxon:function("std:unescape-markup", 3);
declare variable $std:xinclude :=saxon:function("std:xinclude", 3);
declare variable $std:wrap :=saxon:function("std:wrap", 3);
declare variable $std:wrap-sequence :=saxon:function("std:wrap-sequence", 3);
declare variable $std:unwrap :=saxon:function("std:unwrap", 3);
declare variable $std:xslt :=saxon:function("std:xslt", 3);


(: -------------------------------------------------------------------------- :)
declare function std:add-attribute($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:add-xml-base($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:directory-list($primary,$secondary,$options) as item() {
 
(: this should be caught as a static error someday ... will do it in refactoring  :)
util:assert(exists($options/p:option[@name='path']),'p:directory-list path option does not exist'),

    (util:outputResultElement(collection('file:/')))

};


(: -------------------------------------------------------------------------- :)
declare function std:declare-step($primary,$secondary,$options) as item() {

    <todo>need to process this step, this will also be used for embedded p:group and subpipelines</todo>

};


(: -------------------------------------------------------------------------- :)
declare function std:escape-markup($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:http-request($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:insert($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:label-elements($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:load($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:make-absolute-uris($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:namespace-rename($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:pack($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:parameters($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:rename($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:replace($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:set-attributes($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:sink($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:split-sequence($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:store($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:string-replace($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:unescape-markup($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:xinclude($primary,$secondary,$options) as item() {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:identity($primary,$secondary,$options) as item()* {
   $primary
};


(: -------------------------------------------------------------------------- :)
(: TODO this is wrong, its counting the elements needs to count the sequence :)
declare function std:count($primary,$secondary,$options){

let $test := ($primary)
let $limit := xs:integer($options/p:option[@name='limit']/@select)
let $count := count($test)
return
    if (empty($limit)) then
       util:outputResultElement(
        $count
       )
    else if ($count < $limit) then
       util:outputResultElement(
       $count
       )
    else
       util:outputResultElement(
         $limit
       )
};


(: -------------------------------------------------------------------------- :)
declare function std:compare($primary,$secondary,$options) {

util:assert(exists($secondary/p:input[@port='alternate']),'p:compare alternate port does not exist'),

let $result := deep-equal($primary[1]/*,$secondary/p:input[@port='alternate']/*)
let $option := util:boolean($options/p:option[@name='fail-if-not-equal']/@select)
    return

        if($option eq true()) then
            if ( $result eq true())then
                (util:outputResultElement($result))
            else
                (util:dynamicError('err:XC0020','p:compare fail-if-not-equal option is enabled and documents were not equal'))
        else
            (util:outputResultElement($result))
};


(: -------------------------------------------------------------------------- :)
declare function std:delete($primary,$secondary,$options) as item(){
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:error($primary,$secondary,$options) as item() {
(:TODO: this should be generated to the error port:)

<c:errors xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:p="http://www.w3.org/ns/xproc"
          xmlns:my="http://www.example.org/error">
<!-- WARNING: this output should be generated to std error and/or error port //-->
<c:error href="" column="" offset="" 
         name="step-name" type="p:error" 
         code="{$options/p:option[@name='code']/@value}">
    <message>{$primary}</message>
</c:error>
</c:errors>

};


(: -------------------------------------------------------------------------- :)
declare function std:filter($primary,$secondary,$options) as item() {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(exists($options/p:option[@name='select']/@select),'p:option match is required'),

let $v :=document{$primary}
let $xpath := util:evalXPATH(string($options/p:option[@name='select']/@select),$v)
let $result := util:evalXPATH(string($xpath),$v)
    return
        if(exists($result)) then
            $result
        else
            $xpath
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap($primary,$secondary,$options) as item() {
(: TODO - The match option must only match element, text, processing instruction, and comment nodes. It is a dynamic error (err:XC0041) if the match pattern matches any other kind of node. :)

util:assert(exists($options/p:option[@name='match']/@select),'p:option match is required'),
util:assert(exists($options/p:option[@name='wrapper']/@select),'p:option wrapper is required'),

    let $v :=document{$primary}
    return
       document 
       {
        element {string($options/p:option[@name='wrapper']/@select)} {
            util:evalXPATH($options/p:option[@name='match']/@select,$v)
        }
       } 
};


(: -------------------------------------------------------------------------- :)
declare function std:unwrap($primary,$secondary,$options) as item() {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(exists($options/p:option[@name='match']/@select),'p:option match is required'),

(: TODO - The value of the match option must be an XSLTMatchPattern. It is a dynamic error (err:XC0023) if that pattern matches anything other than element nodes. :)
let $v :=document{$primary}
    return
         util:evalXPATH($options/p:option[@name='match']/@select,$v)
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap-sequence($primary,$secondary,$options){
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:xslt($primary,$secondary,$options){

    util:assert(exists($secondary/p:input[@port='stylesheet']),'stylesheet is required'),
    let $v :=document{$primary}
    return
        util:xslt($secondary/p:input[@port='stylesheet']/*,$v)
};


(: -------------------------------------------------------------------------- :)