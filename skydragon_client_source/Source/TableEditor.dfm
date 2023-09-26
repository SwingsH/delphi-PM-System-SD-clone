object TableEditorForm: TTableEditorForm
  Left = 351
  Top = 204
  HorzScrollBar.Margin = 20
  HorzScrollBar.Size = 20
  VertScrollBar.ButtonSize = 20
  VertScrollBar.Margin = 20
  VertScrollBar.Size = 100
  VertScrollBar.ThumbSize = 20
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 10
  Caption = 'TableEditorForm'
  ClientHeight = 534
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object mEditorBox: TScrollBox
    Left = 8
    Top = 0
    Width = 657
    Height = 505
    TabOrder = 0
    object mBTNConfirm: TButton
      Left = 8
      Top = 12
      Width = 57
      Height = 25
      Caption = '--'
      TabOrder = 0
    end
  end
end
