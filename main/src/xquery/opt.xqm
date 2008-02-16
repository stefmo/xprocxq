xquery version "1.0" encoding "UTF-8";

module namespace opt = "http://xproc.net/xproc/opt";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

(: Module Imports :)
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";

(: Module Vars :)
declare variable  $opt:steps := doc("../../etc/pipeline-optional.xml")/p:library;

(: -------------------------------------------------------------------------- :)