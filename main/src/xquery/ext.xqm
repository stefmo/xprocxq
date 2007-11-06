xquery version "1.0" encoding "UTF-8";

module namespace ext = "http://xproc.net/xproc/ext";

(: XProc Namespace Declaration :)
declare namespace p="http://www.w3.org/ns/xproc";
declare namespace c="http://www.w3.org/ns/xproc-step";
declare namespace err="http://www.w3.org/ns/xproc-error";

declare function ext:main() as xs:string {
    "ext entry point executed"
};
