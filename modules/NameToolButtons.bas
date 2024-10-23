Attribute VB_Name = "NameToolButtons"
Sub AddEquip(EquipType As String)

    Worksheets("Equipment Naming").Activate
    
    Dim objCP As Object
    Set objCP = CreateObject("HtmlFile")
    
    Dim EquipPrefix As String
    Dim EquipColumn As Range
    Dim EquipTag As Variant
    Dim NextEquipCount As Variant
    Dim NextEquipName As String
    Dim SheathName As String

    If IsError(Range("PREFIX").value) Then
        MsgBox "Equipment prefix not found;" & vbNewLine & "Please fill out the OLT Name and Market fields in the Data Entry tab"
        Exit Sub
    Else
        EquipPrefix = Range("PREFIX").value
    End If
    
    If EquipType = "DistCan" Then
        Set EquipColumn = Range("B20")
        EquipTag = "D"
    ElseIf EquipType = "SplitCan" Then
        Set EquipColumn = Range("B20")
        EquipTag = "S"
    ElseIf EquipType = "OTE" Then
        Set EquipColumn = Range("C20")
        EquipTag = "0"
    ElseIf EquipType = "MST" Then
        Set EquipColumn = Range("C20")
        EquipTag = "0"
    Else
        Exit Sub
    End If
    
    If IsEmpty(EquipColumn.Offset(1, 0).value) Then
        NextEquipName = EquipPrefix & EquipTag & "001"
        EquipColumn.Offset(1, 0).value = NextEquipName
    Else
        NextEquipCount = Range(EquipColumn.Offset(1, 0), EquipColumn.End(xlDown)).Count + 1
        NextEquipName = EquipPrefix & EquipTag & Format(NextEquipCount, "000")
        EquipColumn.End(xlDown).Offset(1, 0).value = NextEquipName
    End If

    If IsEmpty(Range("TO_EQUIP").value) Then
        Range("FROM_EQUIP").value = Range("OLT").value
    Else
        Range("FROM_EQUIP").value = Range("TO_EQUIP").value
    End If
    Range("TO_EQUIP").value = NextEquipName
    
    If EquipType = "MST" Then
        SheathName = Format(Range("MST_PORT_CT").value, "000") & "CT_" & Range("TO_EQUIP").value
    Else
        If Range("FROM_EQUIP").value = Range("OLT").value Then
            SheathName = "12CT " & Range("FROM_EQUIP").value & " TO " & Range("TO_EQUIP").value
        Else
            SheathName = Range("SHEATH_CT").value & "CT " & Range("FROM_EQUIP").value & " TO " & Range("TO_EQUIP").value
        End If
    End If
    Range("SHEATH_NAME") = SheathName
    objCP.ParentWindow.ClipboardData.SetData "text", SheathName

End Sub

Sub AddDistCan()
    AddEquip ("DistCan")
End Sub

Sub AddSplitCan()
    AddEquip ("SplitCan")
End Sub

Sub AddOTE()
    AddEquip ("OTE")
End Sub

Sub AddMST()
    AddEquip ("MST")
End Sub

Sub Button19_Click()
    Range("TO_EQUIP").value = Range("FROM_EQUIP").value
End Sub

Sub Button22_Click()
    Range("FROM_EQUIP").value = Range("B21:B300").Find(Range("FROM_EQUIP").value).Offset(1, 0).value
    Range("TO_EQUIP").value = Range("FROM_EQUIP").value
End Sub

Sub Button47_Click()
    Dim SearchResult As Range
    
    Set SearchResult = Range("B21:C300").Find(Range("TO_EQUIP").value)

    If SearchResult Is Nothing Then
        Set SearchResult = Range("C21:C300").Find(Range("TO_EQUIP").value)
        
        If SearchResult Is Nothing Then
            MsgBox "Error;" & vbNewLine & "Could not find latest equipment"
            Exit Sub
        End If
    End If
    
    If IsEmpty(SearchResult.Offset(1, 0).value) = False Then
        MsgBox "Can't undo;" & vbNewLine & "The most recent equipment placed isn't the last in its column"
        Exit Sub
    Else
        SearchResult.ClearContents
        Range("TO_EQUIP").value = Range("FROM_EQUIP").value
    End If
End Sub

