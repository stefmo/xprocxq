# p:choose #


## issues ##
p:xpath-context cannot be explicitly defined just now

p:when tests need to use `.//` instead of `//` for paths or `./` for `/`. This is related to how eXist represents root document internally and should be addressed soon.

need to change default context from the XML database to the input binding

p:choose step requires that all the branches should have the equiv output which is currently a little strange in xprocxq ... means you need to explicitly binding to result port for the step to use output.

## xprocxq definition ##
```
    <xproc:element type="p:choose" xproc:step="true" xproc:support="true">
        <p:input port="xproc:xpath-context" primary="false" select="/"/>
        <p:input port="xproc:source" primary="true" select="/"/>
        <p:output port="xproc:result" primary="true" select="/"/>    
         <xproc:element type="p:when" xproc:support="true">
            <xproc:attribute name="test"/>
        </xproc:element>
        <xproc:element type="p:otherwise" xproc:support="true"/>     
    </xproc:element>
```