{$I define.h}
unit Debug;
(**************************************************************************
 * DEBUG 工具
 *
 * @Author Swings Huang
 * @Version 2010/02/22 v1.0
 *************************************************************************)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TDebugForm = class(TForm)
    DebugREdit: TRichEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure InitShow;     //初始化
  end;

var
  DebugForm: TDebugForm;

implementation

{$R *.dfm}

uses
  Main;

const
  cDef_W = 800;
  cDef_H = 400;

  cDef_EditW = 780;
  cDef_EditH = 380;
  cCap = 'SQL 除錯介面';

procedure TDebugForm.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TDebugForm.FormActivate(Sender: TObject);
begin
///
end;

procedure TDebugForm.FormCreate(Sender: TObject);
begin
  //form設定
  Caption := cCap;

  ClientWidth := cDef_W;
  ClientHeight := cDef_H;

  //Left := MainForm.Left + MainForm.Width;
  //Top  := MainForm.Top;

  DebugREdit.Width := cDef_EditW ;
  DebugREdit.Height:= cDef_EditH ;
  DebugREdit.Lines.Clear;
  DebugREdit.Font.Size:= 10 ;
  DebugREdit.Font.Name:='Courier New';
  DebugREdit.ReadOnly:= True;
  DebugREdit.ScrollBars:= ssVertical;
end;

procedure TDebugForm.InitShow;
begin
  //Left := MainForm.Left + MainForm.Width;
  //Top  := MainForm.Top;
  MainForm.MenuItem_SQLDebugForm.Checked:=true;
  Show;
end;

procedure TDebugForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.MenuItem_SQLDebugForm.Checked:=false;
end;

end.
