xquery version "1.0" encoding "UTF-8";

module namespace xproc = "http://xproc.net/xproc";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "../xquery/const.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "../xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "../xquery/ext.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "../xquery/comp.xqm";


declare copy-namespaces no-preserve, inherit;

declare function xproc:main() as xs:string {
    "main xproc.xq executed"
};


(: Parse XProc XML :)
declare function xproc:parse($xproc as item()) {
   (fn:string('import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "src/xquery/comp.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
let $O0 := <test/> '),
    xproc:geninput($xproc),
    xproc:genstep($xproc),
    xproc:genoutput($xproc),
    xproc:post())
};


declare function xproc:geninput($steps as item()) {
for $step at $count in $steps/p:pipeline/*[fn:name()='p:input']
return 
     fn:string(concat('let $PI',$count,' := "primary input" '))
   
};

declare function xproc:genoutput($steps as item()) {
for $step at $count in $steps/p:pipeline/*[fn:name()='p:output']
return 
     fn:string(concat('let $PO',$count,' := "primary output" '))
   
};


declare function xproc:genstep($steps as item()) {
for $step at $count in $steps/p:pipeline/*[fn:not(fn:name()='p:input')][fn:not(fn:name()='p:output')]
return
    (
     fn:string(concat('let $I',$count,' := $O',xs:string(fn:number($count)-1),' ')),
     fn:string(concat('let $O',$count,' := util:call( saxon:function("std:',$step/fn:local-name(),'", 1),$I',$count,')',' '))
    )                            
};


declare function xproc:post() { 
     fn:string('let $I0 := $O2 return $I0')                
};


(: Build Run Tree :)
declare function xproc:build($parsetree) {
fn:string-join($parsetree,'')
};


(: Eval Run Tree :)
declare function xproc:eval($runtree,$stdin){

util:xquery($runtree) 



};


(: Serialize Eval Result :)
declare function xproc:output($evalresult){
    $evalresult
};
