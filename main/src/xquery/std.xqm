xquery version "1.0" encoding "UTF-8";
module namespace std = "http://xproc.net/xproc/std";
(: ------------------------------------------------------------------------------------- 

	std.xqm - Implements all standard xproc steps.
	
---------------------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xproc = "http://xproc.net/xproc";


declare namespace saxon = "http://dummy.org";

(: Module Imports :)
import module namespace u = "http://xproc.net/xproc/util";
import module namespace const = "http://xproc.net/xproc/const";


(: -------------------------------------------------------------------------- :)

(: Module Vars :)
declare variable $std:add-attribute :=util:function(xs:QName("std:add-attribute"), 3);
declare variable $std:add-xml-base :=util:function(xs:QName("std:add-xml-base"), 3);
declare variable $std:count :=util:function(xs:QName("std:count"), 3);
declare variable $std:compare :=util:function(xs:QName("std:compare"),3);
declare variable $std:delete :=util:function(xs:QName("std:delete"),3);
declare variable $std:error :=util:function(xs:QName("std:error"), 3);
declare variable $std:filter :=util:function(xs:QName("std:filter"), 3);
declare variable $std:directory-list :=util:function(xs:QName("std:directory-list"), 3);
declare variable $std:escape-markup :=util:function(xs:QName("std:escape-markup"), 3);
declare variable $std:http-request :=util:function(xs:QName("std:http-request"), 3);
declare variable $std:identity :=util:function(xs:QName("std:identity"), 3);
declare variable $std:label-elements :=util:function(xs:QName("std:label-elements"), 3);
declare variable $std:load :=util:function(xs:QName("std:load"), 3);
declare variable $std:make-absolute-uris :=util:function(xs:QName("std:make-absolute-uris"), 3);
declare variable $std:namespace-rename :=util:function(xs:QName("std:namespace-rename"), 3);
declare variable $std:pack :=util:function(xs:QName("std:pack"), 3);
declare variable $std:parameters :=util:function(xs:QName("std:parameters"), 3);
declare variable $std:rename :=util:function(xs:QName("std:rename"), 3);
declare variable $std:replace :=util:function(xs:QName("std:replace"), 3);
declare variable $std:set-attributes :=util:function(xs:QName("std:set-attributes"), 3);
declare variable $std:sink :=util:function(xs:QName("std:sink"), 3);
declare variable $std:split-sequence :=util:function(xs:QName("std:split-sequence"), 3);
declare variable $std:store :=util:function(xs:QName("std:store"), 3);
declare variable $std:string-replace :=util:function(xs:QName("std:string-replace"), 3);
declare variable $std:unescape-markup :=util:function(xs:QName("std:unescape-markup"), 3);
declare variable $std:xinclude :=util:function(xs:QName("std:xinclude"), 3);
declare variable $std:wrap :=util:function(xs:QName("std:wrap"), 3);
declare variable $std:wrap-sequence :=util:function(xs:QName("std:wrap-sequence"), 3);
declare variable $std:unwrap :=util:function(xs:QName("std:unwrap"), 3);
declare variable $std:xslt :=util:function(xs:QName("std:xslt"), 3);


(: -------------------------------------------------------------------------- :)
declare function std:add-attribute($primary,$secondary,$options) {

(: TODO: need to refactor match attribute :)

let $v := u:get-primary($primary)
let $match := u:get-option('match',$options,$v)
let $attrName := u:get-option('attribute-name',$options,$v)
let $attrValue := u:get-option('attribute-value',$options,$v)
return
    u:treewalker-add-attribute($v,$match,$attrName,$attrValue)
};


(: -------------------------------------------------------------------------- :)
declare function std:add-xml-base($primary,$secondary,$options) {

(: TODO: need to refactor to pass in pipeline uri and any external input uri :)

let $v := u:get-primary($primary)
let $all := xs:boolean(u:get-option('all',$options,$v))
let $relative := xs:boolean(u:get-option('relative',$options,$v))
let $attrNames := xs:QName('xml:base')
let $attrValues := base-uri($v) 

return
    if ($all) then
    for $element in $v/*
       return element { node-name($element)}
                      { for $attrName at $seq in $attrNames
                        return if ($element/@*[node-name(.) = $attrName])
                               then ()
                               else attribute {$attrName}
                                              {$attrValues[$seq]},
                        $element/@*,
                        $element/node() }
else
    for $element in $v/*
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
declare function std:compare($primary,$secondary,$options) {
let $v := u:get-primary($primary)
let $result := deep-equal($v,u:get-secondary('alternate',$secondary))
let $fail-if-not-equal := xs:boolean(u:get-option('fail-if-not-equal',$options,$v))
    return

       if($fail-if-not-equal) then
            if ($result) then          
      			u:outputResultElement('true')
            else
                u:stepError('err:XC0019','p:compare fail-if-not-equal option is enabled and documents were not equal')
        else
            u:outputResultElement($result)
};


(: -------------------------------------------------------------------------- :)
declare function std:count($primary,$secondary,$options){
let $v := u:get-primary($primary)
let $limit := xs:integer(u:get-option('limit',$options,$v))
let $count := count($v/*)
return

    if (empty($limit) or $limit eq 0 or $count lt $limit ) then
		u:outputResultElement($count)
    else
   		u:outputResultElement($limit)
};

(: -------------------------------------------------------------------------- :)
declare function std:delete($primary,$secondary,$options){
let $v := u:get-primary($primary)
let $match := u:get-option('match',$options,$v)
return
	u:copy-filter-elements($v, $match)
};


(: -------------------------------------------------------------------------- :)
declare function std:directory-list($primary,$secondary,$options) {
let $v := u:get-primary($primary)
let $path := u:get-option('path',$options,$v)
return
    u:outputResultElement(collection($path))
};


(: -------------------------------------------------------------------------- :)
declare function std:escape-markup($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
    u:serialize($v,$const:TRACE_SERIALIZE)
};


(: -------------------------------------------------------------------------- :)
declare function std:error($primary,$secondary,$options) {
(: TODO: this should be generated to the error port:)

let $v := u:get-primary($primary)
let $code := u:get-option('code',$options,$v)
let $err := <c:errors xmlns:c="http://www.w3.org/ns/xproc-step"
          xmlns:p="http://www.w3.org/ns/xproc"
          xmlns:my="http://www.example.org/error">
		<c:error href="" column="" offset=""
         	name="step-name" type="p:error"
         	code="{$code}">
    		<message>{$v}</message>
		</c:error>
</c:errors>
return
	u:dynamicError('err:XD0030',concat(": p:error throw custom error code - ",$code," ",u:serialize($err,$const:TRACE_SERIALIZE)))


};


(: -------------------------------------------------------------------------- :)
declare function std:filter($primary,$secondary,$options) {
(: TODO: is it an error for a empty match ? :)
u:assert(exists($options/p:with-option[@name='select']/@select),'p:with-option match is required'),

let $v := u:get-primary($primary)
let $xpath := u:get-option('select',$options,$v)
let $result := u:evalXPATH(string($xpath),$v)
    return
        if(exists($result)) then
            $result
        else
            $xpath
};


(: -------------------------------------------------------------------------- :)
declare function std:http-request($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:identity($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:insert($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:label-elements($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:load($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:make-absolute-uris($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:namespace-rename($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:pack($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:parameters($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:rename($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:replace($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:set-attributes($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:sink($primary,$secondary,$options) {
    (string(''))
};


(: -------------------------------------------------------------------------- :)
declare function std:split-sequence($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:store($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:string-replace($primary,$secondary,$options) {
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:unescape-markup($primary,$secondary,$options){
(: TODO: doesnt work with nested xml elements :)
let $v := u:get-primary($primary)
let $parsed := document{u:serialize($v,$const:TRACE_SERIALIZE)}
return
    util:parse($parsed)
};


(: -------------------------------------------------------------------------- :)
declare function std:xinclude($primary,$secondary,$options){
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap($primary,$secondary,$options) {
(: TODO - The match option must only match element, text, processing instruction, and comment nodes. It is a dynamic error (err:XC0041) if the match pattern matches any other kind of node. :)

u:assert(exists($options/p:with-option[@name='match']/@select),'p:with-option match is required'),
u:assert(exists($options/p:with-option[@name='wrapper']/@select),'p:with-option wrapper is required'),

	let $v := u:get-primary($primary)
    let $wrapper := u:get-option('wrapper',$options,$v)
    let $match := u:get-option('match',$options,$v)
    let $replace := u:evalXPATH($match,$v)

    return
       document 
       {
        element {string($wrapper)} {
            u:evalXPATH($match,$v)
        }
       } 
};


(: -------------------------------------------------------------------------- :)
declare function std:wrap-sequence($primary,$secondary,$options){
let $v := u:get-primary($primary)
return
	$v
};


(: -------------------------------------------------------------------------- :)
declare function std:unwrap($primary,$secondary,$options) {

(: this should be caught as a static error someday ... will do it in refactoring :)
u:assert(exists($options/p:with-option[@name='match']/@select),'p:with-option match is required'),

(: TODO - The value of the match option must be an XSLTMatchPattern. It is a dynamic error (err:XC0023)
if that pattern matches anything other than element nodes. :)
let $v := u:get-primary($primary)
let $match := u:get-option('match',$options,$v)
    return
         u:evalXPATH($match,$v)
};


(: -------------------------------------------------------------------------- :)
declare function std:xslt($primary,$secondary,$options){

    u:assert(exists($secondary/xproc:input[@port='stylesheet']/*),'stylesheet is required'),
	let $v := u:get-primary($primary)
    let $stylesheet := u:get-secondary('stylesheet',$secondary)
    return
        u:xslt($stylesheet,$v)
};


(: -------------------------------------------------------------------------- :)