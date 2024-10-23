Attribute VB_Name = "GeneralUseMacros"
Sub SortTabs()
    
    Application.ScreenUpdating = False
    
    Dim ShCount As Integer, i As Integer, j As Integer
    ShCount = Sheets.Count

    For i = 1 To ShCount - 1
        For j = i + 1 To ShCount
            If UCase(Sheets(j).Name) < UCase(Sheets(i).Name) Then
                Sheets(j).Move Before:=Sheets(i)
            End If
        Next j
    Next i

    Application.ScreenUpdating = True

End Sub

Sub UnHideAll()
'Unhides all sheets, including "very hidden" sheets

    For Each ws In Worksheets
        ws.Visible = xlSheetVisible
    Next
    
End Sub

Sub ResumeUpdating()
'Use if a macro breaks in the middle of operation, before it has a chance to set ScreenUpdating back to True
    
    Application.ScreenUpdating = True
    
End Sub

Sub Button_ClipboardCopyLeft()

    Dim objCP As Object
    Set objCP = CreateObject("HtmlFile")
    
    Dim cellTarget As Range
    Set cellTarget = ActiveSheet.Buttons(Application.Caller).TopLeftCell.Offset(0, -1)
    
    If IsEmpty(cellTarget) Then
        objCP.ParentWindow.ClipboardData.SetData "text", "null"
    Else
        objCP.ParentWindow.ClipboardData.SetData "text", cellTarget.value
    End If
    
End Sub

Sub Button_ClipboardCopyRight()

    Dim objCP As Object
    Set objCP = CreateObject("HtmlFile")
    
    Dim cellTarget As Range
    Set cellTarget = ActiveSheet.Buttons(Application.Caller).TopLeftCell.Offset(0, 1)
    
    If IsEmpty(cellTarget) Then
        objCP.ParentWindow.ClipboardData.SetData "text", "null"
    Else
        objCP.ParentWindow.ClipboardData.SetData "text", cellTarget.value
    End If
    
End Sub

Function LastRowColumn(sht As Worksheet, RowColumn As String) As Integer
'SOURCE: https://www.thespreadsheetguru.com/blog/last-row-column-vba#LastRowColumnFunction
'PURPOSE: Function To Return the Last Row Or Column Number In the Active Spreadsheet
'INPUT: "R" or "C" to determine which direction to search

    Select Case LCase(Left(RowColumn, 1)) 'If they put in 'row' or column instead of 'r' or 'c'.
        Case "c"
            LastRowColumn = sht.Cells.Find("*", LookIn:=xlFormulas, SearchOrder:=xlByColumns, _
            SearchDirection:=xlPrevious).Column
        Case "r"
            LastRowColumn = sht.Cells.Find("*", LookIn:=xlFormulas, SearchOrder:=xlByRows, _
            SearchDirection:=xlPrevious).Row
        Case Else
            LastRowColumn = 1
    End Select
    
End Function

Sub ShowPrintArea()
    MsgBox ActiveSheet.PageSetup.PrintArea
End Sub

Sub FindReplaceAllInRange(Rng As Range, fnd As Variant, rplc As Variant)

    Rng.Cells.Replace What:=fnd, Replacement:=rplc, _
    LookAt:=xlWhole, SearchOrder:=xlByRows, MatchCase:=False, _
    SearchFormat:=False, ReplaceFormat:=False

End Sub


Sub Button_SelectPathRight()
    Dim cellTarget As Range
    Set cellTarget = ActiveSheet.Buttons(Application.Caller).TopLeftCell.Offset(0, 1)
    
    cellTarget.value = Application.GetOpenFilename(FileFilter:="Excel Files (*.*), *.*", title:="Select A File")
End Sub

Public Function ConvertFiberToNum(Fiber As String, Optional buffer As String = "NONE") As Integer
    'Finds the "fiber number" from the two-letter abbreviation. If a buffer is also given, finds the "absolute" number

    Dim arrFibers() As String
    arrFibers = Split("BL,OR,GR,BR,SL,WH,RD,BK,YE,VI,PI,AQ", ",")
    
    Dim FiberNum As Integer
    Dim BufferNum As Integer
    
    For i = 1 To 12
        If Fiber = arrFibers(i - 1) Then
            FiberNum = i
        End If
    Next i
    
    If Not buffer = "NONE" Then
        BufferNum = ConvertFiberToNum(buffer)
        FiberNum = ((BufferNum - 1) * 12) + FiberNum
    End If

    ConvertFiberToNum = FiberNum
End Function

Function Button_AdjacentCell(Optional dir As String = "R") As Range

    Dim cellTarget As Range
    Dim result As Range
    
    Set cellTarget = ActiveSheet.Buttons(Application.Caller).TopLeftCell
    
    Select Case LCase(Left(dir, 1))
        Case "l"
            Set result = cellTarget.Offset(0, -1)
        Case "r"
            Set result = cellTarget.Offset(0, 1)
        Case "u"
            Set result = cellTarget.Offset(-1, 0)
        Case "d"
            Set result = cellTarget.Offset(1, 0)
        Case Else
            MsgBox ("Unrecognized button argument. Ask the maintainer of this spreadsheet for assistance.")
            Set result = cellTarget.Offset(0, 1)
    End Select
    
    Set Button_AdjacentCell = result

End Function

Sub Button_CopyToClipboard(Optional dir As String = "R")

    Dim objCP As Object
    Dim cellTarget As Range
    
    Set objCP = CreateObject("HtmlFile")
    Set cellTarget = Button_AdjacentCell(dir)
    
    objCP.ParentWindow.ClipboardData.SetData "text", CStr(cellTarget.value)
    
End Sub

Public Function Trunc(ByVal value As Double, ByVal num As Integer) As Double
  Trunc = Int(value * (10 ^ num)) / (10 ^ num)
End Function


Sub CreateFolderPath(folderPath As String)
    'Create all the folders in a folder path
    'SOURCE: https://exceloffthegrid.com/vba-code-create-delete-manage-folders/
    Dim individualFolders() As String
    Dim tempFolderPath As String
    Dim arrayElement As Variant

    'Split the folder path into individual folder names
    individualFolders = Split(folderPath, "\")

    'Loop though each individual folder name
    For Each arrayElement In individualFolders

        'Build string of folder path
        tempFolderPath = tempFolderPath & arrayElement & "\"
 
        'If folder does not exist, then create it
        If dir(tempFolderPath, vbDirectory) = "" Then
 
            MkDir tempFolderPath
 
        End If
 
    Next arrayElement
    'End CreateFolders
End Sub
Public Function OpenPath(cell As Range) As Workbook
    Dim wb As Workbook

    ' If there isn't a path available, end all macros and inform the user
    path = cell.value
    If IsEmpty(cell) Or path = "" Or path = False Then
        ThisWorkbook.Worksheets("File Imports").Activate
        cell.Select
        MsgBox (cell.Name.Name & " is not set. Please select a file, then try again.")
        End
    Else
        ' If the file can't be found, end all macros and inform the user
        If dir(path) = "" Then
            ThisWorkbook.Worksheets("File Imports").Activate
            cell.Select
            MsgBox ("File doesn't exist at " & path & ". Please select a different file, then try again.")
            End
        End If
        ' If a file with an identical name (but a different path) is already open, end all macros and inform the user
        fileName = Right(path, Len(path) - InStrRev(path, "\"))
        For Each wb In Application.Workbooks()
            If wb.Name = fileName Then
                If GetLocalPath(wb.FullName) <> path Then
                    ThisWorkbook.Sheets("File Imports").Activate
                    cell.Select
                    MsgBox ("Excel can't open two workbooks with the same name at the same time." & vbNewLine & "Select a different file, or close the other workbook named " & fileName)
                    End
                End If
            End If
        Next
        
        Set wb = Workbooks.Open(path, UpdateLinks:=0)
        Set OpenPath = wb
    End If
End Function

Public Sub TrimSheet(ws As Worksheet)
    For Each cell In ws.UsedRange.SpecialCells(xlCellTypeConstants)
        cell = Application.Clean(WorksheetFunction.Trim(cell))
    Next cell
End Sub
