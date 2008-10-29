xquery version "1.0" encoding "UTF-8"; 

module namespace xproc = "http://xproc.net/xproc";
declare copy-namespaces no-preserve,inherit;

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
(: Walking the tree I. name everything :)
(: -------------------------------------------------------------------------- :)
declare function xproc:explicitnames($xproc as item(), $unique_id){

let $pipelinename := $xproc/@name
let $declare-step := $xproc//p:declare-step

let $explicitnames := 

    for $step at $count in $xproc/*

        let $stepname := name($step)

        (: generate unique name :)
        let $unique_before := concat($unique_id,'.',$count - 1)
        let $unique_current := concat($unique_id,'.',$count)

        (: look up defined step in library :)
        let $allstep := xproc:get-step($stepname,$declare-step)

        return

            (: handle step element ------------------------------------------------------------ :)
            if(xproc:step-available($stepname,$declare-step)) then

                    (: generate step :)
                                element {$stepname} {                                                                                                                                                                                                      attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
                                     (
                                        (: generate bindings for primary input and output:)
                                        for $binding in $allstep/p:*[name(.)='p:input' or name(.)='p:output']
                                            return
                                              element {name($binding)}{
                                                 attribute port{$binding/@port},
                                                 attribute primary{if ($binding/@primary eq '') then 'true' else $binding/@primary},
                                                 attribute select{$step/p:input[@port=$binding/@port]/@select},
                                                 $step/p:input[@port=$binding/@port]/*
                                              },

                                        (: generate bindings for primary output :)
                                              $step/p:output[@primary]
                                              ,

                                        (: generate bindings for non-primary input :)
                                              (: $step/p:input[not(@primary)] :)
                                               ()
                                              ,

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

         else if (xproc:comp-available($stepname)) then
            element {$stepname} {
                 attribute name{if ($step/@name eq '') then $unique_current else $step/@name},
                 attribute xproc:defaultname{$unique_current},
                 (
                     (: TODO: need to recurse to get to nested subpipelines and steps :)
                           xproc:explicitnames(<util:ignore>{$step/*}</util:ignore>,$unique_current)
                 )
            }

        else
            (: TODO: throws error on unknown element in pipeline namespace :)
            util:staticError('err:XS0044', concat($stepname,":",$step/@name))

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
(: Walking the tree II. bind output to input ports :)
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

                 attribute name{if($step/@name eq '') then $step/@xproc:defaultname else $step/@name},
                 attribute xproc:defaultname{$step/@xproc:defaultname},
                 attribute xproc:type{xproc:type($stepname)},
                 (

                    (: generate bindings for input---------------------------------------------- :)
                    for $input in $step/p:input
                        return
                          element {name($input)}{
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

                           (: first step in pipeline :)
                           if (not($xproc/*[$count - 1]/@*:defaultname) and $input/@primary='true' and not($input/p:pipe)) then
                                <p:pipe step="{$pipelinename}|" port="stdin"/>

                           (: primary input step that takes in previous step :)
                           else if (exists($input/p:pipe) and $input/@primary='true' and not($xproc/*[last()]/@*:defaultname)) then
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
            element {$stepname} {
                 attribute name{$step/@name},attribute xproc:defaultname{$step/@xproc:defaultname},
                 attribute xproc:type{xproc:type($stepname)},
                (
                   xproc:explicitbindings(<util:ignore>{$step/*}</util:ignore>) 
                )
            }
         else 
            util:staticError('err:XS0044', concat($stepname,$step/@name))

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
(: Fix up all top level imports  :)
(: -------------------------------------------------------------------------- :)
(: TODO: temporary measure to use p:import :)
declare function xproc:import-fixup($xproc as item()){

        <p:pipeline name="{$xproc/@name}" xmlns:xproc="http://xproc.net/xproc">

{          
        for $import in $xproc/p:import
            return            
                if (doc-available($import/@href)) then
                      doc($import/@href)
                else
                      util:dynamicError('XD0002',"cannot import pipeline document ")
}
            {$xproc/p:*[not(name(.)="p:import")]}
        </p:pipeline>
};



(: -------------------------------------------------------------------------- :)
(: Fix up top level input/output with ext:pre :)
(: -------------------------------------------------------------------------- :)
declare function xproc:port-fixup($xproc as item()){

        <p:pipeline name="{$xproc/@name}">
            <ext:pre name="{$xproc/@name}|">
{
        <p:input port="source" primary="true"/>,
        <p:output port="result" primary="true"/>,
        $xproc/p:input[not(@primary)],
        $xproc/p:output[not(@primary)]
}
            </ext:pre>
            {$xproc/p:*[not(name(.)="p:input")][not(name(.)="p:output")]}

            <ext:post/>
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
(: Generate xquery function sequence :)
declare function xproc:gensteps2($steps) as xs:string*
{

    for $step in $steps/*[not(name()='p:documentation')] 
    return
        let $func := concat("$",$step/@xproc:type,":",local-name($step))
        return
             $func
};


declare function xproc:parse($xproc as item(),$stdin as item()) {
    xproc:parse_and_eval($xproc,$stdin)
};

(: -------------------------------------------------------------------------- :)
(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
declare function xproc:parse_and_eval($xproc as item(),$stdin as item()) {

    let $pipeline := $xproc
    let $steps := xproc:gensteps1($xproc)
    let $stepfunc := xproc:gensteps2($xproc)
    return
        util:step-fold($pipeline,
                       $steps,
                       $stepfunc,
                       saxon:function("xproc:evalstep", 5),
                       $stdin,
                       (
                        <xproc:output
                                step="{$steps[1]}"
                                port="stdin"
                                func="{$pipeline/@type}">{$stdin}</xproc:output>
                        ))
};


(: -------------------------------------------------------------------------- :)
declare function xproc:output($result,$dflag){
    if($dflag="1") then
        <xproc:debug>
            <xproc:pipeline>{subsequence($result,1,1)}</xproc:pipeline>
            <xproc:outputs>{subsequence($result,2)}</xproc:outputs>
        </xproc:debug>
    else
        if (name($result[@port='stdout']) eq 'p:empty') then
            (: FIXME: :)
           (<!-- empty result //-->)
        else
            (: TODO:  needs some attention :)
            ($result/.)[last()]/node()
};


(: -------------------------------------------------------------------------- :)
(: runtime evaluation of xproc steps; throwing dynamic errors and writing output along the way :)
declare function xproc:evalstep ($step,$stepfunc1,$primaryinput,$pipeline,$resulttree) {

    let $stepfunc := concat($const:default-imports,$stepfunc1)

    let $currentstep := $pipeline/*[@name=$step]

    let $primary := (

                    if ( exists($currentstep/p:input[@primary="true"]/*)) then
                       for $child in $currentstep/p:input[@primary="true"]/*
                       return
                       (
                            if(name($child)='p:empty') then
                                (<!-- returned empty //-->)

                            else if(name($child)='p:inline') then
                                $child/*

                            else if(name($child)='p:document') then

                                     if (doc-available($child/@href)) then
                                           doc($child/@href)
                                     else
                                           util:dynamicError('err:XD0002',concat(" p:document cannot access document ",$child/@href))

                            else if(name($child)='p:data') then

                                     if ($child/@href) then
                                             util:unparsed-text($child/@href,'text/plain')
                                     else
                                           util:dynamicError('err:XD0002',concat(" p:data cannot access document ",$child/@href))

                            else if ($child/@port) then

                                let $result := document {$resulttree}
                                    return
                                    if ($result/xproc:output[@port=$child/@port][@step=$child/@step]) then
                                        $result/xproc:output[@port=$child/@port][@step=$child/@step]/*
                                    else
                                        util:dynamicError('err:XD0001',concat(" cannot bind to output port: ",$child/@port," step: ",$child/@step,' ',
saxon:serialize($currentstep,<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" saxon:indent-spaces="1"/>)))

                            else
                                document{$primaryinput}
                        )

                    else

                    if ($pipeline/*[@name=$step]/p:input[@primary='true'][not(@select='/')]) then

                       let $selectval :=util:evalXPATH(string($pipeline/*[@name=$step]/p:input[@primary='true'][@select]/@select),
                                                       $primaryinput)
                       return
                            if (empty($selectval)) then
                                util:dynamicError('err:XD0016',concat(string($pipeline/*[@name=$step]/p:input[@primary='true'][@select]/@select)," did not select anything at ",$step," ",name($pipeline/*[@name=$step])))
                            else
                                $selectval
                    else
                           $primaryinput
                )


    let $secondary :=  <xproc:inputs>{
                            for $input in $pipeline/*[@name=$step]/p:input[not(@primary='true')]
                                return

                                    if ($input/p:document) then
                                        element {name($input)}{
                                         attribute port{$input/@port},
                                         attribute primary{$input/@primary},
                                         attribute select{$input/@select},
                                         if (doc-available($input/p:document/@href)) then
                                               doc($input/p:document/@href)
                                         else
                                               util:dynamicError('err:XD0002',concat($step," p:input ",$input/@port," cannot access document ",$input/p:document/@href))
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
                       }</xproc:inputs>


    let $options :=<xproc:options>{
                              $pipeline/*[@name=$step]/p:with-option
                       }</xproc:options>

    let $output :=<xproc:outputs>{
                              $pipeline/*[@name=$step]/p:output
                       }
                       </xproc:outputs>
    return
        util:call(
                   util:xquery($stepfunc),
                   $primary,
                   $secondary,
                   $options
                  )
};


(: -------------------------------------------------------------------------- :)
declare function xproc:run($pipeline,$input,$dflag,$tflag){

    let $start-time := util:timing()

    (: STEP I: generate parse tree :)
    let $preparse := xproc:preparse($pipeline/p:*)

    (: STEP II: parse and eval tree :)
    let $eval_result := xproc:parse_and_eval($preparse,$input)

    (: STEP III: serialize and return results :)
    let $serialized_result := xproc:output($eval_result,$dflag)

    let $end-time := util:timing()

    return
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