xquery version "1.0" encoding "UTF-8";


module namespace std = "http://xproc.net/xproc/std";
declare copy-namespaces no-preserve,inherit;


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
declare function std:add-attribute($primary,$secondary,$options) {

let $attrNames := util:get-option($options/p:with-option[@name='attribute-name']/@select,$primary)
let $attrValues := util:get-option($options/p:with-option[@name='attribute-value']/@select,$primary)
return
   for $element in $primary[1]/.
   return element { node-name($element)}
                  { for $attrName at $seq in $attrNames
                    return if ($element/@*[node-name(.) = $attrName])
                           then ()
                           else attribute {$attrName}
                                          {$attrValues[$seq]},
                    $element/@*,
                    $element/node() }


(:
util:treewalker(document{$primary[1]},
                saxon:function("util:attrHandler", 3),
                saxon:function("util:textHandler", 1),
                $attName,
                $attValue)

:)
};


(: -------------------------------------------------------------------------- :)
declare function std:add-xml-base($primary,$secondary,$options) {

(: TODO: need to refactor to pass in pipeline uri and any external input uri :)

let $all := xs:boolean(util:get-option($options/p:with-option[@name='all']/@select,$primary))
let $relative := xs:boolean(util:get-option($options/p:with-option[@name='relative']/@select,$primary))
let $attrNames := xs:QName('xml:base')
let $attrValues := base-uri($primary[1]) 

return
    if ($all) then
    for $element in $primary[1]/*
       return element { node-name($element)}
                      { for $attrName at $seq in $attrNames
                        return if ($element/@*[node-name(.) = $attrName])
                               then ()
                               else attribute {$attrName}
                                              {$attrValues[$seq]},
                        $element/@*,
                        $element/node() }
else
    for $element in $primary[1]/.
       return element { node-name($element)}
                      { for $attrName at $seq in $attrNames
                        return if ($element/@*[node-name(.) = $attrName])
                               then ()
                               else attribute {$attrName}
                                              {$attrValues[$seq]},
                        $element/@*,
                        $element/node() }
};


(: -------------------------------------------------------------------------- :)
(: TODO this is wrong, its counting the elements needs to count the sequence :)
declare function std:count($primary,$secondary,$options){

let $v := document{$primary}
let $limit := xs:integer(util:get-option($options/p:with-option[@name='limit']/@select,$v))
let $count := count($v/*)
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

let $alternate := $secondary/p:input[@port='alternate']/*
let $result := deep-equal($primary[1]/*,$alternate/*)
let $fail-if-not-equal := util:boolean($options/p:with-option[@name='fail-if-not-equal']/@select)
    return
        if($fail-if-not-equal eq true()) then
            if ( $result eq true())then
                (util:outputResultElement($result))
            else
                (util:stepError('err:XC0019','p:compare fail-if-not-equal option is enabled and documents were not equal'))
        else
            (util:outputResultElement($result))

};


(: -------------------------------------------------------------------------- :)
declare function std:error($primary,$secondary,$options) {
(: FIXME: this should be generated to the error port:)

<c:errors xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:p="http://www.w3.org/ns/xproc"
          xmlns:my="http://www.example.org/error">
<!-- WARNING: this output should be generated to std error and/or error port //-->
<c:error href="" column="" offset=""
         name="step-name" type="p:error"
         code="{$options/p:with-option[@name='code']/@value}">
    <message>{$primary}</message>
</c:error>
</c:errors>

};


(: -------------------------------------------------------------------------- :)
declare function std:delete($primary,$secondary,$options){

let $match := util:get-option($options/p:with-option[@name='match']/@select,$primary)
return
    util:remove-elements($primary[1],$match)
};


(: -------------------------------------------------------------------------- :)
declare function std:directory-list($primary,$secondary,$options) {
 
(: this should be caught as a static error someday ... will do it in refactoring  :)
util:assert(exists($options/p:with-option[@name='path']),'p:directory-list path option does not exist'),

    (util:outputResultElement(collection('file:/')))

};


(: -------------------------------------------------------------------------- :)
declare function std:declare-step($primary,$secondary,$options) {

    <todo>need to process this step, this will also be used for embedded p:group and subpipelines</todo>

};


(: -------------------------------------------------------------------------- :)
declare function std:escape-markup($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:filter($primary,$secondary,$options) {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(exists($options/p:with-option[@name='select']/@select),'p:with-option match is required'),

let $v :=document{$primary}
let $xpath := util:get-option($options/p:with-option[@name='select']/@select,$v)
let $result := util:evalXPATH(string($xpath),$v)
    return
        if(exists($result)) then
            $result
        else
            $xpath
};

(: -------------------------------------------------------------------------- :)
declare function std:http-request($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function std:identity($primary,$secondary,$options) {
   $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:insert($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:label-elements($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:load($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:make-absolute-uris($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:namespace-rename($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:pack($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:parameters($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:rename($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:replace($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:set-attributes($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:sink($primary,$secondary,$options) {
    (string(''))
};


(: -------------------------------------------------------------------------- :)
declare function std:split-sequence($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:store($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:string-replace($primary,$secondary,$options) {
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:unescape-markup($primary,$secondary,$options){
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:xinclude($primary,$secondary,$options){
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap($primary,$secondary,$options) {
(: TODO - The match option must only match element, text, processing instruction, and comment nodes. It is a dynamic error (err:XC0041) if the match pattern matches any other kind of node. :)

util:assert(exists($options/p:with-option[@name='match']/@select),'p:with-option match is required'),
util:assert(exists($options/p:with-option[@name='wrapper']/@select),'p:with-option wrapper is required'),

    let $v :=document{$primary}
    let $wrapper := util:get-option($options/p:with-option[@name='wrapper']/@select,$v)
    let $match := util:get-option($options/p:with-option[@name='match']/@select,$v)
    let $replace := util:evalXPATH($match,$v)

    return
       document 
       {
        element {string($wrapper)} {
            util:evalXPATH($match,$v)
        }
       } 
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap-sequence($primary,$secondary,$options){
    $primary
};


(: -------------------------------------------------------------------------- :)
declare function std:unwrap($primary,$secondary,$options) {

(: this should be caught as a static error someday ... will do it in refactoring :)
util:assert(exists($options/p:with-option[@name='match']/@select),'p:with-option match is required'),

(: TODO - The value of the match option must be an XSLTMatchPattern. It is a dynamic error (err:XC0023)
if that pattern matches anything other than element nodes. :)
let $v :=document{$primary}
let $match := util:get-option($options/p:with-option[@name='match']/@select,$v)
    return
         util:evalXPATH($match,$v)
};


(: -------------------------------------------------------------------------- :)
declare function std:xslt($primary,$secondary,$options){

    util:assert(exists($secondary/p:input[@port='stylesheet']),'stylesheet is required'),
    let $v :=document{$primary}
    let $stylesheet := $secondary/p:input[@port='stylesheet']/*
    return
        (util:xslt($stylesheet,$v))
};


(: -------------------------------------------------------------------------- :)