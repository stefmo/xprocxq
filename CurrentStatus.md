04/05/2009 added a bunch of steps, working on p:declare-step and p:library to enable reusable pipelines

## Limitations and Issues ##

xprocxq, being implemented in XQuery, currently has several limitations and is no where compliant with the existing XProc draft specification. The best way to understand what works or doesn't currently is to check out [step examples](XprocxqSimpleExamples.md) included in the release.

Here is a list of the more severe limitations:

  * when selecting elements in a namespace u might have to generically select them

  * due to my use of weak typing in XQuery there are several interrelated issues, but this will change as I sanitize the code

  * little consistent support for sequences where you would expect them, once again I am addressing this as I work porting things across

  * have disabled namespace management for the time being which applies XProc namespace fixup rules

  * defining reusable pipelines using p:library, p:import and p:declare-step is currently disabled

  * errors are thrown as XQuery errors, making it difficult to report correct line numbers, not to mention that errors themselves look quite ugly

  * p:compare outputs a c:result element by default

  * p:choose xpath-context, iteration, etc is not implemented just yet

  * in p:choose, need to use ./ convention in p:when (in p:choose) test attributes due to limitation in eXist util:eval function

  * some step sorting issues (intermixing of steps using p:inline), best to use explicit port binding to avoid.

  * p:xquery currently uses a c:result element to output, I also added a xproc:escape attribute to c:query to avoid having to wrap XQuery using CDATA (which is XProc spec requirement).

  * declare base-uri affects module imports (need to investigate across all XQuery processors)

  * cant pass required/add-attribute--002.xml test depends on namespace handling module to be finished

  * errors and/or p:error does not write to error port (also discussing need for a generic 'implementator specific error code' with XProc WG)

  * current preparsing routine is naive; I have a more rigorous solution in a source control branch to merge

The [project issue tracker](http://code.google.com/p/xprocxq/issues/list) is the best place to find and submit issues.

## Changelog ##

Check out [Changelog](http://xprocxq.googlecode.com/svn/trunk/main/ChangeLog) included in the source distro.