xquery version "1.0" encoding "UTF-8";

module namespace ant = "http://xproc.net/xproc/ant";

declare namespace comp = "http://xproc.net/xproc/comp";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

declare namespace task="java:net.xproc.ant.testEmbedded";
declare namespace target="java:net.xproc.ant.AntTargetRunner";

(: Module Vars :)
declare variable  $ant:steps := doc("../../etc/pipeline-ant.xml")/p:library;

(: -------------------------------------------------------------------------- :)

declare variable $ant:test :=saxon:function("ant:test", 1);

(: -------------------------------------------------------------------------- :)
declare function ant:test($action){
    task:main($action)
};

declare function ant:build-target(){
    target:executeTarget("build.xml","/Users/jimfuller/Source/Webcomposite/xprocxq/main","test-target")
};
(: -------------------------------------------------------------------------- :)