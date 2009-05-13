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
import module namespace naming = "http://xproc.net/xproc/naming";

(: -------------------------------------------------------------------------- :)
declare variable $xproc:run-step := util:function(xs:QName("xproc:run-step"), 5);
declare variable $xproc:parse-and-eval := util:function(xs:QName("xproc:parse_and_eval"), 4);
(: -------------------------------------------------------------------------- :)
declare variable $xproc:declare-step :=util:function(xs:QName("xproc:declare-step"), 4);
declare variable $xproc:choose :=util:function(xs:QName("xproc:choose"), 5);
declare variable $xproc:group :=util:function(xs:QName("xproc:group"), 5);
declare variable $xproc:for-each :=util:function(xs:QName("xproc:for-each"), 5);
declare variable $xproc:viewport :=util:function(xs:QName("xproc:viewport"), 4);
declare variable $xproc:library :=util:function(xs:QName("xproc:library"), 4);
declare variable $xproc:pipeline :=util:function(xs:QName("xproc:pipeline"), 4);
(: -------------------------------------------------------------------------- :)

declare function xproc:declare-step($primary,$secondary,$options,$step) {
<test1/>
};

declare function xproc:for-each($primary,$secondary,$options,$currentstep,$outputs) {
let $defaultname := concat(string($currentstep/@xproc:defaultname),'.1')
let $steps := $currentstep
return
	
	for $child in $primary/node()
	return
		u:call($xproc:parse-and-eval,<p:declare-step name="{$defaultname}" xproc:defaultname="{$defaultname}" >{$currentstep/*}</p:declare-step>,$child,(),$outputs)

};

declare function xproc:viewport($primary,$secondary,$options,$step) {
<test3/>
};

declare function xproc:library($primary,$secondary,$options,$step) {
<test4/>
};

declare function xproc:pipeline($primary,$secondary,$options,$step) {
<test5/>
};


(: -------------------------------------------------------------------------- :)
declare function xproc:group($primary,$secondary,$options,$currentstep,$outputs) {
	let $defaultname := concat(string($currentstep/@xproc:defaultname),'.1')
	let $v := document{$primary/*[1]}
	let $steps := $currentstep
	return
		u:call($xproc:parse-and-eval,<p:declare-step name="{$defaultname}" xproc:defaultname="{$defaultname}" >{$currentstep/*}</p:declare-step>,$v,(),$outputs)
};


(: -------------------------------------------------------------------------- :)
declare function xproc:choose($primary,$secondary,$options,$currentstep,$outputs) {
	let $defaultname := concat(string($currentstep/@xproc:defaultname),'.1')
    let $v := document{$primary/*[1]}
    let $stepfuncname := '$xproc:parse-and-eval'
    let $stepfunc := concat($const:default-imports,$stepfuncname)    
    let $when := $currentstep//p:when
    let $otherwise := $currentstep//p:otherwise
    let $when_eval := u:boolean-evalXPATH(string($when/@test),$v)
    return
    	if($when_eval) then  
		u:call($xproc:parse-and-eval,<p:declare-step name="{$defaultname}" xproc:defaultname="{$defaultname}" >{$when/*}</p:declare-step>,$v,(),$outputs)
        else
			u:call($xproc:parse-and-eval,<p:declare-step name="{$defaultname}" xproc:defaultname="{$defaultname}" >{$otherwise/*}</p:declare-step>,$v,(),$outputs)

};


(: -------------------------------------------------------------------------- :)

(: -------------------------------------------------------------------------- :)
(: returns step from std, opt and ext step definitions :)
(: -------------------------------------------------------------------------- :)
declare function xproc:get-step($stepname as xs:string,$declarestep) {
    $const:std-steps/p:declare-step[@type=$stepname],
    $const:opt-steps/p:declare-step[@type=$stepname],
    $const:ext-steps/p:declare-step[@type=$stepname],
    $declarestep/@type
};


(: -------------------------------------------------------------------------- :)
(: returns step type :)
(: -------------------------------------------------------------------------- :)
(: TODO - refactor at some point perhaps using base-uri ? :)
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
        'xproc'
    else if($is_declare-step) then
      string(substring-before($is_declare-step/@type,':'))
    else
      u:staticError('err:XS0044', concat($stepname,":",$stepname,' has no visible declaration'))
};



(: --------------------------------------------------------------------------- :)
                                                        (: PREPARSE II ROUTINES:)
(: --------------------------------------------------------------------------- :)

(: TODO - this section will be refactored:)
declare function xproc:generate-explicit-input($step,$count,$xproc,$unique_before,$unique_id,$allstep){
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
					(: ensure required non primary inputs are bound :)
					if($allstep/p:input[@port = $input/@port][@xproc:required eq 'true']) then
 						u:staticError('err:XS0032', concat("static error during explicit binding pass:",$input,$allstep))
					else
						$input/*
                else
                    if(name($step)="ext:pre" or name($step)="ext:post" ) then
                        $input/*
                    else
						let $l_count := $count - 1
						return					
							if($l_count=0) then
                        		<p:pipe step="{substring-before($unique_id,'.1')}"
								 		port="xproc:source"/>	
							else
                         		<p:pipe step="{if ($xproc/*[$l_count]/@name eq '') then
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
                attribute xproc:step{if (empty($allstep/@xproc:use-function)) then concat('$',xproc:type($stepname,$is_declare-step),':',local-name($step)) else concat('$',$allstep/@xproc:use-function)},
                xproc:generate-explicit-input($step,$count,$xproc,$unique_before,$unique_id,$allstep),
                xproc:generate-explicit-output($step),
                xproc:generate-explicit-options($step)
            }
};


declare function xproc:generate-component-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_id,$unique_before,$compstep){
            element {node-name($step)} {	
				$step/@*,
                if ($const:comp-steps/xproc:element[@type=$stepname]/@xproc:step) then attribute xproc:defaultname{$unique_id} else (),
                attribute xproc:type{xproc:type($stepname,$is_declare-step)},
				if ($const:comp-steps/xproc:element[@type=$stepname]/@xproc:step) then attribute xproc:step{concat('$',xproc:type($stepname,$is_declare-step),':',local-name($step))} else (),
				xproc:generate-explicit-input($step,$count,$xproc,$unique_before,$unique_id,$compstep),
				xproc:explicitbindings(document{$step/*[not(name(.) eq 'p:input')][not(name(.) eq 'p:output')]},$unique_id)
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
            else if($is_step) then xproc:generate-step-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_current,$unique_before,$is_step)
             else if ($is_component) then
               xproc:generate-component-binding($step,$xproc,$count,$stepname,$is_declare-step,$unique_current,$unique_before,$is_component)
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







(: ------------------------------------------------------------------------------------------ :)
                                                                     (: RUN TIME EVAL ROUTINES:)
(:--------------------------------------------------------------------------------------------:)

declare function xproc:resolve-port-binding($child,$result,$pipeline,$currentstep){

(: empty step:)            if(name($child)='p:empty') then
                                (<!-- TODO: replace this !!!! returned empty //-->)

(: inline :)               else if(name($child) eq 'p:inline') then
                                 $child/*

(: document :)             else if(name($child)='p:document') then
                                 if (doc-available($child/@href)) then
                                     doc($child/@href)
                                 else
                                     u:dynamicError('err:XD0002',concat(" cannot access document ",$child/@href))

(: data :)                 else if(name($child)='p:data') then
                                 if ($child/@href) then
                                         u:unparsed-data($child/@href,'text/plain')
                                 else
                                       u:dynamicError('err:XD0002',concat("cannot access document:  ",$child/@href))

(: stdin :)                else if ($child/@port eq 'stdin' and $child/@step eq $pipeline/@name) then
                                 $result/xproc:output[@port eq 'stdin'][@step eq $currentstep/@name]/*

(: prmy top level input :) else if ($child/@primary eq 'true' and $child/@step eq $pipeline/@name) then
(: TODO - fix :)
                                $result/xproc:output[@port eq 'result'][@step=concat('!',$pipeline/@name)]/*

(: top level input :)       else if ($child/@step eq $pipeline/@name) then                       
 							$result/xproc:output[@port=$child/@port][@step=concat('!',$pipeline/@name)]/*

(: pipe :)                  else if ($child/@port) then
                                  if ($result/xproc:output[@port=$child/@port][@step=$child/@step]) then
                                  $result/xproc:output[@port=$child/@port][@step=$child/@step]/*
                            	  else
                                       u:dynamicError('err:XD0001',concat(" cannot bind to port: ",$child/@port," step: ",$child/@step,' ',u:serialize($currentstep,$const:TRACE_SERIALIZE)))

                            else

                            u:dynamicError('err:XD0001',concat(" cannot bind to port: ",$child/@port," step: ",$child/@step,' ',u:serialize($currentstep,$const:TRACE_SERIALIZE)))

};


(:---------------------------------------------------------------------------:)

declare function xproc:eval-primary($pipeline,$step,$currentstep,$primaryinput,$result){

let $primaryresult := document{

    if($currentstep/p:input[@primary eq 'true']/*) then
	(: resolve each nested port binding :)
        for $child in $currentstep/p:input[@primary eq 'true']/*
            return
            	xproc:resolve-port-binding($child,$result,$pipeline,$currentstep)
    else
	(: get previous step output and bind to input:)
		if ($primaryinput/xproc:output) then (: prev step is multi container step output:)
    		$primaryinput/*[last()]/node()		
		else
        	$primaryinput/*				 (: prev step is an atomic step output:)	
    }

    let $select := string(if (empty($currentstep/p:input[@primary='true']/@select)) then
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
        for $input in $currentstep/p:input[@primary eq 'false']
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
			(: TODO - need to refactor p:pipeline and p:declare-step at some point :)
            ()
        else
		let $primaryinput:= <xproc:output step="{$step}"
                          port-type="input" 
                          primary="true"
                          select="{$currentstep/p:input[1][@primary='true']/@select}"
                          port="{$currentstep/p:input[1][@primary='true']/@port}"
                          func="{$stepfuncname}">{
								$primary/*
                         }
            </xproc:output>
         let $secondaryinput: =(  for $child in $secondary/xproc:input
                return
                     <xproc:output step="{$step}"
                                  port-type="input"
                                  primary="false"
                                  select="{$child/@select}"
                                  port="{$child/@port}"
                                  func="{$stepfuncname}">{
                                    $child/*
                                  }
                     </xproc:output>
					)

			return
            	($primaryinput,
			 	$secondaryinput,
			
 				if($currentstep/p:output[@primary='true']) then
                     <xproc:output step="{$step}"
                                      port-type="output"
                                      primary="true"
                                      select="{$currentstep/p:output[@primary='true']/@select}"
                                      port="{$currentstep/p:output[@primary='true']/@port}"
                                      func="{$stepfuncname}">{
                                          if(contains($stepfuncname,'xproc:')) then
u:call(u:xquery($stepfunc),$primary,$secondary,$options,$currentstep,($outputs,$primaryinput,$secondaryinput))
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
                                          if(contains($stepfuncname,'xproc:')) then
u:call(u:xquery($stepfunc),$primary,$secondary,$options,$currentstep,($outputs,$primaryinput,$secondaryinput))
                                            else
                                                u:call(u:xquery($stepfunc),$primary,$secondary,$options)
                                      }
                         </xproc:output>
            )
};



(: --------------------------------------------------------------------------- :)
                                                            (: CONTROL ROUTINES:)
(: --------------------------------------------------------------------------- :)


(: --------------------------------------------------------------------------- :)
(: Generate xquery steps sequence :)
declare function xproc:genstepnames($steps) as xs:string* {
    for $step in $steps/*[not(name()='p:documentation')]
    return
		xs:string($step/@name)
};


(: -------------------------------------------------------------------------- :)
(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)

declare function xproc:parse_and_eval($pipeline,$stdin,$bindings,$outputs) {
    let $steps := xproc:genstepnames($pipeline)
    return
        u:step-fold($pipeline,
                       $steps,
                       util:function(xs:QName("xproc:evalstep"), 4),
                       $stdin,
                       (xproc:resolve-external-bindings($bindings,$pipeline/@name))
        				)
};

declare function xproc:parse_and_eval($pipeline,$stdin,$bindings) {
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


                
(: --------------------------------------------------------------------------- :)                                                                				(: ENTRY POINT   :)
(: --------------------------------------------------------------------------- :)

declare function xproc:run-step($primary,$secondary,$options,$step,$outputs) {
	let $stdin :=$primary
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
    let $xproc-binding := xproc:explicitbindings($preparse-naming,$const:init_unique_id)

    (: STEP II: parse and eval tree :)
    let $eval_result := xproc:parse_and_eval($xproc-binding,$stdin,$bindings)

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