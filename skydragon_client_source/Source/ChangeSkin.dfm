object ChangeSkinForm: TChangeSkinForm
  Left = 430
  Top = 135
  Width = 747
  Height = 504
  Caption = #26356#25563#20296#26223#20027#38988
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 296
    Top = 32
    Width = 401
    Height = 345
  end
  object SkinList: TListBox
    Left = 48
    Top = 32
    Width = 201
    Height = 345
    ItemHeight = 13
    TabOrder = 0
    OnClick = SkinListClick
  end
  object OkBtn: TButton
    Left = 248
    Top = 424
    Width = 75
    Height = 25
    Caption = #30906#23450
    TabOrder = 1
    OnClick = OkBtnClick
  end
  object CancelBtn: TButton
    Left = 432
    Top = 424
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 2
    OnClick = CancelBtnClick
  end
end
