Attribute VB_Name = "QC"
Sub ImportKMLEnclosures()
    Dim XDoc As MSXML2.DOMDocument60
    Dim Namespace As String
    Dim polygonNodes As MSXML2.IXMLDOMNodeList
    Dim polygonNode As MSXML2.IXMLDOMNode
    Dim polName As String
    Dim polUUID As String
    Dim polClass As String
    Dim polModel As String
    Dim polLon As String
    Dim polLat As String
    Dim polCoords As String
    Dim XPath As String
    
    Namespace = "xmlns:kml='http://www.opengis.net/kml/2.2'"
    
    'Load XML
    Set XDoc = New MSXML2.DOMDocument60
    Call XDoc.SetProperty("SelectionNamespaces", Namespace)
    Call XDoc.SetProperty("SelectionLanguage", "XPath")
    XDoc.async = False: XDoc.validateOnParse = False
    XDoc.Load (Range("Path_QC_KML").value)
    
    'Get Nodes that have a child "Polygon"
    'Set polygonNodes = XDoc.SelectNodes("//ns:Polygon/parent::*")
    Set polygonNodes = XDoc.SelectNodes("//kml:Placemark/kml:ExtendedData")
    'Set polygonNodes = XDoc.SelectNodes("//ns:ExtendedData[@featureClass='hybrid']")
    
    
    'Clear existing data
    Sheets("QC").Range(Cells(2, 6), Cells(Rows.Count, Columns.Count)).Delete
    
    Dim temp1 As String
    Dim temp2 As String
    
    'Get polygon data and write it to sheet
    For i = 0 To polygonNodes.Length - 1
        Set polygonNode = polygonNodes(i)
        polClass = ""
        polName = ""
        polModel = ""
        polLength = ""
        polCoords = ""
    
    
        temp1 = polygonNode.ChildNodes(2).Text
        temp2 = polygonNode.ChildNodes(3).Text
        
        If temp1 = "slackStorage" Then
            polClass = "Slack"
            polName = polygonNode.ChildNodes(0).Text 'Slacks are unnamed, so use UUID
            polModel = polygonNode.ChildNodes(3).Text
            polLength = polygonNode.ChildNodes(5).Text
            polCoords = polygonNode.ParentNode.ChildNodes(2).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp1 = "hybrid" And temp2 = "hybrid" Then
            polClass = "Hybrid Tap"
            polName = polygonNode.ChildNodes(0).Text
            polModel = polygonNode.ChildNodes(4).Text
            polLength = "N/A"
            polCoords = polygonNode.ParentNode.ChildNodes(3).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp1 = "hybrid" Then
            polClass = "~Error~ Hybrid Tap"
            polName = "MISSING NAME (" + polygonNode.ChildNodes(0).Text + ")"
            polModel = polygonNode.ChildNodes(3).Text
            polLength = "N/A"
            polCoords = polygonNode.ParentNode.ChildNodes(2).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp2 = "spliceCan" Then
            polClass = "Splice Can"
            polName = polygonNode.ChildNodes(0).Text
            polModel = polygonNode.ChildNodes(4).Text
            polLength = "N/A"
            polCoords = polygonNode.ParentNode.ChildNodes(3).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp1 = "spliceCan" Then
            polClass = "~Error~ Splice Can"
            polName = "MISSING NAME (" + polygonNode.ChildNodes(0).Text + ")"
            polModel = polygonNode.ChildNodes(3).Text
            polLength = "N/A"
            polCoords = polygonNode.ParentNode.ChildNodes(2).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp2 = "fiberCable" Then
            polClass = "Fiber Cable"
            polName = polygonNode.ChildNodes(0).Text
            polModel = polygonNode.ChildNodes(4).Text
            polLength = polygonNode.ChildNodes(6).Text
            polCoords = polygonNode.ParentNode.ChildNodes(3).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp1 = "fiberCable" Then
            polClass = "~Error~ Fiber Cable"
            polName = "MISSING NAME (" + polygonNode.ChildNodes(0).Text + ")"
            polModel = polygonNode.ChildNodes(3).Text
            polLength = polygonNode.ChildNodes(5).Text
            polCoords = polygonNode.ParentNode.ChildNodes(2).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        ElseIf temp2 = "cabinet" Then
            polClass = "Cabinet"
            polName = polygonNode.ChildNodes(0).Text
            polModel = polygonNode.ChildNodes(4).Text
            polLength = "N/A"
            polCoords = polygonNode.ParentNode.ChildNodes(3).Text
            polCoords = CStr(Round(CDbl(Split(polCoords, ",")(1)), 6)) + ", " + CStr(Round(CDbl(Split(polCoords, ",")(0)), 6))
        End If
        

        Sheets("QC").Cells(i + 2, 6) = polClass
        Sheets("QC").Cells(i + 2, 7) = polName
        Sheets("QC").Cells(i + 2, 8) = polModel
        Sheets("QC").Cells(i + 2, 9) = polLength
        Sheets("QC").Cells(i + 2, 10) = polCoords

    Next i
    
    ThisWorkbook.Sheets("QC").Range("F1", Cells(10000, 10)).Sort Key1:=Range("F1"), Order1:=xlAscending, Header:=xlYes, _
        Key2:=Range("G1"), Order1:=xlAscending, Header:=xlYes

End Sub

