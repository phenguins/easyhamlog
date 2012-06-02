unit itemselect;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  CheckLst, Buttons, StdCtrls,inifiles;

type

  { Tfrm_itemselect }

  Tfrm_itemselect = class(TForm)
    Button1: TButton;
    CheckListBox1: TCheckListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frm_itemselect: Tfrm_itemselect;
  logitem:tstringlist;
  setini:Tinifile;
implementation
uses dm;

{ Tfrm_itemselect }

procedure Tfrm_itemselect.FormCreate(Sender: TObject);
var i:integer;
   //st:tstringlist;
   Fn: String;
begin
   with dm1.qry1 do
  try
    Close;
    SQL.Text := 'select * from main';
    open;
    update;
    dm1.DS1.DataSet.Fields.GetFieldNames(checklistbox1.Items);
  finally
    Close;
    sql.Clear;

  end;
  //try
  //  logitem:=tstringlist.create;
  //  checklistbox1.Items.AssignTo(logitem);
  //    st:=tstringlist.create;
  //    Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  //    setini:=Tinifile.Create(fn);
  //    setini.readsection('Logsec',st);
  //    for i:=0 to st.Count-1 do
  //     if st[i].value=
  //finally
  //  logitem.free;
  //  st.free;
  //end;

end;


procedure Tfrm_itemselect.Button1Click(Sender: TObject);
var i:integer;
   Fn: String;
begin
 try
    logitem:=tstringlist.create;
    Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
    setini:=Tinifile.Create(fn);
     for i:=0 to checklistbox1.Items.Count-1 do
     if checklistbox1.Checked[i] then
     begin
      fn:=checklistbox1.items.Strings[i];
      setini.writestring('Logsec',fn,' ');
     end;
  finally
    logitem.free;
    setini.Free;
  end;
  self.close;
end;

initialization
  {$I itemselect.lrs}

end.

