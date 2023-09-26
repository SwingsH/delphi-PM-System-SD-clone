unit CommonSaveRecord;
(********************************************************
 * �t�Φ@�Ϊ� Record ���A
 * @Author Swings Huang (2010/02/25 �s�W)
 * @Todo
 ********************************************************)
interface

uses
  SQLConnecter;

type
  (********************************************************
   * �ΨӦs�� ComboBox ����T
   ********************************************************)
  rComboSave = record
    ID  : Integer;      /// reference ID, ���� database �� id
    Name: String;       /// combo ��ܤ�r
  end;

  (********************************************************
   * ���� SQL DB ���x�s���� - �M��
   ********************************************************)
  rProject = record
    ID  : Integer;
    Name: String;
    LeaderUserID: Integer;
    Description: String;
  end;

  (********************************************************
   * ���� SQL DB ���x�s���� - �`�X���
   ********************************************************)
  rMergeTable = record
    ID  : Integer;
    TemplateID: Integer;       // �`���� ID 1.�|�X�@�`��
    Name: String;
    Description: String;       // �X�֪�满��
    CreateUserID: Integer;     // �إߦX�֪�檺�ϥΪ�ID
    CreateOrganizeID: Integer; // �X�֪����ݪ���´(����H�ƽհ�,���ݥH��´���D)
    CreateProjectID:Integer;   // �X�֪��ҹ������M��
    CreateTime: String;        // �X�֪��إ߮ɶ�
    Expire_time:String;        // �X�֪��L���ɶ�
  end;

  (********************************************************
   * ���� SQL DB ���x�s���� - �l���
   ********************************************************)
  rTable = record
    ID               : Integer;
    TemplateID       : Integer;       // ��檩�� ID 1.�����i�ת�
    Name             : String;
    Description      : String;        // ��满��
    CreateUserID     : Integer;       // �إߪ�檺�ϥΪ�ID
    CreateOrganizeID : Integer;       // �����ݪ���´(����H�ƽհ�,���ݥH��´���D)
    CreateProjectID  : Integer;       // ���ҹ������M��
    CreateTime       : String;        // ���إ߮ɶ�
    Expire_time      : String;        // ���L���ɶ�
  end;

  (********************************************************
   * ���� SQL DB ���x�s���� - �`�X������
   ********************************************************)
   rMergeColumn = record
     MrgTableID  : Integer; // �`������� ID PK
     MrgColumnID : Integer; // �`������� ID PK
     TableID     : Integer; // �ӷ����l��� ID PK
     ColumnID    : Integer; // �ӷ����l��� ID
     CreateUserID: Integer; // �X�֪��إߪ�ID
     CreateTime  : String;  // �X�֪��إ߮ɶ�
     PositionID  : Integer; // �i�s����¾�Ȩ��� ID - mergecolumn_id �P, ¾�� ID ��P..�H�� 2NF..
     Priority    : Integer; // �s���̧C�v��-�ݬd�ߨϥΪ̦b�M�ת��v�Q����
     ColumnType  : String;
     TypeSet     : String;
     Name        : String;  // extra
   end;

  (********************************************************
   * ���� SQL DB ���x�s���� - ������ extra = column + mergecolumn �q�Ϋ��A
   ********************************************************)
   rColumnEx = record
     TableID     : Integer; // �`������� ID PK
     ColumnID    : Integer; // �`������� ID PK
     ColumnName  : String;  // �ӷ����l��� ID PK
     ColumnDesc  : String;  // �ӷ����l��� ID
     CreateUserID: Integer; // �X�֪��إߪ�ID
     CreateTime  : String;  // �X�֪��إ߮ɶ�
     Priority    : Integer; // �s���̧C�v��-�ݬd�ߨϥΪ̦b�M�ת��v�Q����
     ColumnType  : String;
     TypeSet     : String;
     Width       : Integer;
     Height      : Integer;
     (** Extra *)
     MTableID    : Integer;
     MColumnID   : Integer;
     PositionID  : Integer; // mergecolumn_position_id
   end;
   
  (********************************************************
   * [�ѷ�] SQL DB ���x�s���� - ��檺���� & �X�֪�檺����
   *        2010.03.12 DB �W��ڨS�� MergeColumnValue �o�� TB Schema
   ********************************************************)
   rMergeColumnValue = record
     TableID     : Integer; // �`�� ID PK
     ColumnID    : Integer; // �`����� ID
     RowID       : Integer; // �`��C�� ID
     Value       : String;
     DateTime    : String;
   end;

  (********************************************************
   * ���� SQL DB ���x�s���� - �`��, ��V�۰ʦ^��W�h
   ********************************************************)
   rMergeColumnAutofill = record
     ID                  : Integer;
     MergeColumnIDSet    : String;
     TriggerString       : String;
     TriggerMergeTableID : Integer;
     TriggerMergeColumnID: Integer;
     TriggerColumnType   : String;
     DestMergeTableID    : Integer;
     DestMergeColumnID   : Integer;
   end;

implementation

end.
