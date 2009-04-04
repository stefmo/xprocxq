xquery version "1.0" encoding "UTF-8";
module namespace u = "http://xproc.net/xproc/util";
(: -------------------------------------------------------------------------- :)

declare copy-namespaces no-preserve, no-inherit;

(: XProc Namespace Declaration :)
declare namespace p1="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

(:todo - needed to resolve @select on p:input related to compile- to investigate why I need to add this xmlns:)
declare namespace t="http://xproc.org/ns/testsuite";

(: Other Namespace Declaration :)
declare namespace saxon = "http://saxon.sf.net/";
declare namespace jt = "http://net.sf.saxon/java-type";
declare namespace func = "java:net.xproc.saxon.evalXQuery";
declare namespace java = "java:java.lang.System";
declare namespace math="http://exslt.org/math";

declare namespace comp = "http://xproc.net/xproc/comp";
declare namespace xproc = "http://xproc.net/xproc";
declare namespace std = "http://xproc.net/xproc/std";
declare namespace opt = "http://xproc.net/xproc/opt";
declare namespace ext = "http://xproc.net/xproc/ext";


(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const";
import module namespace p = "http://xproc.net/xproc/functions";


(: set to 1 to enable debugging :)
declare variable $u:NDEBUG :=1;

(: -------------------------------------------------------------------------- :)
declare function u:timing() as xs:float  {
    xs:float(java:currentTimeMillis())
};

(: -------------------------------------------------------------------------- :)
declare function u:assert($booleanexp as item(), $why as xs:string)  {
if(not($booleanexp) and boolean($u:NDEBUG)) then 
    u:dynamicError('err:XC0020',$why)
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function u:trace($value as item()*, $what as xs:string)  {
if(boolean($u:NDEBUG)) then
    trace($value,$what)
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function u:assert($booleanexp as item(), $why as xs:string,$error)  {
if(not($booleanexp) and boolean($u:NDEBUG)) then 
    error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Assert Error: ",$why))
else
    ()
};

(: -------------------------------------------------------------------------- :)
declare function u:boolean($test as xs:string)  {
if(contains($test,'false') ) then 
    false()
else
    true()
};

(: -------------------------------------------------------------------------- :)
declare function u:unparsed-data($uri as xs:string, $mediatype as xs:string)  {

let $xslt := saxon:compile-stylesheet(
document {
  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                  xmlns:c="http://www.w3.org/ns/xproc-step"
                  version="2.0">
    <xsl:template match="/">
    <c:data content-type="{$mediatype}">
        <xsl:copy-of select="unparsed-text('{$uri}')"/>
    </c:data>
    </xsl:template>
  </xsl:stylesheet>
}
)
let $source :=
  document { <empty/>}

return
     saxon:transform($xslt, $source)

};

(: -------------------------------------------------------------------------- :)
(: TODO: consider combining error throwing functions :)
(: consider adding saxon:line-number()  :)
declare function u:dynamicError($error,$string) {
    let $info := $const:error//error[@code=substring-after($error,':')]
    return
        error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Dynamic Error: ",$string," ",$info/text()))
};

declare function u:staticError($error,$string) {
    let $info := $const:error//error[@code=substring-after($error,':')]
    return
        error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Static Error: ",$string," ",$info/text()))
};

declare function u:stepError($error,$string) {
    let $info := $const:error//error[@code=substring-after($error,':')]
    return
        error(QName('http://www.w3.org/ns/xproc-error',$error),concat("XProc Step Error: ",$string," ",$info/text()))
};


(: -------------------------------------------------------------------------- :)
declare function u:outputResultElement($exp){
    <c:result>{$exp}</c:result>
};

(: -------------------------------------------------------------------------- :)
declare function u:random() as  xs:double  {
   math:random()
};

(: -------------------------------------------------------------------------- :)
declare function u:eval($exp as xs:string) as item()*{
    saxon:eval(saxon:expression($exp))
};

(: -------------------------------------------------------------------------- :)
(: TODO: refactor the following into a single function :)
declare function u:call($func,$a) as item()*{
    saxon:call($func,$a)
};


declare function u:call($func,$a,$b) as item()*{
    saxon:call($func,$a,$b)
};


declare function u:call($func,$a,$b,$c) as item()*{
    saxon:call($func,$a,$b,$c)
};


declare function u:call($func,$a,$b,$c,$d) as item()*{
    saxon:call($func,$a,$b,$c,$d)
};


declare function u:call($func,$a,$b,$c,$d,$e) as item()*{
    saxon:call($func,$a,$b,$c,$d,$e)
};

declare function u:call($func,$a,$b,$c,$d,$e,$f) as item()*{
    saxon:call($func,$a,$b,$c,$d,$e,$f)
};

(: -------------------------------------------------------------------------- :)
(:
declare function u:function($func,$arity){
    util:function($func, $arity)
};
:)

(: -------------------------------------------------------------------------- :)
declare function u:evalXPATH($xpathstring, $xml as item()*) as item()*{
    let $test:= document{$xml}
    return $test/saxon:evaluate($xpathstring)
};

(: -------------------------------------------------------------------------- :)
declare function u:get-option($option,$v){
    if (empty($option)) then
        ()
    else if(matches($option,"^'") and matches($option,"$'")) then
        string(replace($option,"'",""))
    else
        string(u:evalXPATH(string($option),$v))
};



declare function u:add-ns-node(
    $elem   as element(),
    $prefix as xs:string,
    $ns-uri as xs:string
  ) as element()
{
  element { QName($ns-uri, concat($prefix, ":x")) }{ $elem }/*
};


(: -------------------------------------------------------------------------- :)
declare function u:treewalker($element as element()) as element() {
   element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then u:treewalker($child)
                 else $child
      }
};


declare function u:treewalker-add-attribute($element as element(),$match,$attrName,$attrValue) as element() {
   element {node-name($element)}
      {$element/@*,
       if(name($element) = string($match)) then attribute {$attrName}{$attrValue} else (),
          for $child in $element/node()
              return
               if ($child instance of element())
                 then u:treewalker-add-attribute($child,$match,$attrName,$attrValue)
                 else $child
      }
};


(: -------------------------------------------------------------------------- :)
declare function u:remove-elements
  ( $elements ,
    $names as xs:string* )  as element()* {

   for $element in $elements
   return element
     {node-name($element)}
     {$element/@*,
      $element/node()[not(u:name-test(name(),$names))] }
 } ;

declare function u:name-test
  ( $testname as xs:string? ,
    $names as xs:string* )  as xs:boolean {

$testname = $names
or
$names = '*'
or
u:substring-after-if-contains($testname,':') =
   (for $name in $names
   return substring-after($name,'*:'))
or
substring-before($testname,':') =
   (for $name in $names[contains(.,':*')]
   return substring-before($name,':*'))
 } ;

declare function u:substring-after-if-contains 
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {

   if (contains($arg,$delim))
   then substring-after($arg,$delim)
   else $arg
 } ;



(: -------------------------------------------------------------------------- :)
declare function u:treewalker ($tree,$attrFunc,$elemFunc) {

  let $children := $tree/*
  return
      if(empty($children)) then ()
      else
        for $c in $children
            return
                ( element {node-name($c)}{
                            saxon:call($attrFunc,$c/@*),
                            saxon:call($elemFunc,$c/*),
                        u:treewalker($tree,$attrFunc,$elemFunc)
                })
};

(: -------------------------------------------------------------------------- :)
declare function u:treewalker ($tree,$attrFunc,$textFunc,$attName,$attValue) {

  let $children := $tree/*
  return
      if(empty($children)) then ()
      else
        for $c in $children
            return
                ( element {node-name($c)}{
                            saxon:call($attrFunc,$c/@*,$attName,$attValue),
                            saxon:call($textFunc,$c/text()),
                        u:treewalker($c,$attrFunc,$textFunc,$attName,$attValue)
                })
};


declare function u:attrHandler ($attr,$attName,$attValue) {
	$attr, attribute {string($attName)}{string($attValue)}
 };

declare function u:textHandler ($text) {
	$text
 };


(: -------------------------------------------------------------------------- :)
(: TODO - uses SAXON extension function, need to abstract this out :)
declare function u:xquery($exp as xs:string){
    let $a := func:compileQuery($exp)
    let $result := func:query($a)
    return
        $result
};


(: -------------------------------------------------------------------------- :)
declare function u:xslt($xslt,$xml){
let $compiled_xslt := saxon:compile-stylesheet(document{$xslt})
    return saxon:transform($compiled_xslt, document{$xml})
};

(: -------------------------------------------------------------------------- :)
declare function u:validate($exp) as xs:string {
$exp
(:
    nvdl:main("file:test/data/w3schema.xml file:test/data/schema-example.xml")
:)
};

(: -------------------------------------------------------------------------- :)
declare function u:serialize($xml,$output){
     saxon:serialize($xml,$output)
};

(: -------------------------------------------------------------------------- :)
declare function u:parse-string($string){
    saxon:parse($string)
};

(: -------------------------------------------------------------------------- :)
declare function u:map($func, $seqA as item()*, $seqB as item()*) 
as item()* {
	if(count($seqA) != count($seqB)) then ()
	else
    	for $a at $i in $seqA
    	let $b := $seqB[$i]
    	return
        	u:call($func, $a, $b)
};

(: -------------------------------------------------------------------------- :)
declare function u:filter($func, $seq as item()*) 
as item()* {
	for $i in $seq
	return
		if(u:call($func, $i)) then
			$i
		else
			()
};

(: -------------------------------------------------------------------------- :)
(: test folding the step with a different function :)
declare function u:printstep ($step,$meta,$value) {
    u:call( $step, $value)
};


declare function u:pipeline-step-sort($unsorted, $sorted, $pipelinename )  {
    if (empty($unsorted)) then
        $sorted
    else
        let $allnodes := $unsorted [ every $id in p:input[@primary="true"]/p:pipe/@step
                                            satisfies ($id = $sorted/@name or $id=$pipelinename)]
    return
        if ($allnodes) then
            u:pipeline-step-sort( $unsorted except $allnodes, ($sorted, $allnodes ),$pipelinename)
        else
            ()
};


declare function u:strip-namespace($e as element()) as element() {
  
   element {QName((),local-name($e))} {
    for $child in $e/(@*,*)
    return
      if ($child instance of element())
      then
        u:strip-namespace($child)
      else
        $child
  }
};

declare function u:uniqueid($unique_id,$count){
    concat($unique_id,'.',$count)
};
(: -------------------------------------------------------------------------- :)
declare function u:final-result($pipeline,$resulttree){
    ($pipeline,$resulttree)
};


(: -------------------------------------------------------------------------- :)
declare function u:step-fold( $pipeline,
                                 $steps,
                                 $evalstep-function,
                                 $primaryinput,
                                 $outputs) {
  
    if (empty($steps)) then

        u:final-result($pipeline,$outputs)

    else

        let $result:= u:call($evalstep-function,
                                $steps[1],
                                $primaryinput,
                                $pipeline,
                                $outputs)
    return

        u:step-fold($pipeline,
                       remove($steps, 1),
                       $evalstep-function,
                       $result[last()],
                       ($outputs,$result))
        
};


