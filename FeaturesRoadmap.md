# Planned Features #

**Tighter eXist integration**: next version will have tighter integration with eXist in that xprocxq will get built and included automatically via the build process

**XProc Standard Step Compliance**: tba

**XProc Multi Container Step Compliance**: tba

**W3C XProc Unit Test results**: I have developed an extension step to run xprocxq against the [W3C XProc Unit Test suite](http://tests.xproc.org). It works but needs a bit of attention before I release both the extension step and the test results ... hoping a few more days will result in significantly higher complaince with the spec.

**compile XProc to XQuery**: The way xprocxq has been created its relatively easy to generate an XQuery code listing which can run (with xprocxq modules).

# Roadmap #

  * implement as many of the standard & optional steps as possible
  * refactor handling of sequences, weak typing and replace preparse routine
  * ensure static and dynamic error checking is working properly and try to beautify
> and add useful things like line numbers where error occurred
  * integrate namespace handling module to implement more sophisticated namespace fixup
  * consider porting to other XQuery processors