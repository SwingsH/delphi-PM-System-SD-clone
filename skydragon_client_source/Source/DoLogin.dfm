object LoginForm: TLoginForm
  Left = 793
  Top = 59
  Width = 208
  Height = 334
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'LoginForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ACEdit: TLabeledEdit
    Left = 8
    Top = 24
    Width = 185
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #24115#34399
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 0
    OnKeyPress = ACEditKeyPress
  end
  object PWEdit: TLabeledEdit
    Left = 8
    Top = 72
    Width = 185
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #23494#30908
    LabelPosition = lpAbove
    LabelSpacing = 3
    PasswordChar = 'o'
    TabOrder = 1
    OnKeyPress = PWEditKeyPress
  end
  object OKBtn: TButton
    Left = 64
    Top = 264
    Width = 75
    Height = 25
    Caption = #30331#20837
    TabOrder = 2
    OnClick = OKBtnClick
  end
  object SDHTTP: TIdHTTP
    Request.Accept = 'text/html, */*'
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ProxyPort = 0
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Left = 8
    Top = 272
  end
  object IdAntiFreeze1: TIdAntiFreeze
    IdleTimeOut = 30
    Left = 160
    Top = 272
  end
end
