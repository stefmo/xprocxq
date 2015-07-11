#xprocxq documentation.

# Introduction #

These docs are a bit incomplete at the moment, but being updated daily.


## Hello World XProc ##

The following XQuery file is an example of how to run xprocxq from within eXist.

```

xquery version "1.0" encoding "UTF-8";

(: Run this example first to check that everything is working properly:)

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test>Hello World</test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc">
                        <p:identity/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 

```
[helloworld.xq](http://127.0.0.1:8080/exist/rest/examples/helloworld.xq)

If you installed xprocxq and uploaded the `/examples` directory into eXist then the above link should run the helloworld.xq example via eXist REST interface.

Or just cut n paste the following URL to your browser.

```
http://127.0.0.1:8080/exist/rest/examples/helloworld.xq
```

The result in your browser should be

```
<test>Hello World</test>
```