xquery version "1.0" encoding "UTF-8";

module namespace util = "http://xproc.net/xproc/util";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Other Namespace Declaration :)
declare namespace saxon="http://saxon.sf.net/";
declare namespace jt="http://net.sf.saxon/java-type";
declare namespace func="java:net.xproc.saxon.evalXQuery";
declare namespace system="java:java.lang.System";
declare namespace math="http://exslt.org/math";
declare namespace comp = "http://xproc.net/xproc/comp";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "../xquery/const.xqm";

(: set to 1 to enable debugging :)
declare variable $util:NDEBUG:=1;

(: -------------------------------------------------------------------------- :)
declare function util:help() as xs:string {
    "help util executed"
};

(: -------------------------------------------------------------------------- :)
declare function util:timing() as xs:integer  {
    xs:integer(system:currentTimeMillis())
};

(: -------------------------------------------------------------------------- :)
declare function util:assert($booleanexp as item(), $why as xs:string)  {
if(fn:not($booleanexp) and fn:boolean($util:NDEBUG)) then 
    util:dynamicError('err:XC0020',$why)
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function util:assert($booleanexp as item(), $why as xs:string,$error)  {
if(fn:not($booleanexp) and fn:boolean($util:NDEBUG)) then 
    util:dynamicError($error,$why)
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function util:boolean($test as xs:string)  {
if(contains($test,'false') ) then 
    false()
else
    true()
};


(: -------------------------------------------------------------------------- :)
declare function util:dynamicError($error,$string) {
    fn:error(QName('http://www.w3.org/ns/xproc-error',$error), $string)
};

(: -------------------------------------------------------------------------- :)
declare function util:staticError($error,$string) {
let $info := $const:error-xproc//error[code=$error]
return
    fn:error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Static Error: ",$string," ",$info/description/text()))
};

(: -------------------------------------------------------------------------- :)
declare function util:stepError($error,$string) {
    fn:error(QName('http://www.w3.org/ns/xproc-error',$error), $string)
};

(: -------------------------------------------------------------------------- :)
declare function util:outputResultElement($exp){
    <c:result>{$exp}</c:result>
};

(: -------------------------------------------------------------------------- :)
declare function util:random() as  xs:double  {
   math:random()
};

(: -------------------------------------------------------------------------- :)
declare function util:eval($exp as xs:string) as item()*{
    saxon:eval(saxon:expression($exp))
};

(: -------------------------------------------------------------------------- :)
(: TODO: refactor the following into a single function :)
declare function util:call($func,$a){
    saxon:call($func,$a)
};


declare function util:call($func,$a,$b){
    saxon:call($func,$a,$b)
};


declare function util:call($func,$a,$b,$c){
    saxon:call($func,$a,$b,$c)
};


declare function util:call($func,$a,$b,$c,$d){
    saxon:call($func,$a,$b,$c,$d)
};


declare function util:call($func,$a,$b,$c,$d,$e){
    saxon:call($func,$a,$b,$c,$d,$e)
};

(: -------------------------------------------------------------------------- :)
(:
declare function util:function($func,$arity){
    saxon:function($func, $arity)
};
:)

(: -------------------------------------------------------------------------- :)
declare function util:evalXPATH($xpathstring, $xml){
    $xml/saxon:evaluate($xpathstring)
};


(: -------------------------------------------------------------------------- :)
declare function util:xquery($exp as xs:string){
    let $a := func:compileQuery($exp)
    let $result := func:query($a)
    return
        $result
};


(: -------------------------------------------------------------------------- :)
declare function util:xslt($xslt,$xml) as item()*{
let $compiled_xslt := saxon:compile-stylesheet(document{$xslt})
    return saxon:transform($compiled_xslt, document{$xml})
};

(: -------------------------------------------------------------------------- :)
declare function util:validate($exp) as xs:string {
$exp
(:
    nvdl:main("file:test/data/w3schema.xml file:test/data/schema-example.xml")
:)
};

(: -------------------------------------------------------------------------- :)
declare function util:serialize($xproc,$output){
     saxon:serialize($xproc,$output)
};

(: -------------------------------------------------------------------------- :)
declare function util:map($func, $seqA as item()*, $seqB as item()*) 
as item()* {
	if(count($seqA) != count($seqB)) then ()
	else
    	for $a at $i in $seqA
    	let $b := $seqB[$i]
    	return
        	util:call($func, $a, $b)
};

(: -------------------------------------------------------------------------- :)
declare function util:filter($func, $seq as item()*) 
as item()* {
	for $i in $seq
	return
		if(util:call($func, $i)) then
			$i
		else
			()
};

(: -------------------------------------------------------------------------- :)
(: test folding the step with a different function :)
declare function util:printstep ($step,$meta,$value) {
    util:call( $step, $value)
};


(: -------------------------------------------------------------------------- :)
(: topological sorting of pipeline steps, based on inputs :)
declare function util:pipeline-step-sort($unsorted, $sorted )   {
    if (empty($unsorted))      
       then $sorted 
    else
       let $allnodes := $unsorted [ every $step in p:input/p:pipe/@step 
                                                    satisfies $step = $sorted/@name]
       return 
           util:pipeline-step-sort( $unsorted except $allnodes, 
                                            ($sorted, $allnodes) )
};



(: -------------------------------------------------------------------------- :)
declare function util:final-result($primaryresult,$pipeline,$resulttree){
    ($primaryresult,$pipeline,$resulttree)
};



(: -------------------------------------------------------------------------- :)
declare function util:step-fold1 ($pipeline,$steps,$stepfuncs, $evalstep, $primaryinput, $resulttree) {
$primaryinput
};

(: -------------------------------------------------------------------------- :)
declare function util:step-fold($pipeline,$steps,$stepfuncs, $evalstep, $primaryinput, $resulttree) {
  
    if (empty($steps)) then
       (: no more steps return the results :)
           util:final-result($primaryinput,$pipeline,$resulttree)
    else 
       (: perform evalstep function, generating new primary input :)
       let $result := util:call($evalstep, 
                                  $steps[1],
                                  $stepfuncs[1],
                                  $primaryinput,
                                  $pipeline,
                                  $resulttree)

    return

       (: TODO: tail end recursion, could probably optimise this manually; will investigate
                if the xquery processor is not already optimizing :)
        util:step-fold($pipeline,
                       remove($steps, 1),
                       remove($stepfuncs, 1),
                       $evalstep,
                       $result,
                       ($resulttree,<util:step-state output-port="" name="{$steps[1]}" func="{$stepfuncs[1]}">{$result}</util:step-state>) 
                       )
};

(: -------------------------------------------------------------------------- :)