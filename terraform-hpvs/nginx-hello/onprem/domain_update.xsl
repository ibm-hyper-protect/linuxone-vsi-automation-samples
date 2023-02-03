<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/disk/driver">
    <xsl:copy>
      <xsl:attribute name="iommu">on</xsl:attribute>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <memballoon model="none"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="i" select="position()" />
  <xsl:template match="/domain/devices/interface">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <driver name="vhost" iommu="on"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/domain/devices/controller[@type='virtio-serial']"/>
  <xsl:template match="/domain/devices/channel"/>
  <xsl:template match="/domain/devices/audio"/>
  <xsl:template match="/domain/devices/rng"/>
  
</xsl:stylesheet>

