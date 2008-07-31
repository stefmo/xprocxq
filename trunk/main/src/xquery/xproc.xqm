xquery version "1.0" encoding "UTF-8";

module namespace xproc = "http://xproc.net/xproc";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

(: TODO - need to check what std pragmas are needed for each xqm file :)
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


declare function xproc:comp-available($stepname as xs:string) as xs:boolean {
(: -------------------------------------------------------------------------- :)
(: checks to see if this component exists :)
(: -------------------------------------------------------------------------- :)

    let $component :=$comp:components/xproc:library/xproc:element[@type=$stepname]
    return
        exists($component)
};


(: -------------------------------------------------------------------------- :)
(: checks to see if this step is available :)
(: -------------------------------------------------------------------------- :)
declare function xproc:step-available($stepname as xs:string) as xs:boolean {

    let $stdstep := $std:steps/p:declare-step[@type=$stepname]
    let $optstep := $opt:steps/p:declare-step[@type=$stepname]
    let $extstep := $ext:steps/p:declare-step[@type=$stepname]
    return
        exists($stdstep) or exists($optstep) or exists($extstep)
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
declare function xproc:type($stepname as xs:string) as xs:string {

    let $stdstep := $std:steps/p:declare-step[@type=$stepname]
    let $optstep := $opt:steps/p:declare-step[@type=$stepname]
    let $extstep := $ext:steps/p:declare-step[@type=$stepname]
    let $component :=$comp:components/xproc:library/xproc:top-level-element[@type=$stepname]

    let $stdstepexists := exists($stdstep)        
    let $optstepexists := exists($optstep)
    let $extstepexists := exists($extstep)
    let $compexists := exists($component)
    return    
        if ($optstepexists) then
            'opt'
        else if($extstepexists) then
            'ext'
        else if($stdstepexists) then
            'std'
        else
            'comp'
};


(: -------------------------------------------------------------------------- :)
(: 1) make all step and input/output pipe names explicit :)
(: -------------------------------------------------------------------------- :)
declare function xproc:explicitnames($xproc as item(), $unique_id){

let $pipelinename := $xproc/@name

let $explicitnames := 

    let $steps :=$xproc/*

    for $step at $count in $steps

        let $stepname := name($step)

        let $unique_before := concat($unique_id,'!',$count - 1,':',$pipelinename,':',$step/@name)
        let $unique_current := concat($unique_id,'!',$count,':',$pipelinename,':',$step/@name)

        let $stdstep := $std:steps/p:declare-step[@type=$stepname]
        let $optstep := $opt:steps/p:declare-step[@type=$stepname]
        let $extstep := $ext:steps/p:declare-step[@type=$stepname]
        let $allstep :=($stdstep,$optstep,$extstep)

        return

        (: preparse xproc step :)    

            (: handle step element ------------------------------------------------------------ :)
                if(xproc:step-available($stepname)) then

                element {$stepname} { 
                     attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                     (
                        (: generate bindings for input and output:)
                        for $binding in $allstep/p:*[name(.)='p:input' or name(.)='p:output'] 
                            return
                              element {name($binding)}{
                                 attribute port{$binding/@port},attribute primary{$binding/@primary},attribute select{$step/p:input[@port=$binding/@port][@primary='true']/@select},
                               $step/p:*[name()=name($binding)]/p:*
                              },
                        (: generate options:)
                        for $option in $allstep//p:option 
                            return
                              element {name($option)}{
                                   attribute name{$option/@name},
                                   attribute select{$step//p:with-option[@name=$option/@name]/@select}
                              }
                     )
                   
                }

        (: handle xproc components ------------------------------------------------------------- :)
 
             else if (xproc:comp-available($stepname)) then
                element {$stepname} { 
                     attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                     (
                       xproc:explicitnames(<util:ignore>{$step/*}</util:ignore>,fn:concat($unique_current,':'))
                    )                   
                }
            else

 (: STATIC ERROR  ---------------------------------------------------------------------------------- :)
      (:TODO: need to implement static error here:)
            util:staticError("X0001", concat($stepname,$step/@name))

    return
        if(empty($pipelinename))then
            $explicitnames
        else
        <p:pipeline name="{$pipelinename}">
            {$explicitnames}
        </p:pipeline>
};



(: -------------------------------------------------------------------------- :)
(: 2) explicitly bind output to input ports :)
(: -------------------------------------------------------------------------- :)
(: make all input/output pipe bindings to steps explicit :)
declare function xproc:explicitbindings($xproc as item()){

let $pipelinename := $xproc/@name

let $explicitbindings := 

(    let $steps :=$xproc/*

    for $step at $count in $steps

      let $stepname := name($step) 
      return

        (: handle step element ----------------------------------------------------------------  :)
        if(xproc:step-available($stepname)) then

            element {$stepname} {
                 attribute name{$step/@name},attribute xproc:defaultname{$step/@xproc:defaultname},
                 attribute xproc:type{xproc:type($stepname)},
                (                 
                    (: generate bindings for input---------------------------------------------- :)
                    for $input in $step/p:input
                        return
                          element {name($input)}{
                             attribute port{$input/@port},
                             attribute primary{$input/@primary},
                             attribute select{$input/@select},

                            (: first step in pipeline :)
                            if (fn:not($xproc/*[$count - 1]/@*:defaultname) and $input/@primary='true') then
                                <p:pipe step="{$pipelinename}" port="{$xproc/p:input[@primary='true']/@port}"/> 

                           (: primary input step:)
                           else if ($input/@primary='true') then
                                <p:pipe step="{$xproc/*[$count - 1]/@*:defaultname}" port="{$xproc/*[$count - 1]/p:output[@primary='true']/@port}"/> 

                           (: other inputs :)
                           else if ($input/p:pipe and fn:not($input/@primary='true')) then
                                $input/*

                           (: p:document & p:inline & p:empty :)
                           else
                                $input/*
                          }

            ,(
                        for $option in $step//p:option 
                            return 
                                $option
                    ))
            
            }


         else if (xproc:comp-available($stepname)) then

            element {$stepname} {
                 attribute name{$step/@name},attribute xproc:defaultname{$step/@xproc:defaultname},
                 attribute xproc:type{xproc:type($stepname)},
                (
                   xproc:explicitbindings(<util:ignore>{$step/*}</util:ignore>) 
                )
            }

         else
 (: STATIC ERROR  ---------------------------------------------------------------------------------- :)
      (:TODO: need to implement static error here:)
            util:staticError("X0001", concat($stepname,$step/@name))

)
    return 
    (: if dealing with nested components --------------------------------------------------------- :)
        if(empty($pipelinename)) then
                    $explicitbindings
        else

    (: if dealing with p:pipeline component ------------------------------------------------------ :)
                <p:pipeline xmlns:xproc="http://xproc.net/xproc" name="{$pipelinename}" xproc:preparsed="true">
                    {$explicitbindings}
                </p:pipeline>

};


(: -------------------------------------------------------------------------- :)
(: Preparse pipeline XML, sorting steps by input, throwing some static errors :)
(: apply explicitnames then explicitbindings :)
(: -------------------------------------------------------------------------- :)
declare function xproc:preparse($xproc as item()){

let $preparse := util:pipeline-step-sort(
                        xproc:explicitbindings(
                            xproc:explicitnames($xproc,'')
                        ),
                  ())
return

(: TODO: Error Checking will go away :) 
    if (fn:not($preparse//err:error)) then     
        $preparse
    else
        (: there is some static error thrown by previous explicitbindings and/or explicitnames:)
        (:TODO: throws a rudimentary xproc static error 
        util:staticError('GenericStaticError',concat('preparse result: ',
           $preparse))
        :)
        $preparse

};


(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
(: TODO: dummy function for xquery unit tests :)
declare function xproc:parse($xproc as item()) {
    xproc:parse($xproc,fn:doc('file:test/data/test.xml'))
};

(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
declare function xproc:parse($xproc as item(),$stdin) {

   (fn:string('import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "src/xquery/opt.xqm";

let $O0 := '),util:serialize($stdin,<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>),
fn:string('
let $pipeline :='),util:serialize($xproc,<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>),
    fn:string('
let $steps := ('),xproc:gensteps($xproc),fn:string('"")'),
    fn:string('return util:step-fold($pipeline,$steps, saxon:function("xproc:evalstep", 3),($O0,""))')
)   
};


(: -------------------------------------------------------------------------- :)
(: Generate xquery steps sequence :)
declare function xproc:gensteps($steps) {
for $step in $steps/p:*[fn:not(fn:name()='p:documentation')] 
(: TODO: temp ignore of top level p:documentation elements, this feels a bit OUT OF BAND and needs refactoring :)
return
    let $name := $step/@xproc:defaultname
    return
         fn:string(concat('"',$name,'",'))                            
};


(: -------------------------------------------------------------------------- :)
(: Build Run Tree :)
(: NOTE: this function is more of a latent abstraction to use if needed, instead it justs :)
(: deals with concating strings of xquery code. :)
declare function xproc:build($parsetree) {
    fn:string-join($parsetree,'')
};


(: -------------------------------------------------------------------------- :)
(: Eval Run Tree :)
(: this function may throw some dynamic errors :)
declare function xproc:eval($runtree){
        util:xquery($runtree) 
};


(: -------------------------------------------------------------------------- :)
(: Serialize Eval Result :)
(: TODO: link up xproc serialization params  :)
declare function xproc:output($evalresult){
    $evalresult[1]
};


(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$primaryinput,$pipeline) {

(: TODO: boy all this is ugly; will need a refactor :)
let $stepfunction := fn:local-name($pipeline/*[@xproc:defaultname=$step])
let $stepfunc := fn:string(concat('import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "src/xquery/opt.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";','

$',$pipeline/*[@xproc:defaultname=$step]/@xproc:type,':',$stepfunction))

    return (

      (:TODO:temporary hack to get around blank steps, which are caused by input/outputs and top level elements for now :)
            if($stepfunction='') then
                $primaryinput
            else
                util:call( util:xquery($stepfunc),
 
                          (

      (: generate primary input source :)
                           if($pipeline/*[@xproc:defaultname=$step]/p:input[@select=''][@primary='true']) then
                                $primaryinput[1]
                           else
                               util:evalXPATH(fn:string($pipeline/*[@xproc:defaultname=$step]/p:input[@primary='true'][@select]/@select),document{$primaryinput[1]}),


      (: generate all non primary inputs :)                           
                           <xproc:inputs>{
                                for $input in $pipeline/*[@xproc:defaultname=$step]/p:input[not(@primary='true')]
                                    return 
                                        if ($input/p:document) then
                                            element {name($input)}{
                                             attribute port{$input/@port},attribute primary{$input/@primary},attribute select{$input/@select},
                                             if (fn:doc-available($input/p:document/@href)) then
                                                    fn:doc($input/p:document/@href)
                                             else
                                                util:dynamicError('err:XD0002',fn:concat($step," p:input ",$input/@port," cannot access document ",$input/p:document/@href))
                                            }
                                        else if($input/p:inline) then
                                           element {name($input)}{
                                            attribute port{$input/@port},
                                            attribute primary{$input/@primary},
                                            attribute select{$input/@select},
                                            $input/p:inline/node()
                                            }
                                        else
                                            <xproc:warning desc="xproc.xqm: generated automatically"/>                                            
                           }</xproc:inputs>, 

       (: outputs :)
                           <xproc:outputs>{
                                  $pipeline/*[@xproc:defaultname=$step]/p:output
                           }
                           </xproc:outputs> 
                            ,          
 

      (: generate options :)
                           <xproc:options>{
                                  $pipeline/*[@xproc:defaultname=$step]/p:option
                           }</xproc:options>
                            )
                )
    )

};


