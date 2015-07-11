# Extension Step Reference #

tba

These steps are implemented specifically by xprocxq


```
    <p:declare-step type="ext:pre" xproc:bindings="all" xproc:support="true">
        <p:input port="source" primary="true" select="/"/>
        <p:output port="result" primary="true" select="/"/>
    </p:declare-step>

    <p:declare-step type="ext:post" xproc:support="true">
        <p:input port="source" primary="true" select="/"/>
        <p:output port="stdout" primary="true" select="/"/>
    </p:declare-step> 

    <p:declare-step type="ext:xproc" xproc:use-function="xproc:run-step" xproc:support="true">
        <p:input port="source" primary="true" select="/"/>
        <p:input port="pipeline" primary="false" select="/"/>
        <p:input port="bindings" primary="false" select="/"/>
        <p:output port="result" primary="true"/>
        <p:option name="dflag" select="'0'"/>
        <p:option name="tflag" select="'0'"/>
    </p:declare-step>

```