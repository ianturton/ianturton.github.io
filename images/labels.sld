<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd"
  xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <NamedLayer>
    <Name>labels</Name>
    <UserStyle>
      
      <FeatureTypeStyle>
        <Rule>
          
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>LblShowCO</ogc:PropertyName>
              <ogc:Literal>1</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <LineSymbolizer>
            <Stroke>
              <CssParameter name="stroke">#000000</CssParameter>
             <CssParameter name="stroke-opacity">0.5</CssParameter>
            </Stroke>
            
          </LineSymbolizer>
          </Rule>
        <Rule>
           <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>LblShow</ogc:PropertyName>
              <ogc:Literal>1</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <TextSymbolizer>
            
           <Geometry>
             <ogc:Function name="endPoint">
              <ogc:PropertyName>the_geom</ogc:PropertyName>
             </ogc:Function>
            </Geometry>
            <Label><ogc:PropertyName>LblField</ogc:PropertyName></Label>
            <Font>
              <CssParameter name="font-family">Liberation Sans</CssParameter>
              <CssParameter name="font-size"><!--<ogc:PropertyName>LblSize</ogc:PropertyName>-->10</CssParameter>
            </Font>
            <LabelPlacement>
            <PointPlacement> 
              <AnchorPoint>
                <AnchorPointX>
                  <ogc:Function name="Recode">
                    <ogc:PropertyName>LblAlignH</ogc:PropertyName>
                    <ogc:Literal>Left</ogc:Literal>
                    <ogc:Literal>0.0</ogc:Literal>
                    <ogc:Literal>Center</ogc:Literal>
                    <ogc:Literal>0.5</ogc:Literal>
                    <ogc:Literal>Right</ogc:Literal>
                    <ogc:Literal>1.0</ogc:Literal>
                  </ogc:Function>
                </AnchorPointX>
                <AnchorPointY>
                  <ogc:Function name="Recode">
                    <ogc:PropertyName>LblAlignH</ogc:PropertyName>
                    <ogc:Literal>Bottom</ogc:Literal>
                    <ogc:Literal>0.0</ogc:Literal>
                    <ogc:Literal>Half</ogc:Literal>
                    <ogc:Literal>0.5</ogc:Literal>
                    <ogc:Literal>Top</ogc:Literal>
                    <ogc:Literal>1.0</ogc:Literal>
                  </ogc:Function>
                </AnchorPointY>
              </AnchorPoint>
            </PointPlacement> 
            </LabelPlacement>
            <Halo/>
          </TextSymbolizer>
        </Rule>

      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>