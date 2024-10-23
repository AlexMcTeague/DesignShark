Attribute VB_Name = "CBG"
Sub ExportCBG()
    Dim pathHAF As String
    Dim wbHAF As Workbook
    Dim SheetHAF As Worksheet
    Dim SheetCBG As Worksheet
    Dim LRHAF As Integer
    Dim LRCBG As Integer
    Dim SearchResult As Range
    Dim RoundedValue As Long
    Dim PPResultCell As Range

    Set SheetCBG = ThisWorkbook.Worksheets("HAF")
    pathHAF = Range("Path_HAF")
    Set wbHAF = Workbooks.Open(pathHAF)
    Set SheetHAF = wbHAF.Sheets(1)
    
    LRHAF = SheetHAF.Range("AA2").End(xlDown).Row
    LRCBG = SheetCBG.Cells(Rows.Count, "F").End(xlUp).Row
    LCCBG = SheetCBG.Cells(1, Columns.Count).End(xlToLeft).Column
    
    For Each c In SheetHAF.Range("AA2", "AA" & LRHAF)
        SearchValue = WorksheetFunction.Round(c, 6)
        Set SearchResult = Nothing
        Set SearchResult = SheetCBG.Range("H2", "H" & LRCBG).Find(SearchValue, LookIn:=xlValues, LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext)
        If Not SearchResult Is Nothing Then
            FoundMatch = False
            Do
                If WorksheetFunction.Round(c.Offset(0, 1), 6) = WorksheetFunction.Round(SearchResult.Offset(0, -1), 6) Then
                    Set PPResultCell = SheetCBG.Cells(SearchResult.Row, 9)
                    c.Offset(0, 2).value = PPResultCell.value
                    c.Offset(0, 2).Font.Color = vbBlack
                    c.Offset(0, 3).Font.Color = vbBlack
                    If PPResultCell.value = "SYNERGY" Then
                        c.Offset(0, 3).value = "NONE"
                    ElseIf PPResultCell.value = "STATE GRANT" Then
                        c.Offset(0, 3).value = "FULL"
                    ElseIf Application.WorksheetFunction.IsNumber(PPResultCell.value) Then
                        c.Offset(0, 3).value = "FULL"
                    Else
                        c.Offset(0, 3).value = "ERROR"
                        c.Offset(0, 3).Font.Color = vbRed
                    End If
                    FoundMatch = True
                Else
                    Set SearchResult = SheetCBG.Range("H2", "H" & LRCBG).FindNext(SearchResult)
                End If
            Loop Until FoundMatch = True Or SearchResult Is Nothing
            
            If FoundMatch = False Then
                c.Offset(0, 2).value = "LON NOT FOUND"
                c.Offset(0, 3).value = "LON NOT FOUND"
                c.Offset(0, 2).Font.Color = vbRed
                c.Offset(0, 3).Font.Color = vbRed
            End If
        Else
            c.Offset(0, 2).value = "LAT NOT FOUND"
            c.Offset(0, 3).value = "LAT NOT FOUND"
            c.Offset(0, 2).Font.Color = vbRed
            c.Offset(0, 3).Font.Color = vbRed
        End If
    Next c
End Sub

Sub DetermineCBG()
    Dim LR As Integer
    LR = Sheets("HAF").Range("F1").End(xlDown).Row
    Dim LC As Integer
    LC = Sheets("HAF").Cells(1, Columns.Count).End(xlToLeft).Column
    Dim TrueCount As Integer
    Dim OutputCell As Range
    
    For i = 2 To LR
        TrueCount = Application.WorksheetFunction.CountIf(Range(Cells(i, 10), Cells(i, LC)), "TRUE")
        Set OutputCell = Cells(i, 9)
        
        Select Case TrueCount
        Case 0
            OutputCell.value = "SYNERGY"
        Case 1
            OutputCell.value = Cells(1, Range(Cells(i, 10), Cells(i, LC)).Find("TRUE").Column)
        Case Is > 1
            OutputCell.value = "OVERLAP"
            OutputCell.Font.Color = vbYellow
        Case Else
            OutputCell.value = "ERROR"
            OutputCell.Font.Color = vbRed
        End Select
    Next i
    
    Sheets("HAF").Columns(LC + 1).NumberFormat = "0"
    Sheets("HAF").Columns("F:Z").AutoFit
End Sub

Sub ExtractKML(ByVal pathToKMZ As String, ByVal returnPath As String, Optional ByVal temp As String = "")
    Dim applicationObject As Object
    Set applicationObject = CreateObject("Shell.Application")
    Dim fileSystemObject As Object
    Set fileSystemObject = CreateObject("Scripting.FileSystemObject")
    
    ' If a temporary working folder is not provided, create one in the same folder as the KMZ
    tempDirectory = ""
    If (temp = "") Then
        tempDirectory = fileSystemObject.CreateFolder(fileSystemObject.GetParentFolderName(pathToKMZ) & "\KML_CONVERSION_TEMP")
    Else
        tempDirectory = temp
    End If
    
    ' Copy the KMZ to the temp folder as a KMZ
    pathAsZip = tempDirectory & "\" & Replace(fileSystemObject.GetFileName(pathToKMZ), ".kmz", ".zip")
    fileSystemObject.CopyFile pathToKMZ, pathAsZip, True
    
    ' Loop through the items in the zip file and operate on the one that ends in ".kml"
    For Each f In applicationObject.Namespace(pathAsZip).Items
        If Right(f.path, 4) = ".kml" Then
            ' Copy the kml file to the temp folder with whatever name it had within the kmz
            applicationObject.Namespace(tempDirectory).CopyHere f.path, 20
            
            ' Copy the kml to the destination path, which includes the intended file name
            fileSystemObject.CopyFile tempDirectory & "\" & f.Name, returnPath, True
            
            ' Clean up the unnamed kml
            fileSystemObject.DeleteFile tempDirectory & "\" & f.Name
        End If
    Next
    
    ' Clean up the zip file
    fileSystemObject.DeleteFile pathAsZip
    
    ' If we made a temp folder, clean that up as well
    If (temp = "") Then
        fileSystemObject.DeleteFolder tempDirectory
    End If
End Sub

Function Load_From_KML_Or_KMZ(path As String) As MSXML2.DOMDocument60
    ' Takes a filepath argument, returns an XML object

    ' If a KML path was given, we can proceed without hassle!
    If path Like "*.kml" Then
        kmlPath = path
    ' If a KMZ path was given, the KML will need to be extracted
    ElseIf path Like "*.kmz" Then
        ' Establish the path to the temp folder
        tempPath = Left(path, InStrRev(path, "\"))
        tempFolderName = "QC_SHEET_TEMP"
        tempFullPath = tempPath & tempFolderName
    
        ' Create the temp folder
        CreateFolderPath (tempFullPath)
        
        ' Extract the KML into the temp folder
        kmlPath = tempFullPath & "\ripeKML.kml"
        ExtractKML path, kmlPath, tempFullPath
    Else
        MsgBox "Expected KMZ or KML file!" & vbNewLine & "Path: " & path
        End
    End If
    
    
    ' Declare variables
    Dim xmlObj As MSXML2.DOMDocument60
    Dim Namespace As String
    
    ' Set KML Standard Namespace
    Namespace = "xmlns='http://www.opengis.net/kml/2.2' xmlns:gx='http://www.google.com/kml/ext/2.2' xmlns:kml='http://www.opengis.net/kml/2.2' xmlns:atom='http://www.w3.org/2005/Atom'"
    
    ' Load XML
    Set xmlObj = New MSXML2.DOMDocument60
    Call xmlObj.SetProperty("SelectionNamespaces", Namespace)
    Call xmlObj.SetProperty("SelectionLanguage", "XPath")
    xmlObj.async = False: xmlObj.validateOnParse = False
    xmlObj.Load (kmlPath)
    
    ' Clean up the temp directory if one exists
    If Not IsEmpty(tempFullPath) Then
        Dim fileSystemObject As Object
        Set fileSystemObject = CreateObject("Scripting.FileSystemObject")
        fileSystemObject.DeleteFolder tempFullPath
    End If

    ' Return the XML object
    Set Load_From_KML_Or_KMZ = xmlObj
End Function

