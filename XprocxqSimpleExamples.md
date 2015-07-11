These examples have been tested against xprocxq.



**note**: the links after each example will run your local eXist copy of /examples which you must upload to eXist.



## p:add-attribute ##

Add an attribute to matched elements.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

let $stdin := document{<test>
                            <a>
                                <c/>
                                <b/>
                            </a>
                            <c>
                                <d>test
                                 </d>
                                <b/>
                             </c>
                       </test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:add-attribute attribute-name="attr-name" attribute-value="attr-val" match="//c"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[padd-attribute.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/padd-attribute.xq)

## p:rename ##

Renames matched elements

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test><a><b/></a><c><b/></c></test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:rename match="//c" new-name="success"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[prename.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/prename.xq)

## p:string-replace ##

Replace matched node with string.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test><a><b/></a><c><b/></c></test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
						<p:string-replace match="//c" replace="test"/>
                    </p:pipeline>
                }
return
     xproc:run($pipeline,$stdin)
```
[pstring-replace.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pstring-replace.xq)

## p:count ##

The p:count step returns the number of items selected by the input binding. In its simplest usage it is used to count the number of items in a sequence as illustrated in the following example.

```

xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

let $stdin :=(<doc/>,<doc/>,<doc/>)

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">

            <p:count/>

</p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'0') 

```
[pcount.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pcount.xq)

When this example is processed it should return something like

```
<c:result xmlns:c="http://www.w3.org/ns/xproc-step">3</c:result>
```

## p:replace ##

The p:replace step replaces matching elements in its primary input with the document element of the replacement port's document.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test><a><b/></a><c><b/></c></test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:replace match="//c">
                            <p:input port="replacement">
                                <p:inline>
                                    <success/>
                                </p:inline>
                            </p:input>
                        </p:replace>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[preplace.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/preplace.xq)

## p:insert ##

this step is undergoing refactoring, so it may not do all that p:insert is supposed to.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test><a><b/></a><c><b/></c></test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:insert match="//a" position="after">
                            <p:input port="insertion">
                                <p:inline>
                                    <success/>
                                </p:inline>
                            </p:input>
                        </p:insert>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 
```
[pinsert.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pinsert.xq)


## p:set-attributes ##

This step adds all attributes found on the document element of attributes input port to matched elements.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test>
                            <a>
                                <c/>
                                <b/>
                            </a>
                            <c>
                                <d>test
                                 </d>
                                <b/>
                             </c>
                       </test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:set-attributes match="//c">
                             <p:input port="attributes">
                                <p:inline>
                                    <root rootattr="test">
                                        <a test="1"/>
                                        <b b="2"/>
                                    </root>
                                </p:inline>
                             </p:input>
                        </p:set-attributes>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)

```
[pset-attributes.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pset-attributes.xq)


## p:delete ##

Using a match pattern you can delete elements from a document. This step is rather naively implemented at the moment.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test><a><b/></a></test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:delete match="//b"/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 

```
[pdelete.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pdelete.xq)

## p:label-elements ##

On matched elements this step will create a new label. This step is limited in that one cannot currently generate the attribute value (e.g. label option) dynamically just yet.

```

xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test>
                            <a>
                                <c/>
                                <b/>
                            </a>
                            <c>
                                <d>test
                                 </d>
                                <b/>
                             </c>
                       </test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:label-elements attribute="label" label="part # " replace="true" match="//c"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)

```
[plabel-elements.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/plabel-elements.xq)

## p:wrap ##
Wrap matched element with an element.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test>
                            <a>
                                <c/>
                                <b/>
                            </a>
                            <c>
                                <d>test
                                 </d>
                                <b/>
                             </c>
                       </test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:wrap match="//c" wrapper="success"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[pwrap.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pwrap.xq)

## p:wrap-sequence ##

Wrap a sequence of documents with an element.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := (<test/>,<test/>,<test/>)
let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:wrap-sequence wrapper="success"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[pwrap-sequence.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pwrap-sequence.xq)

## p:wrap ##
Unwrap an element, replacing it with its children

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test>
                            <a>
                                <c/>
                                <b/>
                            </a>
                            <c>
                                <d>test
                                 </d>
                                <b/>
                             </c>
                       </test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:unwrap match="//a"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[punwrap.xq ](http://127.0.0.1:8080/exist/rest/examples/step_examples/punwrap.xq)

## p:identity ##

```

xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test>Hello World</test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:identity/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 


```

[helloworld.xq](http://127.0.0.1:8080/exist/rest/examples/helloworld.xq)

## p:compare ##

see p:choose example

## p:load ##

Step loads up xml document from a collection or file://

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "file:///tmp";   (: CHANGE ME :)

let $stdin :=document{<doc>
                        <title>Title</title>
                        <p>Some paragraph.</p>
                      </doc>
                      }

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:load name="read-from-home" href="{$local:XPROCXQ_EXAMPLES}/storetest.xml"/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'1') 

```
[pload.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pload.xq)

## p:filter ##

see the p:http-request example


## p:directory-list ##

Lists out contents of a directory

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<doc>
                        <title>Title</title>
                        <p>Some paragraph.</p>
                      </doc>
                      }

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:directory-list path="/usr/local/bin" include-filter='*.*'/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'0')
```
[pdirectory-list.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pdirectory-list.xq)

## p:pack ##

Concatenate two inputs.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

let $stdin :=document{<doc>
                        <title>Title</title>
                        <p>Some bad document .</p>
                      </doc>
                      }

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">

                    <p:pack  wrapper="root">
                       <p:input port="alternate">
                         <p:inline>
                           <message>This demonstrates how 2 xml docs are concatanated using p:pack.</message>
                         </p:inline>
                       </p:input>
                    </p:pack>

        </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'0') 

```
[ppack.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/ppack.xq)

## p:xinclude ##

This step will resolve any xinclude statements within your source XML document.

```
xquery version "1.0" encoding "UTF-8";

declare option exist:serialize "expand-xincludes=no";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)


let $stdin :=doc(concat($local:XPROCXQ_EXAMPLES,'/data/xinclude_test.xml'))

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:xinclude/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'0') 
```
[pxinclude.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pxinclude.xq)

Of course, since eXist has enabled-xincludes on by default you may never need this step, but in situations where you want to control the behavior then add an eXist pragma exist:serialize (as shown in the code).

## p:uuid ##

Generates a Universally Unique Identifier and places an xproc:uuid attribute on the matched elements. This step is not yet conformant with XProc specification.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin := document{<test>
                            <a>
                                <c/>
                                <b/>
                            </a>
                            <c>
                                <d>test
                                 </d>
                                <b/>
                             </c>
                       </test>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:uuid match="//c"/>
                     </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin)
```
[puuid.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/puuid.xq)

## p:xslt ##

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test/>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                                <p:xslt>                                         
                                   <p:input port="stylesheet">
                                       <p:document href="{$local:XPROCXQ_EXAMPLES}/xslt/stylesheet.xsl"/>
                                   </p:input>
                                </p:xslt>

                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 

```
[pxslt.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pxslt.xq)


## p:error ##

To arbitrarily throw an error use the p:error step.

```

xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

let $stdin :=document{<doc>
                        <title>Title</title>
                        <p>Some bad document .</p>
                      </doc>
                      }

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">

<p:error xmlns:my="http://www.example.org/error"
         name="bad-document" code="my-error-code-1">
   <p:input port="source">
     <p:inline>
       <message>The document is bad for unexplained reasons.</message>
     </p:inline>
   </p:input>
</p:error>
</p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'1') 

```
[perror.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/perror.xq)


## p:xquery 1: using p:inline ##

The p:xquery step will execute an arbitrary bit of xquery. The default context is currently the eXist XML Database, it should be the source port input binding but I have a few more tweaks on util:eval within eXist.

I also added a xproc:escape extension attribute to the c:query element as XProc spec wants the XQuery to not be considered XML.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test/>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                               <p:xquery>
                                   <p:input port="query">
                                       <p:inline>
                                           <c:query xmlns:c="http://www.w3.org/ns/xproc-step" xproc:escape="true">
                                               let $r := 'this pipeline successfully processed' return $r (: for now default context goes to xml database :)
                                           </c:query>
                                       </p:inline>
                                   </p:input>
                               </p:xquery>

                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 


```
[pxquery.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pxquery.xq)

## p:xquery 2: using p:data ##

Probably the best way to bring in an external xquery is to use the p:data element.

```

xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test/>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                               <p:xquery>
                                   <p:input port="query">
                                       <p:data href="/db/examples/helloworld.xq" 
                                               wrapper="c:query" 
                                               content-type="plain/text" 
                                               xproc:escape="false"/>
                                   </p:input>
                               </p:xquery>
                    </p:pipeline>
                }

return
    xproc:run($pipeline,$stdin) 


```
[pxquery2.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pxquery2.xq)

p:data also has the `xproc:escape` extension attribute which you can use to 'escape' the contents of the file.

## p:xquery 3: use external bindings ##
You can also pass input in via external bindings mechanism. The $external-bindings variable is a sequence which lets you define named input sources either inline or referring to another resource URL.


```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test/>}
let $external-options :=() (: disabled :)
let $timing-flag :="0"  (: deprecated :)
let $debug-flag :="0"  (: change value to 1 to see p:log trace :)
let $internaldbg := 0

let $external-bindings :=('xquerysrc1=/db/examples/xml/xquery.xml')

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                               <p:xquery>
                                   <p:input port="query">
                                       <p:pipe step="pipeline" port="xquerysrc1"/>
                                   </p:input>
                               </p:xquery>
                    </p:pipeline>
                }

return
            xproc:run($pipeline,$stdin,$debug-flag,$timing-flag,$external-bindings,$external-options) 

```
[pxquery3.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pxquery3.xq)


## p:http-request ##

This pipeline makes an http GET request to http://tests.xproc.org/service/fixed-xml. You will need to ensure that expath.jar is installed and both EXPath and eXist http extension module are enabled.

```
xquery version "1.0" encoding "UTF-8";

(: example test for xprocxq:)

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=()

let $pipeline :=document{<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
                                     xmlns:c="http://www.w3.org/ns/xproc-step"
                           name="pipeline">

<p:http-request name="http-get">  (: http get test step :)
<p:input port="source">
  <p:inline>
    <c:request xmlns:c="http://www.w3.org/ns/xproc-step" 
               href="http://tests.xproc.org/service/fixed-xml" 
               method="get"/>
  </p:inline>
</p:input>
</p:http-request>

<p:filter select="/doc"/>

</p:pipeline>}

return
    xproc:run($pipeline,$stdin)
```
[phttp-request.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/phttp-request.xq)

This step returns the `<doc/>` element from a sequence of two items, courtesy of using a p:filter step. The output from the p:http-request looks like the following code listing.

```
<http:response xmlns:http="http://www.expath.org/mod/http-client" status="200">
    <http:header name="Date" value="Thu, 30 Apr 2009 17:25:08 GMT"/>
    <http:header name="Server" value="Apache/2.0.63 (Unix) PHP/4.4.7 mod_ssl/2.0.63 OpenSSL/0.9.7e mod_fastcgi/2.4.2 Phusion_Passenger/2.0.6 DAV/2 SVN/1.4.2"/>
    <http:header name="Content-Length" value="63"/>
    <http:header name="Content-Type" value="application/xml"/>
    <http:body content-type="application/xml"/>
</http:response>
<doc>
    <title>Sample document</title>
<p>Hello world!</p>

</doc>
```

Your browser will not be able to display this, so view source on the page to see the actual output.

## p:http-request2 ##

This shows how namespaced elements can be selected
```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare namespace atom="http://www.w3.org/2005/Atom";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=(<test>Hello <a>World</a></test>)

let $pipeline :=document{<p:pipeline name="pipeline"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:atom="http://www.w3.org/2005/Atom">
    <p:http-request name="http-get">
        <p:input port="source">
            <p:inline>
                <c:request href="http://twitter.com/statuses/user_timeline/existdb.atom" 
                    method="get"/>
            </p:inline>
        </p:input>
    </p:http-request>

<p:filter select="//atom:feed"/>

</p:pipeline>
                }

return
     xproc:run($pipeline,$stdin,'0') 

```
[phttp-request2.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/phttp-request2.xq)

## p:store ##

p:store can save document to eXist XML Database. To run this example you will have to allow write permissions for XQuery to generate storetest.xml to /db/examples/result collection, otherwise you will get an error.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test/>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:store href="{$local:XPROCXQ_EXAMPLES}/result/storetest.xml"/>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 


```
[pstore.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pstore.xq) [generated storetest.xml](http://127.0.0.1:8080/exist/rest/examples/result/storetest.xml)



## p:store2 ##

Here is an example of storing to the file system.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "file:///tmp";   (: CHANGE ME :)

let $stdin :=document{<test/>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                        <p:store href="{$local:XPROCXQ_EXAMPLES}/storetest.xml"/>
                    </p:pipeline>
                }

return
    xproc:run($pipeline,$stdin) 

```
[pstore2.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pstore2.xq)

note: currently there is a limitation in that only xml documents can be stored via file://

## p:group ##
```

xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=document{<test/>}

let $pipeline :=document{
                    <p:pipeline name="pipeline"
                                xmlns:p="http://www.w3.org/ns/xproc"
                                xmlns:c="http://www.w3.org/ns/xproc-step">
                                <p:group name="test">
                                <p:xslt>                                         
                                   <p:input port="stylesheet">
                                       <p:document href="{$local:XPROCXQ_EXAMPLES}/xslt/stylesheet.xsl"/>
                                   </p:input>
                                </p:xslt>
                                </p:group>
                    </p:pipeline>
                }

return
     xproc:run($pipeline,$stdin) 

```
[pgroup.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pgroup.xq)

## p:choose ##

The p:choose step has a few [Limitations](CurrentStatus.md) at this time

  * p:xpath-context does not work
  * need to use special eXist convention for p:when paths ( `.//` for `//`)
  * steps contained in p:choose branches should probably use explicit input port
binding to define step input
  * to use output from a p:choose step need to explicitly define port binding


This example pipeline first compares 2 xml documents (both the same document) and returns either `<c:result>true</c:result>` or `<c:result>false</c:result>` if documents are equal or not. Based on that value a branch in the p:choose is executed.

```
xquery version "1.0" encoding "UTF-8";

(: example test for xprocxq:)

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=doc(concat($local:XPROCXQ_EXAMPLES,'/xml/test.xml'))

let $pipeline :=document{<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
                                     xmlns:c="http://www.w3.org/ns/xproc-step"
                           name="pipeline">

<p:compare name="compare">                       (: compare test step :)
   <p:input port="alternate">
       <p:document href="{$local:XPROCXQ_EXAMPLES}/xml/test.xml"/> (: example of using p:document :)
   </p:input>
</p:compare>

<p:choose name="mychoosestep">
       <p:when test=".//c:result[.='false']">      (: note the eXist specific path convention with root :)
           <p:identity>
               <p:input port="source">
                   <p:inline>
                       <p>This pipeline failed.</p>
                   </p:inline>
               </p:input>
           </p:identity>
       </p:when>
       <p:when test=".//c:result[.='true']">  (: success :)
       <p:identity>
           <p:input port="source">
               <p:inline>
                   <p>This pipeline successfully processed.</p>
               </p:inline>
           </p:input>
       </p:identity>
       </p:when>
       <p:otherwise>
           <p:identity>
               <p:input port="source">
                   <p:inline>
                       <p>This pipeline failed.</p>
                   </p:inline>
               </p:input>
           </p:identity>
       </p:otherwise>
   </p:choose>

    <p:identity>        (: need to explicitly define p:step to get multi container step output :)
        <p:input port="source">
            <p:step port="result" step="mychoosestep"/>
        </p:input>
    </p:identity>


</p:pipeline>}

return
    xproc:run($pipeline,$stdin)
    
```
[pchoose.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pchoose.xq)



## p:for-each ##

The p:for-each step applies a subpipeline to each item in the input sequence.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES:= "/db/examples";   (: CHANGE ME :)

let $stdin :=(<test/>,<a/>,<b/>)
let $external-bindings := ()

let $pipeline :=document{<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
               name="pipeline">

<p:for-each name="test">
    <p:xslt>                      
       <p:input port="stylesheet">
           <p:document href="{$local:XPROCXQ_EXAMPLES}/xslt/stylesheet.xsl"/>
       </p:input>
    </p:xslt>
</p:for-each>

</p:pipeline>}

return
    xproc:run($pipeline,$stdin,'0')

```
[pfor-each.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pfor-each.xq)

the result of this pipeline should return the following:

```
<success version="" vendor="Apache Software Foundation">
    <test/>
</success>
<success version="" vendor="Apache Software Foundation">
    <a/>
</success>
<success version="" vendor="Apache Software Foundation">
    <b/>
</success>
```

## p:escape-markup / p:unescape-markup ##

The p:escape-markup step will escape all data below the root element of the input document.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=<test><a/></test>
  
let $pipeline :=document{<p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

<p:escape-markup/>

<!-- <p:unescape-markup/> //-->

</p:pipeline>}

return
    xproc:run($pipeline,$stdin)
```
[pescape-markup.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pescape-markup.xq)

the result of this processing should look like

```
<test>&lt;a&gt;
    &lt;b/&gt;
&lt;/a&gt;</test>
```

p:unescape-markup does the reverse action and you can view this for yourself by uncommenting the step in the example.


## p:xsl-formatter ##

This example takes a web page (http://www.xproc.org/index.html) and converts into a simple pdf representation. To run this example you will have to allow write permissions for XQuery to generate test.pdf to /db/examples/result collection, otherwise you will get an error.

```
xquery version "1.0" encoding "UTF-8";

import module namespace const = "http://xproc.net/xproc/const";
import module namespace xproc = "http://xproc.net/xproc";
import module namespace naming = "http://xproc.net/xproc/naming";
import module namespace u = "http://xproc.net/xproc/util";

import module namespace xslfo = "http://exist-db.org/xquery/xslfo"; (: required for p:xsl-formatter :)

declare variable $local:XPROCXQ_EXAMPLES := "/db/examples";   (: CHANGE ME :)

let $stdin :=doc('http://www.xproc.org')             (: get index page of a website :)
  
let $pipeline :=document{<p:pipeline name="pipeline"
            xmlns:p="http://www.w3.org/ns/xproc">

<p:xslt>                                         
   <p:input port="stylesheet">
        (: use antennahouse xhtml2fo xslt transformation :)
       <p:document href="http://www.antennahouse.com/XSLsample/sample-xsl-xhtml2fo/xhtml2fo.xsl"/>
   </p:input>
</p:xslt>

(: generate pdf:)
<p:xsl-formatter href='{$local:XPROCXQ_EXAMPLES}/result/test.pdf'/>

</p:pipeline>}

return
    xproc:run($pipeline,$stdin,"1")
               
        
```
[pxslformatter.xq](http://127.0.0.1:8080/exist/rest/examples/step_examples/pxslformatter.xq) [generated test.pdf](http://127.0.0.1:8080/exist/rest/examples/result/test.pdf)

You will need to ensure that you have built the XSLFO eXist extension and ensure the module is activated in conf.xml

In this example I used the version of xproc:run function, ` xproc:run($pipeline,$stdin,"1")`,  that outputs debug output