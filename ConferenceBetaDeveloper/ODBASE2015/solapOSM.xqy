module namespace solap = "solap";

import module namespace osm = "osm" at "osmXQueryLibrary.xqy";

declare function solap:tableComposer($document)
{
<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="en" lang="en"> 
<head> 
 <title>Geo-Analytics on OpenStreetMap Road Data | BeyoBlog</title> 
  <link rel='stylesheet' type='text/css' href='./styles/main.css' />
 </head> 
<body>
 <table dir="ltr" border = "0" cellspacion = "0" cellpadding = "0"
  witdh = "700" height = "1"> 
 <trbody>
<td align="right" width="75" height="30"  valign="Bottom" style='height:15.0pt;  padding-left:1.5pt;padding-right:2.0pt;padding-top:1.5pt;padding-bottom:1.5pt;  border-top:solid black .5pt'><span style="font-size: 11px;italic;"><i>Version</i></span>
</td>
</trbody>
 </table> 
</body>
</html>
};

declare function solap:globalStatisctic($document)
{
 count($document/*/way)
};