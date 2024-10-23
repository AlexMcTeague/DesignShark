Attribute VB_Name = "HAF"
Sub FormatHAF()

    Dim OLTName As String
    Dim Dash As Worksheet
    Dim pathHAF As String
    Dim wbHAF As Workbook
    Dim SheetHAF As Worksheet
    
    OLTName = ThisWorkbook.Sheets("Data Entry").Range("OLT").value
    Set Dash = ThisWorkbook.Sheets("HAF")
    pathHAF = Dash.Range("Path_HAF")
    Set wbHAF = Workbooks.Open(pathHAF)
    Set SheetHAF = wbHAF.Sheets(1)
    
    'Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    
    Call TrimSheet(SheetHAF)
    
    Dim LR As Long 'this is the last row
    LR = SheetHAF.Cells(1, 1).End(xlDown).Row
    Dim LC As Long
    LC = 40
    
    'Edit Dwelling Type. TODO: Add more Cases
    Dim DwellingType As String
    Dim i As Integer
    For i = 2 To LR
        Select Case SheetHAF.Range("P" & i).value
        Case "RESIDENTIAL", "RES"
            DwellingType = "HOUSE"
        Case "COMMERCIAL", "COM"
            DwellingType = "BUS SINGLE (STAND-ALONE LOCATION)"
        Case "Bus Multi (Multi-Tenant Units)", _
            "Bus Single (Stand-Alone Location)", "Existing Customer - In Biller", _
            "Government", "Hospital", "Hotel", "House", "In-House", "K-12 School", _
            "Library", "Marina/RV Park", "MDU (4+ Units 1-3 Stories)", _
            "MDU (4+ Units 4+ Stories)", "Mobile Home Park", "Motel", _
            "On Campus School Dorm", "Religious", "SDU (2-3 Units)", "University", _
            "Vacant Lot Commercial", "Vacant Lot Residential", _
            "Gate,Elevator,ATM,Security Camera,Fire Alarm"
            
            DwellingType = UCase(SheetHAF.Range("P" & i).value)
        Case "BUS MULTI (MULTI-TENANT UNITS)", _
            "BUS SINGLE (STAND-ALONE LOCATION)", "EXISTING CUSTOMER - IN BILLER", _
            "GOVERNMENT", "HOSPITAL", "HOTEL", "HOUSE", "IN-HOUSE", "K-12 SCHOOL", _
            "LIBRARY", "MARINA/RV PARK", "MDU (4+ UNITS 1-3 STORIES)", _
            "MDU (4+ UNITS 4+ STORIES)", "MOBILE HOME PARK", "MOTEL", _
            "ON CAMPUS SCHOOL DORM", "RELIGIOUS", "SDU (2-3 UNITS)", "UNIVERSITY", _
            "VACANT LOT COMMERCIAL", "VACANT LOT RESIDENTIAL", _
            "GATE,ELEVATOR,ATM,SECURITY CAMERA,FIRE ALARM"
            
            DwellingType = SheetHAF.Range("P" & i).value
        Case Else
            DwellingType = "UNKNOWN"
        End Select
        SheetHAF.Range("P" & i).value = DwellingType
    Next
    
    'column Q as NEW
    SheetHAF.Range("Q2:Q" & LR).value = "NEW"
    
    'Installation Type
    For Each cell In SheetHAF.Range("S2:S" & LR)
        If cell.Offset(0, -4).value = "AERIAL" Then
            If cell.Offset(0, 12).value > 400 Then
                cell.value = "Non-Standard Aerial (>400ft Aerial Only)"
            Else
                cell.value = "Standard Aerial (<400ft Aerial Only)"
            End If
        ElseIf cell.Offset(0, -4).value = "UNDERGROUND" Then
            If cell.Offset(0, 12).value > 400 Then
                cell.value = "Non-Standard UG (>400ft UG Only) With Bore"
            Else
                cell.value = "Standard UG (<400ft UG Only) With Bore"
            End If
        End If
    Next cell
    
    'placing node name in AMP column
    SheetHAF.Range("Y2:Y" & LR).value = OLTName
    
    'filling in power supply name
    SheetHAF.Range("Z2:Z" & LR).value = OLTName + "_A"
    
    'format lat/long to a number with 6 decimal places
    With SheetHAF.Range("AA2", Cells(LR, 27))
        .value = Evaluate(.Address & "*1")
    End With
    With SheetHAF.Range("AB2", Cells(LR, 28))
        .value = Evaluate(.Address & "*1")
    End With
    SheetHAF.Range("AA2", "AA" & LR).NumberFormat = "0.000000"
    SheetHAF.Range("AB2", "AB" & LR).NumberFormat = "0.000000"
    
    'format CBG to 0 decimal places
    SheetHAF.Range("AC:AC").NumberFormat = "0"
    
    '''DEPRECATED, kept for posterity
    '''Set Access Issue to yes for Rear support locations (if access issue is empty)
    'Dim accessTick As Integer
    'Dim sloc As Range
    'Dim acciss As Range
    
    'For accessTick = 2 To LR
    '    Set sloc = SheetHAF.Range("AI" & accessTick)
    '    Set acciss = sloc.Offset(0, -1)
    '    Select Case sloc.value
    '    Case "F"
    '        If acciss.value = "" Then
    '            acciss.value = "NO"
    '        End If
    '    Case "R"
    '       If acciss.value = "" Then
    '            acciss.value = "YES"
    '        End If
    '    Case ""
    '        sloc.value = "Missing Support Location"
    '        sloc.Font.Color = vbRed
    '    Case Else
    '        sloc.value = "Unrecognized Support Location"
    '        sloc.Font.Color = vbRed
    '    End Select
    'Next accessTick
    
    Dim re As RegExp
    Dim matches As MatchCollection
    Dim MatchResult As String
    
    Set re = New RegExp
    re.IgnoreCase = True
    
    re.Pattern = "[ /]*PORT"
    
    For i = 2 To LR
        Set cell = Range("AG" & i)
        Set matches = re.Execute(cell.value)
        If matches.Count = 1 Then
            MatchResult = matches(0)
            If Dash.Range("PolePortDiv").value = "Space" Then
                cell.value = Replace(cell.value, MatchResult, " PORT")
            ElseIf Dash.Range("PolePortDiv").value = "Slash" Then
                cell.value = Replace(cell.value, MatchResult, "/PORT")
            End If
        End If
    Next i
    
    'TODO: extract unknown unit numbers as REAR, extract street type and pre/post directions
    SheetHAF.Range(Cells(2, 4), Cells(LR, 4)).Replace What:="TR ", Replacement:="TOWNSHIP ROAD ", _
        LookAt:=xlPart, SearchOrder:=xlByRows, MatchCase:=True, _
        SearchFormat:=False, ReplaceFormat:=False
    SheetHAF.Range(Cells(2, 4), Cells(LR, 4)).Replace What:="CR ", Replacement:="COUNTY ROAD ", _
        LookAt:=xlPart, SearchOrder:=xlByRows, MatchCase:=True, _
        SearchFormat:=False, ReplaceFormat:=False
    SheetHAF.Range(Cells(2, 4), Cells(LR, 4)).Replace What:="SR ", Replacement:="STATE ROUTE ", _
        LookAt:=xlPart, SearchOrder:=xlByRows, MatchCase:=True, _
        SearchFormat:=False, ReplaceFormat:=False
        
    'Divide street types
    'TODO: Needs heavy work
    For j = 2 To LR
        Call DivideStreetInfo(SheetHAF.Cells(j, 4))
    Next j
    
    'Replace street abbreviations with spelled-out versions
    Dim fndrng As Range
    Set fndrng = SheetHAF.Range("E2:E" & LR)
    Call FindReplaceAllInRange(fndrng, "RD", "ROAD")
    Call FindReplaceAllInRange(fndrng, "ST", "STREET")
    Call FindReplaceAllInRange(fndrng, "VLY", "VALLEY")
    Call FindReplaceAllInRange(fndrng, "DR", "DRIVE")
    Call FindReplaceAllInRange(fndrng, "LN", "LANE")
    Call FindReplaceAllInRange(fndrng, "HWY", "HIGHWAY")
    Call FindReplaceAllInRange(fndrng, "TRL", "TRAIL")
    Call FindReplaceAllInRange(fndrng, "CIR", "CIRCLE")
    
    'Extract NA counts to Rear Unit columns
    Dim c As Range
    For Each c In SheetHAF.Range("A2", Cells(LR, 1))
        If c.value Like "*-NA*" Then
            c.Offset(0, 8).value = "REAR"
            c.Offset(0, 9).value = Right(c.value, Len(c.value) - InStr(1, c.value, "-NA") - 2)
            c.value = Left(c.value, InStr(1, c.value, "-NA") - 1)
        End If
    Next c
    
    'Format house numbers as numbers to prepare for sorting
    With SheetHAF.Range("A2", Cells(LR, 1))
        .NumberFormat = "General"
        .value = .value
    End With
    
    'Perform the sort: first by street, then by house number
    With SheetHAF.Sort
        .SortFields.Clear
        .SortFields.Add Key:=Range("D1:D" & LR), Order:=xlAscending
        .SortFields.Add Key:=Range("E1:E" & LR), Order:=xlAscending
        .SortFields.Add Key:=Range("A1:A" & LR), Order:=xlAscending
        .SortFields.Add Key:=Range("J1:J" & LR), Order:=xlAscending
        .SetRange Range("A2", Cells(LR, LC))
        .Apply
        .SortFields.Clear
    End With
    
    
    'Format house numbers as text again
    SheetHAF.Range("A2", Cells(LR, 1)).NumberFormat = "@"
    
    SheetHAF.Columns("A:AI").AutoFit
    
    Dim HAFEncAndPort As Dictionary
    Set HAFEncAndPort = CreateObject("Scripting.Dictionary")
    Dim concat As String
    Dim dupEncAndPort As Boolean
    dupEncAndPort = False
    
    For i = 2 To LR
        concat = SheetHAF.Range("W" & i).value & ": " & SheetHAF.Range("AG" & i).value
        If HAFEncAndPort.Exists(concat) Then
            dupEncAndPort = True
            dupEncAndPortId = dupEncAndPortId & vbNewLine & concat
        Else
            HAFEncAndPort.Add concat, ""
        End If
    Next i
    
    If dupEncAndPort = True Then
        MsgBox "WARNING: Duplicate enclosure + port names. This is usually because MDUs are given the same port on the HAF. Please edit the duplicate ports manually with their correct values." & vbNewLine & dupEncAndPortId
    End If
End Sub


Sub DivideStreetInfo(AddressCell As Range)
    'TODO: Rework to be more performant. Possible: Do these searches on the whole column at a time, and when a match is found exclude that cell from future searches?
    
    'Extract street type when it appears at the end of a cell
    Call DivideUtility(" (Road|Rd)$", "ROAD", 1, True, AddressCell)
    Call DivideUtility(" (Street|St)$", "STREET", 1, True, AddressCell)
    Call DivideUtility(" (Valley|Vly)$", "VALLEY", 1, True, AddressCell)
    Call DivideUtility(" (Drive|Dr)$", "DRIVE", 1, True, AddressCell)
    Call DivideUtility(" (Lane|Ln)$", "LANE", 1, True, AddressCell)
    Call DivideUtility(" Way$", "WAY", 1, True, AddressCell)
    Call DivideUtility(" (Highway|Hwy)$", "HIGHWAY", 1, True, AddressCell)
    Call DivideUtility(" (Trail|Trl)$", "TRAIL", 1, True, AddressCell)
    Call DivideUtility(" (Circle|Cir)$", "CIRCLE", 1, True, AddressCell)
    Call DivideUtility(" (Court|Ct)$", "COURT", 1, True, AddressCell)
    
    'Extract street type when it appears at the beginning of a cell
    Call DivideUtility("^(State Road|County Road|CR|Township Road|TR) ", "ROAD", 1, False, AddressCell)
    Call DivideUtility("^(State Route|SR|Ohio) ", "ROUTE", 1, False, AddressCell)
    
    'Extract Post Direction when it appears at the end of a cell
    Call DivideUtility(" (North|N)$", "N", 2, True, AddressCell)
    Call DivideUtility(" (East|E)$", "E", 2, True, AddressCell)
    Call DivideUtility(" (South|S)$", "S", 2, True, AddressCell)
    Call DivideUtility(" (West|W)$", "W", 2, True, AddressCell)
    Call DivideUtility(" NE$", "NE", 2, True, AddressCell)
    Call DivideUtility(" SE$", "SE", 2, True, AddressCell)
    Call DivideUtility(" SW$", "SW", 2, True, AddressCell)
    Call DivideUtility(" NW$", "NW", 2, True, AddressCell)
    
    'Extract Pre Direction when it appears at the beginning of a cell
    Call DivideUtility("^(North|N) ", "N", -1, True, AddressCell)
    Call DivideUtility("^(East|E) ", "E", -1, True, AddressCell)
    Call DivideUtility("^(South|S) ", "S", -1, True, AddressCell)
    Call DivideUtility("^(West|W) ", "W", -1, True, AddressCell)
    Call DivideUtility("^NE ", "NE", -1, True, AddressCell)
    Call DivideUtility("^SE ", "SE", -1, True, AddressCell)
    Call DivideUtility("^SW ", "SW", -1, True, AddressCell)
    Call DivideUtility("^NW ", "NW", -1, True, AddressCell)

End Sub

Sub DivideUtility(PatternString As String, PasteValue As String, Offset As Integer, RemoveResult As Boolean, AddressCell As Range)
    Dim re As RegExp
    Dim matches As MatchCollection
    Dim MatchResult As String
    
    Set re = New RegExp
    re.IgnoreCase = True
    
    re.Pattern = PatternString
    Set matches = re.Execute(AddressCell.value)
    If matches.Count > 0 Then
        AddressCell.Offset(0, Offset).value = PasteValue
        If RemoveResult = True Then
            MatchResult = matches(0)
            AddressCell.value = Replace(AddressCell.value, MatchResult, "")
        End If
    End If
    
End Sub

Sub SplitHAF()
    Dim SharkData As Worksheet
    Dim RDOF As Workbook
    Dim SG As Workbook
    Dim RDOFCSV As Workbook
    Dim SGCSV As Workbook
    
    Set SharkData = ThisWorkbook.Worksheets("Data Entry")

    'Grab file path from HAF tab
    Dim pathHAF As String
    pathHAF = ThisWorkbook.Worksheets("HAF").Range("Path_HAF").value

    'Copy the HAF to two or four new files in the Downloads folder
    Dim obj As Object
    Set obj = CreateObject("Scripting.FileSystemObject")
    Dim pathDownloads As String
    pathDownloads = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads"
    Dim oldPath As String
    Dim currentPath As String
    
    currentPath = pathDownloads & "\" & SharkData.Range("NAME_HAF").value & ".xlsx"
    Call obj.CopyFile(pathHAF, currentPath, True)
    Set RDOF = Workbooks.Open(currentPath)
    
    If Not SharkData.Range("C6").value = "" Then
        currentPath = pathDownloads & "\" & SharkData.Range("PID").Offset(1, 0).value & "_" & SharkData.Range("OLT") & "_HAF_FIBER" & ".xlsx"
        Call obj.CopyFile(pathHAF, currentPath, True)
        Set SG = Workbooks.Open(currentPath)
        
        For i = RDOF.Worksheets(1).Range("AC" & RDOF.Worksheets(1).Rows.Count).End(xlUp).Row To 2 Step -1
            If RDOF.Worksheets(1).Range("AC" & i).value = "STATE GRANT" Then
                RDOF.Worksheets(1).Range("AC" & i).EntireRow.Delete
            End If
        Next i
        
        For j = SG.Worksheets(1).Range("AC" & SG.Worksheets(1).Rows.Count).End(xlUp).Row To 2 Step -1
            If Not SG.Worksheets(1).Range("AC" & j).value = "STATE GRANT" Then
                SG.Worksheets(1).Range("AC" & j).EntireRow.Delete
            End If
        Next j

        oldPath = currentPath
        currentPath = pathDownloads & "\" & SharkData.Range("PID").Offset(1, 0).value & "_" & SharkData.Range("OLT") & "_HAF_FIBER" & ".csv"
        SG.SaveAs fileName:=currentPath, FileFormat:=xlCSV
        Set SGCSV = Workbooks.Open(currentPath)
        SGCSV.Worksheets(1).Range("AI1").EntireColumn.Delete
        SGCSV.Worksheets(1).Range("AH1").EntireColumn.Delete
        
        SG.Save
        SGCSV.Save
    End If
    
    currentPath = pathDownloads & "\" & SharkData.Range("NAME_HAF").value & ".csv"
    RDOF.SaveAs fileName:=currentPath, FileFormat:=xlCSV
    Set RDOFCSV = Workbooks.Open(currentPath)
    RDOFCSV.Worksheets(1).Range("AI1").EntireColumn.Delete
    RDOFCSV.Worksheets(1).Range("AH1").EntireColumn.Delete
    
    RDOF.Save
    RDOFCSV.Save
    
End Sub

Sub checkCBG()
    Dim Dash As Worksheet
    Set Dash = ThisWorkbook.Sheets("HAF")
    Dim pathKMZ As String
    
    ' Get the path of the KMZ file
    pathKMZ = CStr(Dash.[Path_Polygons].value)
    
    ' If there isn't a KMZ path available, end the macro and inform the user
    If pathKMZ = "" Then
        Dash.Activate
        [Path_Polygons].Select
        MsgBox ("Path_Polygons is not set. Please select a file, then try again.")
        End
    End If
    
    ' If the file doesn't exist at the selected path, end the macro and inform the user
    KMZName = dir(pathKMZ)
    If KMZName = "" Then
        Dash.Activate
        [Path_Polygons].Select
        MsgBox ("File doesn't exist at Path_Polygons. Please select a different file, then try again.")
        End
    End If
    
    Call clear_polygons
    DashLR = Dash.Cells(Rows.Count, "G").End(xlUp).Row
    
    ' Load the file from the given path, whether it's a KML or KMZ file
    Set inputKML = Load_From_KML_Or_KMZ(pathKMZ)
    

    ' Find all Placemarks that contain a Polygon descendant, and don't contain "featureClass" data
    Set placemarks = inputKML.SelectNodes("//kml:Placemark[descendant::kml:Polygon and not(descendant::kml:ExtendedData/kml:Data[@name='featureClass'])]")

    If placemarks.Length = 0 Then
        MsgBox "Could not find CBG polgyons in selected KMZ file!"
        End
    End If
    
    ' Loop through all filtered Placemarks
    For i = 0 To placemarks.Length - 1
        Set headerCell = Dash.Cells(1, 10 + i)
        Set placemark = placemarks(i)
        
        ' Set column header in dashboard
        placemarkName = placemark.SelectSingleNode("./kml:name").Text
        headerCell.value = placemarkName
        
        ' Find all Polygons within the current Placemark (this includes all standalone Polygons, and Polygons inside Multi-geometries)
        Set polygons = placemark.SelectNodes(".//kml:Polygon")
        
        ' Loop through the Polygons
        For j = 0 To polygons.Length - 1
            Set polygon = polygons(j)
            ' Extract the coordinates
            coords = Split(polygon.SelectSingleNode(".//kml:coordinates").Text)
            
            ' Put clean data into polData
            ReDim polData(0 To UBound(coords), 1 To 2)
            For k = 0 To UBound(coords)
                polData(k, 1) = CDbl(Split(coords(k), ",")(0))
                polData(k, 2) = CDbl(Split(coords(k), ",")(1))
            Next k
                
            ' Loop through the addresses in the Dashboard
            For k = 2 To DashLR
                ' Check whether the address is inside the current Polygon
                ' Skip any addresses that are already logged as being inside a Polygon within the current Placemark
                If Not Dash.Cells(k, 10 + i).value = True Then
                    result = PtInPoly(Dash.Range("G" & k).value, Dash.Range("H" & k).value, polData)
                    ' Log the result to the Dashboard
                    If result = True Then Dash.Cells(k, 10 + i).value = True
                End If
            Next k
        Next j
    Next i
    
    Sheets("HAF").Rows(1).NumberFormat = "0"
    Sheets("HAF").Columns(10).NumberFormat = "0"
    Sheets("HAF").Columns("F:Z").AutoFit
End Sub
