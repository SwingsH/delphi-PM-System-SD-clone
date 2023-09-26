object ChangePassForm: TChangePassForm
  Left = 523
  Top = 212
  Width = 312
  Height = 249
  Caption = #26356#25913#23494#30908
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 104
    Top = 8
    Width = 97
    Height = 13
    Caption = #35531#36681#20837#33290#23494#30908#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 104
    Top = 64
    Width = 97
    Height = 13
    Caption = #35531#36681#20837#26032#23494#30908#65306
  end
  object Label3: TLabel
    Left = 104
    Top = 120
    Width = 105
    Height = 13
    Caption = #20877#27425#30906#35469#26032#23494#30908#65306
  end
  object Button1: TButton
    Left = 48
    Top = 184
    Width = 75
    Height = 25
    Caption = #30906#23450
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 192
    Top = 184
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 1
    OnClick = Button2Click
  end
  object OldPass: TEdit
    Left = 72
    Top = 32
    Width = 169
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
  end
  object NewPass: TEdit
    Left = 72
    Top = 88
    Width = 169
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
  end
  object CheckNewPass: TEdit
    Left = 72
    Top = 144
    Width = 169
    Height = 21
    PasswordChar = '*'
    TabOrder = 4
  end
end
