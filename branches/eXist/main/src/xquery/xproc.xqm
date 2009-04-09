xquery version "1.0" encoding "UTF-8"; 
module namespace xproc = "http://xproc.net/xproc";
(: ------------------------------------------------------------------------------------- 
 
	xproc.xqm - core xqm containing entry points, primary eval-step function and
	control functions.
	
---------------------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const";
import module namespace u = "http://xproc.net/xproc/util";
import module namespace opt = "http://xproc.net/xproc/opt";
import module namespace std = "http://xproc.net/xproc/std";
import module namespace ext = "http://xproc.net/xproc/ext";
import module namespace comp = "http://xproc.net/xproc/comp";
import module namespace naming = "http://xproc.net/xproc/naming";

declare variable $xproc:run-step := util:function(xs:QName("xproc:run-step"), 3);

(: -------------------------------------------------------------------------- :)
(: returns step from std, opt and ext step definitions :)
(: -------------------------------------------------------------------------- :)
declare function xproc:get-step($stepname as xs:string,$declarestep) {
    $const:std-steps/p:declare-step[@type=$stepname],
    $const:opt-steps/p:declare-step[@type=$stepname],
    $const:ext-steps/p:declare-step[@type=$stepname],
(:    $const:comp-steps//xproc:element[@type=$stepname], :)
    $declarestep/@type
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
declare function xproc:type($stepname as xs:string,$is_declare-step) as xs:string {

    let $stdstep := $const:std-steps/p:declare-step[@type=$stepname]
    let $optstep := $const:opt-steps/p:declare-step[@type=$stepname]
    let $extstep := $const:ext-steps/p:declare-step[@type=$stepname]
    let $component :=$const:comp-steps//xproc:element[@type=$stepname]

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
          u:staticError('err:XS0044', concat($stepname,":",$stepname,' has no visible declaration'))
};



                (: --------------------------------------------------------------------------- :)
                                                                        (: PREPARSE II ROUTINES:)
                (: --------------------------------------------------------------------------- :)

(: TODO - this section will be refactored into binding.xqm:)

declare function xproc:generate-explicit-input($step,$count,$xproc,$unique_before){

for $input in $step/p:input
    return
        if($input/*) then
            $input
        else
            element {node-name($input)}{

                attribute port{$input/@port},
                attribute primary{if (empty($input/@primary)) then 'true' else $input/@primary},
                attribute select{if(empty($input/@select)) then string('/') else $input/@select},
                if ($input/p:document or $input/p:inline or $input/p:empty or $input/p:data) then
                    $input/*
				else if($input/@primary eq 'false') then
					$input/*
                else
                    if(name($step)="ext:pre" or name($step)="ext:post" ) then
                        $input/*
                    else
					let $l_count := $count - 1
					return
                         <p:pipe step="{
										if ($xproc/*[$l_count]/@name eq '') then
											$unique_before
										else
											$xproc/*[$l_count]/@name}"
								 port="{$xproc/*[$l_count]/p:output[@primary='true']/@port}"/>
           		}
};


declare function xproc:generate-explicit-output($step){
      for $output in $step/p:output
        return
            $output
};


declare function xproc:generate-explicit-options($step){
      for $option in $step/p:with-option
        return
            $option
};


declare function xproc:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_id,$unique_before,$allstep){

            element {if (empty($allstep/@xproc:use-function)) then node-name($step) else $allstep/@xproc:use-function} {
                attribute name{ if($step/@name eq '') then $unique_id else $step/@name},
                attribute xproc:defaultname{$unique_id},
                attribute xproc:type{xproc:type($stepname,$is_declare-step)},
                attribute 

				xproc:step{concat('$',xproc:type($stepname,$is_declare-step),':',local-name($step))},
                xproc:generate-explicit-input($step,$count,$xproc,$unique_before),
                xproc:generate-explicit-output($step),
                xproc:generate-explicit-options($step)
            }
};


declare function xproc:generate-component-binding($step,$stepname,$is_declare-step,$unique_id){
            element {node-name($step)} {
                if ($step/@type) then attribute type{$step/@type} else (),
                if ($step/@psvi-required) then attribute psvi-required{$step/@psvi-required} else (),
                if ($step/@xpath-version) then attribute xpath-version{$step/@xpath-version} else (),
                if ($step/@exclude-inline-prefixes) then attribute exclude-inline-prefixes{$step/@exclude-inline-prefixes} else (),

                attribute name{$step/@name},
                $step/@test,
                if ($const:comp-steps/xproc:element[@type=$stepname]/@xproc:step) then attribute xproc:defaultname{$unique_id} else (),
                attribute xproc:type{xproc:type($stepname,$is_declare-step)},
                 attribute xproc:step{concat('$',xproc:type($stepname,$is_declare-step),':',local-name($step))},
                   xproc:explicitbindings(document{$step/*},$unique_id)
            }
};


declare function xproc:generate-declare-step-binding($step,$is_declare-step){
    $step
};


declare function xproc:explicitbindings($xproc,$unique_id){

let $pipelinename := $xproc/@name
let $explicitbindings := document {

    for $step at $count in $xproc/*

        let $stepname := name($step)

        let $unique_before := u:uniqueid($unique_id,$count - 1)
        let $unique_current := u:uniqueid($unique_id,$count)
        let $unique_after := u:uniqueid($unique_id,$count + 1)

        let $is_declare-step := $xproc//p:declare-step[@type=$stepname]
        let $is_step := xproc:get-step($stepname,$is_declare-step)
        let $is_component := u:get-comp($stepname)

          return

            if ($is_declare-step) then
				xproc:generate-declare-step-binding($step,$is_declare-step)

            else if($is_step) then
xproc:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_current,$unique_before,$is_step)

             else if ($is_component) then
                xproc:generate-component-binding($step,$stepname,$is_declare-step,$unique_current)
            else
                u:staticError('err:XS0044', concat("static error during explicit binding pass:",$stepname,$step/@name,$is_declare-step,$is_step,$is_component))
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








                (: -------------------------------------------------------------------------- :)
                                                                              (: EVAL ROUTINES:)
                (:----------------------------------------------------------------------------:)

declare function xproc:resolve-port-binding($child,$result,$pipeline,$currentstep){

(: empty step:)            if(name($child)='p:empty') then
                                (<!-- TODO: replace this !!!! returned empty //-->)

(: inline :)               else if(name($child)='p:inline') then
                                 $child/*

(: document :)             else if(name($child)='p:document') then
                                 if (doc-available($child/@href)) then
                                       doc($child/@href)
                                 else
                                       u:dynamicError('err:XD0002',concat(" p:document cannot access document ",$child/@href))

(: data :)                 else if(name($child)='p:data') then
                                 if ($child/@href) then
                                         u:unparsed-data($child/@href,'text/plain')
                                 else
                                       u:dynamicError('err:XD0002',concat(" p:data cannot access document ",$child/@href))


(: stdin :)                else if ($child/@port eq 'stdin' and $child/@step eq $pipeline/@name) then

                                 $result/xproc:output[@port='stdin'][@step=$currentstep/@name]/*

(: prmy top level input :)  else if ($child/@primary eq 'true' and $child/@step eq $pipeline/@name) then
(: TODO - fix :)
                                $result/xproc:output[@port='result'][@step=concat('!',$pipeline/@name)]/*

(: top level input :)       else if ($child/@step eq $pipeline/@name) then

                                  $result/xproc:output[@port=$child/@port][@step=concat('!',$pipeline/@name)]/*
(: pipe :)                  else if ($child/@port) then

                                  if ($result/xproc:output[@port=$child/@port][@step=$child/@step]) then
                                       $result/xproc:output[@port=$child/@port][@step=$child/@step]/*
                                  else
                                       u:dynamicError('err:XD0001',concat(" cannot bind to port: ",$child/@port," step: ",$child/@step,' ',u:serialize($currentstep,$const:TRACE_SERIALIZE)))

                            else
(: TODO - fix :)
                                $result/xproc:output[@port='stdin'][@step=$currentstep/@name]/*

};


(:---------------------------------------------------------------------------:)

declare function xproc:eval-primary($pipeline,$step,$currentstep,$primaryinput,$result){

let $primaryresult := document{
    if($currentstep/p:input/*) then
        for $child in $currentstep/p:input/*
            return
            	xproc:resolve-port-binding($child,$result,$pipeline,$currentstep)
    else
        $primaryinput/*
    }

    let $select := string(

                    if (empty($currentstep/p:input[@primary='true']/@select)) then
                        '/'
                    else if($currentstep/p:input[@primary='true']/@select) then
                        string($currentstep/p:input[@primary='true']/@select)
                    else
                       '/'
                    )

    let $selectval :=u:evalXPATH(string($select),$primaryresult)
       return
            if (empty($selectval)) then
                u:dynamicError('err:XD0016',concat(string($pipeline/*[@name=$step]/p:input[@primary='true'][@select]/@select)," did not select anything at ",$step," ",name($pipeline/*[@name=$step])))
            else
                $selectval

};


declare function xproc:eval-secondary($pipeline,$step,$currentstep,$primaryinput,$result){
    <xproc:inputs>{
        for $input in $currentstep/p:input[@primary='false']
            return
            <xproc:input port="{$input/@port}" select="{$input/@select}">
    {
        let $primaryresult := document{
            for $child in $input/*
            return
                xproc:resolve-port-binding($child,$result,$pipeline,$currentstep)
        		}

        let $select := string(
                   if (empty($input/@select)) then
                        '/'
                   else
                        string($input/@select)
                    )

        let $selectval :=u:evalXPATH(string($select),$primaryresult)
           return
                if (empty($selectval)) then
                    u:dynamicError('err:XD0016',concat(string($pipeline/*[@name=$step]/p:input[@primary='true'][@select]/@select)," did not select anything at ",$step," ",name($pipeline/*[@name=$step])))
                else
                    $selectval
    }
            </xproc:input>

    }</xproc:inputs>
};


declare function xproc:eval-options($pipeline,$step){
    <xproc:options>
        {$pipeline/*[@name=$step]/p:with-option}
    </xproc:options>
};


declare function xproc:eval-outputs($pipeline,$step){
    <xproc:outputs>
        {$pipeline/*[@name=$step]/p:output}
    </xproc:outputs>
};


(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$primaryinput,$pipeline,$outputs) {

    let $currentstep := $pipeline/*[@name=$step][1]
    let $stepfuncname := $currentstep/@xproc:step
    let $stepfunc := concat($const:default-imports,$stepfuncname)    
    let $outputs := document{$outputs}

    let $primary := xproc:eval-primary($pipeline,$step,$currentstep,$primaryinput,$outputs)
    let $secondary := xproc:eval-secondary($pipeline,$step,$currentstep,$primaryinput,$outputs)
    let $options := xproc:eval-options($pipeline,$step)
    let $output := xproc:eval-outputs($pipeline,$step)

    return

        if(name($currentstep) = "p:declare-step") then
            ()
        else
            (
            for $child in $secondary/xproc:input
                return
                     <xproc:output step="{$step}"
                                  port-type="input"
                                  primary="false"
                                  select="{$child/@select}"
                                  port="{$child/@port}"
                                  func="{$stepfuncname}">{
                                    $child/*
                                  }
                     </xproc:output>,
                     <xproc:output step="{$step}"
                                   port-type="input" 
                                   primary="true"
                                   select="{$currentstep/p:input[@primary='true']/@select}"
                                   port="{$currentstep/p:input[@primary='true']/@port}"
                                   func="{$stepfuncname}">{
                                         $primaryinput/*
                                  }
                     </xproc:output>,

                    if($currentstep/p:output[@primary='true']) then
                         <xproc:output step="{$step}"
                                      port-type="output"
                                      primary="true"
                                      select="{$currentstep/p:output[@primary='true']/@select}"
                                      port="{$currentstep/p:output[@primary='true']/@port}"
                                      func="{$stepfuncname}">{
                                          if(contains($stepfuncname,'comp:')) then
                                                u:call(u:xquery($stepfunc),$primary,$secondary,$options,$currentstep)
                                            else
                                                u:call(u:xquery($stepfunc),$primary,$secondary,$options)
                                      }
                         </xproc:output>
                     else
                         <xproc:output step="{$step}"
                                      port-type="output"
                                      primary="false"
                                      select="{$currentstep/p:output[@primary='false']/@select}"
                                      port="{$currentstep/p:output[@primary='false']/@port}"
                                      func="{$stepfuncname}">
                                      {
                                          if(contains($stepfuncname,'comp:')) then
                                                u:call(u:xquery($stepfunc),$primary,$secondary,$options,$currentstep)
                                            else
                                                u:call(u:xquery($stepfunc),$primary,$secondary,$options)
                                      }
                         </xproc:output>
            )
};



                (: --------------------------------------------------------------------------- :)
                                                                            (: CONTROL ROUTINES:)
                (: --------------------------------------------------------------------------- :)


(: -------------------------------------------------------------------------- :)
(: Generate xquery steps sequence :)
declare function xproc:genstepnames($steps) as xs:string* {
    for $step in $steps/*[not(name()='p:documentation')]
    return
		xs:string($step/@name)
};


(: -------------------------------------------------------------------------- :)
(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
declare function xproc:parse_and_eval($xproc,$stdin as item(),$bindings) {

    let $pipeline := $xproc
    let $steps := xproc:genstepnames($pipeline)
    return
        u:step-fold($pipeline,
                       $steps,
                       util:function(xs:QName("xproc:evalstep"), 4),
                       $stdin,
                       (xproc:resolve-external-bindings($bindings,$pipeline/@name),
                       (<xproc:output
                                step="{if ($steps[1] = '|') then '!1|' else $steps[1]}"
                                port="stdin"
                                port-type="external"
                                primary="false"								
                                func="{$pipeline/@type}">{$stdin}</xproc:output>))                                                
        )

};



declare function xproc:resolve-external-bindings($bindings,$pipelinename){

if (empty($bindings)) then
    ()
else
    for $binding in $bindings
    let $port := substring-before($binding,'=')
    let $href := substring-after($binding,'=')
        return
        <xsl:output port-type="external" port="{$port}" step="{$pipelinename}">
        	{doc($href)}
        </xsl:output>
};



(: -------------------------------------------------------------------------- :)
declare function xproc:output($result,$dflag){

let $pipeline :=subsequence($result,1,1)
let $output := subsequence($result,2)
    return
        if($dflag="1") then
            <xproc:debug>
                <xproc:pipeline>{$pipeline}</xproc:pipeline>
                <xproc:outputs>{$output}</xproc:outputs>
            </xproc:debug>
        else
           ($output/.)[last()]/node()
};


                (: --------------------------------------------------------------------------- :)
                                                                              (: ENTRY POINT   :)
                (: --------------------------------------------------------------------------- :)

declare function xproc:run-step($primary,$secondary,$options) {

let $stdin :=$primary/*[1]
let $pipeline := $secondary/xproc:input[@port='pipeline']
let $bindings :=()
let $options :=()
let $dflag :="0"
let $tflag :="0"
return
    xproc:run($pipeline,$stdin,$dflag,$tflag,$bindings,$options)

};


(: -------------------------------------------------------------------------- :)
declare function xproc:run($pipeline,$stdin,$dflag,$tflag,$bindings,$options){


    (: STEP I: generate parse tree :)
    let $preparse-naming := naming:explicitnames(naming:fixup($pipeline,$stdin))
    let $preparse-binding := xproc:explicitbindings($preparse-naming,$const:init_unique_id)

    (: STEP II: parse and eval tree :)
    let $eval_result := xproc:parse_and_eval($preparse-binding,$stdin,$bindings)

    (: STEP III: serialize and return results :)
    let $serialized_result := xproc:output($eval_result,$dflag)

    let $internaldbg := 0

    return
        if ($internaldbg eq 1) then
                    xproc:explicitbindings(
                      naming:explicitnames(
                            naming:fixup($pipeline,$stdin)
                      )
                    ,$const:init_unique_id
                    )
        else if ($internaldbg eq 2) then
                      naming:explicitnames(
                            naming:fixup($pipeline,$stdin)
                      )
        else if ($internaldbg eq 3) then
                    $eval_result
        else
        (
         if ($tflag="1") then
                document
                   {
                    <xproc:result xproc:timing="disabled" xproc:ts="{current-dateTime()}">
                        {
                         $serialized_result
                        }
                    </xproc:result>
                    }
             else
                document
                   {
                    $serialized_result
                    }
        )
};
