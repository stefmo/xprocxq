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
(: make all input/output bindings explicit :)
declare function xproc:explicitbinding($xproc as item()){
(:TODO: currently this is a test :)

    let $explicitbinding := <p:pipeline name="{$xproc/@name}" xproc:preparsed="true">{

let $stdsteps := doc("../../etc/pipeline-standard.xml")/p:library
let $optsteps := doc("../../etc/pipeline-optional.xml")/p:library
let $extsteps := doc("../../etc/pipeline-extension.xml")/p:library
let $component := doc("../../etc/xproc-component.xml")/xproc:library

for $step at $count  in $xproc/node()

let $stepname := local-name($step)
let $uniqueid := concat('!',$count,$step/@name,':',fn:string(1+util:random()),':',fn:string(fn:current-time()))
let $stdstep := $stdsteps/p:declare-step[contains(@type,$stepname)]

let $stdstepexists := exists($stdsteps/p:declare-step[contains(@type,$stepname)])
let $optstepexists := exists($optsteps/p:declare-step[contains(@type,$stepname)])
let $extstepexists := exists($extsteps/p:declare-step[contains(@type,$stepname)])
let $compexists := exists($component/xproc:top-level-element[contains(@type,$stepname)])

   return

if($stdstepexists=true()  
   or $optstepexists=true()
   or $extstepexists=true()
   or $compexists=true()
) then

    if (local-name($step)='input' or local-name($step)='output') then

        element {name($step)} { 
            attribute port {$step/@port},
            <p:pipe step="{$xproc/@name}" port="bindtorightport"/> 
        }
        
    else

    if ($step is $xproc/node()[last( )])
    then

           element {name($step)} { 
                attribute name{$step/@name},attribute xproc:default-name {$uniqueid},
                (
                   for $binding in $stdstep/*[@primary='true']
                       return
                            element {name($binding)}{attribute port {$binding/@port},
                              <p:pipe step="laststepbinding" port="{$binding/@port}"/> 
                            }
                )                   
            }

    else
            element {name($step)} { 
                attribute name{$step/@name},attribute xproc:default-name {$uniqueid},
                (
                   for $binding in $stdstep/*[@primary='true']
                       return
                            element {name($binding)}{attribute port {$binding/@port},
                              <p:pipe step="bindtorighstep" port="{$binding/@port}"/> 
                            }
                )                   
            }

else 
(: TODO: will need to replace this with an actual error call :)
   <err:error message="static xproc error"/>

}
    </p:pipeline>
    return 
        $explicitbinding
};


(: -------------------------------------------------------------------------- :)
(: Preparse pipeline XML, sorting steps by input, throwing some static errors :)
declare function xproc:preparse($xproc as item()){
    let $sortsteps := <p:pipeline>{util:pipeline-step-sort($xproc/node(),())}</p:pipeline>
    return $sortsteps
};


(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
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
(: Generate xquery steps sequence :)
declare function xproc:gensteps($steps) {
for $step in $steps/p:*[fn:not(fn:name()='p:documentation')] 
(: TODO: temp ignore of top level p:documentation elements, this feels a bit OUT OF BAND and needs refactoring :)
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
(: TODO: this needs to be refactored. :)
declare function xproc:build($parsetree) {

    fn:string-join($parsetree,'')
};


(: -------------------------------------------------------------------------- :)
(: Eval Run Tree :)
(: this function may throw some dynamic errors :)
declare function xproc:eval($runtree,$stdin){

(:trace($runtree, "xproc:eval runtree: "),:)

    util:xquery($runtree) 
};


(: -------------------------------------------------------------------------- :)
(: Serialize Eval Result :)
(: TODO: link up xproc serialization params  :)
declare function xproc:output($evalresult){

(:trace($evalresult, "xproc:output evalresult: "),:)

    $evalresult[1]
};


(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$name,$state) as xs:anyAtomicType* {

(:trace($name, "name: "),trace($state[1],"state:"),:)

(: 
    step: step-function
    meta: sequence containing input and output
:)

        (: return a sequence, will replace TEMP OUTPUT  soon :)
       (util:call( $step, $state[1]),"test output")
};


