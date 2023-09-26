object NoticeForm: TNoticeForm
  Left = 367
  Top = 315
  Width = 460
  Height = 373
  Caption = 'Notice Form'
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
  object mHTMLViewer: THTMLViewer
    Left = 0
    Top = 0
    Width = 452
    Height = 344
    TabOrder = 0
    Align = alClient
    DefBackground = clCaptionText
    BorderStyle = htFocused
    HistoryMaxCount = 0
    DefFontName = 'Times New Roman'
    DefPreFontName = 'Courier New'
    NoSelect = False
    ScrollBars = ssVertical
    CharSet = CHINESEBIG5_CHARSET
    PrintMarginLeft = 2
    PrintMarginRight = 2
    PrintMarginTop = 2
    PrintMarginBottom = 2
    PrintScale = 1
    htOptions = [htShowDummyCaret]
  end
end
