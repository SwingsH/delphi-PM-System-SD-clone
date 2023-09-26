{$I define.h}
program SkyDragon;

{%File 'define.h'}

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  GridCtrl in 'GridCtrl.pas',
  StateCtrl in 'StateCtrl.pas',
  DBManager in 'DBManager.pas',
  SQLConnecter in 'SQLConnecter.pas',
  TableHandler in 'TableHandler.pas',
  DoLogin in 'DoLogin.pas' {LoginForm},
  CommonFunction in 'CommonFunction.pas',
  NoticeManager in 'NoticeManager.pas',
  XlsCtrl in 'XlsCtrl.pas',
  Debug in 'Debug.pas' {DebugForm},
  Const_Template in 'Const_Template.pas',
  TableControlPanel in 'TableControlPanel.pas',
  CommonSaveRecord in 'CommonSaveRecord.pas',
  ChangePass in 'ChangePass.pas' {ChangePassForm},
  ChangeSkin in 'ChangeSkin.pas' {ChangeSkinForm},
  TableModel in 'TableModel.pas',
  PubFun in 'PubFun.pas',
  TableEditor in 'TableEditor.pas' {TableEditorForm},
  HTMLHint in 'HTMLHint.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TLoginForm, LoginForm);
  Application.CreateForm(TTableEditorForm, gTableEditorForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TChangePassForm, ChangePassForm);
  Application.CreateForm(TChangeSkinForm, ChangeSkinForm);
  Application.Run;
end.
