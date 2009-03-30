xquery version "1.0" encoding "UTF-8"; 
module namespace naming = "http://xproc.net/xproc/naming";
(: -------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "const.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "std.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "opt.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "ext.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "comp.xqm";



declare function naming:uniqueid($unique_id,$count){
    concat($unique_id,'.',$count)
};

(: -------------------------------------------------------------------------- :)
(: checks to see if this component exists :)
(: -------------------------------------------------------------------------- :)
declare function naming:comp-available($compname as xs:string) as xs:boolean {
        exists(naming:get-comp($compname))
};


(: -------------------------------------------------------------------------- :)
(: returns comp from comp definitions :)
(: -------------------------------------------------------------------------- :)
declare function naming:get-comp($compname as xs:string) {
    $const:comp-components/xproc:element[@type=$compname]
};


(: -------------------------------------------------------------------------- :)
(: returns step from std, opt and ext step definitions :)
(: -------------------------------------------------------------------------- :)
declare function naming:get-step($stepname as xs:string,$declarestep) {
    $const:std-steps/p:declare-step[@type=$stepname],
    $const:opt-steps/p:declare-step[@type=$stepname],
    $const:ext-steps/p:declare-step[@type=$stepname],
    $declarestep/@type
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
declare function naming:type($stepname as xs:string,$is_declare-step) as xs:string {

    let $stdstep := $const:std-steps/p:declare-step[@type=$stepname]
    let $optstep := $const:opt-steps/p:declare-step[@type=$stepname]
    let $extstep := $const:ext-steps/p:declare-step[@type=$stepname]
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
        else if($is_declare-step) then
          string(substring-before($is_declare-step/@type,':'))
        else
          util:staticError('err:XS0044', concat($stepname,":",$stepname,' has no visible declaration'))
};


                        (: --------------------------------------------------------------------------- :)
                                                                                 (: PREPARSE I ROUTINES:)
                        (: --------------------------------------------------------------------------- :)


declare function naming:preparse-options($allstep,$step,$stepname){
    for $option in $allstep
        return

            if ($step/p:with-option[@name=$option/@name] and $step/@*[name(.)=$option/@name]) then

               util:staticError('err:XS0027', concat($stepname,":",$step/@name,' option:',$option/@name,' duplicate options'))

            else if ($option/@required eq 'true' and $option/@select) then

               util:staticError('err:XS0017', concat($stepname,":",$step/@name,' option:',$option/@name,' duplicate options'))

            else if ($step/p:with-option[@name=$option/@name]) then

               <p:with-option name="{$option/@name}" select="{$step/p:with-option[@name=$option/@name]/@select}"/>

            else if($step/@*[name(.)=$option/@name]) then

               <p:with-option name="{$option/@name}" select="{concat("'",$step/@*[name(.)=$option/@name],"'")}"/>

            else if($option/@select) then

               <p:with-option name="{$option/@name}" select="{$option/@select}"/>

            else if(not($step/p:with-option[@name=$option/@name] and $step/@*[name(.)=$option/@name]) and $option/@required eq 'true') then

                util:staticError('err:XS0018', concat($stepname,":",$step/@name,' option:',$option/@name,' is required and seems to be missing or incorrect'))

            else
                (: TODO: may have to throw additional errors before this :)
                <p:with-option name="{$option/@name}" select="{$option/@default}"/>

};


declare function naming:preparse-input-bindings($allstep,$step,$allbindings){

if ($allbindings eq 'all') then
    $step/p:input
else
    for $binding in $allstep
       let $currentport := $step/*[@port=$binding/@port]
        return
            element {node-name($binding)} {
               $binding/@port,
               $binding/@primary,
               $binding/@kind,
               $binding/@sequence,

               if($currentport/@select='') then
                  attribute select{$binding/@select}
               else if($currentport/@select) then
                  $currentport/@select
               else
                  attribute select{$binding/@select},
                   $currentport/*
               }
};

declare function naming:preparse-output-bindings($allstep,$step,$allbindings){

if ($allbindings eq 'all') then
    $step/p:output
else
    for $binding in $allstep
       let $currentport := $step/*[@port=$binding/@port]
        return
            element {node-name($binding)} {
               $binding/@port,
               $binding/@primary,
               $binding/@kind,
               $binding/@sequence,
               if($currentport/@select='') then
                  attribute select{$binding/@select}
               else if($currentport/@select) then
                  $currentport/@select
               else
                  attribute select{$binding/@select},
                   $currentport/*
               }
};

declare function naming:generate-step($step,$stepname,$allstep){
    element {node-name($step)} {
        attribute name{$step/@name},
        naming:preparse-input-bindings($allstep/p:*[@primary='true'],$step,$allstep/@xproc:bindings),
        naming:preparse-output-bindings($allstep/p:*[@primary='false'],$step,$allstep/@xproc:bindings),
        naming:preparse-options($allstep/p:option,$step,$stepname)
   }
};


declare function naming:generate-component($xproc,$allcomp,$step,$stepname){

        element {node-name($step)} {
            if ($step/@type) then attribute type{$step/@type} else (),
            if ($step/@psvi-required) then attribute psvi-required{$step/@psvi-required} else (),
            if ($step/@xpath-version) then attribute xpath-version{$step/@xpath-version} else (),
            if ($step/@exclude-inline-prefixes) then attribute exclude-inline-prefixes{$step/@exclude-inline-prefixes} else (),

            if ($allcomp/@xproc:step = "true") then attribute name{$step/@name} else (),

            if ($step/@port) then attribute port{$step/@port} else (),
            if ($step/@select) then attribute port{$step/@select} else (),
            if ($step/@sequence) then attribute port{$step/@sequence} else (),

            (: TODO: will need to fixup top level input/output ports :)
            naming:explicitnames(document{$step/*})

        }
};


declare function naming:explicitnames($xproc as item()){

if(empty($xproc/*)) then
    ()
else
    let $pipelinename := $xproc/@name
    let $explicitnames :=
    
        for $step at $count in $xproc/*
            let $stepname := name($step)

            let $is_declare-step := $xproc/p:declare-step[@type=$stepname]
            let $is_step := naming:get-step($stepname,$is_declare-step)
            let $is_component := naming:get-comp($stepname)

            return
               if ($is_declare-step) then
()
(:
                    <test type="declare-step" name="{$stepname}"/>
:)               else if($is_step) then
                    naming:generate-step($step,$stepname,$is_step)
               else if ($is_component) then
                    naming:generate-component($xproc,$is_component,$step,$stepname)
               else
                    (: throws error on unknown element in pipeline namespace :)
                    util:staticError('err:XS0044', concat("static error during explicit naming pass:  ",$stepname,":",$step/@name,util:serialize($step,$const:TRACE_SERIALIZE)))
    return
        if(empty($pipelinename))then
            util:pipeline-step-sort($explicitnames,(),$pipelinename)
        else
            <p:declare-step name="{$pipelinename}">
                {
                    util:pipeline-step-sort($explicitnames,(),$pipelinename)
                }
                <ext:post name="{$pipelinename}!">
                    <p:input port="source" primary="true"/>
                    <p:output primary="true" port="stdout" select="/"/>
                </ext:post>
            </p:declare-step>
};




(: -------------------------------------------------------------------------- :)
(: Fix up top level input/output with ext:pre                                 :)
(: -------------------------------------------------------------------------- :)
declare function naming:fixup($xproc as item(),$stdin){

let $pipeline := $xproc/p:*[name(.) = "p:pipeline" or name(.) ="p:declare-step"]
let $steps := <p:declare-step>
               <ext:pre name="!{$pipeline/@name}">
            {
            if ($pipeline/p:input[@primary='true']) then
                    $pipeline/p:input[@primary='true']
            else
                    <p:input port="source"
                             kind="document"
                             primary="true"
                             select="{$pipeline/p:input[@port='source']/@select}"
                             sequence="{$pipeline/p:input[@port='source']/@sequence}">
                    {if($stdin) then
                        <p:pipe step="{$pipeline/@name}" port="stdin"/>
                    else
                        $pipeline/p:input[@port='source'][@primary="true"]
                    }
                    </p:input>,

            <p:output port="result" primary="true" select="{if ($pipeline/p:output[@port='result']/@select) then $pipeline/p:output[@port='result']/@select else '/' }"/>,

            $pipeline/p:input[@primary='false'],

            $pipeline/p:output[@primary='false']
            }
           </ext:pre>
            {
               for $import in $xproc/p:import
                return
                    if (doc-available($import/@href)) then
                          doc($import/@href)
                    else
                          util:dynamicError('XD0002',"cannot import pipeline document ")
            }

            {$pipeline/*[not(name(.)="p:input")][not(name(.)="p:output")]}

</p:declare-step>
let $result := util:pipeline-step-sort($steps/*,(),$pipeline/@name)
return

    <p:declare-step name="{$pipeline/@name}">
        {$result}
    </p:declare-step>

};

