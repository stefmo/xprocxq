xquery version "1.0" encoding "UTF-8";
module namespace ant = "http://xproc.net/xproc/ant";
(: -------------------------------------------------------------------------- :)

declare namespace comp = "http://xproc.net/xproc/comp";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "util.xqm";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace target="java:net.xproc.ant.Embedded";

(: Module Vars :)
declare variable  $ant:steps := doc("etc/pipeline-ant.xml")/p:library;

(: -------------------------------------------------------------------------- :)

declare variable $ant:test :=saxon:function("ant:test", 1);

(: -------------------------------------------------------------------------- :)
declare function ant:test($action){
<test/>
};

declare function ant:ExecTask($message){
<test/>
};
(: -------------------------------------------------------------------------- :)