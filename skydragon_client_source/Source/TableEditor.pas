unit TableEditor;
(**************************************************************************
 * 1.���s�边 (�s�W, �ק�), ���� MVC �[�c�إ�
 * 2.���s�����
 *************************************************************************)
interface

uses
  (** Delphi *)
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, StdCtrls, ComCtrls, Forms, ExtCtrls, 
  (** SkyDragon *)
  CommonSaveRecord, SQLConnecter, TableModel;
type
  TTableEditorForm = class(TForm)
    mEditorBox: TScrollBox;
    mBTNConfirm: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  (********************************************************
   * [�`��۰ʦ^��]��ƫ��A TAutofill  ,DB����^��
   *      �֦��Ҧ�
   * @Author Swings Huang
   * @Version 2010/04/15 v1.0
   *************************************************************************)
  TAutofillManager=class(TObject)
  private
    mData: array of rMergeColumnAutofill;
    function GetHasAutofill(aMTableID, aMColumnID: Integer): Boolean;
    function GetInitialized: Boolean;
    function GetData(aMTableID, aMColumnID: Integer): rMergeColumnAutofill;
  public
    procedure Add(aRSet:TRecordSet);
    procedure InitializeData;
    property Initialized: Boolean read GetInitialized;
    property HasAutoFill[aMTableID,aMColumnID:Integer]: Boolean read GetHasAutoFill;
    property Data[aMTableID,aMColumnID:Integer]: rMergeColumnAutofill read GetData ;
  end;

  (**************************************************************************
   * ���s�边 - Model �x�s�θ�� (�Ѧҭ쫬: rMergeColumn + rMergeColumnValue)
   *************************************************************************)
   rTableEditData = record
     TableID       : Integer; // �`�� ID PK
     ColumnID      : Integer; // �`����� ID
     RowID         : Integer; // �`��C�� ID
     ColumnType    : String;
     TypeSet       : String;
     Value         : String;
     CreateUserID  : Integer; // �X�֪��إߪ�ID
     CreateTime    : String;  // �X�֪��إ߮ɶ�
     PositionID    : Integer; // �i�s����¾�Ȩ��� ID - mergecolumn_id �P, ¾�� ID ��P..�H�� 2NF..
     Priority      : Integer; // �s���̧C�v��-�ݬd�ߨϥΪ̦b�M�ת��v�Q����
     Name          : String;  // extra
     (** �۰ʦ^��]�m *)
     AutoFillEnable: Boolean; // �O�_���۰ʦ^��, scs_mergecolumn_autofill
     AutofillValue : String;  // �۰ʦ^�񪺭�
     AutofillData  : rMergeColumnAutofill;
   end;
   rTableEditDataS = array of rTableEditData;
   
  (**************************************************************************
   * ���s�边 - ���, ��@��椧�榡, Model�h
   * �D�n�v�d: 1.�x�s[�~��]�����榡���
   *           2.�榡��ƳB�z, ���Ү榡�O�_���T (�U�Կ��O�_�b�d��,)
   *           3.��ƹB��
   * @Author Swings Huang
   * @Version 2010/03/10 v1.0
   * @Todo
   *************************************************************************)
  TTableEditFormat= class(TObject)
  private
    mAutoFillManager: TAutofillManager;    /// [�`��۰ʦ^��]�޲z��
    mTableID    : Integer;
    mData       : array of rTableEditData;
    //mDesc       : array of String;
    mNewData    : rTableEditDataS;
    function GetColumn(aCount: Integer): rMergeColumn;
    function GetDesc(aCount: Integer): String;
    function GetData(aCount: Integer): rTableEditData;
    function GetNewData(aCount: Integer): rTableEditData;
    function GetNewDataNums: Integer;
  protected
  public
    constructor Create;
    procedure Clear;
    procedure SaveNewData(aData: rTableEditDataS);
    function DataValueCompare(var aSourceData:rTableEditDataS;                 /// �P mData ��� Value, �d�s Value ���P������, @param2 : �O�_�d�s�� mCompareData or �ϥΦ^��
                               aIfSave:Boolean=True):boolean;
    (** IColumnS ����ƨӷ�, �i��O[�`�����]�]�i��O[�l�����], �V�X���A *)
    procedure Fetch(aColumnS: IColumnS); overload;                              /// �^����� - only column, TableModel ����
    procedure Fetch(aColumnS: IColumnS; aValue: String;                         /// �^����� - column + value, TableModel ����
                          aCol, aRow: Integer); overload;
    procedure Fetch(aRSetColumn: TRecordSet); overload;                         /// �^����� - only column, RecordSer ����
    procedure Fetch(aRSetColumn: TRecordSet; aRSetValue: TRecordSet;            /// �^����� - column + value, RecordSer ����
                    aCol,aRow: Integer); overload;
    procedure Fetch(arMColumnS: array of rMergeColumn;                          /// �^����� - filled record
                    arMColumnValueS: array of rMergeColumnValue); overload;
    function  AutofillDataToValueList(aCount:Integer):TStringList;         /// �ഫ autofill's data to stringlist, TODO: �ݻP��Lclass�P�j
    property  ColumnS[aCount: Integer]: rMergeColumn read GetColumn;
    property  Desc[aCount: Integer]   : String read GetDesc;
    property  Data[aCount: Integer]   : rTableEditData read GetData;
    property  NewData[aCount: Integer]: rTableEditData read GetNewData ;
    property  NewDataNums: Integer read GetNewDataNums;
    property  TableID: Integer read mTableID;
    property  AutoFiller: TAutofillManager read mAutoFillManager write mAutoFillManager;
  end;

  (**************************************************************************
   * ���s�边 - ��ܥθ��
   *************************************************************************)
  rColumnLayoutSet= record
    mRect    : TRect;           /// ��ܥΪ�Delphi���� - ��m�]�w
    mName    : String;          /// ��ܥΪ�Delphi���� - �W��, identifier ���i����
    mText    : String;
    mHTMLDesc: String;          /// �����n�S�O��ܪ�����
    mData    : rTableEditData;  /// Model �x�s�θ��
  end;
  
  (**************************************************************************
   * ���s�边 - ��ܥΤ��� : �@��Edit + �h��Combobox
   *************************************************************************)
  TMultiComboBox= class(TObject)
  private
    mOutputMemo  : TMemo;
    mComboBoxS   : array of TComboBox;
    mComboBoxNums: Byte;
    mName        : String;
    mPosition    : TPoint;
    function GetEditText: String;
    procedure SetEditText(const Value: String);
    procedure SetPosition(const Value: TPoint);
    function GetEditColor: TColor;
    procedure SetEditColor(const Value: TColor);
    function GetNameS: TComponentName;
    procedure SetNameS(const Value: TComponentName);
    procedure SetComboboxSOnEnter(const Value: TNotifyEvent);
    procedure SetComboboxSOnExit(const Value: TNotifyEvent);
  protected
    procedure RefreshOutputEdit;
  public
    constructor Create(aOwner: TWinControl; aComboBoxNumS: Byte; aOrder:Byte);
    destructor Destroy; override;
    procedure SetPosSize( aLeft,aTop,aWidth,aHeight, aComboW, aComboH:Integer);
    procedure SetList(aList:TStringList);
    property Color:TColor read GetEditColor write SetEditColor;
    property Name:TComponentName read GetNameS write SetNameS;
    property Text: String read GetEditText write SetEditText;
    (** Event **)
    procedure OnComboBoxChange(Sender:TObject);
    procedure OnComboBoxKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    (** Property **)
    property OnEnter:TNotifyEvent write SetComboboxSOnEnter;
    property OnExit:TNotifyEvent write SetComboboxSOnExit;
  end;
  (**************************************************************************
   * ���s�边 - ���, Combined with Delphi UI, View�h
   * �D�n�v�d: 1. �̷Ӹ�ư��檩���t�m X,Y,W,H, �]�w������� Data�C
   * @Author Swings Huang
   * @Version 2010/03/10 v1.0
   * @Version 2010/04/15 v2.0 �[�J�۰ʦ^��޲z�� Autofill
   * @Todo
   *************************************************************************)
  TTableEditLayout= class
  private
    mForm          : TForm;                         /// ����Ҽ{�אּglobal�ܼ�,TODO: ���P�� func�ޥ� mForm�ɭԦ����~
    mBox           : TScrollBox;
    mBTNConfirm    : TButton;
    mrLayoutSet    : array of rColumnLayoutSet;     /// ***
    mLabelS        : array of TLabel;
    mMemoS         : array of TMemo;                /// �D����: for column_type textarea
    mDateTimeS     : array of TDateTimePicker;      /// �D����: for column_type date
    mEditS         : array of TEdit;                /// �D����: for column_type textfield, number, multicombobox(read),
    mComboBoxS     : array of TComboBox;            /// �D����: for column_type selectbox, multicombobox(write), percent
    mMultiComboBoxS: array of TMultiComboBox;       /// ���[����: �@�Ӥ���i�ण�u�@�ӫ��s, for column_type multicombobox
    mTotalWidth    : Integer;                       /// �Ҧ������`�M���e
    mTotalHeight   : Integer;                       /// �Ҧ������`�M����
    mEditData      : rTableEditDataS;
    mBoxCanScroll  : Boolean;
    function GetComboBoxS(aOrder: Byte): TComboBox;
    function GetDateTimeS(aOrder: Byte): TDateTimePicker;
    function GetEditS(aOrder: Byte): TEdit;
    function GetLabelS(aOrder: Byte): TLabel;
    function GetMemoS(aOrder: Byte): TMemo;
    function GetMultiComboBoxS(aOrder: Byte): TMultiComboBox;
    function GetComboBoxSActive: Boolean;
    function GetLayoutSet(aOrder: Byte): rColumnLayoutSet;
    function GetAutofillMemo(aOrder: Byte): TMemo;
    function IsFuncString(aStr:String):Boolean;    // �O�_���a���\�઺�r��
    function FuncString(aStr:String):String;       // �\��r�겣�ͥX�@��r�� ex: '@NOW' = '2010/04/16'
  protected
  public
    constructor Create;
    procedure Show;
    procedure Arrange(aData:array of rTableEditData);                           //TODO: func split, Save data + execute arrange
    procedure OutputData(out aData:rTableEditDataS);
    (** Layout Event **)
    procedure OnComboFormClose(Sender: TObject; var Action: TCloseAction);
    procedure OnComboBoxSEnter(Sender:TObject);
    procedure OnComboBoxSExit(Sender:TObject);
    procedure OnComboBoxChange(Sender:TObject);
    procedure OnMultiComboBoxSChange(Sender:TObject);
    (** �ʺA�إߤ��� *)
    procedure CreateInstance_Form;                                              // Root, Single component
    procedure CreateInstance_ScrollBox(aOwner:TComponent);                      // Root, Single component�C�ѩ� VCLSkin �� resize scrollbar ��ܷ|�W�X form ��t, �]���n�h���O�@�� panel
    procedure CreateInstance_Label(aOrder:Byte; aData:rColumnLayoutSet);
    procedure CreateInstance_Memo(aOrder: Byte; aData:rColumnLayoutSet); overload;
    function  CreateInstance_Memo(aName:String; aX,aY,aW,aH:Integer):TMemo; overload;
    procedure CreateInstance_DateTime(aOrder: Byte; aData:rColumnLayoutSet);
    procedure CreateInstance_Edit(aOrder: Byte; aData:rColumnLayoutSet);
    procedure CreateInstance_ComboBox(aOrder: Byte; aData:rColumnLayoutSet);
    procedure CreateInstance_MultiComboBoxGroup(aOrder: Byte; aData:rColumnLayoutSet);
    (** �ʺA�R������ *)
    procedure DestroyAllInstance;
    (** ��dfm����ѷӪ��覡�[�J���� *)
    procedure AddInstance_Form(aForm: TForm);                                   /// �[�J����ѷ�
    procedure AddInstance_ScrollBox(aScrollBox: TScrollBox);                    /// �[�J����ѷ�
    procedure AddInstance_Label(aLabelS:array of TLabel);                       /// �[�J����ѷ�
    procedure AddInstance_Memo(aMemoS:array of TMemo);                          /// �[�J����ѷ�
    procedure AddInstance_DateTime(aDateTimeS:array of TDateTimePicker);        /// �[�J����ѷ�
    procedure AddInstance_Edit(aEditS:array of TEdit);                          /// �[�J����ѷ�
    procedure AddInstance_ComboBox(aComboBoxS:array of TComboBox);              /// �[�J����ѷ�
    (** ��Ʀs���� *)
    property Form: TForm read mForm write mForm;
    property Box: TScrollBox read mBox;
    property BTNConfirm: TButton read mBTNConfirm write mBTNConfirm;
    function GetMemoByName(aName:String):TMemo;
    (** ��Ʀs���� - delphi componet*)
    property LabelS[aOrder:Byte]        : TLabel read GetLabelS;
    property MemoS[aOrder:Byte]         : TMemo  read GetMemoS;                    /// for column_type textarea
    property AutofillMemo[aOrder:Byte]  : TMemo  read GetAutofillMemo;             /// �۰ʦ^�������쪺 memo, �Q��󪺦���~
    property DateTimeS[aOrder:Byte]     : TDateTimePicker read GetDateTimeS;       /// for column_type date
    property EditS[aOrder:Byte]         : TEdit read GetEditS;                     /// for column_type textfield, number
    property ComboBoxS[aOrder:Byte]     : TComboBox read GetComboBoxS;             /// for column_type selectbox
    property MultiComboBoxS[aOrder:Byte]: TMultiComboBox read GetMultiComboBoxS;
    property ComboBoxSDropDown          : Boolean read GetComboBoxSActive;         /// Check if any combobox is Active (DropDownlist of combobox is visible) or (Focused)
    property BoxCanScroll               : Boolean read mBoxCanScroll;
    property LayoutSet[aOrder:Byte]     : rColumnLayoutSet read GetLayoutSet;      /// ���o LayoutSet ���
  end;

  (**************************************************************************
   * ���s�边 - �D���x, Control�h
   *************************************************************************)
  TTableEditMode= (temNew (*����-�s�W*), temMod (*����-�ק�*));
  TTableEditor= class(TObject)
  private
    mMode           : TTableEditMode;
    mLayout         : TTableEditLayout;
    mFormat         : TTableEditFormat;
  protected
  public
    constructor Create;
    procedure Arrange;       // Arrange Layout, pass data from Format to Layout
    procedure TriggerShow(aColumnS: IColumnS); overload;                        /// TBModel ��
    procedure TriggerShow(aColumnS: IColumnS; aValue: String;                   /// TBModel ��
                          aCol, aRow: Integer); overload;
    procedure TriggerShow(aRSetColumn: TRecordSet); overload;                   /// RS�ª� , overload, ��ƶǻ��� Trigger �覡�i�ण�P
    procedure TriggerShow(aRSetColumn, aRSetValue: TRecordSet;                  /// RS�ª� , overload, ��ƶǻ��� Trigger �覡�i�ण�P
                          aCol, aRow: Integer); overload;
    (** Event *)
    procedure OnConfirmClick(Sender:Tobject);
    procedure OnBoxMouseWheel(Sender: TObject; Shift: TShiftState;
                              WheelDelta: Integer; MousePos: TPoint;
                              var Handled: Boolean);
    (** Property *)
    property Layout: TTableEditLayout read mLayout;
    property Format: TTableEditFormat read mFormat;
  end;

var
  gTableEditorForm: TTableEditorForm;
  gTableEditor: TTableEditor;

implementation

uses
  TableHandler, DBManager, GridCtrl, TableControlPanel, CommonFunction,
  Math;

const
  cBox_Padding: TRect=(Left:8; Top:8; Right:28; Bottom:52);     // ScrollBox�� default padding ��, �ѩ� scrollbox �|�� SKIN ���k���Y���ܦh�Ŷ�, �]���n�[�j
  cBlock_Padding: TRect=(Left:24; Top:32; Right:12; Bottom:12);  // �C�Ӱ϶��� default padding ��, Left: �t�d�� Label���Ŷ�
  cForm_MinW = 400;
  cForm_MinH = 100;
  cForm_DefW = 400;
  cForm_DefH = 680;
  cEdit_DefW = 200;
  cEdit_DefH =  21;
  cMemo_DefW = 200;
  cMemo_DefH = 140;
  cLabel_Top = 22;
  cDatetime_DefW = 140;
  cDatetime_DefH =  21;
  cComboBox_DefW = 140;
  cComboBox_DefH =  21;
  cMultiComboBox_DefW = 140;
  cMultiComboBox_DefH = 120;
  cMultiComboBox_Edit_DefW = 140;
  cMultiComboBox_Edit_DefH = 48;
  cMouseWheel_Size = 64; // �ƹ��u�ʪ����j�Z��
  
{$R *.dfm}

{ TTableEditLayout }

procedure TTableEditLayout.AddInstance_ComboBox(
  aComboBoxS: array of TComboBox);
var
  vLength: Integer;
  i: Integer;
begin
  vLength:= Length(aComboBoxS);
  if vLength <= 0 then
    exit;
    
  SetLength(mComboBoxS, vLength);
  for i:= Low(mComboBoxS) to High(mComboBoxS) do
    mComboBoxS[i]:= aComboBoxS[i];
end;

procedure TTableEditLayout.AddInstance_DateTime(
  aDateTimeS: array of TDateTimePicker);
var
  vLength: Integer;
  i: Integer;
begin
  vLength:= Length(aDateTimeS);
  if vLength <= 0 then
    exit;
    
  SetLength(mDateTimeS, vLength);
  for i:= Low(mDateTimeS) to High(mDateTimeS) do
    mDateTimeS[i]:= aDateTimeS[i];
end;

procedure TTableEditLayout.AddInstance_Edit(aEditS: array of TEdit);
var
  vLength: Integer;
  i: Integer;
begin
  vLength:= Length(aEditS);
  if vLength <= 0 then
    exit;
    
  SetLength(mEditS, vLength);
  for i:= Low(mEditS) to High(mEditS) do
    mEditS[i]:= aEditS[i];
end;

procedure TTableEditLayout.AddInstance_Form(aForm: TForm);
begin
  mForm:= aForm;
  mForm.OnClose:= OnComboFormClose;
end;

procedure TTableEditLayout.AddInstance_Label(aLabelS: array of TLabel);
var
  vLength: Integer;
  i: Integer;
begin
  vLength:= Length(aLabelS);
  if vLength <= 0 then
    exit;
    
  SetLength(mLabelS, vLength);
  for i:= Low(mLabelS) to High(mLabelS) do
    mLabelS[i]:= aLabelS[i];
end;

procedure TTableEditLayout.AddInstance_Memo(aMemoS: array of TMemo);
var
  vLength: Integer;
  i: Integer;
begin
  vLength:= Length(aMemoS);
  if vLength <= 0 then
    exit;
    
  SetLength(mMemoS, vLength);
  for i:= Low(mMemoS) to High(mMemoS) do
    mMemoS[i]:= aMemoS[i];
end;

procedure TTableEditLayout.Arrange(aData:array of rTableEditData);
var
  i, vLength: Integer;
  vType: String;
begin
  if Length(aData) = 0 then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditLayout.Arrange error!');
{$endif}
    exit;
  end;
  // clear, freeandnil
  DestroyAllInstance;                                    // free instance
  fillchar(mrLayoutSet, Sizeof(mrLayoutSet), 0);    // free layout setdata
  fillchar(mEditData, Sizeof(mEditData), 0);
  mBox.VertScrollBar.Range:= 0;
  mBox.VertScrollBar.Position:=0;
  
  vLength:= Length(aData);
  SetLength(mrLayoutSet, vLength);
  SetLength(mEditData,   vLength);   // save
  for i:= 0 to vLength-1 do
    mEditData[i]:= aData[i];

  for i:= 0 to vLength-1 do
  begin
    vType:= mEditData[i].ColumnType;
    if (vType='textfield') or (vType='number')  or (vType = 'function') then
    begin
      /// �x�s���                 
      mrLayoutSet[i].mName       := Format('s%d_textfield',[i]);
      mrLayoutSet[i].mHTMLDesc   := ''; // todo:
      mrLayoutSet[i].mData       := mEditData[i];
      mrLayoutSet[i].mText       := mEditData[i].Value;
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + cEdit_DefH + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom 
      /// �̷Ӹ�ƫإ߹���
      CreateInstance_Edit(i, mrLayoutSet[i]);
    end
    else if vType = 'textarea' then
    begin
      /// �x�s���  
      mrLayoutSet[i].mName       := Format('s%d_textarea',[i]);
      mrLayoutSet[i].mHTMLDesc   := ''; // todo:
      mrLayoutSet[i].mData       := mEditData[i];
      mrLayoutSet[i].mText       := mEditData[i].Value;
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + cMemo_DefH + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom 
      /// �̷Ӹ�ƫإ߹���
      CreateInstance_Memo(i, mrLayoutSet[i]);
    end
    else if vType = 'function' then
    begin
      /// �x�s���  
      mrLayoutSet[i].mName       := Format('s%d_func',[i]);
      mrLayoutSet[i].mHTMLDesc   := ''; // todo:
      mrLayoutSet[i].mData       := mEditData[i];
      mrLayoutSet[i].mText       := mEditData[i].Value;
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + cDatetime_DefH + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom
      /// �̷Ӹ�ƫإ߹���
      CreateInstance_Edit(i, mrLayoutSet[i]);
    end
    else if vType = 'date' then
    begin
      /// �x�s���  
      mrLayoutSet[i].mName       := Format('s%d_date',[i]);
      mrLayoutSet[i].mHTMLDesc   := ''; // todo:
      mrLayoutSet[i].mData       := mEditData[i];
      mrLayoutSet[i].mText       := mEditData[i].Value;
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + cDatetime_DefH + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom
      /// �̷Ӹ�ƫإ߹���
      CreateInstance_DateTime(i, mrLayoutSet[i]);
    end
    else if vType = 'selectbox' then
    begin
      /// �x�s���  
      mrLayoutSet[i].mName       := Format('s%d_selectbox',[i]);
      mrLayoutSet[i].mHTMLDesc   := ''; // todo:
      mrLayoutSet[i].mData       := mEditData[i];
      mrLayoutSet[i].mText       := mEditData[i].Value;
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + cComboBox_DefH + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom
      /// �̷Ӹ�ƫإ߹���
      CreateInstance_ComboBox(i, mrLayoutSet[i]);
    end
    else if vType = 'multiselectbox' then
    begin
      /// �x�s���
      mrLayoutSet[i].mName       := Format('s%d_multiselectboxs',[i]);
      mrLayoutSet[i].mHTMLDesc   := ''; // todo:
      mrLayoutSet[i].mData       := mEditData[i];
      mrLayoutSet[i].mText       := mEditData[i].Value;
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + cMultiComboBox_DefH + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom
      /// �̷Ӹ�ƫإ߹���
      CreateInstance_MultiComboBoxGroup(i, mrLayoutSet[i]);
    end
    else if vType = 'checkbox' then
    begin
      // TODO:
    end
    else if vType = 'radiobox' then
    begin
      // TODO:
    end
    else
    begin
      // none type, error
      mrLayoutSet[i].mRect.Top   := mrLayoutSet[Max(i-1,0)].mRect.Bottom + cBlock_Padding.Top;
      mrLayoutSet[i].mRect.Left  := cBlock_Padding.Left;
      mrLayoutSet[i].mRect.Bottom:= mrLayoutSet[i].mRect.Top + 40 + cBlock_Padding.Bottom ; // Top + �� + ���Z = bottom
    end;
    // Create Label
    CreateInstance_Label(i,mrLayoutSet[i]);
  end;
  /// Save total data
  mTotalHeight:= mrLayoutSet[ Length(mrLayoutSet)-1 ].mRect.Bottom ;   //- cBlock_Padding.Top
  mTotalWidth := cForm_DefW - cBox_Padding.Left - cBox_Padding.Right;  // �e����
  /// Reset ScrollBox
  mBox.VertScrollBar.Range:= mTotalHeight;
  mBox.VertScrollBar.Visible:= True;      //ScrolBox ������ܤ~��վ� bar �� Position
  mBox.VertScrollBar.Position:=0;
  mBox.VertScrollBar.Increment:= 8 ;
  mBox.VertScrollBar.Style := ssRegular;
  mBox.Left  := cBox_Padding.Left;
  mBox.Top   := cBox_Padding.Top;
  mBox.Width := mTotalWidth;
  mBox.Height:= Min(mTotalHeight, cForm_DefH - cBox_Padding.Top - cBox_Padding.Bottom); // �ϥ� Min ��������̤jH
  /// Reset Confirm BTN
  mBTNConfirm.Left := mTotalWidth - 90 ;
  mBTNConfirm.Top  := mTotalHeight - 40;
  mBTNConfirm.Caption:= '�T�{';

  /// Reset Form
  mForm.Width := cForm_DefW;
  mForm.Height:= mBox.Height + cBox_Padding.Top + cBox_Padding.Bottom ;
  mForm.Left  := (Screen.Width - mForm.Width) div 2;  //�e���m��
  mForm.Top   := (Screen.Height - mForm.Height) div 2; //�e���m��
end;

constructor TTableEditLayout.Create;
begin
  //CreateInstance_Form;
  //CreateInstance_ScrollBox(mForm);
  mBoxCanScroll:= true;
end;

procedure TTableEditLayout.CreateInstance_ComboBox(aOrder: Byte; aData:rColumnLayoutSet);
var
  vIdx, i: Integer;
  vList: TStringList;
begin
  vIdx:= Length(mComboBoxS);

  SetLength(mComboBoxS, vIdx+1);
  mComboBoxS[vIdx] := TComboBox.Create(mBox);   /// Note: �ǤJref,�O mBox�b���餺�إ� new TComboBox �C
  mComboBoxS[vIdx].Parent  := mBox;             /// Note: Set TComboBox�� parent �� mBox, �۹���۩� mBox�C
  mComboBoxS[vIdx].Left    := aData.mRect.Left;
  mComboBoxS[vIdx].Top     := aData.mRect.Top;
  mComboBoxS[vIdx].Width   := cEdit_DefW;
  mComboBoxS[vIdx].Height  := cEdit_DefH;
  mComboBoxS[vIdx].Name    := aData.mName;
  mComboBoxS[vIdx].Text    := aData.mText;
  mComboBoxS[vIdx].Style   := csDropDownList;   /// ��Ū, �T����N��J
  mComboBoxS[vIdx].OnEnter := OnComboBoxSEnter;
  mComboBoxS[vIdx].OnExit  := OnComboBoxSExit;
  mComboBoxS[vIdx].OnChange:= OnComboBoxChange;

  // Set Elemnet
  vList:= gTableHandler.StringToSelectList( aData.mData.TypeSet );
  for i:=0 to vList.Count-1 do
  begin
    if IsFuncString(vList[i])=false then
      mComboBoxS[vIdx].Items.Add(vList[i])
    else
      mComboBoxS[vIdx].Items.Add(FuncString(vList[i]));  
  end;
  mComboBoxS[vIdx].TabOrder:=aOrder;
  mComboBoxS[vIdx].Tag     :=aOrder;
end;

procedure TTableEditLayout.CreateInstance_MultiComboBoxGroup(aOrder: Byte;
  aData: rColumnLayoutSet);
var
  vIdx: Integer;
  vList: TStringList;
const
  cComboxNums  = 6;
  cComboxWidth = 120;
  cComboxHeight= 25;
begin
  vIdx:= Length(mMultiComboBoxS);
  SetLength(mMultiComboBoxS,vIdx+1);

  mMultiComboBoxS[vIdx]:= TMultiComboBox.Create(mBox, cComboxNums, aOrder);     // �إ߽ƿ說�U�Կ��
  mMultiComboBoxS[vIdx].SetPosSize( aData.mRect.Left, aData.mRect.Top,          // �]�w XYWH
                                    cMultiComboBox_Edit_DefW, cMultiComboBox_Edit_DefH,
                                    cComboxWidth, cComboxHeight);

  vList:= gTableHandler.StringToSelectList( aData.mData.TypeSet );              // [�r��]�Ѧ�[�ﶵLIST]
  vList.Insert(0,'');                                                           // �[�J�ſﶵ = �������
  mMultiComboBoxS[vIdx].SetList(vList);                                         // �]�w�U�Ԧ���涵��
  mMultiComboBoxS[vIdx].Color   := clSilver;                                    // �Ϧ�, �ܷN�L�k��J
  mMultiComboBoxS[vIdx].Name    := aData.mName;
  mMultiComboBoxS[vIdx].Text    := aData.mText;
  mMultiComboBoxS[vIdx].OnExit  := OnComboBoxSExit;                             // dynamic combobox �u��������o��بƥ�, ��]����
  mMultiComboBoxS[vIdx].OnEnter := OnComboBoxSEnter;
end;

procedure TTableEditLayout.CreateInstance_DateTime(aOrder: Byte; aData:rColumnLayoutSet);
var
  vIdx: Integer;
begin
  vIdx:= Length(mDateTimeS);

  SetLength(mDateTimeS, vIdx+1);
  mDateTimeS[vIdx] := TDateTimePicker.Create(mBox);
  mDateTimeS[vIdx].Left   := aData.mRect.Left;
  mDateTimeS[vIdx].Top    := aData.mRect.Top;
  mDateTimeS[vIdx].Width  := cEdit_DefW;
  mDateTimeS[vIdx].Height := cEdit_DefH;
  mDateTimeS[vIdx].Name   := aData.mName;

  (**   // TODO: �]�����e�ɶ��榡�d�_�ʩ�,�]���Serror�~��C TODO: �T�{�Ҧ�DB�T���S���D�~�ഫ
  if (StrToIntDef( aData.mData.Value ,-1) <> -1) and
     ()then
    mDateTimeS[vIdx].Time   := StrToDate(aData.mData.Value);
  **)
  mDateTimeS[vIdx].Parent := mBox;
  mDateTimeS[vIdx].TabOrder:=aOrder;
  mDateTimeS[vIdx].Tag    := aOrder;
end;

procedure TTableEditLayout.CreateInstance_Edit(aOrder: Byte; aData:rColumnLayoutSet);
var
  vIdx: Integer;
begin
  vIdx:= Length(mEditS);

  SetLength(mEditS, vIdx+1);
  mEditS[vIdx] := TEdit.Create(mBox);
  mEditS[vIdx].Left    := aData.mRect.Left;
  mEditS[vIdx].Top     := aData.mRect.Top;
  mEditS[vIdx].Width   := cEdit_DefW;
  mEditS[vIdx].Height  := cEdit_DefH;
  mEditS[vIdx].Name    := aData.mName;
  mEditS[vIdx].Text    := aData.mText;
  mEditS[vIdx].Parent  := mBox;
  mEditS[vIdx].TabOrder:= aOrder;
  mEditS[vIdx].Tag     := aOrder;
end;

procedure TTableEditLayout.CreateInstance_Form;
begin
  try
    Application.CreateForm(TForm, mForm)
  except
    exit;
  end;    
  mForm.BorderStyle:= bsSingle;
end;

procedure TTableEditLayout.CreateInstance_ScrollBox(aOwner: TComponent);
begin
  if aOwner= nil then
    exit;
  mBox:= TScrollBox.Create(aOwner);
end;

procedure TTableEditLayout.CreateInstance_Label(aOrder: Byte; aData:rColumnLayoutSet);
var
  vIdx: Integer;
begin
  vIdx:= Length(mLabelS);

  // Label ���������, �u�O�� rColumnLayoutSet ��Ѧ�
  SetLength(mLabelS, vIdx+1);
  mLabelS[vIdx]:= TLabel.Create(mBox);
  mLabelS[vIdx].Parent  := mBox;  // TWinControl
  mLabelS[vIdx].Left    := aData.mRect.Left;
  mLabelS[vIdx].Top     := aData.mRect.Top - cLabel_Top;
  mLabelS[vIdx].Name    := Format('s%d_label', [aOrder]);
  mLabelS[vIdx].Caption := aData.mData.Name;
  mLabelS[vIdx].AutoSize:= True;
  mLabelS[vIdx].Width   := mLabelS[vIdx].Width + 10;
  mLabelS[vIdx].Tag     := aOrder;
  //mLabelS[vIdx].Color   := clSkyBlue;
end;

procedure TTableEditLayout.CreateInstance_Memo(aOrder: Byte; aData:rColumnLayoutSet);
var
  vIdx: Integer;
begin
  vIdx:= Length(mMemoS);
      
  SetLength(mMemoS, vIdx+1);
  mMemoS[vIdx] := TMemo.Create(mBox);
  mMemoS[vIdx].Left   := aData.mRect.Left;
  mMemoS[vIdx].Top    := aData.mRect.Top;
  mMemoS[vIdx].Width  := cMemo_DefW;
  mMemoS[vIdx].Height := cMemo_DefH;
  mMemoS[vIdx].Name   := aData.mName;
  mMemoS[vIdx].Text   := aData.mText;
  mMemoS[vIdx].Parent := mBox;
  mMemoS[vIdx].TabOrder:= aOrder;
  mMemoS[vIdx].Tag     := aOrder;
  mMemoS[vIdx].ScrollBars:=ssVertical;
end;

procedure TTableEditLayout.Show;
begin
  if mForm = nil then
    exit;
  if Length(mrLayoutSet) = 0 then    // �S�� layout setdata
    exit;
      
  mForm.Show;
end;

procedure TTableEditLayout.AddInstance_ScrollBox(aScrollBox: TScrollBox);
begin
  mBox:= aScrollBox;
end;

procedure TTableEditLayout.DestroyAllInstance;
var
  vLength, i : Integer;
begin
  // for save, Destroy child first
  vLength:= Length(mLabelS);
  for i:= 0 to vLength-1 do
    FreeAndNil(mLabelS[i]);
  SetLength(mLabelS,0);
  
  vLength:= Length(mMemoS);
  for i:= 0 to vLength-1 do
    FreeAndNil(mMemoS[i]);
  SetLength(mMemoS,0);

  vLength:= Length(mDateTimeS);
  for i:= 0 to vLength-1 do
    FreeAndNil(mDateTimeS[i]);
  SetLength(mDateTimeS,0);

  vLength:= Length(mEditS);
  for i:= 0 to vLength-1 do
    FreeAndNil(mEditS[i]);
  SetLength(mEditS,0);

  vLength:= Length(mComboBoxS);
  for i:= 0 to vLength-1 do
    FreeAndNil(mComboBoxS[i]);
  SetLength(mComboBoxS,0);

  vLength:= Length(mMultiComboBoxS);
  for i:= 0 to vLength-1 do
    FreeAndNil(mMultiComboBoxS[i]);
  SetLength(mMultiComboBoxS,0);

  //FreeAndNil(mBox);
  //FreeAndNil(mForm);
end;

procedure TTableEditLayout.OutputData(out aData:rTableEditDataS);
var
  i, vLength: Integer;
  vType: String;
begin
  vLength:= Length(mEditData);

  SetLength(aData, vLength);   // save all
  for i:= 0 to vLength-1 do
    aData[i]:= mEditData[i];

  // �榡����, value �|��, ���s���o, reassign
  for i:= 0 to vLength-1 do
  begin
    (** �@�� value ���B�z *)
    vType:= aData[i].ColumnType;
    if (vType='textfield') or (vType='number') or (vType = 'function') then
      aData[i].Value:= EditS[i].Text
    else if vType = 'textarea' then
      aData[i].Value:= MemoS[i].Text
    else if vType = 'date' then
      aData[i].Value:= DateTimeToStr( DateTimeS[i].Time )
    else if vType = 'selectbox' then
      aData[i].Value:= ComboBoxS[i].Text
    else if vType = 'multiselectbox' then
      aData[i].Value:= MultiComboBoxS[i].Text
    else if vType = 'checkbox' then
    begin
      // TODO:
    end
    else if vType = 'radiobox' then
    begin
      // TODO:
    end
    else
    begin
      // none type, error
    end;

    (** �۰ʦ^�� value ���B�z *)
    if aData[i].AutoFillEnable then
    begin
      aData[i].AutofillValue:= AutofillMemo[i].Text; // �ݧ�, �����Өϥ� AutofillValue=''�P�_�O�_�^��C
    end;
  end;
end;

function TTableEditLayout.GetComboBoxS(aOrder: Byte): TComboBox;
var
  i: Integer;   // ����ϥ� byte �_�h Length(xxx)-1 �p��s�ɷ|���~
begin
  result:= nil;
  for i:= 0 to Length(mComboBoxS)-1 do
  begin
    if mComboBoxS[i].Name = Format('s%d_selectbox', [aOrder]) then
    begin
      result:= mComboBoxS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetDateTimeS(aOrder: Byte): TDateTimePicker;
var
  i: Integer;   // ����ϥ� byte �_�h Length(xxx)-1 �p��s�ɷ|���~
begin
  result:= nil;
  for i:= 0 to Length(mDateTimeS)-1 do
  begin
    if mDateTimeS[i].Name = Format('s%d_date', [aOrder]) then
    begin
      result:= mDateTimeS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetEditS(aOrder: Byte): TEdit;
var
  i: Integer;   // ����ϥ� byte �_�h Length(xxx)-1 �p��s�ɷ|���~
begin
  result:= nil;
  for i:= 0 to Length(mEditS)-1 do
  begin
    if mEditS[i].Name = Format('s%d_textfield', [aOrder]) then
    begin
      result:= mEditS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetLabelS(aOrder: Byte): TLabel;
var
  i: Integer;   // ����ϥ� byte �_�h Length(xxx)-1 �p��s�ɷ|���~
begin
  result:= nil;
  for i:= 0 to Length(mLabelS)-1 do
  begin
    if mLabelS[i].Name = Format('s%d_label', [aOrder]) then
    begin
      result:= mLabelS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetMemoS(aOrder: Byte): TMemo;
var
  i: Integer;   // ����ϥ� byte �_�h Length(xxx)-1 �p��s�ɷ|���~
begin
  result:= nil;
  for i:= 0 to Length(mMemoS)-1 do
  begin
    if mMemoS[i].Name = Format('s%d_textarea', [aOrder]) then
    begin
      result:= mMemoS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetMultiComboBoxS(aOrder: Byte): TMultiComboBox;
var
  i:Integer;
begin
  result:= nil;
  for i:= 0 to Length(mMultiComboBoxS)-1 do
  begin
    if mMultiComboBoxS[i].Name = Format('s%d_multiselectboxs',[aOrder]) then
    begin
      result:= mMultiComboBoxS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetComboBoxSActive: Boolean;
var
  i, vLength: Integer;
begin
  result:= false;
  vLength:= Length(mComboBoxS);
  for i:=0 to vLength-1 do
  begin
    if (mComboBoxS[i].DroppedDown) or   // Active = DroppedDown or Focused
       (mComboBoxS[i].Focused)then      // Focused is nouse when ComboBox is csDeopDownList
    begin
      result:= true;
      exit;
    end;
  end;
end;

procedure TTableEditLayout.OnComboBoxSEnter(Sender: Tobject);
begin
  mBoxCanScroll:= False;    // ComboBox �@�Τ���, ScrollBox �T��u��
end;

procedure TTableEditLayout.OnComboBoxSExit(Sender: Tobject);
begin
  mBoxCanScroll:= True;    // ComboBox ���}��, ScrollBox �i�H�u��
end;

procedure TTableEditLayout.OnComboBoxChange(Sender: TObject);
var
  vOrder: Integer;
  vAutofillData: rMergeColumnAutofill;
  vMemo : TMemo;
begin
  /// �P�_�۰ʦ^��
  vOrder:= TComboBox(Sender).Tag;
  if LayoutSet[vOrder].mData.AutoFillEnable=false then   /// if not �}�Ҧ۰ʦ^��
    exit;

  /// if �}�Ҧ۰ʦ^��
  if LayoutSet[vOrder].mData.AutofillData.TriggerString = TComboBox(Sender).Text then /// if Ĳ�o�r��۲ŦX
  begin
    vAutofillData:= LayoutSet[vOrder].mData.AutofillData;

    /// �إߦ۰ʦ^�� textarea ���
    if vAutofillData.TriggerColumnType='textarea' then
    begin
      vMemo:= CreateInstance_Memo( Format('s%d_textarea_autofill', [vOrder]), /// Name
                           LayoutSet[vOrder].mRect.Left,             // X
                           LayoutSet[vOrder].mRect.Bottom + cBlock_Padding.Bottom, // Y
                           cMemo_DefW,
                           cMemo_DefH );
      mBox.Height:= LayoutSet[vOrder].mRect.Bottom+ cBlock_Padding.Top + cBlock_Padding.Bottom + cMemo_DefH;
      mForm.Height:= mBox.Height + cBox_Padding.Top + cBox_Padding.Bottom ;
      /// �ثe TableModel �S���ڭn����� = MTableName, �]���ϥ� gTableControlPanel, �ݧ� S.H: 2010.0415
      vMemo.Text:= Format('�����N�۰ʦ^��i%s�j', [gTableControlPanel.MergeTableData[ vAutofillData.DestMergeTableID ].Name]);
    end

    /// �إߦ۰ʦ^�� textfield ���
    else if vAutofillData.TriggerColumnType='textfield'then
    begin
      // TODO:
    end;
  end
  else  /// if Ĳ�o�r��  ���۲ŦX
  begin
    mBox.Height:= LayoutSet[vOrder].mRect.Bottom;
    mForm.Height:= mBox.Height+cBox_Padding.Top+cBox_Padding.Bottom ;

    vMemo := GetMemoByName(Format('s%d_textarea_autofill', [vOrder]));
    if vMemo <> nil then
      vMemo.Text:= '';  // �۰ʦ^��M��
  end;
end;

procedure TTableEditLayout.OnMultiComboBoxSChange(Sender: TObject);
begin
  //
end;

procedure TTableEditLayout.OnComboFormClose(Sender: TObject; var Action: TCloseAction);
begin
  mBoxCanScroll:= True;    // �������}��, ���] ScrollBox �i�H�u��
end;

function TTableEditLayout.GetLayoutSet(aOrder: Byte): rColumnLayoutSet;
begin
  fillchar(result, sizeof(rColumnLayoutSet),0);
  if aOrder >= Length(mrLayoutSet) then
    exit;
  result:= mrLayoutSet[aOrder];
end;

function TTableEditLayout.CreateInstance_Memo(aName: String; aX, aY, aW,aH: Integer):TMemo;
var
  vIdx: Integer;
  vMemo: TMemo;
begin
  result:= nil;
  try
    vMemo := GetMemoByName(aName);
    if vMemo=nil then            // �Ӥ��󤣦s�b
    begin
      vIdx:= Length(mMemoS);
      SetLength(mMemoS, vIdx+1);
      mMemoS[vIdx] := TMemo.Create(mBox);

      vMemo:= mMemoS[vIdx];
    end;
  
    vMemo.Left      := aX;
    vMemo.Top       := aY;
    vMemo.Width     := aW;
    vMemo.Height    := aH;
    vMemo.Name      := aName;
    vMemo.Parent    := mBox;
    vMemo.ScrollBars:=ssVertical;
    result:= vMemo;
  except
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;
end;

function TTableEditLayout.GetMemoByName(aName: String): TMemo;
var
  i: Integer;
begin
  result:= nil;
  for i:= 0 to Length(mMemoS)-1 do
  begin
    if mMemoS[i].Name = aName then
    begin
      result:= mMemoS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.GetAutofillMemo(aOrder: Byte): TMemo;
var
  i: Integer;   // ����ϥ� byte �_�h Length(xxx)-1 �p��s�ɷ|���~
begin
  result:= nil;
  for i:= 0 to Length(mMemoS)-1 do
  begin
    if mMemoS[i].Name = Format('s%d_textarea_autofill', [aOrder]) then
    begin
      result:= mMemoS[i];
      exit;
    end;
  end;
end;

function TTableEditLayout.FuncString(aStr: String): String;
begin
  result:=aStr;
  if aStr= '@NOW()' then
    result:= GetClientDateTime;
  (**
  else if aStr= '@SELFNAME()' then
    result:=
    **)
end;

function TTableEditLayout.IsFuncString(aStr: String): Boolean;
begin
  result:= false;
  if copy(aStr,0,1)='@' then // function flag = '@'
  begin
    result:= true;
  end;
end;

{ TTableEditor }

procedure TTableEditor.Arrange;
begin
  mLayout.Arrange(mFormat.mData);
end;

constructor TTableEditor.Create;
begin
  mLayout:= TTableEditLayout.Create;
  mFormat:= TTableEditFormat.Create;

  // Set Layout UI
  mLayout.AddInstance_Form(gTableEditorForm);
  mLayout.AddInstance_ScrollBox(gTableEditorForm.mEditorBox);
  mLayout.BTNConfirm:= gTableEditorForm.mBTNConfirm;
  mLayout.BTNConfirm.OnClick:= OnConfirmClick;
  mLayout.mBox.OnMouseWheel:= OnBoxMouseWheel;

  mLayout.Form.BorderStyle:= bsSingle;
  mLayout.Form.Caption    := '�@�Ѫ��s - ���s�W�ק�';
end;

procedure TTableEditor.TriggerShow(aRSetColumn: TRecordSet);
begin
  mMode:= temNew; 
  Format.Fetch(aRSetColumn);
  Arrange;
  Layout.Show;
end;

procedure TTableEditor.OnConfirmClick(Sender: Tobject);
var
  vLogID, i, vRowID : Integer;
  vNewData : rTableEditDataS;
  vValueList: TStringList;
begin
  Layout.OutputData( vNewData );     // ��X UI Layout �������

  case mMode of
    temNew:
    begin
      vValueList:= TStringList.Create;
      for i:=0 to Length(vNewData)-1 do
      begin
        vValueList.Add( vNewData[i].Value );
      end;
      
      vRowID := gDBManager.GetMergeColumnvalue_ID(Format.TableID, 'max');
      Inc(vRowID);
      gMergeTableHandler.NewRow(Format.TableID, vRowID, vValueList);  //�s�W�@�����
    end;

    temMod:
    begin
      if Format.DataValueCompare(vNewData) then   // �s��� & �¸�� ��� + �簣�C
      begin
        vLogID := gMergeTableHandler.CreateLog(Format.TableID, ltMod);
        for i:=0 to Format.NewDataNums-1 do
        begin
          gMergeTableHandler.ModifyColumnvalue(vLogID, Format.TableID,          //�ק�@�����
            Format.NewData[i].ColumnID, Format.NewData[i].RowID, Format.NewData[i].Value);

          (***�@ �۰ʦ^��P�_!�@***)
          if Format.NewData[i].AutoFillEnable=true then
          if Format.NewData[i].AutoFillValue<>'' then
          begin
            vValueList:= Format.AutofillDataToValueList(i);
            vRowID := gDBManager.GetMergeColumnvalue_ID(Format.NewData[i].AutofillData.DestMergeTableID, 'max');
            Inc(vRowID);
            gMergeTableHandler.NewRow(Format.NewData[i].AutofillData.DestMergeTableID,
                                      vRowID, vValueList);  //�s�W�@�����
          end;
        end;

        if GridManage.IsSelect then     
          GridManage.TriggerGridCancelSearch;  // �]���z��Ҧ��U���H���� mSearchTable��s�A�]���Ȯɱj��ϥΪ� cancel search�Aauto check value update�ثe�u���b�D�z��Ҧ��~���@��   2010.04.14 S.H: �ݧR
      end;
    end;
  end;

  Layout.Form.Hide;
  GridManage.Update;  // todo.. �٬O�ޥΨ�~�� grid �F..
end;

procedure TTableEditor.TriggerShow(aRSetColumn, aRSetValue: TRecordSet;
  aCol, aRow: Integer);
begin
  mMode:= temMod; 
  Format.Fetch(aRSetColumn, aRSetValue, aCol, aRow);
  Arrange;
  Layout.Show;
end;

procedure TTableEditor.TriggerShow(aColumnS: IColumnS);
begin
  /// ��l��  �s�褶���� �۰ʦ^��޲z��
  if mFormat.AutoFiller.Initialized=false then
    mFormat.AutoFiller.InitializeData;

  mMode:= temNew;  // �s�W
  Format.Fetch(aColumnS);
  Arrange;
  Layout.Show;
end;

procedure TTableEditor.TriggerShow(aColumnS: IColumnS; aValue: String;
  aCol, aRow: Integer);
begin
  /// ��l��  �s�褶���� �۰ʦ^��޲z��
  if mFormat.AutoFiller.Initialized=false then
    mFormat.AutoFiller.InitializeData;
    
  mMode:= temMod;  // �ק�
  Format.Fetch(aColumnS, aValue, aCol, aRow);
  Arrange;
  Layout.Show;
end;

procedure TTableEditor.OnBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if Layout.ComboBoxSDropDown then  /// ComboBox�@�Τ�,�u���\��u�v�T�� ComboBox�C���O�u���L�@�ΡC
    exit;
  if Layout.BoxCanScroll=false then /// Layout���� Box���� scroll ���ɭ�
    exit;
    
  if (WheelDelta > 0) then
  begin
    TScrollBox(Sender).VertScrollBar.Position :=
      TScrollBox(Sender).VertScrollBar.Position-cMouseWheel_Size; //TScrollBox(Sender).VertScrollBar.InstanceSize;
  end;
  if (wheelDelta < 0) then
  begin
    TScrollBox(Sender).VertScrollBar.Position:=
      TScrollBox(Sender).VertScrollBar.Position+cMouseWheel_Size; //TScrollBox(Sender).VertScrollBar.InstanceSize;
  end;
end;

{ TTableEditFormat }

function TTableEditFormat.AutofillDataToValueList(aCount: Integer): TStringList;
type
  rIDSet= record
    mSrcID,mDestID:Integer
  end;
var                             
  mEditData: rTableEditData;
  i, vIdx, vDestTable_ColumnNums: Integer;
  vIDList_1, vIDList_2: TStringList;
  arIDSet: array of rIDSet;
  vSourceTableModel: TTableModel;
  aRSet:TRecordSet;
begin
  result:= TStringList.Create;
  if aCount < 0 then
    exit;
  if aCount >= Length(mNewData) then
    exit;

  mEditData:= mNewData[aCount];  

  /// �ѪR autofill_mergecolumn_id_set  ���W�h
  vIDList_1:= SplitString(mEditData.AutofillData.MergeColumnIDSet, ',');  // ex: 1=>1,3=>2,19=>5
  SetLength(arIDSet,vIDList_1.Count);
  for i:=0 to vIDList_1.Count-1 do
  begin
    vIDList_2:= SplitString( vIDList_1[i] ,'=>');

    arIDSet[i].mSrcID := StrToInt(vIDList_2[0]);    // 19=>5  �e�̬��ӷ�ID
    arIDSet[i].mDestID:= StrToInt(vIDList_2[1]);    // 19=>5  ��̬��ؼ�ID
  end;

  vIdx:=0;
  vSourceTableModel    := GridManage.TableManager.MrgTableS[ mEditData.AutofillData.TriggerMergeTableID ];
  /// �ѩ� TableModel �u��q current table ���o�˵����� data, �]���Ȯɨϥ� recordset
  aRSet:= gDBManager.GetMergeTable_ColumnS(mEditData.AutofillData.DestMergeTableID);
  vDestTable_ColumnNums:= aRSet.RowNums;
  //vDestTableModel  := GridManage.TableManager.MrgTableS[ mEditData.AutofillData.DestMergeTableID ];

  freeandnil(aRSet);
  for i:=0 to vDestTable_ColumnNums-1 do  /// ���o�ت� dest �� column����
  begin
    if (vIdx < Length(arIDSet)) and        // not ocerflow
       (arIDSet[vIdx].mDestID = i+1) then  // id �۲�
    begin
      if arIDSet[vIdx].mSrcID<>0 then
      begin
        aRSet:= gDBManager.GetMergeTable_ColumnvalueS(mEditData.AutofillData.TriggerMergeTableID,
                                                      '', arIDSet[vIdx].mSrcID, mEditData.RowID );
        //result.Add( vSourceTableModel.Row[mEditData.RowID-1].Columns[arIDSet[vIdx].mSrcID-1].Value ); // tablemodel�����i�� ,�]�� mergetable �Ȧs���c
        result.Add( aRSet.Row[0,'value'] );    /// ���X�򥦦P�@�C�� ��L��쪺 value
      end
      else
      begin
        result.Add('CURRENT_TIMESTAMP()');
      end;
      Inc(vIdx);
      freeandnil(aRSet);
    end
    else if mEditData.AutofillData.DestMergeColumnID = i+1 then
    begin
      result.Add(mEditData.AutofillValue);
    end
    else
      result.Add(''); // �Ŧr��
  end;
end;

procedure TTableEditFormat.Clear;
begin
  fillchar(mData, sizeof(mData), 0);
  SetLength(mData,0);
end;

constructor TTableEditFormat.Create;
begin
  mAutoFillManager:= TAutofillManager.Create;
end;

function TTableEditFormat.DataValueCompare(
  var aSourceData: rTableEditDataS; aIfSave: Boolean):boolean;
var
  i, vIdx, vLength: Integer;
  vDestData: rTableEditDataS;
begin
  Result:= false ;
  if Length(mData) <> Length(aSourceData) then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditFormat.DataValueCompare error!!');
{$endif}
    exit;
  end;

  vIdx   := 0;
  vLength:= Length(aSourceData);
  for i:= 0 to vLength-1 do
  begin
    if (aSourceData[i].Value <> mData[i].Value) or    // �s��ت� value ���P, �x�s
       (aSourceData[i].AutofillValue<>'')then         // �s��ت� value �ۦP, ���O���۰ʦ^���ݩ�, �@��
    begin
      SetLength(vDestData, vIdx+1);
      vDestData[vIdx]:= aSourceData[i];
      Inc(vIdx);
      Result:= true ;      
    end;
  end;

  if aIfSave = True then  // �x�s�� mNewData
    SaveNewData(vDestData)
  else                    // �����^��
  begin
    fillChar(aSourceData,SizeOf(aSourceData),0);
    vLength:= Length(vDestData);
    for i:= 0 to vLength-1 do
    begin
      aSourceData[i]:= vDestData[i];
    end;
  end;    
end;

procedure TTableEditFormat.Fetch(arMColumnS: array of rMergeColumn;
  arMColumnValueS: array of rMergeColumnValue);
begin
  // Todo:
  //SetLength(mColumnS, Length(arMColumnS));
  //move(arMColumnS,mColumnS,sizeof(arMColumnS));
end;

procedure TTableEditFormat.Fetch(aRSetColumn: TRecordSet);
var
  i: Integer;
begin
  Clear;
  if aRSetColumn= nil then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditFormat.Fetch error !!');
{$endif}
    exit;
  end;

  SetLength(mData, aRSetColumn.RowNums);
  for i:=0 to aRSetColumn.RowNums-1 do
  begin
    mData[i].TableID     := StrToIntDef(aRSetColumn.Row[i,'mergetable_id'],0);
    mData[i].ColumnID    := StrToIntDef(aRSetColumn.Row[i,'mergecolumn_id'],0);
    mData[i].RowID       := 0;  // New Row
    mData[i].ColumnType  := aRSetColumn.Row[i,'mergecolumn_type'];
    mData[i].TypeSet     := aRSetColumn.Row[i,'mergecolumn_typeset'];
    mData[i].Value       := ''; // New Row
    mData[i].CreateUserID:= StrToIntDef(aRSetColumn.Row[i,'mergecolumn_create_user_id'],0);
    mData[i].CreateTime  := aRSetColumn.Row[i,'mergecolumn_create_time'];
    mData[i].PositionID  := StrToIntDef(aRSetColumn.Row[i,'mergecolumn_position_id'],0);
    mData[i].Priority    := StrToIntDef(aRSetColumn.Row[i,'mergecolumn_priority'],0);
    mData[i].Name        := aRSetColumn.Row[i,'column_name'];
  end;

  mTableID:= mData[0].TableID;
end;

procedure TTableEditFormat.Fetch(aRSetColumn: TRecordSet; aRSetValue: TRecordSet;aCol,aRow: Integer);
var
  i, j: Integer;
begin
  Clear;
  if (aRSetColumn= nil) or (aRSetValue= nil) then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditFormat.Fetch error !!');
{$endif}
    exit;
  end;

  if (aRSetValue.RowNums mod aRSetColumn.RowNums) <> 0 then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditFormat.Fetch error !!');
{$endif}
    exit;
  end;

  SetLength(mData, 1);

  i:= aCol-1;
  mData[0].TableID     := StrToIntDef(aRSetColumn.Row[i,'mergetable_id'],0);
  mData[0].ColumnID    := StrToIntDef(aRSetColumn.Row[i,'mergecolumn_id'],0);
  mData[0].RowID       := aRow;
  mData[0].ColumnType  := aRSetColumn.Row[i,'mergecolumn_type'];
  mData[0].TypeSet     := aRSetColumn.Row[i,'mergecolumn_typeset'];
  mData[0].CreateUserID:= StrToIntDef(aRSetColumn.Row[i,'mergecolumn_create_user_id'],0);
  mData[0].CreateTime  := aRSetColumn.Row[i,'mergecolumn_create_time'];
  mData[0].PositionID  := StrToIntDef(aRSetColumn.Row[i,'mergecolumn_position_id'],0);
  mData[0].Priority    := StrToIntDef(aRSetColumn.Row[i,'mergecolumn_priority'],0);
  mData[0].Name        := aRSetColumn.Row[i,'column_name'];

  for j:=0 to aRSetValue.RowNums-1 do
  begin
    if (aRSetColumn.Row[i,'mergetable_id']  = aRSetValue.Row[j,'mergetable_id']) and
       (aRSetColumn.Row[i,'mergecolumn_id'] = aRSetValue.Row[j,'mergecolumn_id']) and
       (mData[0].RowID  = StrToInt(aRSetValue.Row[j,'column_row_id']) ) then
    mData[0].Value := aRSetValue.Row[j,'value'];
  end;

  mTableID:= mData[0].TableID;
end;

procedure TTableEditFormat.Fetch(aColumnS: IColumnS);
var
  i: Integer;
begin
  Clear;
  if aColumnS= nil then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditFormat.Fetch error !!');
{$endif}
    exit;
  end;

  if mAutoFillManager.Initialized=false then    /// ���u���ˬd, �p�G�|����l, �i��data��l
    mAutoFillManager.InitializeData;

  SetLength(mData, aColumnS.Count);
  for i:=0 to aColumnS.Count-1 do
  begin
    mData[i].TableID     :=  aColumnS.Data[i].MTableID ;
    mData[i].ColumnID    :=  aColumnS.Data[i].MColumnID ;
    mData[i].RowID       :=  0 ;     // New Row
    mData[i].ColumnType  :=  aColumnS.Data[i].ColumnType ;
    mData[i].TypeSet     :=  aColumnS.Data[i].TypeSet ;
    mData[i].Value       :=  '' ;    // New Row
    mData[i].CreateUserID:=  aColumnS.Data[i].CreateUserID ;
    mData[i].CreateTime  :=  aColumnS.Data[i].CreateTime ;
    mData[i].PositionID  :=  aColumnS.Data[i].PositionID ;
    mData[i].Priority    :=  aColumnS.Data[i].Priority ;
    mData[i].Name        :=  aColumnS.Data[i].ColumnName ;
  end;

  mTableID:= mData[0].TableID;

end;

procedure TTableEditFormat.Fetch(aColumnS: IColumnS; aValue: String; aCol,
  aRow: Integer);
var
  i: Integer;
begin
  Clear;
  if aColumnS= nil then
  begin
{$ifdef Debug}
    ShowMessage('TTableEditFormat.Fetch error !!');
{$endif}
    exit;
  end;

  if mAutoFillManager.Initialized=false then    /// ���u���ˬd, �p�G�|����l, �i��data��l
    mAutoFillManager.InitializeData;
    
  SetLength(mData, 1);
  i:= aCol-1;
  mData[0].TableID      :=  aColumnS.Data[i].MTableID ;
  mData[0].ColumnID     :=  aColumnS.Data[i].MColumnID ;
  mData[0].RowID        :=  aRow;       // Not New Row
  mData[0].ColumnType   :=  aColumnS.Data[i].ColumnType ;
  mData[0].TypeSet      :=  aColumnS.Data[i].TypeSet ;
  mData[0].Value        :=  aValue ;    // Not New Row
  mData[0].CreateUserID :=  aColumnS.Data[i].CreateUserID ;
  mData[0].CreateTime   :=  aColumnS.Data[i].CreateTime ;
  mData[0].PositionID   :=  aColumnS.Data[i].PositionID ;
  mData[0].Priority     :=  aColumnS.Data[i].Priority ;
  mData[0].Name         :=  aColumnS.Data[i].ColumnName ;
  (* �H�U = �۰ʦ^�񪺸�� *)
  mData[0].AutofillEnable:=  mAutoFillManager.HasAutoFill[aColumnS.Data[i].MTableID, aColumnS.Data[i].MColumnID];
  mData[0].AutofillValue :=  '';                                                // �̷ӥ��e�n�D, �۰ʦ^�����@�{�M�šC
  mData[0].AutofillData  :=  mAutoFillManager.Data[aColumnS.Data[i].MTableID,   // Ĳ�o�]�w��
                                                   aColumnS.Data[i].MColumnID];
  
  mTableID:= mData[0].TableID;
end;

function TTableEditFormat.GetColumn(aCount: Integer): rMergeColumn;
begin
  if aCount < 0 then
    exit;
end;

function TTableEditFormat.GetData(aCount: Integer): rTableEditData;
begin
  if aCount < 0 then
    exit;
  result:= mData[aCount];  
end;

function TTableEditFormat.GetDesc(aCount: Integer): String;
begin
  result:= '';
  if aCount < 0 then
    exit;
    
end;

function TTableEditFormat.GetNewData(aCount: Integer): rTableEditData;
begin
  if aCount < 0 then
    exit;
    
  result:= mNewData[aCount];
end;

function TTableEditFormat.GetNewDataNums: Integer;
begin
  result:= length(mNewData);
end;

procedure TTableEditFormat.SaveNewData(aData: rTableEditDataS);
var
  i, vLength: Integer;
begin
  fillChar(mNewData, Sizeof(mNewData), 0);

  vLength:= Length(aData);
  SetLength(mNewData, vLength);

  for i:= 0 to vLength-1 do
  begin
    mNewData[i]:= aData[i];
  end;
end;

{ TMultiComboBox }

constructor TMultiComboBox.Create(aOwner: TWinControl; aComboBoxNumS: Byte; aOrder:Byte);
var
  i:Integer;
begin
  mOutputMemo  := TMemo.Create(aOwner);
  mOutputMemo.Parent  := aOwner;
  mOutputMemo.ReadOnly:= true;
  mOutputMemo.TabOrder:= aOrder;

  mComboBoxNums:= aComboBoxNums;
  SetLength(mComboboxS, mComboBoxNums);
  for i:=0 to mComboBoxNums-1 do
  begin
    mComboboxS[i]:= TCombobox.Create(aOwner);
    mComboboxS[i].Parent   := aOwner;
    mComboboxS[i].Style    := csDropDownList;
    mComboboxS[i].OnChange := OnComboBoxChange;
    mComboboxS[i].OnKeyDown:= OnComboBoxKeyDown;
  end;
end;

function TMultiComboBox.GetEditColor: TColor;
begin
  result:=mOutputMemo.Color;
end;

function TMultiComboBox.GetEditText: String;
begin
  result:=mOutputMemo.Text;
end;

procedure TMultiComboBox.SetEditText(const Value: String);
var
  vList: TStringList;
  i: Integer;
begin
  mOutputMemo.Text:= Value;

  if Value = '' then
    exit;
    
  vList:= SplitString(Value,'�B');

  for i:=0 to min(vList.Count,mComboBoxNums)-1 do      // �w�� out of index, use min
  begin
    mComboBoxS[i].ItemIndex:= mComboBoxS[i].Items.IndexOf(vList[i]);
  end;
end;

function TMultiComboBox.GetNameS: TComponentName;
begin
  result:= mOutputMemo.Name;
end;

procedure TMultiComboBox.OnComboBoxChange(Sender: TObject);
begin
  RefreshOutputEdit;
end;

procedure TMultiComboBox.OnComboBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_Delete: TComboBox(Sender).ItemIndex:=0;
  end;

  RefreshOutputEdit; 
end;

procedure TMultiComboBox.RefreshOutputEdit;
var
  vLength, i: Integer;
  vList: TStringList;
begin
  mOutputMemo.Text:= '';
                                     
  vLength:= Length(mComboBoxS);
  vList  := TStringList.Create;
  for i:=0 to vLength-1 do
  begin
    if mComboBoxS[i].Text<>'' then    // ���X�D�Ū���
       vList.Add(mComboBoxS[i].Text);
  end;

  mOutputMemo.Text:= ImplodeString(vList,'�B');
end;

procedure TMultiComboBox.SetEditColor(const Value: TColor);
begin
  mOutputMemo.Color:= Value;
end;

procedure TMultiComboBox.SetList(aList: TStringList);
var
  vLength, i, j :Integer;
begin
  vLength:= Length(mComboboxS);
  for i:=0 to vLength-1 do
  begin
    for j:=0 to aList.Count-1 do
    begin
      mComboboxS[i].Items.Add(aList[j]);
    end;  
  end;
end;

procedure TMultiComboBox.SetNameS(const Value: TComponentName);
var
  vLength,i: Integer;  
begin
  mOutputMemo.Name:= Value;

  vLength:= Length(mComboboxS);
  for i:=0 to vLength-1 do
    mComboBoxS[i].Name:= Format('%s_%d',[Value,i])
end;

procedure TMultiComboBox.SetPosition(const Value: TPoint);
begin
  if mOutputMemo = nil then
    exit;
end;

procedure TMultiComboBox.SetPosSize(aLeft, aTop, aWidth, aHeight, aComboW,
  aComboH: Integer);
var
  vLength,i: Integer;  
begin
  mOutputMemo.Left  := aLeft;
  mOutputMemo.Top   := aTop;
  mOutputMemo.Width := aWidth;
  mOutputMemo.Height:= aHeight;

  vLength:= Length(mComboboxS);
  for i:=0 to vLength-1 do
  begin
    mComboBoxS[i].Left   := mOutputMemo.Left + ((i mod 2)*aComboW);
    mComboBoxS[i].Top    := mOutputMemo.Top  + aHeight + (((i div 2))*aComboH);
    mComboBoxS[i].Width  := aComboW;
    mComboBoxS[i].Height := aComboH;
  end;
end;

destructor TMultiComboBox.Destroy;
var
  i, vLength:Integer;
begin
  freeandnil(mOutputMemo);
  freeandnil(mPosition);

  vLength:= Length(mComboBoxS);
  for i:=0 to vLength-1 do
  begin
    freeandnil(mComboBoxS[i]);
  end;
  SetLength(mComboBoxS,0); // delphi   will(not!!!)   free   memory   automatically
end;

procedure TMultiComboBox.SetComboboxSOnEnter(const Value: TNotifyEvent);
var
  vLength,i: Integer;  
begin
  vLength:= Length(mComboboxS);
  for i:=0 to vLength-1 do
    mComboBoxS[i].OnEnter:= Value;
end;

procedure TMultiComboBox.SetComboboxSOnExit(const Value: TNotifyEvent);
var
  vLength,i: Integer;  
begin
  vLength:= Length(mComboboxS);
  for i:=0 to vLength-1 do
    mComboBoxS[i].OnExit:= Value;
end;

{ TAutofillManager }

procedure TAutofillManager.Add(aRSet: TRecordSet);
var
  i: Integer;
begin
  SetLength(mData,aRSet.RowNums);
  for i:=0 to aRSet.RowNums-1 do
  begin
    mData[i].ID                   := StrToInt(aRSet.Row[i,'autofill_id']);
    mData[i].MergeColumnIDSet     := aRSet.Row[i,'autofill_mergecolumn_id_set'];
    mData[i].TriggerString        := aRSet.Row[i,'autofill_trigger_string'];
    mData[i].TriggerMergeTableID  := StrToInt(aRSet.Row[i,'autofill_trigger_mergetable_id']);
    mData[i].TriggerMergeColumnID := StrToInt(aRSet.Row[i,'autofill_trigger_mergecolumn_id']);
    mData[i].TriggerColumnType    := aRSet.Row[i,'autofill_trigger_columntype'];
    mData[i].DestMergeTableID     := StrToInt(aRSet.Row[i,'autofill_dest_mergetable_id']);
    mData[i].DestMergeColumnID    := StrToInt(aRSet.Row[i,'autofill_dest_mergecolumn_id']);
  end;
end;

function TAutofillManager.GetData(aMTableID,aMColumnID: Integer): rMergeColumnAutofill;
var
  i, vLength: Integer;
begin
  fillchar(result,sizeof(rMergeColumnAutofill),0);
  vLength:= Length(mData);
  for i:=0 to vLength-1 do
  begin
    if (mData[i].TriggerMergeTableID=aMTableID) and
       (mData[i].TriggerMergeColumnID=aMColumnID) then
    begin
      result:= mData[i];
      exit;
    end;
  end;
end;

function TAutofillManager.GetHasAutofill(aMTableID,aMColumnID: Integer): Boolean;
var
  i, vLength: Integer;
begin
  result:= false;
  vLength:= Length(mData);
  for i:=0 to vLength-1 do
  begin
    if (mData[i].TriggerMergeTableID=aMTableID) and
       (mData[i].TriggerMergeColumnID=aMColumnID) then
    begin
      result:= true;
      exit;
    end;
  end;
end;

function TAutofillManager.GetInitialized: Boolean;
begin
  result:= false;
  if Length(mData)<> 0 then
    result:= true;
end;

procedure TAutofillManager.InitializeData;
begin
  Add(gDBManager.GetMergeColumnAutofill);
end;

end.
