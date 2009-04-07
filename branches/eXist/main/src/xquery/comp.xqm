xquery version "1.0" encoding "UTF-8";
module namespace comp = "http://xproc.net/xproc/comp";
(: ------------------------------------------------------------------------------------- 

	comp.xqm - implements all xproc multi container steps.
	
---------------------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace u = "http://xproc.net/xproc/util";
import module namespace const = "http://xproc.net/xproc/const";

(: -------------------------------------------------------------------------- :)

declare variable $comp:declare-step :=util:function(xs:QName("comp:declare-step"), 3);
declare variable $comp:choose :=util:function(xs:QName("comp:choose"), 4);
declare variable $comp:when :=util:function(xs:QName("comp:when"), 3);
declare variable $comp:otherwise :=util:function(xs:QName("comp:otherwise"), 3);
declare variable $comp:for-each :=util:function(xs:QName("comp:for-each"), 3);

(:
declare variable $comp:parse_eval :=util:function(xs:QName("xproc:parse_and_eval"), 3);
:)

(: -------------------------------------------------------------------------- :)
declare function comp:choose($primary,$secondary,$options,$step) {
    let $v := document{$primary/*[1]}
    let $stepfunc :=concat($const:default-imports,())
    let $when := $step/p:when
    let $otherwise := $step/p:otherwise
    let $when_eval :=u:evalXPATH(string($when/@test),$v)
    return
        if($when_eval) then
            <test1/>
        else
            u:call(u:xquery($stepfunc),<p:declare-step><p:input port="source" primary="true"/>{$otherwise/*}</p:declare-step>,$v,<test/>)
};


(: -------------------------------------------------------------------------- :)
declare function comp:when($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:otherwise($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:for-each($primary,$secondary,$options) {
    $primary
};

(: -------------------------------------------------------------------------- :)
declare function comp:declare-step($primary,$secondary,$options) {
    $primary
};

