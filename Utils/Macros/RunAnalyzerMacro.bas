Attribute VB_Name = "Module2"
Dim MATLAB As Object
  Sub RunAnalyzer()
   'Create the Matlab Object
    Set MATLAB = CreateObject("Matlab.Application")
    Call MATLAB.Execute("Analyzer([], 'filename', '" & ActiveCell.Value & "' )")
  End Sub
