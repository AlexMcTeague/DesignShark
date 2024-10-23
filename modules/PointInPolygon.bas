Attribute VB_Name = "PointInPolygon"
' Inspired by chrism216's "Point In Polygon" thread on MrExcel.com
' https://www.mrexcel.com/board/threads/google-earth-determine-which-points-are-inside-a-polygon-using-coordinates.828554/

Sub analyze()
    
    Call get_addresses
    Call checkCBG
    Call DetermineCBG
    
End Sub

Function PtInPoly(ByVal Xcoord As Double, ByVal Ycoord As Double, ByVal polygon As Variant) As Variant

  Dim x As Long, NumSidesCrossed As Long, m As Double, b As Double, Poly As Variant
  
  Poly = polygon
  
  ' Raycast from the given point to a known point in the Polygon
  For x = LBound(Poly) To UBound(Poly) - 1
    If Poly(x, 1) > Xcoord Xor Poly(x + 1, 1) > Xcoord Then
      m = (Poly(x + 1, 2) - Poly(x, 2)) / (Poly(x + 1, 1) - Poly(x, 1))
      b = (Poly(x, 2) * Poly(x + 1, 1) - Poly(x, 1) * Poly(x + 1, 2)) / (Poly(x + 1, 1) - Poly(x, 1))
      If m * Xcoord + b > Ycoord Then NumSidesCrossed = NumSidesCrossed + 1
    End If
  Next
  
  ' If the raycast passes the shape border an even number of times, the given point is also inside the Polygon
  PtInPoly = CBool(NumSidesCrossed Mod 2)
  
End Function


Public Sub get_addresses()

    Dim Dash As Worksheet
    Dim wbHAF As Workbook
    Dim SheetHAF As Worksheet
    
    Dim pointName As String
    Dim pointLon As Double
    Dim pointLat As Double
    
    Set Dash = ThisWorkbook.Sheets("HAF")
    Set wbHAF = OpenPath(Dash.Range("Path_HAF"))
    Set SheetHAF = wbHAF.Sheets(1)

    
    'Clear rows
    ThisWorkbook.Activate
    Call clear_points
    
    'Read address data
    For i = 2 To SheetHAF.Range("AA" & SheetHAF.Rows.Count).End(xlUp).Row
        pointAddress = SheetHAF.Range("A" & i).value & " " & SheetHAF.Range("C" & i).value & " " & _
            SheetHAF.Range("D" & i).value & " " & SheetHAF.Range("E" & i).value & " " & SheetHAF.Range("F" & i).value
        pointAddress = Application.Trim(pointAddress)
        pointLon = CDbl(SheetHAF.Range("AB" & i).value)
        pointLat = CDbl(SheetHAF.Range("AA" & i).value)
    
        'Fill data in sheet
        Dash.Cells(i, 6) = pointAddress
        Dash.Cells(i, 7) = pointLon
        Dash.Cells(i, 8) = pointLat
    Next i
    
    Dash.Columns("G:H").NumberFormat = "0.000000"
    Dash.Columns("F:Z").AutoFit
End Sub

Public Sub get_polygon_names()
    Dim XDoc As MSXML2.DOMDocument60
    Dim polygonNodes As MSXML2.IXMLDOMNodeList
    Dim polygonNode As MSXML2.IXMLDOMNode
    Dim polName As String
    Dim XPath As String
    
    'Load XML
    Set XDoc = Load_From_KML_Or_KMZ(Range("Path_Polygons").value)
    
    'Clear cols
    Call clear_polygons
    
    'Get Nodes that have a child "Polygon"
    Set polygonNodes = XDoc.SelectNodes("//kml:Polygon/parent::*")
    
    'Get polygon names and write them to sheet
    For i = 0 To polygonNodes.Length - 1
        Set polygonNode = polygonNodes(i)
        polName = polygonNode.SelectSingleNode(".//kml:name").Text
        Sheets("HAF").Cells(1, i + 10).value = polName
    Next i
    
    Sheets("HAF").Rows(1).NumberFormat = "0"
    Sheets("HAF").Columns(9).NumberFormat = "0"
    Sheets("HAF").Columns("F:Z").AutoFit
End Sub

Public Function get_polygon_data(ByVal polName As String) As Variant
    Dim XDoc As MSXML2.DOMDocument60
    Dim polygonNode As MSXML2.IXMLDOMNode
    Dim coords As Variant
    Dim polData() As Variant
    'Dim path As String
    Dim XPath As String
    
    Namespace = "xmlns:kml='http://www.opengis.net/kml/2.2'"
    'path = Application.ActiveWorkbook.path
    
    'Load XML
    Set XDoc = Load_From_KML_Or_KMZ(Range("Path_Polygons").value)
    
    'get Nodes that have a child "Polygon" with the desired name
    Set polygonNode = XDoc.SelectSingleNode("//kml:name[text()='" & polName & "']/parent::*")
    
    'Extract the coordinates
    coords = Split(polygonNode.SelectSingleNode(".//kml:coordinates").Text)
    
    'Put clean data into output variable polData
    ReDim polData(0 To UBound(coords), 1 To 2)
    For i = 0 To UBound(coords)
        polData(i, 1) = CDbl(Split(coords(i), ",")(0))
        polData(i, 2) = CDbl(Split(coords(i), ",")(1))
    Next i
    
    get_polygon_data = polData
    
End Function


Sub clear_points()
    Worksheets("HAF").Range(Cells(2, 6), Cells(Rows.Count, Columns.Count)).Delete
End Sub


Sub clear_polygons()
    Sheets("HAF").Range(Cells(1, 10), Cells(1, Columns.Count)).EntireColumn.Delete
End Sub
