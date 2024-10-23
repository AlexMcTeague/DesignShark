Attribute VB_Name = "FileCreation"
Sub PackTemplate()
    'SOURCE: https://exceloffthegrid.com/vba-to-hide-all-sheets-except-one/

    'Create a variable to hold worksheets
    Dim ws As Worksheet

    'Create a variable to hold the worksheet name to keep
    Dim wsKeepName As String

    'Store the name of the sheet to keep
    wsKeepName = "Shark Controller"

    'Loop through each worksheet in the workbook
    For Each ws In ActiveWorkbook.Worksheets

        'If the ws in the loop is the one you want to keep then
        If ws.Name = wsKeepName Then

            'Make the worksheet visible
            ws.Visible = xlSheetVisible
        Else
            'Make all other sheets invisible
            ws.Visible = xlSheetVeryHidden
        End If

    Next ws

End Sub

Sub UnpackTemplate()

    Dim ws As Worksheet

    For Each ws In ActiveWorkbook.Worksheets

        ws.Visible = xlSheetVisible

    Next ws

End Sub

Sub CreateShark()

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
    
    
    Dim InputOLT As String
    InputOLT = InputBox("Please provide the name of your OLT", "Input OLT Name", "OLTNAME")
            
    ThisWorkbook.SaveCopyAs myFolder & "DesignShark_RDOF_" & InputOLT & ".xlsm"
    Workbooks.Open (myFolder & "DesignShark_RDOF_" & InputOLT & ".xlsm")
    Call UnpackTemplate
    ActiveWorkbook.Worksheets("Shark Controller").Visible = xlSheetVeryHidden
    ActiveWorkbook.Worksheets("Data Entry").Range("OLT") = InputOLT
    ThisWorkbook.Close

End Sub

Sub CreateSharkFolder()

    'SelectFolder
    'SOURCE: www.TheSpreadsheetGuru.com/the-code-vault
    Dim FldrPicker As FileDialog
    Dim myFolder As String
    
    'Have User Select Folder to Save to with Dialog Box
    Set FldrPicker = Application.FileDialog(msoFileDialogFolderPicker)
    
    With FldrPicker
        .title = "Select Your Project Workspace"
        .allowMultiSelect = False
        If .Show <> -1 Then Exit Sub 'Check if user clicked cancel button
        myFolder = .SelectedItems(1) & "\"
    End With
    'End SelectFolder
    
    
    Dim InputOLT As String
    InputOLT = InputBox("Please provide the name of your OLT", "Input OLT Name", "OLTNAME")
            
    
    CreateFolderPath (myFolder & InputOLT & "\Deliverables\Completed")
    CreateFolderPath (myFolder & InputOLT & "\KMZs")
    CreateFolderPath (myFolder & InputOLT & "\Reports\BOMs")
    
    ThisWorkbook.SaveCopyAs myFolder & InputOLT & "\DesignShark_RDOF_" & InputOLT & ".xlsm"
    Workbooks.Open (myFolder & InputOLT & "\DesignShark_RDOF_" & InputOLT & ".xlsm")
    Call UnpackTemplate
    ActiveWorkbook.Worksheets("Shark Controller").Visible = xlSheetVeryHidden
    ActiveWorkbook.Worksheets("Data Entry").Range("OLT") = InputOLT
    ThisWorkbook.Close

End Sub

Sub SayPath()
    Dim FldrPicker As FileDialog
    Dim myFolder As String
    
    'Have User Select Folder to Save to with Dialog Box
    Set FldrPicker = Application.FileDialog(msoFileDialogFolderPicker)
    
    With FldrPicker
        .title = "Select Your Project Workspace"
        .allowMultiSelect = False
        If .Show <> -1 Then Exit Sub 'Check if user clicked cancel button
        myFolder = .SelectedItems(1) & "\"
    End With
    
    MsgBox (myFolder)
    'MsgBox (Application.ActiveWorkbook.Path)
End Sub
