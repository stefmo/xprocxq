xquery version "1.0" encoding "UTF-8";

module namespace xproc = "http://xproc.net/xproc";


(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

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
(: make all input/output pipe bindings to steps explicit :)
declare function xproc:explicitbindings($xproc as item()){

let $pipelinename := $xproc/@name

let $explicitbindings := <p:pipeline xmlns:xproc="http://xproc.net/xproc" name="{$pipelinename}" xproc:preparsed="true">

{

let $steps :=$xproc/*

for $step at $count in $steps

    let $stepname := name($step)

    let $component :=$comp:components/xproc:library/xproc:top-level-element[@type=$stepname]

    let $stdstep := $std:steps/p:declare-step[@type=$stepname]
    let $optstep := $opt:steps/p:declare-step[@type=$stepname]
    let $extstep := $ext:steps/p:declare-step[@type=$stepname]
    let $currentstep :=($stdstep,$optstep,$extstep)

    let $compexists := exists($component)
    let $stdstepexists := exists($stdstep)
    let $optstepexists := exists($optstep)
    let $extstepexists := exists($extstep)

    return

    (:std step element:)
    if($stdstepexists=true() or $optstepexists=true() or $extstepexists=true() ) then

        element {$stepname} {
             attribute name{$step/@name},attribute xproc:defaultname{$step/@xproc:defaultname},
             (
                (: generate bindings for input:)
                for $input in $step/p:*[name(.)='p:input']
                    return
                      element {name($input)}{
                         attribute port{$input/@port},attribute primary{$input/@primary},attribute select{$input/@select},
                
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
                      },

                (: generate bindings for output:)
                for $output in $step/p:*[name(.)='p:output']
                    return
                        $output,

                (: generate options:)
                for $option in $step/p:option 
                    return
                      element {name($option)}{
                           attribute name{$option/@name},attribute select{$option/@select},attribute value{$option/@value}
                      }
             )                   
        }

    (: preparse xproc component :)
     else if ($compexists=true()) then
        $step

     else if (name($step)= 'err:error') then
        $step

     else
     (:TODO: need to implement static error here:)
        <err:error message="general static error thrown during explicit binding: "/>
}

</p:pipeline>

return 
    $explicitbindings

};

(: -------------------------------------------------------------------------- :)
(: make all step and input/output pipe names explicit :)
declare function xproc:explicitnames($xproc as item()){

let $pipelinename := $xproc/@name

let $explicitnames := 

    let $steps :=$xproc/*

    for $step at $count in $steps

        let $stepname := name($step)

        let $unique_before := concat('!',$count - 1,':',$pipelinename,':',$step/@name)
        let $unique_current := concat('!',$count,':',$pipelinename,':',$step/@name)

        let $component := $comp:components/xproc:library/xproc:top-level-element[@type=$stepname]

        let $stdstep := $std:steps/p:declare-step[@type=$stepname]
        let $optstep := $opt:steps/p:declare-step[@type=$stepname]
        let $extstep := $ext:steps/p:declare-step[@type=$stepname]

        let $currentstep :=($stdstep,$optstep,$extstep)

        let $compexists := exists($component)
        let $stdstepexists := exists($stdstep)
        let $optstepexists := exists($optstep)
        let $extstepexists := exists($extstep)

        return

(: preparse xproc step :)    

(:std step element:)
     if($stdstepexists=true()) then

        element {$stepname} { 
             attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
             (
                (: generate bindings for input and output:)
                for $binding in $stdstep/p:*[name(.)='p:input' or name(.)='p:output'] 
                    return
                      element {name($binding)}{
                         attribute port{$binding/@port},attribute primary{$binding/@primary},attribute select{$step/p:input[@port=$binding/@port][@primary='true']/@select},
                       $step/p:*[name()=name($binding)]/p:*
                      },
                (: generate options:)
                for $option in $stdstep/p:option 
                    return
                      element {name($option)}{
                           attribute name{$option/@name},attribute select{$step/p:option[@name=$option/@name]/@select},attribute value{$step/p:option[@name=$option/@name]/@value}
                      }

             )                   
        }

     else if($optstepexists=true()) then

        element {$stepname} { 
             attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
             (
                (: generate bindings for input and output:)
                for $binding in $optstep/p:*[name(.)='p:input' or name(.)='p:output'] 
                    return
                      element {name($binding)}{
                         attribute port{$binding/@port},attribute primary{$binding/@primary},attribute select{$step/p:input[@port=$binding/@port][@primary='true']/@select},
                       $step/p:*[name()=name($binding)]/p:*
                      },
                (: generate options:)
                for $option in $optstep/p:option 
                    return
                      element {name($option)}{
                           attribute name{$option/@name},attribute select{$step/p:option[@name=$option/@name]/@select},attribute value{$step/p:option[@name=$option/@name]/@value}
                    }

             )                   
        }

     else if($extstepexists=true()) then

        element {$stepname} { 
             attribute name{$step/@name},attribute xproc:defaultname{$unique_current},
             (
                (: generate bindings for input and output:)
                for $binding in $extstep/p:*[name(.)='p:input' or name(.)='p:output'] 
                    return
                      element {name($binding)}{
                         attribute port{$binding/@port},attribute primary{$binding/@primary},attribute select{$step/p:input[@port=$binding/@port][@primary='true']/@select},
                       $step/p:*[name()=name($binding)]/p:*
                      },
                (: generate options:)
                for $option in $extstep/p:option 
                    return
                      element {name($option)}{
                           attribute name{$option/@name},attribute select{$step/p:option[@name=$option/@name]/@select},attribute value{$step/p:option[@name=$option/@name]/@value}
                      }
             )                   
        }


(: preparse xproc component :)
     else if ($compexists=true()) then

		(:binds unconnected primary input to stdin:)
		    if ($stepname='p:input' and $step/@primary='true' and not($step/p:*)) then

		        element {$stepname} {
		            attribute port {$step/@port},
		            attribute primary {'true'},
		            attribute xproc:stdin {'true'},

		            (: bind to either inline, or doc :)
		            <p:pipe step="{$xproc/@name}" port="xproc:stdin"/> 
		        }

		(:binds unconnected primary output to stdout:)
		    else if ($stepname='p:output' and $step/@primary='true' and not($step/p:*)) then

		        element {$stepname} { 
		            attribute port {$step/@port},
		            attribute primary {'true'},
		            attribute xproc:stdout {'true'},                           
(:
    unbounded primary output <- last step output 
:)		            
                        <p:pipe step="!0:{$pipelinename}" port="result"/> 
		        }

		(:handle generic input/output:)
		    else 
		        element {$stepname} {
		            attribute port {$step/@port},
		            <p:pipe step="" port=""/> 
		        }
    else
    (:TODO: need to implement static error here:)
        <err:error message="general static error thrown during explicit naming: {name($step)} is an unknown element"/>


    return
    (:apply a topological sort based on step names :)
        <p:pipeline name="{$pipelinename}">
            {util:pipeline-step-sort($explicitnames,())}
        </p:pipeline>
};


(: -------------------------------------------------------------------------- :)
(: Preparse pipeline XML, sorting steps by input, throwing some static errors :)
declare function xproc:preparse($xproc as item()){

let $preparse := xproc:explicitbindings(xproc:explicitnames($xproc))
return
    if (fn:not($preparse//err:error)) then     
        $preparse
    else
        (:TODO: throws a rudimentary xproc static error :)
        fn:error( QName("http://www.w3.org/ns/xproc-error", "XprocStaticError"), concat('preparse result: ',util:serialize($preparse,<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>)))

};


(: Parse pipeline XML, generating xquery code, throwing some static errors if neccesary :)
declare function xproc:parse($xproc as item()) {

   (fn:string('import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
let $O0 := <test/>'),
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
(: TODO: this needs to be refactored. :)
declare function xproc:build($parsetree) {

    fn:string-join($parsetree,'')

};


(: -------------------------------------------------------------------------- :)
(: Eval Run Tree :)
(: this function may throw some dynamic errors :)
declare function xproc:eval($runtree,$stdin){
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
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";','

$std:',$stepfunction))

    return (
        (:TODO:temporary hack to get around blank steps, which are caused by input/outputs and top level elements for now :)
            if($stepfunction='') then
                $primaryinput
            else
                util:call( util:xquery($stepfunc),
                           (
                           if($pipeline/*[@xproc:defaultname=$step]/p:input[@select=''][@primary='true']) then
                                $primaryinput[1]
                           else
                               util:evalXPATH(fn:string($pipeline/*[@xproc:defaultname=$step]/p:input[@primary='true'][@select]/@select),document{$primaryinput[1]}),
                           <inputs>{
                                for $input in $pipeline/*[@xproc:defaultname=$step]/p:input[not(@primary='true')]
                                    return 
                                        if ($input/p:document) then
                                            element {name($input)}{
                                             attribute port{$input/@port},attribute primary{$input/@primary},attribute select{$input/@select},
                                             if (fn:doc-available($input/p:document/@href)) then
                                                fn:doc($input/p:document/@href)
                                             else
                                                <err:error message="cannot access document {$input/p:document/@href}"/>
                                            }
                                        else
                                        (: p:empty and p:inline :)
                                            $input
                           }</inputs>, 
                           <outputs/>, 
                           <options>{
                                $pipeline/*[@xproc:defaultname=$step]/p:option
                           }</options>
                            )
                )
    )

};