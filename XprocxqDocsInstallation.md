# Download #

Download latest release zip here, which requires **latest** trunk version of [eXist XML Database](http://exist.sourceforge.net).

# Prerequisites #

This version of xprocxq requires the current trunk version of [eXist XML Database](http://exist.sourceforge.net).

xprocxq uses the [EXPath](http://www.expath.org) http-client module which I have included in jar form for convenience.


# Installing xprocxq #

To install within eXist XML Database follow these instructions.

## Step I ##

Place xprocxq.jar and expath.jar into $EXIST\_HOME/lib/user directory and insert the following elements into eXist's conf.xml, in `<built-in-modules/>` element

```
<!-- expath module imports (for p:http-request)//-->
<module class="org.exist.xquery.modules.httpclient.HTTPClientModule" uri="http://exist-db.org/xquery/httpclient" />
<module src="resource:org/expath/www/mod/http-client/http-client.xqm" uri="http://www.expath.org/mod/http-client"/>
<!-- uncomment if you want to use the p:xsl-formatter step
<module class="org.exist.xquery.modules.xslfo.XSLFOModule" uri="http://exist-db.org/xquery/xslfo" />
//-->
<!-- xprocxq module imports //-->
<module src="resource:net/xproc/xprocxq/src/xquery/const.xqm" uri="http://xproc.net/xproc/const"/>
<module src="resource:net/xproc/xprocxq/src/xquery/xproc.xqm" uri="http://xproc.net/xproc"/>
<module src="resource:net/xproc/xprocxq/src/xquery/util.xqm" uri="http://xproc.net/xproc/util"/>
<module src="resource:net/xproc/xprocxq/src/xquery/functions.xqm" uri="http://xproc.net/xproc/functions"/>                                                                     
<module src="resource:net/xproc/xprocxq/src/xquery/std.xqm" uri="http://xproc.net/xproc/std"/>                                                                           
<module src="resource:net/xproc/xprocxq/src/xquery/ext.xqm" uri="http://xproc.net/xproc/ext"/>                                                                           
<module src="resource:net/xproc/xprocxq/src/xquery/opt.xqm" uri="http://xproc.net/xproc/opt"/>                                                            
<module src="resource:net/xproc/xprocxq/src/xquery/naming.xqm" uri="http://xproc.net/xproc/naming"/>
```


**note**: Future releases will reduce this to a single module import

## Step II ##

Please follow these instructions to support the following steps.

> p:xinclude - you must `enable-xincludes='yes'' within eXist XML Database conf.xml

> p:xsl-formatter - you will **need** to build eXist with extension XSLFO enabled if you want to use the p:xsl-formatter step. To do this set `include.module.xslfo = true` in extensions/build.properties and rerun eXist build process (please follow eXist instructions on this)

## Step III ##
Load /examples directory, included in the dist, into eXist XML Database. You
can use the eXist webadmin, webdav or java client interfaces to do this.

## Step IV ##
Amend the path variable in examples to reflect the collection path you have placed it
in (most likely /db/examples) and test using the browser.

```
ex. http://127.0.0.1:8080/exist/rest/examples/helloworld.xq
```


# Build from Source #

You may build xprocxq.jar from source distribution by running the dist Apache Ant target.

```
>ant dist
```