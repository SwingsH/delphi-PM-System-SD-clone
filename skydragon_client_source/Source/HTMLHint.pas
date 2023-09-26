unit HTMLHint;

interface

uses
  Htmlview,
  StdCtrls, Classes, SysUtils, ControlS,Windows;
type
  (********************************************************
   * HTML UI base, HTML¬É­±
   * @Author Swings Huang
   * @Version 2010/04/16 v1.0
   ********************************************************)
  THTMLBase=class(TObject)
  private
    mParent :TWinControl;              
    mVisible:Boolean;
    mViewer :THTMLViewer;
  protected
  public
    constructor Create(aParent :TWinControl);
    destructor Destroy;override;
    procedure SetAlign(aAlign:TAlign);
    procedure SetParent(aParent:TWinControl);
    procedure Show;
    procedure Hide;
    property  Viewer:THTMLViewer read mViewer write mViewer;
  end;

  (********************************************************
   * HTML Hint, Decorater of HTML Base
   * @Author Swings Huang
   * @Version 2010/04/16 v1.0
   ********************************************************)
  THTMLHint=class(TObject)
  private
    mParent    :TWinControl;               
    mHTMLParent:THTMLBase;
    mHTMLString: String;
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(const aValue:Integer);
    procedure SetWidth(const aValue:Integer);
    function GetViewer: THTMLViewer;
  protected
  public
    constructor Create(aParent :TWinControl);
    destructor Destroy;override;
    procedure Inititial;
    procedure SetHTMLParent(aHTMLParent:THTMLBase);
    procedure SetContent(aStr:String);
    procedure SetCoordinate(aX,aY:Integer);
    procedure Show;
    procedure Hide;
    property  Width:Integer read GetWidth write SetWidth;
    property  Height:Integer read GetHeight write SetHeight;
    property  Viewer:THTMLViewer read GetViewer;
  end;

implementation

uses
  Const_Template;

const
  cHTMLHint_W= 250;
  cHTMLHint_H= 100;
  
{ THTMLBase }

constructor THTMLBase.Create(aParent:TWinControl);
begin
  if aParent=nil then
    exit;
  mParent:=aParent;
  mViewer:=THTMLViewer.Create(mParent);
  mViewer.Enabled:=true;
  mViewer.Parent:= TWinControl(mParent);
end;

destructor THTMLBase.Destroy;
begin
  inherited;
  mParent:=nil;
  freeandnil(mViewer);
end;

procedure THTMLBase.Hide;
begin
  mViewer.Visible:=false;
end;

procedure THTMLBase.SetAlign(aAlign: TAlign);
begin              
  mViewer.Align:=aAlign;
end;

procedure THTMLBase.SetParent(aParent: TWinControl);
begin
  mParent:= aParent;
end;

procedure THTMLBase.Show;
begin
  mViewer.Visible:=true;
end;

{ THTMLHint }

constructor THTMLHint.Create(aParent: TWinControl);
begin
  if aParent=nil then
    exit;
  mParent:=aParent;

  mHTMLParent:= THTMLBase.Create(mParent);
  Inititial;
end;

destructor THTMLHint.Destroy;
begin
  freeandnil(mHTMLParent);
  inherited;
end;

function THTMLHint.GetHeight: Integer;
begin
  result:= mHTMLParent.Viewer.Height;
end;

function THTMLHint.GetWidth: Integer;
begin
  result:= mHTMLParent.Viewer.Width;
end;

procedure THTMLHint.Hide;
begin
  mHTMLParent.Hide;
end;

procedure THTMLHint.SetContent(aStr: String);
begin
  mHTMLString:=aStr;
  mHTMLParent.Viewer.LoadFromBuffer(Pchar(aStr),Length(aStr),'');
end;

procedure THTMLHint.SetCoordinate(aX, aY: Integer);
begin
  mHTMLParent.Viewer.Left:=aX;
  mHTMLParent.Viewer.Top:=aY;
end;

procedure THTMLHint.SetHeight(const aValue: Integer);
begin
  mHTMLParent.Viewer.Height:= aValue;
end;

procedure THTMLHint.SetWidth(const aValue:Integer);
begin
  mHTMLParent.Viewer.Width:= aValue;
end;

procedure THTMLHint.SetHTMLParent(aHTMLParent: THTMLBase);
begin
  freeandnil(mHTMLParent);
  mHTMLParent:= aHTMLParent;
end;

procedure THTMLHint.Show;
begin
  mHTMLParent.Show;
end;

procedure THTMLHint.Inititial;
begin
  //mHTMLParent.Viewer.Width:= cHTMLHint_W;
  //mHTMLParent.Viewer.Height:= cHTMLHint_H;
  mHTMLParent.Viewer.CharSet:=CHINESEBIG5_CHARSET;  /// TFontCharset type
  mHTMLParent.Viewer.Enabled:= true;
  mHTMLParent.Viewer.NoSelect:= true;
end;

function THTMLHint.GetViewer: THTMLViewer;
begin
  result:= mHTMLParent.Viewer;  
end;

end.
