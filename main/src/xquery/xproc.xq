xquery version "1.0" encoding "UTF-8";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";
declare namespace fn ="http://www.w3.org/TR/xpath-functions/";

(: Module Imports :)
import module namespace const = "http://xproc.net/xproc/const"
                        at "../xquery/const.xqm";
import module namespace util = "http://xproc.net/xproc/util"
                        at "../xquery/util.xqm";
import module namespace std = "http://xproc.net/xproc/std"
                        at "../xquery/std.xqm";
import module namespace opt = "http://xproc.net/xproc/opt"
                        at "../xquery/opt.xqm";
import module namespace ext = "http://xproc.net/xproc/ext"
                        at "../xquery/ext.xqm";
import module namespace comp = "http://xproc.net/xproc/comp"
                        at "../xquery/comp.xqm";
import module namespace xproc = "http://xproc.net/xproc"
                        at "../xquery/xproc.xqm";

(: Module Vars :)
(: load in xproc xml :)

declare variable $flag external;

declare variable $xproc as item() external;

declare variable $stdin as item() external;

(: :)
declare variable $source := document{.};


(: -------------------------------------------------------------------------- :)
(: XProc Processing :)

    let $start-time := util:timing()

    (: STEP I: generate parse tree :)
    let $preparse := xproc:preparse($xproc/p:*)

    (: STEP II: parse and eval tree :)
    let $eval_result := xproc:parse($preparse,$stdin)

    (: STEP III: serialize and return results :)
    let $serialized_result := xproc:output($eval_result,0)

    let $end-time := util:timing()

    return
    document
       {
        <xproc:result xproc:timing="{$end-time - $start-time}ms" xproc:ts="{current-dateTime()}">
            {
                $serialized_result
            }
        </xproc:result>
        }
(: -------------------------------------------------------------------------- :)
