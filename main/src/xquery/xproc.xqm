xquery version "1.0" encoding "UTF-8"; 

module namespace xproc = "http://xproc.net/xproc";

(: TODO: need to check what std pragmas are needed for each xqm file :)
declare copy-namespaces no-preserve, inherit; 

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

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
(: checks to see if this component exists :)
(: -------------------------------------------------------------------------- :)
declare function xproc:comp-available($stepname as xs:string) as xs:boolean {

    let $component :=$comp:components/xproc:library/xproc:element[@type=$stepname]
    return
        exists($component)
};



(: -------------------------------------------------------------------------- :)
(: returns step from step definitions :)
(: -------------------------------------------------------------------------- :)
declare function xproc:get-step($stepname as xs:string,$declare-step) {

    $std:steps/p:declare-step[@type=$stepname],
    $opt:steps/p:declare-step[@type=$stepname],
    $ext:steps/p:declare-step[@type=$stepname],
    $declare-step/p:declare-step[@type=$stepname]

};



(: -------------------------------------------------------------------------- :)
(: checks to see if this step is available :)
(: -------------------------------------------------------------------------- :)
declare function xproc:step-available($stepname as xs:string,$declare-step) as xs:boolean {

   exists(($std:steps/p:declare-step[@type=$stepname],
          $opt:steps/p:declare-step[@type=$stepname],
          $ext:steps/p:declare-step[@type=$stepname],
          $declare-step/p:declare-step[@type=$stepname]))
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
declare function xproc:type($stepname as xs:string) as xs:string {

    let $stdstep := $std:steps/p:declare-step[@type=$stepname]
    let $optstep := $opt:steps/p:declare-step[@type=$stepname]
    let $extstep := $ext:steps/p:declare-step[@type=$stepname]
    let $component :=$comp:components//xproc:element[@type=$stepname]

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
        else if($compexists) then
            'comp'
        else
            'unknown'
};



(: -------------------------------------------------------------------------- :)
(: 1) make all step and input/output pipe names explicit :)
(: -------------------------------------------------------------------------- :)
declare function xproc:explicitnames($xproc as item(), $unique_id){

let $pipelinename := $xproc/@name
let $declare-step := $xproc//p:declare-step

let $explicitnames := 

    for $step at $count in $xproc/*

        let $stepname := name($step)

        (: generate unique name :)
        (: TODO: refactor generation of name into a utility function :)
        let $unique_before := concat($unique_id,'!',$count - 1,':',$pipelinename,':',$step/@name)
        let $unique_current := concat($unique_id,'!',$count,':',$pipelinename,':',$step/@name)

        (: look up defined step in library :)
        let $allstep := xproc:get-step($stepname,$declare-step)

        return

            (: handle step element ------------------------------------------------------------ :)
                if(xproc:step-available($stepname,$declare-step)) then

(: util:step is a convention for wrapping top level ports :)
if($stepname eq "util:step") then

            (: generate input/output ports :)
                element {$stepname} {
                     attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                     $step/*
                     }
else
            (: generate step :)
                element {$stepname} {
                     attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                     (

                        (: generate bindings for input and output:)
                        for $binding in $allstep/p:*[name(.)='p:input' or name(.)='p:output'] 
                            return
                              element {name($binding)}{
                                 attribute port{$binding/@port},
                                 attribute primary{$binding/@primary},
                                 attribute select{$step/p:input[@port=$binding/@port]/@select},
                                 $step/p:input[@port=$binding/@port]/*
                              },

                        (: convert step attributes to options :)
                        (for $option-from-attribute in $step/@* 
                            return 
                            if (not(name($option-from-attribute)='name')) then
                                <p:option name="{name($option-from-attribute)}" select="{$option-from-attribute}"/>
                            else
                                ()
                         ),

                        (: match options with step definitions and generate options:)
                        for $option in $allstep//p:option 
                            return
                                if ($step//p:with-option[@name=$option/@name]/@select) then
                                  element {name($option)}{
                                       attribute name{$option/@name},
                                       attribute required{$option/@required},
                                       attribute select{$step//p:with-option[@name=$option/@name]/@select}
                                  }
                                else
                                    ()
                     )
                }

        (: handle xproc components ------------------------------------------------------------- :)
 
             else if (xproc:comp-available($stepname)) then
                element {$stepname} { 
                     attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                     (
                           (: need to recurse to get to nested subpipelines and steps :)
                           xproc:explicitnames(<util:ignore>{$step/*}</util:ignore>,fn:concat($unique_current,':'))
                    )                   
                }
            else

 (: STATIC ERROR  ---------------------------------------------------------------------------------- :)
            util:staticError("X0001", concat($stepname,":",$step/@name))

    return

        (: return topologically sorted pipeline  --------------------------------------------------- :)
        if(empty($pipelinename))then
                 util:pipeline-step-sort($explicitnames,())
            else
            <p:pipeline name="{$pipelinename}">
                { util:pipeline-step-sort($explicitnames,())}
            </p:pipeline>
};



(: -------------------------------------------------------------------------- :)
(: 2) explicitly bind output to input ports :)
(: -------------------------------------------------------------------------- :)
(: make all input/output pipe bindings to steps explicit :)
declare function xproc:explicitbindings($xproc as item()){

let $pipelinename := $xproc/@name
let $declare-step := $xproc//p:declare-step

let $explicitbindings := 

    for $step at $count in $xproc/*

      let $stepname := name($step) 
      return

        (: handle step element ----------------------------------------------------------------  :)
        if(xproc:step-available($stepname,$declare-step)) then

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

                    if ($input/p:document or $input/p:inline or $input/p:empty) then
                        (: copy document, inline, empty elements :)
                        $input/*
                    else
                    (

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
                    )

                          },
                        (for $option in $step//p:option 
                            return 
                                $option
                         ),
                         (for $output in $step/p:output 
                            return 
                                $output
                         )
                )
            
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
            util:staticError("X0001", concat($stepname,$step/@name))


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
(: Fix up top level input/output with util:step :)
(: -------------------------------------------------------------------------- :)
(: TODO: temporary measure to use util:step :)
declare function xproc:import-fixup($xproc as item()){

        <p:pipeline name="{$xproc/@name}">

{          
        for $import in $xproc/p:import
            return            
                if (fn:doc-available($import/@href)) then
                      fn:doc($import/@href)
                else
                      util:dynamicError('err:XD0002',"cannot import pipeline document ")
}
            {$xproc/p:*[not(name(.)="p:import")]}
        </p:pipeline>
};



(: -------------------------------------------------------------------------- :)
(: Fix up top level input/output with util:step :)
(: -------------------------------------------------------------------------- :)
(: TODO: temporary measure to use util:step :)
declare function xproc:port-fixup($xproc as item()){

        <p:pipeline name="{$xproc/@name}">
            <ext:pre name="{$xproc/@name}">
                {$xproc/p:input}
                {$xproc/p:output}
            </ext:pre>
            {$xproc/p:*[not(name(.)="p:input")][not(name(.)="p:output")]}
        </p:pipeline>
};


(: -------------------------------------------------------------------------- :)
(: Preparse pipeline XML, sorting steps by input, throwing some static errors :)
(: apply explicitnames then explicitbindings :)
(: -------------------------------------------------------------------------- :)
declare function xproc:preparse($xproc as item()){

    xproc:explicitbindings(
          xproc:explicitnames(
                xproc:port-fixup(
                      xproc:import-fixup($xproc)
                )
          ,'')
    )

};



(: -------------------------------------------------------------------------- :)
(: Generate xquery steps sequence :)
declare function xproc:gensteps1($steps) as xs:string* {

    for $step in $steps/*[fn:not(fn:name()='p:documentation')] 
    return
        let $name := $step/@xproc:defaultname
        return
             $name                            
};



(: -------------------------------------------------------------------------- :)
(: Generate xquery steps sequence :)
declare function xproc:gensteps2($steps) as xs:string*
{

    for $step in $steps/*[fn:not(fn:name()='p:documentation')] 
    return
        let $func := concat("$",$step/@xproc:type,":",local-name($step))
        return
             $func                            
};



(: -------------------------------------------------------------------------- :)
(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
declare function xproc:parse($xproc as item(),$stdin) {

    let $O0 := $stdin
    let $pipeline := $xproc
    let $steps := xproc:gensteps1($xproc)
    let $stepfunc := xproc:gensteps2($xproc)
    return
        xproc:evaltree($steps,$stepfunc,$pipeline,$O0)
};



(: -------------------------------------------------------------------------- :)
(: Eval Run Tree :)
declare function xproc:evaltree($steps,$stepfunc,$pipeline,$stdin){

    util:step-fold($pipeline,$steps,$stepfunc,saxon:function("xproc:evalstep", 5),($stdin,""),())

};



(: -------------------------------------------------------------------------- :)
(: Serialize Eval Result :)
(: TODO: implement xproc serialization params  :)
declare function xproc:output($evalresult,$flag){

    if($flag = 3) then
        $evalresult
    else if($flag = 2 ) then
        subsequence($evalresult,3)
    else if($flag = 1 ) then
        $evalresult[2]
    else 
        $evalresult[1]

        
};



(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$stepfunc1,$primaryinput,$pipeline,$resulttree) {

let $stepfunc := concat($const:default-imports,$stepfunc1)
let $currentstep := $pipeline/*[@xproc:defaultname=$step]
    return (
            util:call( util:xquery($stepfunc),
                       ( 
               
                    (: generate primary input source :)
                           if($currentstep/p:input[@primary='true'][@select='']) then

                           for $child in $currentstep/p:input/*
                           return
                           (
                                if(name($child)='p:empty') then

                                    ()

                                else if(name($child)='p:inline') then

                                    $child/*

                                else if($child/@href) then

                                             if (fn:doc-available($child/@href)) then
                                                   fn:doc($child/@href)
                                             else
                                                   util:dynamicError('err:XD0002',fn:concat(" cannot access document ",$child/@href))

                                else
                                    $primaryinput[1]
                            )

                           else if($currentstep/p:input[@primary='true'][@select]) then
                               util:evalXPATH(fn:string($pipeline/*[@xproc:defaultname=$step]/p:input[@primary='true'][@select]/@select),document{$primaryinput[1]})

                           else 
                               (<p:empty/>)

                               
                ,
                               

      (: non-primary inputs :)                           
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
                                            <xproc:warning message="xproc.xqm: generated automatically"/>                                            
                           }</xproc:inputs>, 

     (: outputs :)
                           <xproc:outputs>{
                                  $pipeline/*[@xproc:defaultname=$step]/p:output
                           }
                           </xproc:outputs> 
                            ,          

     (: options :)
                           <xproc:options>{
                                  $pipeline/*[@xproc:defaultname=$step]/p:option
                           }</xproc:options>
                            )
                )
    )

};