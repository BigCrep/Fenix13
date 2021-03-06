VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsGraphicalInventory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'*****************************************************
'Graphical inventory for ORE 0.4.1
'Designed and implemented by Juan Mart�n Sotuyo Dodero (Maraxus)
'juansotuyo@hotmail.com
'*****************************************************

'**************************************************************************
'This program is free software; you can redistribute it and/or modify
'it under the terms of the GNU General Public License as published by
'the Free Software Foundation; either version 2 of the License, or
'(at your option) any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'Affero General Public License for more details.
'
'You should have received a copy of the GNU General Public License
'along with this program; if not, write to the Free Software
'Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'**************************************************************************

Option Explicit

Private Type TYPE_INVENTORY_POSITION
        X   As Integer
        Y   As Integer
        W   As Integer
        H   As Integer
End Type

Private Position                   As TYPE_INVENTORY_POSITION

Private InventoryOffset            As Long             'Number of lines we scrolled down from topmost
Private InvSelectedItem            As Long             'Currently selected item
Private MouseDownSelectedItem      As Long
Private InventoryTickCount         As Long

Private ownTilePixelWidth          As Integer
Private ownTilePixelHeight         As Integer
Private startdX                    As Integer
Private startdY                    As Integer

Dim TempItem                       As Long

Private ShowValue                  As Boolean
Private ImgContainer               As Boolean

Private Inventory()                As Inventory    'User's inventory

Public Sub SelectGold()
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Sets the gold as the currently selected item
        '***************************************************

        Dim prevSelectedItem As Long
    
        'Store preivously selected item
        prevSelectedItem = InvSelectedItem
    
        'Select the gold
        InvSelectedItem = FLAGORO
    
        'Redraw old item to deselect it

        If prevSelectedItem <> FLAGORO Then
                Call DrawInventory
        End If

End Sub

Public Sub DeselectItem()
        '***************************************************
        'Author: ZaMa
        'Last Modify Date: 30/11/2009
        'Deselect the currently selected item
        '***************************************************

        If InvSelectedItem = 0 Then Exit Sub
    
        Dim ClearSlot As Byte
    
        ClearSlot = InvSelectedItem
    
        'Select nothing
        InvSelectedItem = 0
    
        'Redraw old item to deselect it
    
        Call DrawInventory
End Sub

Public Sub ChangeSlotItemAmount(ByVal slot As Byte, ByVal Amount As Long)
        '***************************************************
        'Author: ZaMa
        'Created Date: 30/11/2009
        'Last Modify Date: 09/12/2009 (Budi)
        'Change the amount of the required item, and update the slot.
        '***************************************************
    
        Inventory(slot).Amount = Amount
    
        'Update Amount
        Call DrawInventory
End Sub

Public Property Get SelectedItem() As Long
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the selected item index
        '***************************************************
        SelectedItem = InvSelectedItem
End Property

Public Property Get MaxHit(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the max hit of the selected item
        '***************************************************
        MaxHit = Inventory(slot).MaxHit
End Property

Public Property Get MinHit(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the min hit of the selected item
        '***************************************************
        MinHit = Inventory(slot).MinHit
End Property

Public Property Get MaxDef(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the defense of the selected item
        '***************************************************
        MaxDef = Inventory(slot).MaxDef
End Property

Public Property Get MinDef(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Budi
        'Last Modify Date: 02/1209
        'Retrieves the defense of the selected item
        '***************************************************
        MinDef = Inventory(slot).MinDef
End Property

Public Property Get GrhIndex(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the grh index of the selected item
        '***************************************************

        If slot = 0 Then Exit Sub
        GrhIndex = Inventory(slot).GrhIndex
End Property

Public Property Get Valor(ByVal slot As Byte) As Single
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the value of the selected item
        '***************************************************
        Valor = Inventory(slot).Valor
End Property

Public Property Get Amount(ByVal slot As Byte) As Long
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the selected item's amount
        '***************************************************

        If slot = FLAGORO Then
                Amount = UserGLD
        ElseIf slot >= LBound(Inventory) And slot <= UBound(Inventory) Then
                Amount = Inventory(slot).Amount
        End If
          
End Property

Public Property Get OBJIndex(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the selected item's object index
        '***************************************************
        OBJIndex = Inventory(slot).OBJIndex
End Property

Public Property Get OBJType(ByVal slot As Byte) As Integer
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the selected item's object type
        '***************************************************
        OBJType = Inventory(slot).OBJType
End Property

Public Property Get ItemName(ByVal slot As Byte) As String
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves the selected item's name
        '***************************************************
        ItemName = Inventory(slot).Name
End Property

Public Property Get Equipped(ByVal slot As Byte) As Boolean
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Retrieves True if the item at the given pos is eqiupped
        '***************************************************
        Equipped = Inventory(slot).Equipped

End Property

Public Property Get MaxObjs() As Byte
        '***************************************************
        'Author: Torres Patricio (Pato)
        'Last Modify Date: 09/16/09
        'Retrieves the capacity of the Inventory
        '***************************************************
        MaxObjs = UBound(Inventory)
End Property

Public Sub SetMaxObjs(ByVal MaxObjs As Byte)
        '***************************************************
        'Author: Torres Patricio (Pato)
        'Last Modify Date: 09/16/09
        'Set the capacity of the Inventary
        '***************************************************

        If UBound(Inventory) = MaxObjs Then Exit Sub
    
        ReDim Preserve Inventory(1 To MaxObjs) As Inventory
End Sub

Public Sub SetItem(ByVal slot As Byte, _
                   ByVal eOBJIndex As Integer, _
                   ByVal eAmount As Long, _
                   ByVal eEquipped As Byte, _
                   ByVal eGrhIndex As Integer, _
                   ByVal eObjType As Integer, _
                   ByVal eMaxHit As Integer, _
                   ByVal eMinHit As Integer, _
                   ByVal MaxDef As Integer, _
                   ByVal MinDef As Integer, _
                   ByVal eValor As Single, _
                   ByVal eName As String)
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 12/04/06
        'Sets all data for a given inventory slot
        '***************************************************
        
        If slot < 1 Or slot > UBound(Inventory) Then Exit Sub
    
        With Inventory(slot)
                .Amount = eAmount
                .MaxDef = MaxDef
                .MinDef = MinDef
                .Equipped = eEquipped
                .GrhIndex = eGrhIndex
                .MaxHit = eMaxHit
                .MinHit = eMinHit
                .Name = eName
                .OBJIndex = eOBJIndex
                .OBJType = eObjType
                .Valor = eValor
        End With
    
        'If InventoryWindow.Visible = False Then InventoryWindow.Visible = True
    
        'Render inventory slot (we don't need to render the whole inventory)
'        Call DrawInventory
End Sub

Private Function ClickItem(ByVal X As Long, ByVal Y As Long) As Long
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Selects the item clicked if it's valid and return's it's index
        '***************************************************

        Dim temp_x As Long
        Dim temp_y As Long
    
        temp_x = (X - Position.X) \ ownTilePixelWidth '34
        temp_y = (Y - Position.Y) \ ownTilePixelHeight
    
        TempItem = temp_x + temp_y * (Position.W \ ownTilePixelWidth) + 1
    
        'Make sure it's within limits

        If TempItem <= UBound(Inventory) Then
                'Make sure slot isn't empty

                If Inventory(TempItem).GrhIndex Then
                        ClickItem = TempItem
                Else
                        ClickItem = 0
                End If
        End If

End Function

Public Sub LoopDrawInv(Batch As clsBGFXSpriteBatch)

        'If GetTickCount - InventoryTickCount > 100 Then
                Call DrawInventory(Batch)
        '        InventoryTickCount = GetTickCount
        'End If
    
End Sub

Private Sub DrawInventory(Batch As clsBGFXSpriteBatch)

        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Renders the inventory to the given PictureBox
        '***************************************************

        Dim loopC          As Long

        For loopC = 1 To UBound(Inventory)
                startdX = Position.X + ((loopC - 1) Mod (Position.W / 32)) * 32
                startdY = Position.Y + ((loopC - 1) \ (Position.H / 32)) * 32

                If Inventory(loopC).GrhIndex Then
                
                        If InvSelectedItem = loopC Then
                                If ImgContainer Then
                                        Call Device_Textured_Render(startdX, startdY, _
                                                                    ownTilePixelWidth, ownTilePixelHeight, _
                                                                    0, 0, _
                                                                    SurfaceDB.Surface(2), _
                                                                    White())
                                End If

                        Else
                                Call Device_Textured_Render(startdX, startdY, _
                                                                    ownTilePixelWidth, ownTilePixelHeight, _
                                                                    GrhData(Inventory(loopC).GrhIndex).sX, GrhData(Inventory(loopC).GrhIndex).sY, _
                                                                    SurfaceDB.Surface(GrhData(Inventory(loopC).GrhIndex).FileNum), _
                                                                    White())
                        End If
                        
                        'If equipped we render "E"

                        If Inventory(loopC).Equipped Then
                                Text_Draw Batch, startdX + 20, startdY + 20, "+", Red
                        End If

                        'Render the item grh and the amount

                        If ShowValue Then
                                Text_Draw Batch, startdX, startdY, CStr(Inventory(loopC).Amount), White
                        End If
                End If

        Next loopC
        
End Sub


Public Sub Initialize(ByVal X As Integer, ByVal Y As Integer, _
                      ByVal W As Integer, ByVal H As Integer, _
                      ByVal MaxObjs As Byte, _
                      Optional ByVal TileWidth As Integer = 32, _
                      Optional ByVal TileHeight As Integer = 32, _
                      Optional ByVal startX As Integer = 0, _
                      Optional ByVal startY As Integer = 0, _
                      Optional ByVal bImgContainer As Boolean = True, _
                      Optional ByVal bShowText As Boolean = True)

        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 03/12/09
        'Sets the reference to the picture box on which to render the inventory
        '03/12/09: I added the optionals args FontSize, TileWidth, TileHeight, startX and startY. (Budi)
        '***************************************************
    
        ReDim Inventory(1 To MaxObjs) As Inventory
        
        Position.X = X
        Position.Y = Y
        Position.W = W
        Position.H = H
        
        ownTilePixelHeight = TileHeight
        ownTilePixelWidth = TileWidth
        startdX = startX
        startdY = startY
    
        ImgContainer = bImgContainer
        ShowValue = bShowText
    
        '\TODO
    
        If ImgContainer Then InvSelectedItem = ClickItem(Position.X, Position.Y)   'If there is anything there we select the top left item
      
End Sub

Private Sub InventoryWindow_MouseMove(Button As Integer, _
                                      Shift As Integer, _
                                      X As Single, _
                                      Y As Single)
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Implements the mouse move event of the inventory picture box
        'Displays a ToolTip of the item under the mouse
        '***************************************************

        Dim temp_x As Integer
        Dim temp_y As Integer
    
        'Exit if it got outside the control's area

        If X < 0 Or Y < 0 Or X > InventoryWindow.Width Or Y > InventoryWindow.Height Then Exit Sub
    
        temp_x = X \ ownTilePixelWidth
        temp_y = Y \ ownTilePixelHeight
    
        TempItem = temp_x + (temp_y + InventoryOffset) * (InventoryWindow.ScaleWidth \ ownTilePixelWidth) + 1
    
        If TempItem <= UBound(Inventory) Then
                InventoryWindow.ToolTipText = Inventory(TempItem).Name
        End If

End Sub

Public Sub Inventory_MouseDown(Button As Integer, _
                                      Shift As Integer, _
                                      X As Single, _
                                      Y As Single)

        Dim TempItem As Long
 
        If Button = 2 Then
                TempItem = ClickItem(X, Y)
                
                If TempItem = 0 Then Exit Sub
             
                If Inventory(TempItem).GrhIndex Then
                        MouseDownSelectedItem = TempItem

                        Exit Sub

                End If
        End If
   
        'MouseDownSelectedItem = 0
End Sub

Public Sub Inventory_MouseUp(Button As Integer, _
                                    Shift As Integer, _
                                    X As Single, _
                                    Y As Single)
        '***************************************************
        'Author: Juan Mart�n Sotuyo Dodero (Maraxus)
        'Last Modify Date: 27/07/04
        'Implements the mouse up event of the inventory picture box
        'Check outs which item was clicked
        '***************************************************
        'Store previously selected item

        Dim prevSelItem As Long
    
        'Exit if it got outside the control's area

        If X < 0 Or Y < 0 Or X > InventoryWindow.Width Or Y > InventoryWindow.Height Then

                Exit Sub

        End If

        prevSelItem = InvSelectedItem

        'Get the currently clickced item

        InvSelectedItem = ClickItem(CInt(X), CInt(Y))

        'Update needed inventory slots

        If prevSelItem <> InvSelectedItem Then
                If prevSelItem <> 0 And prevSelItem <> FLAGORO Or InvSelectedItem Then
                        Call DrawInventory
                End If
        End If
    

End Sub


