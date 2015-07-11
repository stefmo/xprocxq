# XProc Standard Step Reference #

Please check [Step examples](XprocxqSimpleExamples.md) to see what steps are working.

```
   <p:declare-step type="p:add-attribute" xml:id="add-attribute" xmlns:xproc="http://xproc.net/xproc">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="match" required="true"/>
      <p:option name="attribute-name" required="true"/>
      <p:option name="attribute-value" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:add-xml-base" xml:id="add-xml-base">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="all" select="'false'"/>
      <p:option name="relative" select="'true'"/>
   </p:declare-step>
   <p:declare-step type="p:compare" xml:id="compare" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:input port="alternate" primary="false" select="/" xproc:required="true"/>
      <p:output port="result" primary="false" select="/"/>
      <p:option name="fail-if-not-equal" select="'false'"/>
   </p:declare-step>
   <p:declare-step type="p:count" xml:id="count" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" primary="true" sequence="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="limit" select="'0'"/>
   </p:declare-step>
   <p:declare-step type="p:delete" xml:id="delete" xmlns:xproc="http://xproc.net/xproc">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="match" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:directory-list" xml:id="directory-list" xmlns:xproc="http://xproc.net/xproc"  xproc:support="true">
      <p:output port="result" primary="true" select="/"/>
      <p:option name="path"/>
      <p:option name="include-filter"/>
      <p:option name="exclude-filter"/>
   </p:declare-step>
   <p:declare-step type="p:error" xml:id="error" xmlns:xproc="http://xproc.net/xproc">
      <p:input port="source" primary="true" select="/"/>
      <p:option name="code" required="true"/>
      <p:output port="error" primary="true" select="/"/>
   </p:declare-step>
   <p:declare-step type="p:escape-markup" xml:id="escape-markup" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="cdata-section-elements"/>
      <p:option name="doctype-public"/>
      <p:option name="doctype-system"/>
      <p:option name="escape-uri-attributes"/>
      <p:option name="include-content-type"/>
      <p:option name="indent" select="'false'"/>
      <p:option name="media-type"/>
      <p:option name="method" select="'xml'"/>
      <p:option name="omit-xml-declaration" select="'true'"/>
      <p:option name="standalone"/>
      <p:option name="undeclare-prefixes"/>
      <p:option name="version" select="'1.0'"/>
   </p:declare-step>
   <p:declare-step type="p:filter" xml:id="filter" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" sequence="true" select="/"/>
      <p:option name="select" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:http-request" xml:id="http-request" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="byte-order-mark"/>
      <p:option name="cdata-section-elements"/>
      <p:option name="doctype-public"/>
      <p:option name="doctype-system"/>
      <p:option name="encoding"/>
      <p:option name="escape-uri-attributes"/>
      <p:option name="include-content-type"/>
      <p:option name="indent" select="'false'"/>
      <p:option name="media-type"/>
      <p:option name="method" select="'xml'"/>
      <p:option name="normalization-form"/>
      <p:option name="omit-xml-declaration"/>
      <p:option name="standalone"/>
      <p:option name="undeclare-prefixes"/>
      <p:option name="version" select="'1.0'"/>
   </p:declare-step>
   <p:declare-step type="p:identity" xml:id="identity" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" sequence="true" primary="true" select="/"/>
      <p:output port="result" sequence="true" primary="true" select="/"/>
   </p:declare-step>
   <p:declare-step type="p:insert" xml:id="insert" xmlns:xproc="http://xproc.net/xproc">
      <p:input port="source" primary="true" select="/"/>
      <p:input port="insertion" primary="false" sequence="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="match" select="'/*'"/>
      <p:option name="position" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:label-elements" xml:id="label-elements">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="attribute" select="'xml:id'"/>
      <p:option name="label" select="'concat(&#34;_&#34;,$p:index)'"/>
      <p:option name="match" select="'*'"/>
      <p:option name="replace" select="'true'"/>
   </p:declare-step>
   <p:declare-step type="p:load" xml:id="load" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:output port="result" primary="true" select="/"/>
      <p:option name="href" required="true"/>
      <p:option name="dtd-validate" select="&#34;false&#34;"/>
   </p:declare-step>
   <p:declare-step type="p:make-absolute-uris" xml:id="make-absolute-uris">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" select="/"/>
      <p:option name="match" required="true"/>
      <p:option name="base-uri"/>
   </p:declare-step>
   <p:declare-step type="p:namespace-rename" xml:id="namespace-rename">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="from"/>
      <p:option name="to"/>
      <p:option name="elements-only" select="&#34;false&#34;"/>
   </p:declare-step>
   <p:declare-step type="p:pack" xml:id="pack">
      <p:input port="source" sequence="true" primary="true" select="/"/>
      <p:input port="alternate" primary="false" sequence="true" select="/"/>
      <p:output port="result" sequence="true" select="/"/>
      <p:option name="wrapper" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:parameters" xml:id="parameters">
      <p:input port="parameters" kind="parameter" primary="false" select="/"/>
      <p:output port="result" primary="false" select="/"/>
   </p:declare-step>
   <p:declare-step type="p:rename" xml:id="rename">
      <p:input port="source" select="/"/>
      <p:output port="result" select="/"/>
      <p:option name="match" required="true"/>
      <p:option name="new-name" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:replace" xml:id="replace">
      <p:input port="source" primary="true" select="/"/>
      <p:input port="replacement" primary="false" select="/"/>
      <p:output port="result" primary="true"/>
      <p:option name="match" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:set-attributes" xml:id="set-attributes">
      <p:input port="source" primary="true" select="/"/>
      <p:input port="attributes" primary="false" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="match" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:sink" xml:id="sink" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" sequence="true" select="/"/>
   </p:declare-step>
   <p:declare-step type="p:split-sequence" xml:id="split-sequence">
      <p:input port="source" sequence="true" select="/"/>
      <p:output port="matched" sequence="true" primary="true" select="/"/>
      <p:output port="not-matched" sequence="true" select="/"/>
      <p:option name="initial-only" select="'false'"/>
      <p:option name="test" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:store" xml:id="store" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" select="/"/>
      <p:output port="result" primary="false" select="/"/>
      <p:option name="href" select="''"/>
      <p:option name="byte-order-mark"/>
      <p:option name="cdata-section-elements"/>
      <p:option name="doctype-public"/>
      <p:option name="doctype-system"/>
      <p:option name="encoding"/>
      <p:option name="escape-uri-attributes"/>
      <p:option name="include-content-type"/>
      <p:option name="indent" select="'false'"/>
      <p:option name="media-type"/>
      <p:option name="method" select="'xml'"/>
      <p:option name="normalization-form"/>
      <p:option name="omit-xml-declaration"/>
      <p:option name="standalone"/>
      <p:option name="undeclare-prefixes"/>
      <p:option name="version" select="'1.0'"/>
   </p:declare-step>
   <p:declare-step type="p:string-replace" xml:id="string-replace">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="match" required="true"/>
      <p:option name="replace" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:unescape-markup" xml:id="unescape-markup" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="namespace"/>
      <p:option name="content-type" select="'application/xml'"/>
      <p:option name="encoding"/>
      <p:option name="charset" select="'UTF-8'"/>
   </p:declare-step>
   <p:declare-step type="p:unwrap" xml:id="unwrap" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="match" required="true"/>
   </p:declare-step>
   <p:declare-step type="p:wrap" xml:id="wrap" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="wrapper" required="true" default="/"/>
      <p:option name="match" required="true" default="/"/>
      <p:option name="group-adjacent" default="/"/>
   </p:declare-step>
   <p:declare-step type="p:wrap-sequence" xml:id="wrap-sequence">
      <p:input port="source" sequence="true" primary="true" select="/"/>
      <p:output port="result" sequence="true" primary="true" select="/"/>
      <p:option name="wrapper" required="true"/>
      <p:option name="group-adjacent"/>
   </p:declare-step>
   <p:declare-step type="p:xinclude" xml:id="xinclude" xproc:support="true">
      <p:input port="source" primary="true" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:option name="fixup-xml-base" select="'false'"/>
      <p:option name="fixup-xml-lang" select="'false'"/>
   </p:declare-step>
   <p:declare-step type="p:xslt" xml:id="xslt" xmlns:xproc="http://xproc.net/xproc" xproc:support="true">
      <p:input port="source" sequence="true" primary="true" select="/"/>
      <p:input port="stylesheet" primary="false" select="/"/>
      <p:input port="parameters" primary="false" kind="parameter" select="/"/>
      <p:output port="result" primary="true" select="/"/>
      <p:output port="secondary" primary="false" sequence="true" select="/"/>
      <p:option name="initial-mode"/>
      <p:option name="template-name"/>
      <p:option name="output-base-uri"/>
      <p:option name="version"/>
   </p:declare-step>

```