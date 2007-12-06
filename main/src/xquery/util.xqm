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

(: -------------------------------------------------------------------------- :)

declare function util:help() as xs:string {
    "help util executed"
};

(: -------------------------------------------------------------------------- :)

declare function util:timing() as xs:integer  {
    xs:integer(system:currentTimeMillis())
};


(: -------------------------------------------------------------------------- :)
(: TODO: all of the below functions need to add exist eval function :)


declare function util:eval($exp as xs:string) as item()*{
    saxon:eval(saxon:expression($exp))
};


declare function util:call($func,$a){
    saxon:call($func,$a)
};


declare function util:call($func,$a,$b){
    saxon:call($func,$a,$b)
};


declare function util:call($func,$a,$b,$c){
    saxon:call($func,$a,$b,$c)
};


(:
declare function util:function($func,$arity){
    saxon:function($func, $arity)
};
:)


declare function util:evalXPATH($xpathstring, $xml){
    $xml/saxon:evaluate($xpathstring)
};


declare function util:xquery($exp as xs:string) as item()*{
let $a := func:compileQuery($exp)
return func:query($a)
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

declare function util:step-fold ($sequence as item()*, $operation, $start-value as item()*) {
     if (empty($sequence)) then $start-value
                           else util:step-fold(remove(remove($sequence, 1),1), 
                                          $operation,
                                          util:call($operation, $sequence[1], $sequence[2], $start-value))
};


(: -------------------------------------------------------------------------- :)
(: evaluate the step, throwing dynamic errors and writing output along the way :)
declare function util:evalstep ($step,$meta,$value) {
    util:call( $step, $value)
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