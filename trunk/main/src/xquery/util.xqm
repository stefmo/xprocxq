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
declare namespace xproc="http://xproc.net/xproc";

declare namespace comp = "http://xproc.net/xproc/comp";

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
declare function util:dynamicError($error,$string) {
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
    saxon:call($func,$a,$b,$c)
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
declare function util:xquery($exp as xs:string) as item()*{
    let $a := func:compileQuery($exp)
    return 
        func:query($a)
};

(: -------------------------------------------------------------------------- :)
declare function util:serialize($xproc,$output){
     saxon:serialize($xproc,$output)
};

(: -------------------------------------------------------------------------- :)
(: All those useful FP functions ... all dependent on xquery eval() call :)
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

declare function util:step-fold ($pipeline,$steps as item()*, $operation, $primaryinput) {
     if (empty($steps)) then $primaryinput
                           else 
                                    let $newinput := util:call($operation, 
                                                              $steps[1], 
                                                              $primaryinput,
                                                              $pipeline)
                           return
                                    util:step-fold($pipeline,
                                                   remove($steps, 1), 
                                                   $operation,
                                                   $newinput)

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