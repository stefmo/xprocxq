# p:for-each #

tba


## issues ##

p:iteration-source can't be defined currently

## xprocxq definition ##
```
    <xproc:element type="p:for-each" xproc:step="true" xproc:support="true">
        <p:input port="xproc:source" primary="true" select="/"/>
        <p:output port="xproc:output" primary="true" select="/"/>
    </xproc:element>
```