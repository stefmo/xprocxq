xquery version "1.0" encoding "UTF-8";


declare copy-namespaces preserve, inherit;

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace fn ="http://www.w3.org/TR/xpath-functions/";

declare base-uri "file:///Users/jimfuller/Source/Webcomposite/xprocxq/main/";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "src/xquery/const.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "src/xquery/util.xqm";
import module namespace xproc = "http://xproc.net/xproc"
                        at "src/xquery/xproc.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "src/xquery/std.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "src/xquery/opt.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "src/xquery/ext.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "src/xquery/comp.xqm";

(: Module Vars :)


declare variable $flag external;

declare variable $xproc as item() external;

declare variable $stdin as item() external;

declare variable $bindings as xs:string external;
declare variable $_bindings := if ($bindings) then $bindings else ();

declare variable $options as xs:string external;

declare variable $dflag as item() external;

declare variable $tflag as item() external;

declare variable $oval as item() external;

declare variable $ival as item() external;

(: will have to refactor stdin versus stdin2 at some point :)
declare variable $stdin2 := document{.};

(: -------------------------------------------------------------------------- :)
(: XProc Processing :)

    xproc:run($xproc,$stdin,$dflag,$tflag,tokenize($_bindings,','),tokenize($options,','))

(: -------------------------------------------------------------------------- :)


