Attribute VB_Name = "MQMS_Prism"
Sub Import_BOM_For_Prism()

    Dim BOMs As Workbook
    Set BOMs = Workbooks.Open(Range("Path_BOMs").value)
    
    ThisWorkbook.Worksheets("MQMS-Prism").Range("MQMS_AerialStrand").value = BOMs.Worksheets("StrandQuickDetails").Range("B7").value
    ThisWorkbook.Worksheets("MQMS-Prism").Range("MQMS_UGStrand").value = BOMs.Worksheets("StrandQuickDetails").Range("B8").value + BOMs.Worksheets("StrandQuickDetails").Range("B9").value
    ThisWorkbook.Worksheets("MQMS-Prism").Range("MQMS_AerialFiber").value = BOMs.Worksheets("FiberQuickDetails").Range("B7").value
    ThisWorkbook.Worksheets("MQMS-Prism").Range("MQMS_UGFiber").value = BOMs.Worksheets("FiberQuickDetails").Range("B8").value + BOMs.Worksheets("FiberQuickDetails").Range("B9").value
    ThisWorkbook.Worksheets("MQMS-Prism").Range("MQMS_AerialPassings").value = BOMs.Worksheets("StrandQuickDetails").Range("B18").value + BOMs.Worksheets("StrandQuickDetails").Range("C18").value + BOMs.Worksheets("StrandQuickDetails").Range("D18").value
    ThisWorkbook.Worksheets("MQMS-Prism").Range("MQMS_UGPassings").value = BOMs.Worksheets("StrandQuickDetails").Range("B19").value + BOMs.Worksheets("StrandQuickDetails").Range("C19").value + BOMs.Worksheets("StrandQuickDetails").Range("D19").value
    

    
End Sub

Sub Import_MOP_For_Prism()
    Dim pathMOP As String
    Dim MOP As Workbook
    pathMOP = Application.GetOpenFilename(FileFilter:="Excel Files (*.*), *.*", title:="Select A File")
    Set MOP = Workbooks.Open(pathMOP)

    Dim FoundCell As Range
    Dim HEROW As Integer
    Set FoundCell = MOP.Worksheets("MOP").Range("B:B").Find(What:="HE Termination")
    If Not FoundCell Is Nothing Then
        HEROW = FoundCell.Offset(1, 0).Row
    End If

    ThisWorkbook.Worksheets("MQMS-Prism").Range("Headend_Sheath").value = MOP.Worksheets("MOP").Range("D" & HEROW).value
    Dim FiberNum As Integer
    FiberNum = MOP.Worksheets("MOP").Range("F" & HEROW).value
    ThisWorkbook.Worksheets("MQMS-Prism").Range("Headend_FiberAssigned").value = MOP.Worksheets("MOP").Range("E" & HEROW).value & "/" & FiberNum & "-" & FiberNum + 1
End Sub

Sub Value_If_Exists(ImportRange As Range)
'WIP to handle imports with incomplete BOMs or MOPs

    Dim Test As Range
    On Error Resume Next
    Set Test = ActiveSheet.Range(R)
    RangeExists = Err.Number = 0
    
End Sub


