xquery version "1.0" encoding "UTF-8";

module namespace util = "http://xproc.net/xproc/util";
declare copy-namespaces no-preserve,inherit;

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
declare namespace xproc = "http://xproc.net/xproc";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "../xquery/const.xqm";

(: set to 1 to enable debugging :)
declare variable $util:NDEBUG :=1;

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
if(not($booleanexp) and boolean($util:NDEBUG)) then 
    util:dynamicError('err:XC0020',$why)
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function util:trace($value as item()*, $what as xs:string)  {
if(boolean($util:NDEBUG)) then
    trace($value,$what)
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function util:assert($booleanexp as item(), $why as xs:string,$error)  {
if(not($booleanexp) and boolean($util:NDEBUG)) then 
    util:stepError($error,$why)
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
(: TODO: consider combining error throwing functions :)

declare function util:dynamicError($error,$string) {
let $info := $const:error-dynamic//error[code=$error]
return
    error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Dynamic Error: ",$string," ",$info/description/text()))
};

declare function util:staticError($error,$string) {
let $info := $const:error-static//error[code=$error]
return
    error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Static Error: ",$string," ",$info/description/text()))
};

declare function util:stepError($error,$string) {
let $info := $const:error-step//error[code=$error]
return
    error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Step Error: ",$string," ",$info/description/text()))
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
declare function util:call($func,$a) as item()*{
    saxon:call($func,$a)
};


declare function util:call($func,$a,$b) as item()*{
    saxon:call($func,$a,$b)
};


declare function util:call($func,$a,$b,$c) as item()*{
    saxon:call($func,$a,$b,$c)
};


declare function util:call($func,$a,$b,$c,$d) as item()*{
    saxon:call($func,$a,$b,$c,$d)
};


declare function util:call($func,$a,$b,$c,$d,$e) as item()*{
    saxon:call($func,$a,$b,$c,$d,$e)
};

(: -------------------------------------------------------------------------- :)
(:
declare function util:function($func,$arity){
    saxon:function($func, $arity)
};
:)

(: -------------------------------------------------------------------------- :)
declare function util:evalXPATH($xpathstring, $xml as item()*) as item()*{
    let $test:= document{$xml}
    return $test/saxon:evaluate($xpathstring)
};

(: -------------------------------------------------------------------------- :)
declare function util:get-option($option,$v){
    if (empty($option)) then
        ()
    else if(matches($option,"^'") and matches($option,"$'")) then
        string(replace($option,"'",""))
    else
        string(util:evalXPATH(string($option),$v))
};

(: -------------------------------------------------------------------------- :)
declare function util:treewalker ($html) {

  let $children := $html/*
  return
      if(empty($children)) then ()
      else
        for $c in $children
            return
                ( element {name($c)}{
                    $c/@*,
                    $c/text(),
                    util:treewalker($c)
                })
 };


(: -------------------------------------------------------------------------- :)
declare function util:remove-elements
  ( $elements ,
    $names as xs:string* )  as element()* {

   for $element in $elements
   return element
     {node-name($element)}
     {$element/@*,
      $element/node()[not(util:name-test(name(),$names))] }
 } ;

declare function util:name-test
  ( $testname as xs:string? ,
    $names as xs:string* )  as xs:boolean {

$testname = $names
or
$names = '*'
or
util:substring-after-if-contains($testname,':') =
   (for $name in $names
   return substring-after($name,'*:'))
or
substring-before($testname,':') =
   (for $name in $names[contains(.,':*')]
   return substring-before($name,':*'))
 } ;

declare function util:substring-after-if-contains 
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {

   if (contains($arg,$delim))
   then substring-after($arg,$delim)
   else $arg
 } ;

declare function util:add-attributes
  ( $elements as element()* ,
    $attrNames as xs:QName* ,
    $attrValues as xs:anyAtomicType* )  as element()? {

   for $element in $elements
   return element { node-name($element)}
                  { for $attrName at $seq in $attrNames
                    return if ($element/@*[node-name(.) = $attrName])
                           then ()
                           else attribute {$attrName}
                                          {$attrValues[$seq]},
                    $element/@*,
                    $element/node() }
 } ;

(: -------------------------------------------------------------------------- :)
declare function util:treewalker ($tree,$attrFunc,$textFunc,$attName,$attValue) {

  let $children := $tree/*
  return
      if(empty($children)) then ()
      else
        for $c in $children
            return
                ( element {name($c)}{
                            saxon:call($attrFunc,$c/@*,$attName,$attValue),
                            saxon:call($textFunc,$c/text()),
                        util:treewalker($c,$attrFunc,$textFunc,$attName,$attValue)
                })
};


declare function util:attrHandler ($attr,$attName,$attValue) {
	$attr, attribute {string($attName)}{string($attValue)}
 };

declare function util:textHandler ($text) {
	$text
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
declare function util:serialize($xml,$output){
     saxon:serialize($xml,$output)
};

(: -------------------------------------------------------------------------- :)
declare function util:parse-string($string){
     saxon:parse($string)
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



declare function util:strip-namespace($e as element()) as element() {
  
   element {QName((),local-name($e))} {
    for $child in $e/(@*,*)
    return
      if ($child instance of element())
      then
        util:strip-namespace($child)
      else
        $child
  }
};


(: -------------------------------------------------------------------------- :)
declare function util:final-result($pipeline,$resulttree){
    ($pipeline,$resulttree)
};


(: -------------------------------------------------------------------------- :)
declare function util:step-fold( $pipeline,
                                 $steps,
                                 $stepfuncs,
                                 $evalstep-function,
                                 $primaryinput as item()*,
                                 $outputs) {
  
    if (empty($steps)) then

           util:final-result($pipeline,$outputs)

    else
        let $result:= util:call($evalstep-function,
                              $steps[1],
                              $stepfuncs[1],
                              $primaryinput,
                              $pipeline,
                              $outputs)
    return

        util:step-fold($pipeline,
                   remove($steps, 1),
                   remove($stepfuncs, 1),
                   $evalstep-function,
                   $result,
                   ($outputs
                            ,<xproc:output
                                step="{$steps[1]}"
                                port="{$pipeline/*[@name=$steps[1]]/p:output[1]/@port}"
                                func="{$stepfuncs[1]}">{$result}</xproc:output>)
                   )
};

(: -------------------------------------------------------------------------- :)