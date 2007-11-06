xquery version "1.0" encoding "UTF-8";

module namespace util = "http://xproc.net/xproc/util";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Saxon Namespace Declaration :)
declare namespace saxon="http://saxon.sf.net/";
declare namespace jt="http://net.sf.saxon/java-type";

declare namespace func="java:net.xproc.saxon.evalXQuery";

declare function util:help() as xs:string {
    "help util executed"
};


(: TODO: all of the below functions need to add exist eval function :)


declare function util:eval($exp as xs:string) as item()*{
    saxon:eval(saxon:expression($exp))
};


declare function util:call($func,$a,$b){
    saxon:call($func,$a,$b)
};


declare function util:call($func,$a){
    saxon:call($func,$a)
};


declare function util:evalXPATH($xpathstring, $xml){
    $xml/saxon:evaluate($xpathstring)
};


declare function util:xquery($exp as xs:string) as item()*{
let $a := func:compileQuery($exp)
return func:query($a)
};


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


declare function util:numeric-fold ($sequence as xs:double*, $operation, $start-value as xs:double) {
     if (empty($sequence)) then $start-value
                           else util:numeric-fold(remove($sequence, 1), 
                                          $operation,
                                          util:call($operation, $start-value, $sequence[1]))
};


declare function util:plus ($a as xs:double, $b as xs:double) {$a + $b};


declare function util:times ($a as xs:double, $b as xs:double) {$a * $b};


declare function util:sum ($sequence as xs:double*) as xs:double {
   util:numeric-fold($sequence, saxon:function('util:plus', 2), 0)
};


declare function util:product ($sequence as xs:double*) as xs:double {
   util:numeric-fold($sequence, saxon:function('util:times', 2), 1)
};