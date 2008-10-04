<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:t='http://xproc.org/ns/testsuite'
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    >
<xsl:output method="text" xml:space="preserve"/>
    
 <xsl:template match="t:test-suite">
    <xsl:apply-templates select="t:test" mode="xprocxq"/>
</xsl:template>
    
    <xsl:template match="t:test" mode="xprocxq">
        xprocxq <xsl:value-of select="t:input[@port='source']/xi:include/@href"/>&#160; <xsl:value-of select="t:pipeline/xi:include/@href"/> &gt; <xsl:value-of select="t:output[@port='result']/xi:include/@href"/>&#xD;
    </xsl:template>

    <xsl:template match="t:test" mode="calabash">calabash <xsl:value-of select="t:input[@port='source']/xi:include/@href"/>  <xsl:value-of select="t:pipeline/xi:include/@href"/> &gt; <xsl:value-of select="t:output[@port='result']/xi:include/@href"/>
    </xsl:template>
    
</xsl:stylesheet>
