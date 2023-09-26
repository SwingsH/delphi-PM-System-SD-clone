{$I define.h}
unit XlsCtrl;

interface

type
  //excel�U��
  TXlsManage = class
  private
  public
    constructor Create;
    destructor Destroy; override;

    { TODO: �ثe����²���������ɶ��A��s }
    procedure NewExcel;  //�Ыؤ@�ӷs��excel
    procedure NewTemplateExcel;
    procedure NewSimpleExcel; /// TODO: ��� class ��g
  end;

var
  XlsManage: TXlsManage;
  XlsModel:string;

implementation

uses
  ComObj, StateCtrl, GridCtrl, Main, TableControlPanel, Variants;

{ TXlsManage }

constructor TXlsManage.Create;
begin
  XlsModel := Main.AppPath + 'template\xls�d��.xls';
end;

destructor TXlsManage.Destroy;
begin
  inherited;
end;

procedure TXlsManage.NewExcel;
var
  vTemplateID: Integer;
begin
  if not StateManage.CheckState then
    exit;

  //if vIdx < 0 then
  //  vTemplateID:= 0
  //else

  vTemplateID:= gTableControlPanel.Table.TemplateID;// TODO: gTableControlPanel, ��Ƴ��d�b list controler. ���n���@�k�A�n��

  if vTemplateID <= 0 then
    NewSimpleExcel
  else
    NewTemplateExcel;
end;

procedure TXlsManage.NewSimpleExcel;
var
  vApp: Variant;
  vCap: String;
  i, j: Integer;
begin
  if not StateManage.CheckState then
    exit;

  vApp := CreateOleObject('Excel.Application');  //�ʺA�Ы�excel
  vApp.Visible := True;                          //�i��
  //if GridManage.IsMrg then
    vCap := '�s�ت��';//GridManage.Table.Row[GridManage.TableID, 'mergetable_name']
  //else
  //  vCap := '�s�ت��'; // TODO: GridManage.Table.Row[GridManage.TableID, 'table_name'];
  vApp.Caption := vCap;                          //�����D
  vApp.WorkBooks.Add;                            //�s�W�u�@��

  //�N���D��s
  for j := 1 to GridManage.GridColNum do
    vApp.Cells[1, j] := MainForm.Grid.Cells[j, 0];

  //�N��椺�e��s
  for i := 1 to GridManage.GridRowNum do
  begin
    for j := 1 to GridManage.GridColNum do
    begin
      vApp.Cells[(i + 1), j] := MainForm.Grid.Cells[j, i];
    end;
  end;
end;

procedure TXlsManage.NewTemplateExcel;
var
  vModel,vApp: Variant;
  i, j: Integer;
  vTemplateID: Integer;
begin
  if not StateManage.CheckState then
    exit;

  if MainForm.mListBox_TableList.ItemIndex= -1 then
    Exit;

  vTemplateID:= gTableControlPanel.Table.TemplateID;
  vApp := CreateOleObject('Excel.Application');  //�ʺA�Ы�excel
  vModel:=CreateOleObject('Excel.Application');
  vModel.Workbooks.Open(XlsModel);
  vModel.WorkSheets[vTemplateID].Activate;

  //�N��椺�e��s
  for i := 1 to GridManage.GridRowNum do
  begin
    for j := 1 to GridManage.GridColNum do
    begin
      vModel.Cells[(i + 1), j] := MainForm.Grid.Cells[j, i];
    end;
  end;

  vModel.ActiveSheet.UsedRange.copy;
  vApp.Visible := True;                          //�i��
  vApp.Caption := MainForm.mListBox_TableList.Items[MainForm.mListBox_TableList.ItemIndex];                          //�����D
  vApp.WorkBooks.Add;                            //�s�W�u�@��
  vApp.Application.WorkSheets[1].Paste;
  vApp.ActiveSheet.UsedRange.Select;
  vApp.Selection.Columns.Autofit;
  vModel.ActiveWorkBook.Saved := True;
  vModel.Quit;

  vModel := Unassigned;
  vApp := Unassigned;
end;

end.
