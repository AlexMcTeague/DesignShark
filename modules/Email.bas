Attribute VB_Name = "Email"
Sub Draft_Reject_Email()
    Dim Hyperlink As String
    Hyperlink = ActiveSheet.Range("Email_Reject_Hyperlink").value
    ActiveWorkbook.FollowHyperlink (Hyperlink)
End Sub

Sub Draft_Details_Email()
    Dim Hyperlink As String
    Hyperlink = ActiveSheet.Range("Email_Details_Hyperlink").value
    ActiveWorkbook.FollowHyperlink (Hyperlink)
End Sub

