xquery version "1.0" encoding "UTF-8"; 
module namespace binding = "http://xproc.net/xproc/binding";
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



declare function binding:uniqueid($unique_id,$count){
    concat($unique_id,'.',$count)
};

(: -------------------------------------------------------------------------- :)
(: checks to see if this component exists :)
(: -------------------------------------------------------------------------- :)
declare function binding:comp-available($compname as xs:string) as xs:boolean {
        exists(binding:get-comp($compname))
};


(: -------------------------------------------------------------------------- :)
(: returns comp from comp definitions :)
(: -------------------------------------------------------------------------- :)
declare function binding:get-comp($compname as xs:string) {
    $const:comp-components/xproc:element[@type=$compname]
};


(: -------------------------------------------------------------------------- :)
(: returns step from std, opt and ext step definitions :)
(: -------------------------------------------------------------------------- :)
declare function binding:get-step($stepname as xs:string,$declarestep) {
    ($const:opt-steps/p:declare-step[@type=$stepname],
    $const:std-steps/p:declare-step[@type=$stepname],
    $const:ext-steps//p:declare-step[@type=$stepname],
    $declarestep/@type)
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
declare function binding:type($stepname as xs:string,$is_declare-step) as xs:string {

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
                                                                        (: PREPARSE II ROUTINES:)
                (: --------------------------------------------------------------------------- :)


declare function binding:generate-explicit-input($step,$count,$xproc,$unique_before){

for $input in $step/p:input
    return
        if($input/*) then
            $input
        else
            element {node-name($input)}{
                attribute port{$input/@port},
                attribute primary{if ($input/@primary eq '') then 'true' else $input/@primary},
                attribute select{if($input/@select eq '') then string('/') else $input/@select},

                if ($input/p:document or $input/p:inline or $input/p:empty or $input/p:data) then
                    $input/*
                else
                    if(name($step)="ext:pre" or name($step)="ext:post" ) then
                        $input/*
                    else
                         <p:pipe step="{if ($xproc/*[$count - 1]/@name eq '') then $unique_before else $xproc/*[$count - 1]/@name}"
                                 port="{$xproc/*[$count - 1]/p:output[@primary='true']/@port}"/>
            }
};


declare function binding:generate-explicit-output($step){
      for $output in $step/p:output
        return
            $output
};


declare function binding:generate-explicit-options($step){
      for $option in $step/p:with-option
        return
            $option
};


declare function binding:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_id,$unique_before){

            element {node-name($step)} {
                 attribute name{if($step/@name eq '') then $unique_id else $step/@name},
                 attribute xproc:defaultname{$unique_id},
                 attribute xproc:type{binding:type($stepname,$is_declare-step)},
                 attribute xproc:step{concat('$',binding:type($stepname,$is_declare-step),':',local-name($step))},

                 binding:generate-explicit-input($step,$count,$xproc,$unique_before),
                 binding:generate-explicit-output($step),
                 binding:generate-explicit-options($step)
            }
};


declare function binding:generate-component-binding($step,$stepname,$is_declare-step,$unique_id){
            element {node-name($step)} {
                if ($step/@type) then attribute type{$step/@type} else (),
                if ($step/@psvi-required) then attribute psvi-required{$step/@psvi-required} else (),
                if ($step/@xpath-version) then attribute xpath-version{$step/@xpath-version} else (),
                if ($step/@exclude-inline-prefixes) then attribute exclude-inline-prefixes{$step/@exclude-inline-prefixes} else (),

                attribute name{$step/@name},
                attribute xproc:defaultname{$step/@xproc:defaultname},
                attribute xproc:type{binding:type($stepname,$is_declare-step)},
                 attribute xproc:step{concat('$',binding:type($stepname,$is_declare-step),':',local-name($step))},
                   binding:explicitbindings(document{$step/*},$unique_id)
            }
};


declare function binding:generate-declare-step-binding($step,$is_declare-step){
    $step
};


declare function binding:explicitbindings($xproc as item(),$unique_id){

let $pipelinename := $xproc/@name
let $explicitbindings := document {

    for $step at $count in $xproc/*

        let $stepname := name($step)

        let $unique_before := binding:uniqueid($unique_id,$count - 1)
        let $unique_current := binding:uniqueid($unique_id,$count)
        let $unique_after := binding:uniqueid($unique_id,$count + 1)

        let $is_declare-step := $xproc/p:declare-step[@type=$stepname]
        let $is_step := binding:get-step($stepname,$is_declare-step)
        let $is_component := binding:get-comp($stepname)

          return

            if ($is_declare-step) then
()
(:              binding:generate-declare-step-binding($step,$is_declare-step)
:)
            else if($is_step) then
                binding:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_current,$unique_before)

             else if ($is_component) then
                binding:generate-component-binding($step,$stepname,$is_declare-step,$unique_current)

            else
                util:staticError('err:XS0044', concat("static error during explicit binding pass:",$stepname,$step/@name))
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
                {$explicitbindings}
            </p:declare-step>
};

