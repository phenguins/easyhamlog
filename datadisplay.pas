unit datadisplay;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  DbCtrls, db;

type

  { TDynDataForm }

  TDynDataForm = class(TForm)
    DBEdit1: TDBEdit;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
       CtrlArry:TStrings;
  protected
     procedure   BuildForm;
  public
     //procedure   BuildForm;
     constructor Create(AOwner:TComponent);override;
     destructor  Destroy;override;   { public declarations }
  end; 

var
  DynDataForm: TDynDataForm;

implementation
uses dm;
{ TDynDataForm }



constructor TDynDataForm.Create(AOwner:TComponent);
begin
   inherited;
   CtrlArry:=TStringList.Create;
end;

destructor TDynDataForm.Destroy;
begin
   while CtrlArry.count>0 do begin
         CtrlArry.Objects[CtrlArry.count-1].free;
         CtrlArry.delete(CtrlArry.count-1);
   end;
   //inherited;
end;

procedure TDynDataForm.FormCreate(Sender: TObject);
begin
  dm.dm1.qry2.Close;
  dm.dm1.qry2.SQL.text:='select * from [main]';
  dm.dm1.qry2.open;
  self.BuildForm;
end;

procedure TDynDataForm.BuildForm;
var i:integer;
    tmpctrl:TWinControl;
begin
    //if you do want this order
    //you can use a TList to change the order
    for i:=0 to dm1.DS2.DataSet.FieldCount-1 do begin
        case dm1.DS2.DataSet.Fields[i].DataType of
             ftstring:begin
                      tmpctrl:=TDBEdit.Create(self);
                      tmpctrl.Parent:=self;
                      tmpctrl.Top:=i*25;
                      tmpctrl.height:=15;

                      //do something that you want
                      //and assign tmpctrl property
                      end;
             ftMemo: begin
                      tmpctrl:=TDBMemo.Create(self);
                      tmpctrl.Parent:=self;
                      tmpctrl.Top:=i*25;
                      tmpctrl.height:=15;
                      //do something that you want
                      //and assign tmpctrl property
                      end;
        end;
             //add you case
    CtrlArry.AddObject(dm1.DS2.DataSet.Fields[i].FieldName,tmpCtrl);
    end;

end;


initialization
  {$I datadisplay.lrs}

end.

