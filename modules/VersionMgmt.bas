Attribute VB_Name = "VersionMgmt"
Sub DeleteModule(ModuleToRemove As String)
'SOURCE: http://www.cpearson.com/excel/vbe.aspx
    Dim VBProj As VBIDE.VBProject
    Dim VBComp As VBIDE.VBComponent
    
    Set VBProj = ActiveWorkbook.VBProject
    Set VBComp = VBProj.VBComponents(ModuleToRemove)
    VBProj.VBComponents.Remove VBComp
End Sub

Sub CreateNewVersion()
    Dim KeepSheets(50) As String
    Dim KeepModules(50) As String
    Dim IndexSheets As Integer
    Dim IndexModules As Integer
    IndexSheets = 0
    IndexModules = 0
    
    KeepSheets(IndexSheets) = "Setup"
    IndexSheets = IndexSheets + 1
    KeepSheets(IndexSheets) = "How-To"
    IndexSheets = IndexSheets + 1
    KeepSheets(IndexSheets) = "Data Entry"
    IndexSheets = IndexSheets + 1
    KeepSheets(IndexSheets) = "ITU CHANNELS"
    IndexSheets = IndexSheets + 1
    KeepSheets(IndexSheets) = "Market Abbreviations"
    IndexSheets = IndexSheets + 1
    KeepSheets(IndexSheets) = "Design Shark Changelog"
    IndexSheets = IndexSheets + 1
    KeepSheets(IndexSheets) = "Credits"
    IndexSheets = IndexSheets + 1
    KeepModules(IndexModules) = "GeneralUseMacros"
    IndexModules = IndexModules + 1
    KeepModules(IndexModules) = "LibFileTools"
    IndexModules = IndexModules + 1
    
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("FILE_CREATION").value = 1 Then
        KeepSheets(IndexSheets) = "Shark Controller"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "FileCreation"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("NAMING_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "Equipment Naming"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "NameToolButtons"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("MOP_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "MOP"
        IndexSheets = IndexSheets + 1
        KeepSheets(IndexSheets) = "Splice Tab Template"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "MOP"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("BOM_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "BOMs"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "BOMs"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("HAF_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "HAF"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "HAF"
        IndexModules = IndexModules + 1
        KeepModules(IndexModules) = "CBG"
        IndexModules = IndexModules + 1
        KeepModules(IndexModules) = "PointInPolygon"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("QC_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "QC"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "QC"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("WEB_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "MQMS-Prism"
        IndexSheets = IndexSheets + 1
        KeepSheets(IndexSheets) = "Node Portal"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "MQMS_Prism"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("EMAIL_TOOL").value = 1 Then
        KeepSheets(IndexSheets) = "Email"
        IndexSheets = IndexSheets + 1
        KeepModules(IndexModules) = "Email"
        IndexModules = IndexModules + 1
    End If
    If ThisWorkbook.Sheets("Version Management").CheckBoxes("EXPERIMENTAL").value = 1 Then
        KeepSheets(IndexSheets) = "VBA DATA"
        IndexSheets = IndexSheets + 1
        KeepSheets(IndexSheets) = "OLT Power"
        IndexSheets = IndexSheets + 1
    End If
    
    
    'SelectFolder
    'SOURCE: www.TheSpreadsheetGuru.com/the-code-vault
    Dim FldrPicker As FileDialog
    Dim myFolder As String
    
    'Have User Select Folder to Save to with Dialog Box
    Set FldrPicker = Application.FileDialog(msoFileDialogFolderPicker)
    
    With FldrPicker
        .title = "Select Folder"
        .allowMultiSelect = False
        If .Show <> -1 Then Exit Sub 'Check if user clicked cancel button
        myFolder = .SelectedItems(1) & "\"
    End With
    'End SelectFolder
   
    Dim InputVersion As String
    InputVersion = InputBox("Please provide the name of the new version", "Input Version Name", "NEW_VERSION")
    
    Dim newName As String
    newName = myFolder & "DesignShark_RDOF_" & InputVersion & ".xlsm"
    ThisWorkbook.SaveCopyAs newName
    Workbooks.Open (myFolder & "DesignShark_RDOF_" & InputVersion & ".xlsm")
    
    
    Dim filterVar As Variant
    Dim VBComp As Variant
  
    Application.DisplayAlerts = False
    For Each ws In ActiveWorkbook.Worksheets
        filterVar = Filter(KeepSheets, ws.Name)
        If UBound(filterVar) < 0 Then ws.Delete
    Next ws
    Application.DisplayAlerts = True
    
    For Each VBComp In ActiveWorkbook.VBProject.VBComponents
        If VBComp.Type = 1 Then
            filterVar = Filter(KeepModules, VBComp.CodeModule.Name)
            If UBound(filterVar) < 0 Then ActiveWorkbook.VBProject.VBComponents.Remove ActiveWorkbook.VBProject.VBComponents(VBComp.CodeModule.Name)
        End If
    Next VBComp
    
    Call DeleteBrokenNamedRanges
    
    ActiveWorkbook.Save
        
End Sub

Sub DeleteBrokenNamedRanges()
Dim NR As Name
Dim numberDeleted As Variant

numberDeleted = 0
For Each NR In ActiveWorkbook.Names
    If InStr(NR.value, "#REF!") > 0 Then
        NR.Delete
        numberDeleted = numberDeleted + 1
    End If
Next

MsgBox ("A total of " & numberDeleted & " broken Named Ranges deleted!")

End Sub
