Attribute VB_Name = "BOMs"
Sub FormatBOM(Optional TotalCol As Integer = 0, Optional SortCol1 As Integer = 0, Optional SortCol2 As Integer = 0)
    
    Columns("A:Z").AutoFit
    
    If (Not SortCol1 = 0) And (Not SortCol2 = 0) Then
        Range("A1", "Z100").Sort Key1:=Cells(1, SortCol1), Order1:=xlAscending, Header:=xlYes, _
            Key2:=Cells(1, SortCol2), Order1:=xlAscending, Header:=xlYes
    End If
    
    If (Not TotalCol = 0) And (Not DesignCol = 0) Then
        Range(Cells(2, TotalCol), Cells(100, TotalCol)).Copy Range(Cells(2, DesignCol), Cells(100, DesignCol))
    End If
    
End Sub

Sub FormatAllBOMs()
    
    Workbooks.Open (Range("Path_BOMs").value)
    
    Worksheets("CoaxPS").Activate
    Call FormatBOM(6, 9)
    
    'Worksheets("StrandQuickDetails").Activate
    'Call FormatBOM()
    
    'Worksheets("FiberQuickDetails").Activate
    'Call FormatBOM()
    
    Worksheets("FiberCabinets").Activate
    Call FormatBOM(5, 8)
    
    Worksheets("FiberFBS").Activate
    Call FormatBOM(3, 6)
    
    'Worksheets("FiberFiberAndCoaxOnly").Activate
    'Call FormatBOM()
    
    Worksheets("FiberFiberOnly").Activate
    Call FormatBOM(3, 6)
    
    'Worksheets("FiberHeadends").Activate
    'Call FormatBOM()
    
    Worksheets("FiberInternals").Activate
    Call FormatBOM(14, 6, 12)
    Dim Found As Range
    Set Found = Columns("F").Find(What:="FTTX_VN_ENTRA_SF-4X_OLT", LookIn:=xlValues, LookAt:=xlPart)
    If Not Found Is Nothing Then Found.EntireRow.Delete
    
    Worksheets("FiberNodes").Activate
    Call FormatBOM(6, 3, 5)
    Set Found = Columns("E").Find(What:="FTTX_VN_ENTRA_SF-4X_OLT", LookIn:=xlValues, LookAt:=xlPart)
    If Not Found Is Nothing Then Found.EntireRow.Delete
    
    Worksheets("FiberSegments").Activate
    Call FormatBOM(3, 1, 2)
    
    Worksheets("FiberSplices").Activate
    Call FormatBOM(5, 2, 4)
    
    Worksheets("FiberTotalSheath").Activate
    Call FormatBOM(8, 2, 4)
    
    ActiveWorkbook.Save

End Sub


Sub CreateOverallBOM()
    Dim SharkData As Worksheet
    Dim BOMs As Workbook
    Dim OvBOM As Workbook
    
    'Grab template file path from BOMs tab
    Dim pathOvBOMTemplate As String
    pathOvBOMTemplate = Range("Path_OverallBOM_Template").value
    
    'Copy the Overall BOM Template to a new file in the Downloads folder (overwrites existing files with the same name)
    Dim objNewOvBOM As Object
    Set objNewOvBOM = CreateObject("Scripting.FileSystemObject")
    Dim pathDownloads As String
    pathDownloads = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads"
    Dim pathNewOvBOM As String
    pathNewOvBOM = pathDownloads & "\" & Range("NAME_OVERALL_BOM").value & ".xlsx"
    Call objNewOvBOM.CopyFile(pathOvBOMTemplate, pathNewOvBOM, True)
    
    'Open/set all three files
    Set SharkData = ThisWorkbook.Worksheets("Data Entry")
    Set BOMs = Workbooks.Open(Range("Path_BOMs").value)
    Set OvBOM = Workbooks.Open(pathNewOvBOM)
    
     
     
    'Project Overview
    Dim OvBOMOv As Worksheet
    Set OvBOMOv = OvBOM.Worksheets("Project Overview")
    OvBOMOv.Range("C3").value = Date
    OvBOMOv.Range("C7").value = SharkData.Range("REGION").value 'Region
    OvBOMOv.Range("C8").value = SharkData.Range("MARKET").value  'Market
    OvBOMOv.Range("C9").value = SharkData.Range("SITE_NAME").value 'Project Name
    
    'Fills OLT address, or coordinates if unavailable
    If IsEmpty(SharkData.Range("OLT_ADDRESS").value) = True Then
        OvBOMOv.Range("C10") = SharkData.Range("COORDINATES").value
    Else
        OvBOMOv.Range("C10") = SharkData.Range("OLT_ADDRESS").value
    End If

    OvBOMOv.Range("C11").value = "EPON ONLY" 'Architecture
    OvBOMOv.Range("F4").value = SharkData.Range("PASSINGS").value 'Total Units
    OvBOMOv.Range("F6").value = SharkData.Range("HUB").value 'Hub Name
    OvBOMOv.Range("F7").value = SharkData.Range("CLLI").value 'CLLI
    
    'Copy data from BOM Reports
    OvBOMOv.Range("F8").value = BOMs.Worksheets("FiberQuickDetails").Range("C14").value 'Fiber Dist Mileage
    OvBOMOv.Range("F12").value = BOMs.Worksheets("FiberQuickDetails").Range("B7").value 'Total Cable Bearing Strand
    Dim CBUG As Single
    CBUG = BOMs.Worksheets("FiberQuickDetails").Range("B8").value + BOMs.Worksheets("FiberQuickDetails").Range("B9").value
    OvBOMOv.Range("F13").value = CBUG 'Total Cable Bearing UG
    OvBOMOv.Range("F14").value = Application.WorksheetFunction.Sum(BOMs.Worksheets("FiberNodes").Range("F:F")) 'Total OTEs/MSTs
    OvBOMOv.Range("F16").value = SharkData.Range("HEADEND_DIST").value 'Distance from Hub to OLT



    'EPON Optics and Materials
    'TODO: Add warning popup if any row in each tab wasn't summed
    Dim Mats As Worksheet
    Set Mats = OvBOM.Worksheets("EPON Optics and Materials")
    Dim CurSht As Worksheet
    
    'Fiber Sheath
    Set CurSht = BOMs.Worksheets("FiberTotalSheath")
    Mats.Range("F11") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_12", "*COUNT_12") * 1.13, 0) '12CT Sheath
    Mats.Range("F12") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_24", "*COUNT_24") * 1.13, 0) '24CT Sheath
    Mats.Range("F13") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_48", "*COUNT_48") * 1.13, 0) '48CT Sheath
    Mats.Range("F14") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_72", "*COUNT_72") * 1.13, 0) '72CT Sheath
    Mats.Range("F15") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_96", "*COUNT_96") * 1.13, 0) '96CT Sheath
    Mats.Range("F16") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_144", "*COUNT_144") * 1.13, 0) '144CT Sheath
    Mats.Range("F17") = Application.WorksheetFunction.RoundUp(SumBOMModels(CurSht, "D", "H", "*CT_LS_288", "*COUNT_288") * 1.13, 0) '288CT Sheath
    
    'Fiber Nodes
    Set CurSht = BOMs.Worksheets("FiberNodes")
    Mats.Range("F18") = SumBOMModels(CurSht, "E", "F", "*02_OTE") '2CT OTE
    Mats.Range("F19") = SumBOMModels(CurSht, "E", "F", "*04_OTE") '4CT OTE
    Mats.Range("F20") = SumBOMModels(CurSht, "E", "F", "*06_OTE") '6CT OTE
    Mats.Range("F21") = SumBOMModels(CurSht, "E", "F", "*08_OTE") '8CT OTE
    Mats.Range("F22") = SumBOMModels(CurSht, "E", "F", "*012_OTE") '12CT OTE
    Mats.Range("F23") = SumBOMModels(CurSht, "E", "F", "*_OTE") 'OTE Hanger (Sum of OTEs)
    
    Mats.Range("F24") = SumBOMModels(CurSht, "E", "F", "*02_MH_HMST", "*02_SMST") '2CT MST
    Mats.Range("F37") = SumBOMModels(CurSht, "E", "F", "*04_MH_HMST", "*04_NHM_SMST") '4CT MST
    'TODO: Add logic for 6 port MSTs (minimum drop in BOM is 750ft?)
    Mats.Range("F54") = SumBOMModels(CurSht, "E", "F", "*08_MH_HMST", "*08_NHM_SMST") '8CT MST
    'TODO: Add logic for 12 port MSTs (no row for it in the Overall BOM?)
    
    'OLT
    Mats.Range("F89") = 1 'Power supply (edit manually if using existing supply)
    Mats.Range("F90") = 1 'Power supply mount (edit manually if power supply is on UG pole)
    Mats.Range("F92") = 1 'OLT
    Mats.Range("F99") = 4 'Activate 4 ports every time regardless of addresses
    Mats.Range("F230") = 1 'ONU testing unit
    
    'OLT Hub Optics
    If SharkData.Range("PASSINGS") <= 64 Then Mats.Range("F101") = 1
    If SharkData.Range("PASSINGS") <= 128 And SharkData.Range("PASSINGS") > 64 Then Mats.Range("F102") = 1
    If SharkData.Range("PASSINGS") <= 192 And SharkData.Range("PASSINGS") > 128 Then Mats.Range("F105") = 1
    If SharkData.Range("PASSINGS") <= 256 And SharkData.Range("PASSINGS") > 192 Then Mats.Range("F106") = 1
    
    'Splice Enclosures
    Set CurSht = BOMs.Worksheets("FiberSplices")
    Mats.Range("F110") = SumBOMModels(CurSht, "D", "E", "*")
    Mats.Range("F113") = SumBOMModels(CurSht, "D", "E", "*") * 2
    '^Technically you should manually count how many 48-fiber kits you'll need for all cans
    
    'DWDM and Splitters
    Dim Rng As Range
    Dim strSearch As String
    strSearch = SharkData.Range("CHANNEL").value
    Set Rng = Mats.Range("D176:D185").Find(strSearch, , xlValues, xlPart) 'Find DWDM
    Rng.Offset(0, 2).value = 2 'Set quantity to 2 DWDMs
    
    Set CurSht = BOMs.Worksheets("FiberInternals")
    Mats.Range("F239") = SumBOMModels(CurSht, "L", "N", "*1X2_SPL")
    Mats.Range("F243") = SumBOMModels(CurSht, "L", "N", "*1X32_SPL")
    Mats.Range("F244") = SumBOMModels(CurSht, "L", "N", "*1X64_SPL")
    
    For Each c In Mats.Range("F3:F300")
        If c.value = 0 Then c.ClearContents
    Next c
    
    OvBOM.Save
    
End Sub

Public Function SumBOMModels(BOMTab As Worksheet, SearchCol As String, CountCol As String, SearchKey As String, Optional Key2 As String = "NO SEARCH", Optional Key3 As String = "NO SEARCH") As Variant
    
    Dim Sum As Variant
    Sum = Application.WorksheetFunction.SumIfs(BOMTab.Range(CountCol & ":" & CountCol), BOMTab.Range(SearchCol & ":" & SearchCol), SearchKey, BOMTab.Range(SearchCol & ":" & SearchCol), "<>*TAIL*")
    Sum = Sum + Application.WorksheetFunction.SumIfs(BOMTab.Range(CountCol & ":" & CountCol), BOMTab.Range(SearchCol & ":" & SearchCol), Key2, BOMTab.Range(SearchCol & ":" & SearchCol), "<>*TAIL*")
    Sum = Sum + Application.WorksheetFunction.SumIfs(BOMTab.Range(CountCol & ":" & CountCol), BOMTab.Range(SearchCol & ":" & SearchCol), Key3, BOMTab.Range(SearchCol & ":" & SearchCol), "<>*TAIL*")
    SumBOMModels = Sum

End Function

