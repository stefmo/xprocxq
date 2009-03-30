xquery version "1.0" encoding "UTF-8"; 
module namespace preparse = "http://xproc.net/xproc/preparse";
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



                        (: --------------------------------------------------------------------------- :)
                                                                                    (: XPROC UTILITIES :)
                        (: --------------------------------------------------------------------------- :)


declare function preparse:uniqueid($unique_id,$count){
    concat($unique_id,'.',$count)
};

(: -------------------------------------------------------------------------- :)
(: checks to see if this component exists :)
(: -------------------------------------------------------------------------- :)
declare function preparse:comp-available($compname as xs:string) as xs:boolean {
        exists(preparse:get-comp($compname))
};


(: -------------------------------------------------------------------------- :)
(: returns comp from comp definitions :)
(: -------------------------------------------------------------------------- :)
declare function preparse:get-comp($compname as xs:string) {
    $comp:components/xproc:element[@type=$compname]
};


(: -------------------------------------------------------------------------- :)
(: returns step from std, opt and ext step definitions :)
(: -------------------------------------------------------------------------- :)
declare function preparse:get-step($stepname as xs:string,$declarestep) {
    $std:steps/p:declare-step[@type=$stepname],
    $opt:steps/p:declare-step[@type=$stepname],
    $ext:steps/p:declare-step[@type=$stepname],
    $declarestep/@type
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
declare function preparse:type($stepname as xs:string,$is_declare-step) as xs:string {

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
        else if($is_declare-step) then
          string(substring-before($is_declare-step/@type,':'))
        else
          util:staticError('err:XS0044', concat($stepname,":",$stepname,' has no visible declaration'))
};




                        (: --------------------------------------------------------------------------- :)
                                                                                 (: PREPARSE I ROUTINES:)
                        (: --------------------------------------------------------------------------- :)


declare function preparse:preparse-options($allstep,$step,$stepname){
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


declare function preparse:preparse-input-bindings($allstep,$step,$allbindings){

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

declare function preparse:preparse-output-bindings($allstep,$step,$allbindings){

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

declare function preparse:generate-step($step,$stepname,$allstep){
    element {node-name($step)} {
        attribute name{$step/@name},
        preparse:preparse-input-bindings($allstep/p:*[@primary='true'],$step,$allstep/@xproc:bindings),
        preparse:preparse-output-bindings($allstep/p:*[@primary='false'],$step,$allstep/@xproc:bindings),
        preparse:preparse-options($allstep/p:option,$step,$stepname)
   }
};


declare function preparse:generate-component($xproc,$allcomp,$step,$stepname){

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
            preparse:explicitnames(document{$step/*})

        }
};


declare function preparse:explicitnames($xproc as item()){

if(empty($xproc/*)) then
    ()
else
    let $pipelinename := $xproc/@name
    let $explicitnames :=
    
        for $step at $count in $xproc/*
            let $stepname := name($step)

            let $is_step := preparse:get-step($stepname,$xproc//p:declare-step[@type=$stepname])
            let $is_component := preparse:get-comp($stepname)
            let $is_declare-step := $xproc//p:declare-step[@type=$stepname]

            return

                if($is_step) then
                    preparse:generate-step($step,$stepname,$is_step)
               else if ($is_component) then
                    preparse:generate-component($xproc,$is_component,$step,$stepname)
                else
                    (: throws error on unknown element in pipeline namespace :)
                    util:staticError('err:XS0044', concat("Parser explicit naming pass:  ",$stepname,":",$step/@name,util:serialize($step,$const:TRACE_SERIALIZE)))
    return
        if(empty($pipelinename))then
            $explicitnames
        else
            <p:declare-step name="{$pipelinename}">
                {
                    $explicitnames
                }
            </p:declare-step>
};










                        (: --------------------------------------------------------------------------- :)
                                                                                (: PREPARSE II ROUTINES:)
                        (: --------------------------------------------------------------------------- :)

declare function preparse:generate-explicit-input($step,$count,$xproc,$unique_before){
$step/p:input
(:
for $input in $step/p:input
    return
      element {node-name($input)}{
        attribute port{$input/@port},
        attribute primary{if ($input/@primary eq '') then 'true' else $input/@primary},
        attribute select{if($input/@select eq '') then string('/') else $input/@select},

        if ($input/p:document or $input/p:inline or $input/p:empty or $input/p:data) then
            $input/*
        else
            (: handle ext:pre binding :)
                           if(name($step)="ext:pre") then
                                $input/*
            (: primary input step that takes in previous step :)
                           else if (not($input/p:pipe) and $input/@primary='true' and not($xproc/*[last()]/@*:defaultname)) then
                                <p:pipe step="{if ($xproc/*[$count - 1]/@name eq '') then $unique_before else $xproc/*[$count - 1]/@name}" port="{$xproc/*[$count - 1]/p:output[@primary='true']/@port}"/>
            (: non-primary inputs with pipe :)
                           else if ($input/p:pipe and not($input/@primary='true')) then
                                $input/*
                           else
                                ()
        }
:)
};


declare function preparse:generate-explicit-output($step){
      for $output in $step/p:output
        return
            $output
};


declare function preparse:generate-explicit-options($step){
      for $option in $step/p:with-option
        return
            $option
};


declare function preparse:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_id,$unique_before){

            element {node-name($step)} {
                 attribute name{if($step/@name eq '') then $unique_id else $step/@name},
                 attribute xproc:defaultname{$unique_id},
                 attribute xproc:type{preparse:type($stepname,$is_declare-step)},
                 attribute xproc:step{concat('$',preparse:type($stepname,$is_declare-step),':',local-name($step))},
                 
                 preparse:generate-explicit-input($step,$count,$xproc,$unique_before),
                 preparse:generate-explicit-output($step),
                 preparse:generate-explicit-options($step)
            }
};


declare function preparse:generate-component-binding($step,$stepname,$is_declare-step,$unique_id){
            element {node-name($step)} {
                if ($step/@type) then attribute type{$step/@type} else (),
                if ($step/@psvi-required) then attribute psvi-required{$step/@psvi-required} else (),
                if ($step/@xpath-version) then attribute xpath-version{$step/@xpath-version} else (),
                if ($step/@exclude-inline-prefixes) then attribute exclude-inline-prefixes{$step/@exclude-inline-prefixes} else (),

                attribute name{$step/@name},
                attribute xproc:defaultname{$step/@xproc:defaultname},
                attribute xproc:type{preparse:type($stepname,$is_declare-step)},
                 attribute xproc:step{concat('$',preparse:type($stepname,$is_declare-step),':',local-name($step))},
                   preparse:explicitbindings(document{$step/*},$unique_id)
            }
};


declare function preparse:generate-declare-step-binding($step,$is_declare-step){
    $step
};


declare function preparse:explicitbindings($xproc as item(),$unique_id){

let $pipelinename := $xproc/@name
let $explicitbindings := document {

    for $step at $count in $xproc/*

        let $stepname := name($step)

        let $unique_before := preparse:uniqueid($unique_id,$count - 1)
        let $unique_current := preparse:uniqueid($unique_id,$count)
        let $unique_after := preparse:uniqueid($unique_id,$count + 1)

        let $is_step := preparse:get-step($stepname,$xproc//p:declare-step[@type=$stepname])
        let $is_component := preparse:get-comp($stepname)
        let $is_declare-step := $xproc//p:declare-step[@type=$stepname]

          return

            if($is_step) then
                preparse:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_current,$unique_before)
    
             else if ($is_component) then
                preparse:generate-component-binding($step,$stepname,$is_declare-step,$unique_current)
(:
            else if ($is_declare-step) then
                preparse:generate-declare-step-binding($step,$is_declare-step)
    :)
            else
                ()
    (:
                util:staticError('err:XS0044', concat("parssing explicit binding pass:",$stepname,$step/@name))
    :)
    }

    return
        (: if dealing with nested components --------------------------------------------------------- :)
        if(empty($pipelinename)) then
            $explicitbindings
        else
        (: if dealing with p:pipeline component ------------------------------------------------------ :)
            <p:declare-step xmlns:xproc="http://xproc.net/xproc"
                            name="{$pipelinename}"
                            xproc:defaultname="{$unique_id}">
                {util:pipeline-step-sort($explicitbindings,(),$pipelinename)}
            </p:declare-step>

};





(: -------------------------------------------------------------------------- :)
(: Fix up top level input/output with ext:pre :)
(: -------------------------------------------------------------------------- :)
declare function preparse:fixup($xproc as item(),$stdin){

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
        <ext:post name="{$pipeline/@name}!">
            <p:input port="source" primary="true"/>
            <p:output primary="true" port="stdout" select="/"/>
        </ext:post>
    </p:declare-step>


};


