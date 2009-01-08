xquery version "1.0" encoding "UTF-8"; 

module namespace xproc = "http://xproc.net/xproc";
declare copy-namespaces preserve,inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

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


(: -------------------------------------------------------------------------- :)
(: checks to see if this component exists :)
(: -------------------------------------------------------------------------- :)
declare function xproc:comp-available($compname as xs:string) as xs:boolean {
        exists(xproc:get-comp($compname))
};


(: -------------------------------------------------------------------------- :)
(: returns comp from comp definitions :)
(: -------------------------------------------------------------------------- :)
declare function xproc:get-comp($compname as xs:string) {
    $comp:components/xproc:element[@type=$compname]
};


(: -------------------------------------------------------------------------- :)
(: checks to see if this step is available :)
(: -------------------------------------------------------------------------- :)
declare function xproc:step-available($stepname as xs:string) as xs:boolean {
   exists(xproc:get-step($stepname))
};


(: -------------------------------------------------------------------------- :)
(: returns step from std, opt and ext step definitions :)
(: -------------------------------------------------------------------------- :)
declare function xproc:get-step($stepname as xs:string) {
    $std:steps/p:declare-step[@type=$stepname],
    $opt:steps/p:declare-step[@type=$stepname],
    $ext:steps/p:declare-step[@type=$stepname]

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
(: PREPARSE I: give everything a name if it doesn't already have one :)
(: -------------------------------------------------------------------------- :)
declare function xproc:explicitnames($xproc as item(), $unique_id){

let $pipelinename := $xproc/@name

(: TODO: the definitive test for detecting an atomic declare-step is to check that no subpipeline exists:)
let $declare-step := $xproc//p:declare-step[@type]

let $explicitnames := 

    for $step at $count in $xproc/*

        let $stepname := name($step)

        (: generate unique default name :)
        let $unique_before := concat($unique_id,'.',$count - 1)
        let $unique_current := concat($unique_id,'.',$count)
        let $unique_after := concat($unique_id,'.',$count + 1)

        (: look up defined step in library :)
        let $allstep := xproc:get-step($stepname)
        let $allcomp := xproc:get-comp($stepname)

        return

            (: handle step element ------------------------------------------------------------ :)
            if($allstep) then

            (: generate step :)
                        element {node-name($step)} {                                                                                                                                                                                                      attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                             (
                                (: primary input and output:)
                                for $binding in $allstep/p:*[name(.)='p:input' or name(.)='p:output'][@primary='true']
                                    return
                                      element {name($binding)}{
                                         attribute port{$binding/@port},
                                          attribute primary{"true"},

                                         attribute select{if (name($binding) = 'p:input') then 
                                                            $step/p:input[@port=$binding/@port]/@select
                                                          else
                                                            $step/p:output[@port=$binding/@port]/@select
                                         },
                                         if (name($binding) = 'p:input') then
                                                            $step/p:input[@port=$binding/@port]/*
                                                          else
                                                            $step/p:output[@port=$binding/@port]/*
                                      },

                                if($allstep/@xproc:input) then
                                    $step/p:input[@primary="false"]
                                else
                                    ()
                                ,
                              
                                if($allstep/@xproc:output) then
                                    $step/p:output[@primary="false"]
                                else
                                    ()
                                ,
                                (: secondary input and output:)
                                for $binding in $allstep/p:*[name(.)='p:input' or name(.)='p:output'][@primary="" or not(@primary) or @primary="false"]
                                    return
                                      element {name($binding)}{
                                         attribute port{$binding/@port},
                                          attribute primary{"false"},

                                         attribute select{if (name($binding) = 'p:input') then
                                                            $step/p:input[@port=$binding/@port]/@select
                                                          else
                                                            $step/p:output[@port=$binding/@port]/@select
                                         },
                                         if (name($binding) = 'p:input') then
                                                            $step/p:input[@port=$binding/@port]/*
                                                          else
                                                            $step/p:output[@port=$binding/@port]/*
                                      },

                                (: match options with step definitions and generate p:with-option:)
                                for $option in $allstep/p:option
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
                                            (: TODO: need to possibly throw err:XS0010 error on unrecognized options :)
                                            util:trace($option,"option conforms to step signature")
                             )
                        }

         else if ($allcomp) then
            element {node-name($step)} {
                if ($step/@type) then attribute type{$step/@type} else (),
                if ($step/@psvi-required) then attribute psvi-required{$step/@psvi-required} else (),
                if ($step/@xpath-version) then attribute xpath-version{$step/@xpath-version} else (),
                if ($step/@exclude-inline-prefixes) then attribute exclude-inline-prefixes{$step/@exclude-inline-prefixes} else (), 
                if ($allcomp/@xproc:step = "true") then attribute name{$unique_current} else attribute name{$step/@name},
                if ($allcomp/@xproc:step = "true") then attribute xproc:defaultname{$unique_current} else (),
                (: TODO: will need to fixup top level input/output ports :)
                xproc:explicitnames(document{$step/*},$unique_current)
            }

        else if ($xproc/p:declare-step[@type=$stepname]) then
                        element {node-name($step)} {                                                                                                                                                                                                      attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                             (
                                (: primary input and output:)
                                for $binding in $xproc/p:declare-step[@type=$stepname]/p:*[name(.)='p:input' or name(.)='p:output'][not(@primary) or @primary="true"]
                                    return
                                      element {name($binding)}{
                                         attribute port{$binding/@port},
                                         attribute primary{"true"},

                                         attribute select{ if (name($binding) = 'p:input') then
                                                            $step/p:input[@port=$binding/@port]/@select
                                                           else
                                                            $step/p:output[@port=$binding/@port]/@select
                                         },
                                         if (name($binding) = 'p:input') then
                                                            $step/p:input[@port=$binding/@port]/*
                                                          else
                                                            $step/p:output[@port=$binding/@port]/*
                                      },


                                (: non-primary input and output :)
                                (: TODO: need to handle attributes :)
                                      $step/p:*[name(.)='p:input' or name(.)='p:output'][@primary="false"]
                                      ,

                                (: match options with step definitions and generate p:with-option:)
                                for $option in $xproc/p:declare-step[@type=$stepname]/p:option
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
                                            (: TODO: need to possibly throw err:XS0010 error on unrecognized options :)
                                            util:trace($option,"option conforms to step signature")
                             )
                        }

        else
            (: TODO: throws error on unknown element in pipeline namespace :)
            util:staticError('err:XS0044', concat("Parser explicit naming pass:  ",$stepname,":",$step/@name,util:serialize($declare-step,<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" saxon:indent-spaces="1"/>)))


return

    (: return topologically sorted pipeline  --------------------------------------------------- :)

    if(empty($pipelinename))then
        util:pipeline-step-sort($explicitnames,())
    else
    (: if dealing with p:pipeline  ------------------------------------------------------------- :)
        <p:pipeline xmlns:xproc="http://xproc.net/xproc" name="{if ($pipelinename eq '') then $unique_id else $pipelinename}" xproc:defaultname="{$unique_id}">
            { util:pipeline-step-sort($explicitnames,())}
        </p:pipeline>

};


(: -------------------------------------------------------------------------- :)
(: PREPARSE II. bind output to input ports :)
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
        if(xproc:step-available($stepname)) then

            element {node-name($step)} {

                 attribute name{if($step/@name eq '') then $step/@xproc:defaultname else $step/@name},
                 attribute xproc:defaultname{$step/@xproc:defaultname},
                 attribute xproc:type{xproc:type($stepname)},
                 attribute xproc:step{concat('$',xproc:type($stepname),':',local-name($step))},
                 (

                    (: generate bindings for input---------------------------------------------- :)
                    for $input in $step/p:input
                        return
                          element {node-name($input)}{
                             attribute port{$input/@port},
                             attribute primary{if ($input/@primary eq '') then 'true' else $input/@primary},
                             attribute select{if($input/@select eq '') then string('/') else $input/@select},

                                if ($input/p:document or $input/p:inline or $input/p:empty) then
                                    $input/*
                                else
                                (: bind p:pipe elements :)

(: NOTE - refactor here ------------------------------------------------------------------------ :)

    (: if p:pipe is not defined then pipe in preceding step :)
    (: if 1st step in pipeline, then it should be ext:pre and primary input should take in stdin :)
    (: p:pipe should get their values from xproc:output :)
    (: late bind non defined inputs :)


                           (: primary input step that takes in previous step :)
                           if (exists($input/p:pipe) and $input/@primary='true' and not($xproc/*[last()]/@*:defaultname)) then
                                <p:pipe step="{$xproc/*[$count - 1]/@name}" port="{$xproc/*[$count - 1]/p:output[@primary='true']/@port}"/>

                           (: non-primary inputs with pipe :)
                           else if ($input/p:pipe and not($input/@primary='true')) then
                                $input/*

                           (: p:document & p:inline & p:empty :)
                           else
                                $input/*

                          },

                          for $option in $step/p:with-option
                            return 
                                $option
                          ,

                          for $output in $step/p:output
                            return 
                                $output
                )
            
            }

         else if (xproc:comp-available($stepname)) then
            element {node-name($step)} {
                if ($step/@type) then attribute type{$step/@type} else (),
                if ($step/@psvi-required) then attribute psvi-required{$step/@psvi-required} else (),
                if ($step/@xpath-version) then attribute xpath-version{$step/@xpath-version} else (),
                if ($step/@exclude-inline-prefixes) then attribute exclude-inline-prefixes{$step/@exclude-inline-prefixes} else (),

                attribute name{$step/@name},
                attribute xproc:defaultname{$step/@xproc:defaultname},
                attribute xproc:type{xproc:type($stepname)},
                 attribute xproc:step{concat('$',xproc:type($stepname),':',local-name($step))},
                
                   xproc:explicitbindings(document{$step/*})
                
            }

        else if ($xproc/p:declare-step[@type=$stepname]) then
            $step

        else
            util:staticError('err:XS0044', concat("parssing explicit binding pass:",$stepname,$step/@name))

return 
    (: if dealing with nested components --------------------------------------------------------- :)
    if(empty($pipelinename)) then
        $explicitbindings
    else
    (: if dealing with p:pipeline component ------------------------------------------------------ :)
        <p:declare-step xmlns:xproc="http://xproc.net/xproc"
                        name="{$pipelinename}"
                        xproc:defaultname="{$xproc/@xproc:defaultname}">
            {$explicitbindings}
        </p:declare-step>

};


(: -------------------------------------------------------------------------- :)
(: Fix up top level input/output with ext:pre :)
(: -------------------------------------------------------------------------- :)
declare function xproc:fixup($xproc as item(),$stdin){

let $pipeline := $xproc/p:*[name(.) = "p:pipeline" or name(.) ="p:declare-step"]
    return
        <p:declare-step name="{$pipeline/@name}">
            <ext:pre>
            {
            <p:input port="source"
                     kind="document"
                     select="{$pipeline/p:input[@port='source']/@select}"
                     sequence="{$pipeline/p:input[@port='source']/@sequence}">
            {if($stdin) then
                <p:pipe step="{$pipeline/@name}" port="stdin"/>
            else
                $pipeline/p:input[@port='source']/*
            }
            </p:input>,

            <p:output port="result" select="{$pipeline/p:output[@port='result']/@select}"/>,

            $pipeline/p:input[not(@port='source')],

            $pipeline/p:output[not(@port='result')]
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

            <ext:post/>
</p:declare-step>
};


(: -------------------------------------------------------------------------- :)
(: Preparse pipeline XML, sorting steps by input, throwing some static errors :)
(: apply explicitnames then explicitbindings :)
(: -------------------------------------------------------------------------- :)
declare function xproc:preparse($pipeline as item(),$stdin){
    xproc:explicitbindings(
          xproc:explicitnames(
                xproc:fixup($pipeline,$stdin)
          ,$const:init_unique_id)
    )
};


(: -------------------------------------------------------------------------- :)
(: Generate xquery steps sequence :)
declare function xproc:gensteps1($steps) as xs:string* {
    for $step in $steps/*[not(name()='p:documentation')] 
    return
        let $name := $step/@name
        return
            $name
};


(: -------------------------------------------------------------------------- :)
declare function xproc:parse($xproc as item(),$stdin as item()) {
    xproc:parse_and_eval($xproc,$stdin)
};


(: -------------------------------------------------------------------------- :)
(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
declare function xproc:parse_and_eval($xproc as item(),$stdin as item()) {

    let $pipeline := $xproc
    let $steps := xproc:gensteps1($xproc)
    return
        util:step-fold($pipeline,
                       $steps,
                       saxon:function("xproc:evalstep", 4),
                       $stdin,
                       (<xproc:output
                                step="{if ($steps[1] = '|') then '!1|' else $steps[1]}"
                                port="stdin"
                                port-type="external"
                                primary="false" 
                                func="{$pipeline/@type}">{$stdin}</xproc:output>)
                        )
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


(:---------------------------------------------------------------------------:)

declare function xproc:resolve-port-binding($child,$result,$pipeline,$currentstep){


(: empty step:)            if(name($child)='p:empty') then

                                (<!-- returned empty //-->)

(: inline :)               else if(name($child)='p:inline') then

                                 $child/*

(: document :)             else if(name($child)='p:document') then

                                 if (doc-available($child/@href)) then
                                       doc($child/@href)
                                 else
                                       util:dynamicError('err:XD0002',concat(" p:document cannot access document ",$child/@href))

(: data :)                 else if(name($child)='p:data') then

                                 if ($child/@href) then
                                         util:unparsed-data($child/@href,'text/plain')
                                 else
                                       util:dynamicError('err:XD0002',concat(" p:data cannot access document ",$child/@href))

(: stdin :)                else if ($child/@port eq 'stdin' and $child/@step eq $pipeline/@name) then

                                 $result/xproc:output[@port='stdin'][@step=$currentstep/@name]/*

(: prmy top level input :)  else if ($child/@port eq 'source' and $child/@step eq $pipeline/@name) then

                                  $result/xproc:output[@port='result'][@step='!1.1']/*

(: top level input :)       else if ($child/@step eq $pipeline/@name) then

                                <not_implemented_yet/>
(:
                                  $result/xproc:output[@port='result'][@step='!1.1']/xproc:inputs/p:input[@port=$child/@port]/*
:)
(: pipe :)                  else if ($child/@port) then

                                  if ($result/xproc:output[@port=$child/@port][@step=$child/@step]) then
                                       $result/xproc:output[@port=$child/@port][@step=$child/@step]/*
                                  else
                                       util:dynamicError('err:XD0001',concat(" cannot bind to port: ",$child/@port," step: ",$child/@step,' ',util:serialize($currentstep,<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" saxon:indent-spaces="1"/>)))
                            else

                                 $result/xproc:output[@port='stdin'][@step=$currentstep/@name]/*
};

declare function xproc:generate-primary($pipeline,$step,$currentstep,$primaryinput,$result){

let $primaryresult := document{

    if($currentstep/p:input/*) then

        for $child in $currentstep/p:input/*

        return

            xproc:resolve-port-binding($child,$result,$pipeline,$currentstep)

    else
           $primaryinput/*
    }

    let $select := string( if ($currentstep/p:input[@primary='true'][@select]/@select) then
                        $currentstep/p:input[@primary='true'][@select]/@select
                   else
                        '/'
                    )

    let $selectval :=util:evalXPATH(string($select),$primaryresult)
       return
            if (empty($selectval)) then
                util:dynamicError('err:XD0016',concat(string($pipeline/*[@name=$step]/p:input[@primary='true'][@select]/@select)," did not select anything at ",$step," ",name($pipeline/*[@name=$step])))
            else
                $selectval
};


declare function xproc:generate-secondary($pipeline,$step,$currentstep,$primaryinput,$result){
<xproc:inputs>{
    for $input in $currentstep/p:input[@primary='false']
        return
        <p:input port="{$input/@port}" select="{$input/@select}">
{
    let $primaryresult := document{
        for $child in $input/*
        return
            xproc:resolve-port-binding($child,$result,$pipeline,$currentstep)
    }

    let $select := string(
               if ($input/@select) then
                    string($input/@select)
               else
                    '/'
                )

    let $selectval :=util:evalXPATH(string($select),$primaryresult)
       return
            if (empty($selectval)) then
                util:dynamicError('err:XD0016',concat(string($pipeline/*[@name=$step]/p:input[@primary='true'][@select]/@select)," did not select anything at ",$step," ",name($pipeline/*[@name=$step])))
            else
                $selectval
}
        </p:input>

}</xproc:inputs>
};


declare function xproc:generate-options($pipeline,$step){
    <xproc:options>
    {
        $pipeline/*[@name=$step]/p:with-option
    }
    </xproc:options>
};


declare function xproc:generate-outputs($pipeline,$step){
    <xproc:outputs>
    {
        $pipeline/*[@name=$step]/p:output
    }
    </xproc:outputs>
};


(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$primaryinput,$pipeline,$outputs) {

    let $currentstep := $pipeline/*[@name=$step]
    let $stepfuncname := $currentstep/@xproc:step
    let $stepfunc := concat($const:default-imports,$stepfuncname)    
    let $outputs := document{$outputs}
    let $primary := xproc:generate-primary($pipeline,$step,$currentstep,$primaryinput,$outputs)
    let $secondary := xproc:generate-secondary($pipeline,$step,$currentstep,$primaryinput,$outputs)
    let $options := xproc:generate-options($pipeline,$step)
    let $output := xproc:generate-outputs($pipeline,$step)

    return

        if (name($currentstep) eq 'p:declare-step') then
            (:TODO add in bindings and options when they are done :)
            xproc:run(document{<p:pipeline name="{$currentstep/@xproc:defaultname}"
                                    xmlns:p="http://www.w3.org/ns/xproc">
                                          {$currentstep/node()}
                                </p:pipeline>},$primary,'0','0',
                                 '','')
        else
            (
            for $child in $secondary/p:input
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
             <xproc:output step="{$step}"
                          port-type="output"
                          primary="true"
                          select="{$currentstep/p:output[@primary='true']/@select}"
                          port="{$currentstep/p:output[@primary='true']/@port}"
                          func="{$stepfuncname}">{
                            util:call(util:xquery($stepfunc),$primary,$secondary,$options)
                          }
             </xproc:output>
            )
};

(:---------------------------------------------------------------------------:)



















(: -------------------------------------------------------------------------- :)
declare function xproc:run($pipeline,$stdin,$dflag,$tflag,$bindings,$options){

    let $start-time := util:timing()

    (: STEP I: generate parse tree :)
    let $preparse := xproc:preparse($pipeline,$stdin)

    (: STEP II: parse and eval tree :)
    let $eval_result := xproc:parse_and_eval($preparse,$stdin)

    (: STEP III: serialize and return results :)
    let $serialized_result := xproc:output($eval_result,$dflag)

    let $end-time := util:timing()

    let $internaldbg :=0

    return
    if ($internaldbg eq 1) then

        xproc:explicitbindings(
                  xproc:explicitnames(
                        xproc:fixup($pipeline,$stdin)
                  ,$const:init_unique_id)
        )

    else
    (
     if ($tflag="1") then
            document
               {
                <xproc:result xproc:timing="{$end-time - $start-time}ms" xproc:ts="{current-dateTime()}">
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