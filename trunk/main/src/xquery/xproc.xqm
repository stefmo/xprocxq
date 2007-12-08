xquery version "1.0" encoding "UTF-8";

module namespace xproc = "http://xproc.net/xproc";


(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

declare copy-namespaces no-preserve, inherit;

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "../xquery/const.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "../xquery/std.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "../xquery/opt.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "../xquery/ext.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "../xquery/comp.xqm";

(: -------------------------------------------------------------------------- :)

declare function xproc:main() as xs:string {
    "main xproc.xq executed"
};

(: -------------------------------------------------------------------------- :)

(: Preparse pipeline XML, sorting along the way, throwing some static errors :)
declare function xproc:preparse($xproc as item()){
    let $sortsteps := <p:pipeline>{util:pipeline-step-sort($xproc/node(),())}</p:pipeline>
    return $sortsteps
};


(: Parse pipeline XML, generating xquery code, throwing some static errors :)
declare function xproc:parse($xproc as item()) {

   (fn:string('import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "src/xquery/comp.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
let $O0 := <test/>  '),

    fn:string('let $steps := ("pre step",$ext:pre,'),    
    xproc:gensteps($xproc),
    fn:string('"post-step",$ext:post)'),
    fn:string('return util:step-fold($steps, saxon:function("xproc:evalstep", 3),($O0,""))')
)
};


(: -------------------------------------------------------------------------- :)


(: Generate output xquery statement :)
declare function xproc:genoutput($steps as item()) {
for $step at $count in $steps/p:pipeline/*[fn:name()='p:output']
return 
     fn:string(concat('let $PO',$count,' := "primary output" '))   
};

    
(: Generate xquery steps sequence :)
declare function xproc:gensteps($steps) {
for $step in $steps/p:*[fn:not(fn:name()='p:documentation')] (: note: ignore top level p:documentation elements :)
return
    let $name := $step/@name
    return
    (
     fn:string(concat('"',$name,'",')),
     fn:string(concat('$std:',$step/fn:local-name(),','))

    )                            
};


(: -------------------------------------------------------------------------- :)
(: Build Run Tree :)
(: TODO: this needs to be refactored, working with strings is not the plan with XML! :)
declare function xproc:build($parsetree) {
    fn:string-join($parsetree,'')
};


(: -------------------------------------------------------------------------- :)
(: Eval Run Tree :)
(: this function may throw some dynamic errors :)
declare function xproc:eval($runtree,$stdin){
    util:xquery($runtree) 
};


(: -------------------------------------------------------------------------- :)
(: Serialize Eval Result :)
(: TODO: link up xproc serialization params  :)
declare function xproc:output($evalresult){
    $evalresult[1]
};

(: -------------------------------------------------------------------------- :)


(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$name,$state) as xs:anyAtomicType* {

(: 
    step: step-function
    meta: sequence containing input and output
:)

       (util:call( $step, $state[1]),"output results")
};
(: -------------------------------------------------------------------------- :)

