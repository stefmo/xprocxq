# Running xprocxq from XQuery #

To use xprocxq in eXist invoke the `xproc:run()` function, supplying it with the XProc pipeline and default standard source input.

```
let $stdin := document {<test/>}
let $pipeline := document {<p:pipeline> ... </p:pipeline>}
return
 xproc:run($pipeline,$stdin)
```

xprocxq provides several overloaded xproc:run functions.

## xproc:run($pipeline,$stdin) ##

_$pipeline_ should contain the XProc pipeline XML document

_$stdin_ contains the default input source port XML document

## xproc:run($pipeline,$stdin,$debug) ##

_$pipeline_ should contain the XProc pipeline XML document

_$stdin_ contains the default input source port XML document

_$debug_ set to "1" will output p:log trace which for a simple example looks like

```
<xproc:debug xmlns:xproc="http://xproc.net/xproc">
    <xproc:pipeline>
        <p:declare-step xmlns:p="http://www.w3.org/ns/xproc" name="pipeline" xproc:defaultname="!1">
            <ext:pre xmlns:ext="http://xproc.net/xproc/ext" name="!pipeline" xproc:defaultname="!1.1" xproc:type="ext" xproc:step="$ext:pre">
                <p:input port="source" kind="document" primary="true" select="/" sequence="">
                    <p:pipe step="pipeline" port="stdin"/>
                </p:input>
                <p:output port="result" primary="true" select="/"/>
            </ext:pre>

            <p:identity name="!1.2" xproc:defaultname="!1.2" xproc:type="std" xproc:step="$std:identity">
                <p:input port="source" primary="true" select="/">
                    <p:pipe step="!pipeline" port="result"/>
                </p:input>
                <p:output port="result" primary="true" sequence="true" select="/"/>
            </p:identity>
            <ext:post xmlns:ext="http://xproc.net/xproc/ext" name="pipeline!" xproc:defaultname="!1.3" xproc:type="ext" xproc:step="$ext:post">
                <p:input port="source" primary="true" select="/"/>
                <p:output primary="true" port="stdout" select="/"/>

            </ext:post>
        </p:declare-step>
    </xproc:pipeline>
    <xproc:outputs>
        <xproc:output step="!pipeline" port="stdin" port-type="external" primary="false" func="">
            <test/>
        </xproc:output>
        <xproc:output step="!pipeline" port-type="input" primary="true" select="/" port="source" func="$ext:pre">
            <test/>

        </xproc:output>
        <xproc:output step="!pipeline" port-type="output" primary="true" select="/" port="result" func="$ext:pre">
            <test/>
        </xproc:output>
        <xproc:output step="!1.2" port-type="input" primary="true" select="/" port="source" func="$std:identity">
            <test/>
        </xproc:output>
        <xproc:output step="!1.2" port-type="output" primary="true" select="/" port="result" func="$std:identity">
            <test/>

        </xproc:output>
        <xproc:output step="pipeline!" port-type="input" primary="true" select="/" port="source" func="$ext:post">
            <test/>
        </xproc:output>
        <xproc:output step="pipeline!" port-type="output" primary="true" select="/" port="stdout" func="$ext:post">
            <test/>
        </xproc:output>
    </xproc:outputs>
</xproc:debug>

```

## xproc:run($pipeline,$stdin,$debug,$bindings,$options) ##

_$pipeline_ should contain the XProc pipeline XML document

_$stdin_ contains the default input source port XML document

_$debug_ set to "1" will output p:log trace

_$bindings_ allow you to define input ports outside of xprocxq, here are
a few examples

```
let $bindings :=('source2=<test/>')
```

the above would expose a p:input port named source2 to XProc

You can also define multiple ports as well as use a URI to retrieve a document
```
let $bindings := ('source3=<a>test</a>','source4=/db/examples/xml/test.xml')
```

_$options_ are currently disabled