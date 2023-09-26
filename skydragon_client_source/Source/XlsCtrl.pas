{$I define.h}
unit XlsCtrl;

interface

type
  //excel助手
  TXlsManage = class
  private
  public
    constructor Create;
    destructor Destroy; override;

    { TODO: 目前先用簡陋版等有時間再研究 }
    procedure NewExcel;  //創建一個新的excel
    procedure NewTemplateExcel;
    procedure NewSimpleExcel; /// TODO: 整個 class 改寫
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
  XlsModel := Main.AppPath + 'template\xls範本.xls';
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

  vTemplateID:= gTableControlPanel.Table.TemplateID;// TODO: gTableControlPanel, 資料都留在 list controler. 不好的作法，要改

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

  vApp := CreateOleObject('Excel.Application');  //動態創建excel
  vApp.Visible := True;                          //可見
  //if GridManage.IsMrg then
    vCap := '新建表格';//GridManage.Table.Row[GridManage.TableID, 'mergetable_name']
  //else
  //  vCap := '新建表格'; // TODO: GridManage.Table.Row[GridManage.TableID, 'table_name'];
  vApp.Caption := vCap;                          //更改標題
  vApp.WorkBooks.Add;                            //新增工作頁

  //將標題轉存
  for j := 1 to GridManage.GridColNum do
    vApp.Cells[1, j] := MainForm.Grid.Cells[j, 0];

  //將表格內容轉存
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
  vApp := CreateOleObject('Excel.Application');  //動態創建excel
  vModel:=CreateOleObject('Excel.Application');
  vModel.Workbooks.Open(XlsModel);
  vModel.WorkSheets[vTemplateID].Activate;

  //將表格內容轉存
  for i := 1 to GridManage.GridRowNum do
  begin
    for j := 1 to GridManage.GridColNum do
    begin
      vModel.Cells[(i + 1), j] := MainForm.Grid.Cells[j, i];
    end;
  end;

  vModel.ActiveSheet.UsedRange.copy;
  vApp.Visible := True;                          //可見
  vApp.Caption := MainForm.mListBox_TableList.Items[MainForm.mListBox_TableList.ItemIndex];                          //更改標題
  vApp.WorkBooks.Add;                            //新增工作頁
  vApp.Application.WorkSheets[1].Paste;
  vApp.ActiveSheet.UsedRange.Select;
  vApp.Selection.Columns.Autofit;
  vModel.ActiveWorkBook.Saved := True;
  vModel.Quit;

  vModel := Unassigned;
  vApp := Unassigned;
end;

end.
