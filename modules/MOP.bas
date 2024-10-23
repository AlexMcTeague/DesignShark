Attribute VB_Name = "MOP"
Sub CreateMOP()
    'Application.ScreenUpdating = False
    'Application.EnableEvents = False
    'Application.DisplayAlerts = False
    
    
    'Grab file paths from MOP tab
    Dim pathMOPTemplate As String
    pathMOPTemplate = Range("Path_MOP_Template").value
    
    Dim pathFWDTrace As String
    pathFWDTrace = Range("Path_FWD_Trace").value
    Dim pathRTNTrace As String
    pathRTNTrace = Range("Path_RTN_Trace").value
    
    Dim pathSplice1 As String
    pathSplice1 = Range("Path_Splice_1").value
    
    
    'Copy the MOP Template to a new file in the Downloads folder (overwrites existing MOP if any)
    Dim objNewMOP As Object
    Set objNewMOP = CreateObject("Scripting.FileSystemObject")
    Dim pathDownloads As String
    pathDownloads = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads"
    Call objNewMOP.CopyFile(pathMOPTemplate, pathDownloads & "\" & Range("Name_MOP").value & ".xlsx", True)
    
    Dim RDOF_Shark As Workbook
    Set RDOF_Shark = Application.ThisWorkbook
    Dim pathNewMOP As String
    pathNewMOP = pathDownloads & "\" & Range("Name_MOP").value & ".xlsx"
    Workbooks.Open pathNewMOP
    Dim NewMOP As Workbook
    Set NewMOP = ActiveWorkbook
    
    'Delete unnecessary tabs
    Application.DisplayAlerts = False
    NewMOP.Worksheets("Splice 1").Delete
    NewMOP.Worksheets("Splice 2").Delete
    NewMOP.Worksheets("Splice 3").Delete
    NewMOP.Worksheets("BOM").Delete
    Application.DisplayAlerts = True
    
    'Filling out Trace tab
    'FWD Trace
    'Application.ScreenUpdating = False
    NewMOP.Worksheets("Trace").Range("A1").value = "FWD-TRACE"
    NewMOP.Worksheets("Trace").Range("A1").HorizontalAlignment = xlCenter
    NewMOP.Worksheets("Trace").Range("A1").Font.Bold = True
    
    Dim FWD_Trace As Workbook
    
    Set FWD_Trace = Application.Workbooks.Open(pathFWDTrace)
    FWD_Trace.Worksheets("TRACE REPORT").UsedRange.Copy NewMOP.Worksheets("Trace").Range("A2")
    
    FWD_Trace.Close SaveChanges:=False
    
    'Range(NewMOP.Worksheets("Trace").Range("C:C").Find("CABINET").Offset(1, 0), Cells(Rows.Count, 3)).EntireRow.Delete
    'Range("B4").Value = Application.WorksheetFunction.CountIf(Range("P:P"), "*<- FUSION ->*")
    'Range("B5").Value = Application.WorksheetFunction.Sum(Range("O:O"))
    
    'RTN Trace
    Dim MidRow As Integer
    NewMOP.Worksheets("Trace").UsedRange
    MidRow = LastRowColumn(NewMOP.Worksheets("Trace"), "r") + 2
    NewMOP.Worksheets("Trace").Cells(MidRow, 1).EntireRow.Interior.ColorIndex = 27
    
    NewMOP.Worksheets("Trace").Cells(MidRow, 1).Offset(2, 0).value = "RTN-TRACE"
    NewMOP.Worksheets("Trace").Cells(MidRow, 1).Offset(2, 0).HorizontalAlignment = xlCenter
    NewMOP.Worksheets("Trace").Cells(MidRow, 1).Offset(2, 0).Font.Bold = True
    
    Dim RTN_Trace As Workbook
    
    Set RTN_Trace = Application.Workbooks.Open(pathRTNTrace)
    RTN_Trace.Worksheets("TRACE REPORT").UsedRange.Copy NewMOP.Worksheets("Trace").Cells(MidRow, 1).Offset(3, 0)
    
    RTN_Trace.Close SaveChanges:=False
    
    'Scrap note: LastRow = MidRow - 2
    'Range(Range(Cells(LastRow, 3).Offset(5, 0), Cells(Rows.Count, 3)).Find("CABINET").Offset(1, 0), Cells(Rows.Count, 3)).EntireRow.Delete
    'Range(Cells(LastRow, 2).Offset(8, 0)).Value = Application.WorksheetFunction.CountIf(Range(Cells(LastRow, 16).Offset(5, 0), Cells(Rows.Count, 16)), "*<- FUSION ->*")
    'Range(Cells(LastRow, 2).Offset(9, 0)).Value = Application.WorksheetFunction.Sum(Range(Cells(LastRow, 15).Offset(5, 0), Cells(Rows.Count, 15)))
    
    NewMOP.Worksheets("Trace").Columns("A:W").AutoFit
    
    'Filling out MOP tab
    Worksheets("MOP").Range("B3") = Date
    
    Worksheets("MOP").Range("B6") = RDOF_Shark.Worksheets("Data Entry").Range("SITE_NAME").value
    If IsEmpty(RDOF_Shark.Worksheets("Data Entry").Range("OLT_ADDRESS").value) = True Then
        Worksheets("MOP").Range("C6") = RDOF_Shark.Worksheets("Data Entry").Range("COORDINATES").value
    Else
        Worksheets("MOP").Range("C6") = RDOF_Shark.Worksheets("Data Entry").Range("OLT_ADDRESS").value
    End If
    
    Worksheets("MOP").Range("B9:F9") = "NA"
    Worksheets("MOP").Range("B12:D12") = "NA"
    
    Worksheets("MOP").Range("B35") = RDOF_Shark.Worksheets("Data Entry").Range("CLLI").value
    Worksheets("MOP").Range("B36") = RDOF_Shark.Worksheets("Data Entry").Range("CLLI").value
    
    'Getting some info for MOP tab from Trace tab
    Dim FirstConnection As Range
    Set FirstConnection = Range(NewMOP.Worksheets("Trace").Cells(1, 16), NewMOP.Worksheets("Trace").Cells(MidRow, 16)).Find("*CONNECTION*").Offset(1, 0)
    
    'Worksheets("MOP").Range("C35") = RDOF_Shark.Worksheets("Data Entry").Range("HUB_ROW_RACK_RU").Value & "." & RDOF_Shark.Worksheets("Data Entry").Range("C25")
    Worksheets("MOP").Range("C35") = FirstConnection.Offset(0, -9).value & "." & FirstConnection.Offset(0, -6).value
    Worksheets("MOP").Range("D35") = FirstConnection.Offset(0, 7).value
    Worksheets("MOP").Range("E35") = FirstConnection.Offset(0, 5).value
    Worksheets("MOP").Range("F35") = ConvertFiberToNum(FirstConnection.Offset(0, 6).value, Worksheets("MOP").Range("E35").value)

    Set FirstConnection = Range(NewMOP.Worksheets("Trace").Cells(MidRow, 16), NewMOP.Worksheets("Trace").Cells(Rows.Count, 16)).Find("*CONNECTION*").Offset(1, 0)

    'Worksheets("MOP").Range("C36") = RDOF_Shark.Worksheets("Data Entry").Range("HUB_ROW_RACK_RU").Value & "." & RDOF_Shark.Worksheets("Data Entry").Range("C26")
    Worksheets("MOP").Range("C36") = FirstConnection.Offset(0, -9).value & "." & FirstConnection.Offset(0, -6).value
    Worksheets("MOP").Range("D36") = FirstConnection.Offset(0, 7).value
    Worksheets("MOP").Range("E36") = FirstConnection.Offset(0, 5).value
    Worksheets("MOP").Range("F36") = ConvertFiberToNum(FirstConnection.Offset(0, 6).value, Worksheets("MOP").Range("E36").value)

    Worksheets("MOP").Range("G35") = RDOF_Shark.Worksheets("Data Entry").Range("OLT").value
    Worksheets("MOP").Range("G36") = RDOF_Shark.Worksheets("Data Entry").Range("OLT").value
    
    Worksheets("MOP").Range("H35") = Worksheets("Trace").Range("B6").value
    Worksheets("MOP").Range("H36") = NewMOP.Worksheets("Trace").Cells(MidRow, 2).Offset(7, 0).value

    'CORWAVE
    Worksheets("MOP").Range("B83") = RDOF_Shark.Worksheets("Data Entry").Range("OLT").value
    Worksheets("MOP").Range("C83") = RDOF_Shark.Worksheets("Data Entry").Range("CORWAVE").value
    Worksheets("MOP").Range("C95") = RDOF_Shark.Worksheets("Data Entry").Range("CLLI").value
    Worksheets("MOP").Range("C96") = RDOF_Shark.Worksheets("Data Entry").Range("HUB").value
    
    Worksheets("MOP").Range("B106") = RDOF_Shark.Worksheets("Data Entry").Range("OLT").value
    Worksheets("MOP").Range("C106") = RDOF_Shark.Worksheets("Data Entry").Range("CORWAVE").value
    Worksheets("MOP").Range("C118") = RDOF_Shark.Worksheets("Data Entry").Range("CLLI").value
    Worksheets("MOP").Range("C119") = RDOF_Shark.Worksheets("Data Entry").Range("HUB").value
    
    Worksheets("MOP").Range("D128") = "" 'Deleting that one random EDFA name from the template
    
    'Link Loss
    Worksheets("MOP").Range("H82") = Worksheets("MOP").Range("I35").value
    Worksheets("MOP").Range("H105") = Worksheets("MOP").Range("I36").value
    
    Worksheets("MOP").Range("H84") = Application.WorksheetFunction.CountIf(Worksheets("Trace").Range("J:J"), "*UPG*") / 2
    Worksheets("MOP").Range("H107") = Application.WorksheetFunction.CountIf(Worksheets("Trace").Range("J:J"), "*UPG*") / 2
    
    Worksheets("MOP").Range("H85") = 1
    Worksheets("MOP").Range("H108") = 1
    
    'Worksheets("MOP").Range("H95") = Worksheets("Trace").Range("B5").Value
    'Worksheets("MOP").Range("H118") = Worksheets("Trace").Cells(LastRow, 2).Offset(8, 0).Value
    
    'Worksheets("MOP").Range("H95") = Application.WorksheetFunction.CountIf(Worksheets("Trace").Range("P:P"), "*<- FUSION ->*") / 2
    'Worksheets("MOP").Range("H118") = Application.WorksheetFunction.CountIf(Worksheets("Trace").Range("P:P"), "*<- FUSION ->*") / 2
    
    'WIP Corrected Fusion Counter
    Dim PreviousFusion As String
    PreviousFusion = "Null"
    Dim FusionCount As Integer
    FusionCount = 0
    For j = 1 To MidRow
        If InStr(Worksheets("Trace").Cells(j, 16).value, "FUSION") > 0 Or InStr(Worksheets("Trace").Cells(j, 16).value, "N/A") > 0 Then
            If Not Worksheets("Trace").Cells(j, 4).value = PreviousFusion Then
                If Not Worksheets("Trace").Cells(j, 3).value = "HEADEND" Then
                    FusionCount = FusionCount + 1
                    PreviousFusion = Worksheets("Trace").Cells(j, 4).value
                End If
            End If
        End If
    Next j
    Worksheets("MOP").Range("H95") = FusionCount
    
    PreviousFusion = "Null"
    FusionCount = 0
    For k = MidRow To LastRowColumn(NewMOP.Worksheets("Trace"), "r")
        If InStr(Worksheets("Trace").Cells(k, 16).value, "FUSION") > 0 Or InStr(Worksheets("Trace").Cells(k, 16).value, "N/A") > 0 Then
            If Not Worksheets("Trace").Cells(k, 4).value = PreviousFusion Then
                If Not Worksheets("Trace").Cells(k, 3).value = "HEADEND" Then
                    FusionCount = FusionCount + 1
                    PreviousFusion = Worksheets("Trace").Cells(k, 4).value
                End If
            End If
        End If
    Next k
    Worksheets("MOP").Range("H118") = FusionCount
    
    Worksheets("MOP").Range("H96") = 2
    Worksheets("MOP").Range("H119") = 2

    'Splice Tabs
    Dim TotalSpliceTabs As Integer
    TotalSpliceTabs = Application.WorksheetFunction.CountIf(RDOF_Shark.Worksheets("MOP").Range("C6:C25"), "*")
    
    Dim TabName As String
    Dim pathSplice As String
    Dim SpliceWorkbook As Workbook
    Dim SpliceDeviceName As String

    Dim ExtraRows As Integer
    ExtraRows = 0
    
    RDOF_Shark.Sheets("Splice Tab Template").Visible = True
    For i = 1 To TotalSpliceTabs
        TabName = "Splice " & i
        RDOF_Shark.Sheets("Splice Tab Template").Copy Before:=NewMOP.Sheets("Trace")
        ActiveSheet.Name = TabName
        Range("A40") = TabName
        
        pathSplice = RDOF_Shark.Worksheets("MOP").Cells(5 + i, 3).value
        Set SpliceWorkbook = Application.Workbooks.Open(pathSplice)
        SpliceDeviceName = SpliceWorkbook.Sheets(1).Cells(1, 2)
        If IsEmpty(RDOF_Shark.Worksheets("MOP").Cells(5 + i, 5)) Then
            SpliceDeviceLoc = SpliceWorkbook.Sheets(1).Cells(2, 2)
        Else
            SpliceDeviceLoc = RDOF_Shark.Worksheets("MOP").Cells(5 + i, 5).value
        End If
        SpliceWorkbook.Worksheets(1).UsedRange.Copy NewMOP.Worksheets(TabName).Range("A41")
        SpliceWorkbook.Close
        
        NewMOP.Worksheets(TabName).Activate
        Call FormatSpliceTab
        If Application.WorksheetFunction.CountIf(Range("A:A"), "*OPTICAL SPLITTERS*") = 1 Then
            Call FormatSpliceTabSplitters
        End If
        
        'TODO: Make room for more splice tabs in Overview when needed
        If i > 6 Then
            NewMOP.Worksheets("MOP").Cells(14 + i - 1, 1).EntireRow.Copy
            NewMOP.Worksheets("MOP").Cells(14 + i, 1).EntireRow.Insert
            ExtraRows = ExtraRows + 1
        End If
        NewMOP.Worksheets("MOP").Cells(14 + i, 2).value = "SPLICE " & i & ": SEE SPLICE TAB " & Chr(34) & "SPLICE " & i & Chr(34) & " FOR SPLICING DETAILS"
        
        If i > 10 Then
            NewMOP.Worksheets("MOP").Cells(22 + ExtraRows + i - 1, 1).EntireRow.Copy
            NewMOP.Worksheets("MOP").Cells(22 + ExtraRows + i, 1).EntireRow.Insert
        End If
        NewMOP.Worksheets("MOP").Cells(22 + ExtraRows + i, 2).value = TabName
        NewMOP.Worksheets("MOP").Cells(22 + ExtraRows + i, 3).value = SpliceDeviceName
        NewMOP.Worksheets("MOP").Cells(22 + ExtraRows + i, 4).value = SpliceDeviceLoc
    Next i
    RDOF_Shark.Sheets("Splice Tab Template").Visible = False
    RDOF_Shark.Sheets("MOP").Activate
    NewMOP.Worksheets("MOP").Activate
    NewMOP.Save
    Application.ScreenUpdating = True
    Application.EnableEvents = True
    Application.DisplayAlerts = True
    
    'Reminder Message
    MsgBox "MOP created! Double-check that everything is correct, including:" & vbNewLine & _
        "* Ensure Link Loss calc fields are correct (EDFAs must be added manually)" & vbNewLine & _
        "* Add images to each Splice tab" & vbNewLine & _
        "* Replace coordinates with addresses where possible"

End Sub


Sub Import_FWD_Trace()
    Dim FWD_Trace_Path As Variant
    Dim FWD_Trace As Workbook
    
    FWD_Trace_Path = Application.GetOpenFilename(FileFilter:="Excel Files (*.*), *.*", title:="Select FWD Trace", ButtonText:="Select FWD Trace")
    
    'Application.ScreenUpdating = False
    
    Set FWD_Trace = Application.Workbooks.Open(FWD_Trace_Path)
    FWD_Trace.Sheets("Trace Report").Copy After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count)
    ActiveSheet.Name = "FWD Trace"
    FWD_Trace.Close SaveChanges:=False
    
    Range(Range("C:C").Find("CABINET").Offset(1, 0), Cells(Rows.Count, 3)).EntireRow.Delete
    Range("B4").value = Application.WorksheetFunction.CountIf(Range("P:P"), "*<- FUSION ->*")
    Range("B5").value = Application.WorksheetFunction.Sum(Range("O:O"))
    
    Rows(1).Insert
    Range("A1").value = "FWD-TRACE"
    Range("A1").HorizontalAlignment = xlCenter
    Range("A1").Font.Bold = True
    
    Application.ScreenUpdating = True
End Sub

Sub Import_RTN_Trace()
    Dim RTN_Trace_Path As Variant
    Dim RTN_Trace As Workbook
    
    RTN_Trace_Path = Application.GetOpenFilename(FileFilter:="Excel Files (*.*), *.*", title:="Select RTN Trace", ButtonText:="Select RTN Trace")
    
    'Application.ScreenUpdating = False
    
    Set RTN_Trace = Application.Workbooks.Open(RTN_Trace_Path)
    RTN_Trace.Sheets("Trace Report").Copy After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count)
    ActiveSheet.Name = "RTN Trace"
    RTN_Trace.Close SaveChanges:=False
    
    Range(Range("C:C").Find("CABINET").Offset(1, 0), Cells(Rows.Count, 3)).EntireRow.Delete
    Range("B4").value = Application.WorksheetFunction.CountIf(Range("P:P"), "*<- FUSION ->*")
    Range("B5").value = Application.WorksheetFunction.Sum(Range("O:O"))
    
    Rows(1).Insert
    Range("A1").value = "RTN-TRACE"
    Range("A1").HorizontalAlignment = xlCenter
    Range("A1").Font.Bold = True
    
    Application.ScreenUpdating = True
End Sub

Sub FormatSpliceTab()
    Dim R As Integer
    Dim fr As Integer
    Dim LR As Integer
    Dim FinalRow As Integer
    Dim Heading As Boolean
    
    Columns("A:T").AutoFit
    
    FinalRow = LastRowColumn(ActiveSheet, "r")
    ActiveSheet.PageSetup.PrintArea = "$A$1:$T$" & FinalRow
    ' ActiveSheet.PageSetup.PrintArea = Range("A1", Cells(Rows.Count, 20)).Address
    ' ActiveSheet.VPageBreaks.Item(0).Location = Range("T1")
    ' Cells(Rows.Count, Columns.Count).Select
    ' ActiveSheet.VPageBreaks(1).DragOff xlToRight, 1
    
    fr = Range("I:I").Find("*CIRCUIT*").Offset(1, 0).Row
    LR = Cells(fr, 9).End(xlDown).Row
    
    For R = fr To LR
        Heading = False
        If Not Cells(R, "J") = "X" Then
            If Cells(R, "B").Interior.Color = RGB(255, 186, 0) Then
                Heading = True
            End If
        
            Rows(R).Interior.ColorIndex = 27
            Rows(R).Font.Bold = True
            
            If Heading = True Then
                Cells(R, "A").Interior.Color = RGB(255, 186, 0)
                Cells(R, "B").Interior.Color = RGB(255, 186, 0)
            End If
        End If
    Next R

End Sub

Sub FormatSpliceTabSplitters()
    Dim fr2 As Integer
    Dim lr2 As Integer
    Dim Heading As Boolean
    
    fr2 = Range("E:E").Find("*CONNECTION*").Offset(1, 0).Row
    lr2 = Cells(fr2, 4).End(xlDown).Row
    
    For r2 = fr2 To lr2
        Heading = False
        If Not Cells(r2, "E") = "X" Then
            If Cells(r2, "B").Interior.Color = RGB(255, 186, 0) Then
                Heading = True
            End If

            Rows(r2).Interior.ColorIndex = 27
            Rows(r2).Font.Bold = True
            
            If Heading = True Then
                Cells(r2, "A").Interior.Color = RGB(255, 186, 0)
                Cells(r2, "B").Interior.Color = RGB(255, 186, 0)
            End If
        End If
    Next r2

End Sub



