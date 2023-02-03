<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/volume">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <allocation unit="bytes">0</allocation>
     </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

