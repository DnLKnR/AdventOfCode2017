Imports System.IO
Imports System.Runtime.CompilerServices

Module Day19
    Sub Main(args As String())
        Dim text As String = File.ReadAllText("input.txt")

        Dim maze As Maze = New Maze(text)
        Dim result = maze.Traverse()
        Console.WriteLine(String.Format("Letters (In Order): {0}", result.Word))
        Console.WriteLine(String.Format("Total Steps: {0}", result.Steps))
        Console.WriteLine()
        Console.WriteLine(String.Format("Press Any Key To Continue..."))
        Console.ReadKey(True)
    End Sub
End Module

Public Class Maze
    Private Matrix As List(Of List(Of String))
    Private Start As (X As Integer, Y As Integer)
    Private Word As String = String.Empty
    Private Steps As Integer = 0

    Public Sub New(ByVal Input As String)
        Matrix = New List(Of List(Of String))

        Dim lines As String() = Input.Split(New String() {Environment.NewLine}, StringSplitOptions.None)

        For Each line As String In lines
            Matrix.Add(line.ToStringList())
        Next

        Dim firstRow = Matrix.First()
        Dim length = firstRow.Count()
        For index As Integer = 0 To length Step 1
            If Not String.IsNullOrWhiteSpace(firstRow.Item(index)) Then
                Start = (0, index)
                Exit For
            End If
        Next

    End Sub

    Public Function Traverse() As (Word As String, Steps As Integer)
        Word = ""
        Steps = 0

        Dim p As (X As Integer, Y As Integer, D As Direction) = (Start.X, Start.Y, Direction.DOWN)
        While Matrix.IsValid(p)
            Steps += 1
            Dim value = Matrix.Item(p.X).Item(p.Y)
            If value.IsLetter() Then
                Word += value
            End If
            p = GetNext(p)
        End While
        Return (Word, Steps)
    End Function

    Public Function GetNext(ByVal position As (X As Integer, Y As Integer, D As Direction)) As (X As Integer, Y As Integer, D As Direction)
        Dim value = Matrix.Item(position.X).Item(position.Y)
        If value.IsCorner() Then
            Dim direction = Matrix.ChangeDirection(position)
            Return position.Move(direction)
        End If
        Return position.Move(position.D)
    End Function
End Class


Public Enum Direction As Byte
    UP
    DOWN
    LEFT
    RIGHT
End Enum

Module Extensions
    Private directionMap As Dictionary(Of Direction, String) = New Dictionary(Of Direction, String) From {{Direction.UP, "|"},
                                                                                                          {Direction.DOWN, "|"},
                                                                                                          {Direction.LEFT, "-"},
                                                                                                          {Direction.RIGHT, "-"}}

    <Extension()>
    Public Function Maintain(ByVal value As String, ByVal aDirection As Direction) As Boolean
        Return directionMap.Item(aDirection) = value
    End Function

    <Extension()>
    Public Function ToStringList(ByVal value As String) As List(Of String)
        Return value.Select(Function(character) character.ToString()).ToList()
    End Function

    <Extension()>
    Public Function IsCorner(ByVal value As String) As Boolean
        Return value = "+"
    End Function

    <Extension()>
    Public Function IsLetter(ByVal value As String) As Boolean
        Return Char.IsLetter(value, 0)
    End Function

    <Extension()>
    Public Function Move(ByVal position As (X As Integer, Y As Integer, D As Direction), ByVal aDirection As Direction) As (X As Integer, Y As Integer, D As Direction)
        Select Case aDirection
            Case Direction.UP
                Return (position.X - 1, position.Y, aDirection)
            Case Direction.DOWN
                Return (position.X + 1, position.Y, aDirection)
            Case Direction.LEFT
                Return (position.X, position.Y - 1, aDirection)
            Case Direction.RIGHT
                Return (position.X, position.Y + 1, aDirection)
        End Select
    End Function

    <Extension()>
    Public Function IsValid(ByVal matrix As List(Of List(Of String)), ByVal position As (X As Integer, Y As Integer, D As Direction)) As Boolean
        Dim height = matrix.Count()
        If position.X >= height Or position.X < 0 Then
            Return False
        End If
        Dim width = matrix.Item(position.X).Count()
        If position.Y >= width Or position.Y < 0 Then
            Return False
        End If

        Dim value As String = matrix.Item(position.X).Item(position.Y)
        Return Not String.IsNullOrWhiteSpace(value)
    End Function

    <Extension()>
    Public Function IsVertical(ByVal aDirection As Direction) As Boolean
        Return {Direction.UP, Direction.DOWN}.Contains(aDirection)
    End Function

    <Extension()>
    Public Function ChangeDirection(ByVal matrix As List(Of List(Of String)), ByVal position As (X As Integer, Y As Integer, D As Direction)) As Direction
        If position.D.IsVertical() Then
            Dim left = position.Move(Direction.LEFT)
            If matrix.IsValid(left) Then
                Return Direction.LEFT
            Else
                Return Direction.RIGHT
            End If
        End If

        Dim down = position.Move(Direction.DOWN)
        If matrix.IsValid(down) Then
            Return Direction.DOWN
        End If

        Return Direction.UP
    End Function
End Module
