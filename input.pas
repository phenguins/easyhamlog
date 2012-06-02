unit input;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, EditBtn, DbCtrls, PairSplitter, inifiles;//Calendar, ButtonPanel;

type

  { Tfrm_input }

  Tfrm_input = class(TForm)
    Button1: TButton;
    bandbox: TComboBox;
    CheckBox1: TCheckBox;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Label7: TLabel;
    PairSplitter1: TPairSplitter;
    PairSplitterSide2: TPairSplitterSide;
    realtime: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    edittime2: TEditButton;
    EditTime1: TEditButton;
    edtinsert: TLabeledEdit;
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure CheckBox1Change(Sender: TObject);
    procedure EditTime1Change(Sender: TObject);
    procedure edittime2ButtonClick(Sender: TObject);
    procedure EditTime1ButtonClick(Sender: TObject);
    procedure edtinsertChange(Sender: TObject);
    procedure edtinsertKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frm_input: Tfrm_input;
  setini:Tinifile;
implementation
uses dm;

{ Tfrm_input }

procedure Tfrm_input.edtinsertChange(Sender: TObject);
var s:string;
i:tstringlist;
t: integer;
begin
  s:=edtinsert.Text;
  i:=tstringlist.Create;
  memo1.lines.clear;
  if  s<>'' then begin
    with dm.dm1.qry2 do
    try
      Close;
      SQL.Text := 'select distinct [CALL] from [main] where [CALL] like :call';
      Params.ParamByName('call').Value:= '%'+s+'%';
      open;
      i.Clear;
      dm.dm1.ds2.DataSet.first;
      while not dm.dm1.ds2.DataSet.EOF do
      begin
        i.add(dm.dm1.ds2.DataSet.FieldByName('call').AsString+' ');
        dm.dm1.ds2.DataSet.next;
      end;
      for t:=0 to i.Count-1 do
      memo1.Lines.Text:=memo1.Lines.Text+(i[t]+' ');
    finally
      s:='';
      dm.dm1.qry2.close;
      i.free;
    end;
  end;
end;

procedure Tfrm_input.edtinsertKeyPress(Sender: TObject; var Key: char);
var t:string;
    rst:integer;
     feq:Double;
     time:TDateTime;
begin
  if (key=#13) or (Key=#32) then
    begin
      t:=Trim(edtinsert.Text);
      if(trystrtoint(t,rst))and (rst<600)and(rst>58)    then
        begin
        edit2.Text:=t;
        exit;
        end
      else
      if TryStrToDate(t,time) then begin
        dateedit1.Text:=t;
        exit;
      end
      else        //FormatDateTime('yyyy-mm-dd',now);
      if TryStrToTime(StringReplace(t,'.',':',[rfReplaceAll]),time) then
        begin
        edittime1.Text:=StringReplace(t,'.',':',[rfReplaceAll]);
        exit;
        end
      else
      if TryStrToFloat(t,feq) then
        begin
          edit5.Text:=t;
          exit;
        end
      else
      if (t='CW') or (t='SSB') or (t='FM') or (t='USB') or (t='AM')
      or(t='LSB') or (t='cw') or (t='ssb') or (t='fm') or (t='usb')
      or (t='am') or(t='lsb') then
        begin
        edit6.Text:=t;
        exit;
        end
      else
      edit1.Text:=t;
      edtinsert.Clear;
      edtinsert.SetFocus;
    end;

end;

procedure Tfrm_input.FormCreate(Sender: TObject);
var
  Fn: String;
    st,sm:tstringlist;
    n:integer;
begin
  try
    st:=tstringlist.create;
    sm:=tstringlist.create;
    Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  setini:=Tinifile.Create(fn);
  SetIni.ReadSectionRaw('band',sm);
    sm.Sort;
    for  n:= 0 to sm.Count - 1 do
    bandbox.Items.Add(Copy(sm[n],0,Pos('=',sm[n])-1));
  finally
    setini.free;
  end;
end;

procedure Tfrm_input.Timer1Timer(Sender: TObject);
begin
  realtime.Caption:=FormatDateTime('yyyy/mm/dd hh:nn:ss',now);
end;

//procedure Tfrm_input.Button1KeyPress(Sender: TObject; var Key: char);
//var t:string;
//     feq:Double;
//     time:TDateTime;
//begin
//if (key=#13) or (Key=#32) then
//  begin
//    t:=Trim(edtinsert.Text);
//    if t='599' then
//      if edtinsert.Text='' then edt1.Text:=t else edt2.Text:=t
//    else
//    if TryStrToDate(t,time) then medtDate.Text:=t
//    else        //FormatDateTime('yyyy-mm-dd',now);
//    if TryStrToTime(StringReplace(t,';',':',[rfReplaceAll]),time) then
//    edtbegin.Text:=StringReplace(t,';',':',[rfReplaceAll])
//    else
//    if TryStrToFloat(t,feq) then edtfeq.Text:=t
//    else
//    if (t='CW') or (t='SSB') or (t='FM') or (t='USB') or (t='AM') then
//      edtmode.Text:=t
//    else
//    lblCALL.Caption:=t;
//    edtinsert.Clear;
//    edtinsert.SetFocus;
//  end;

//end;

procedure Tfrm_input.edittime2ButtonClick(Sender: TObject);
begin
  edittime2.text:= FormatDateTime('hh:mm',now);
end;

procedure Tfrm_input.CheckBox1Change(Sender: TObject);
begin
  if checkbox1.Checked then
    begin
     edittime2.Enabled:=false;
     edittime2.Text:=edittime1.Text;
    end else
    edittime2.Enabled:=true;
end;



procedure Tfrm_input.EditTime1Change(Sender: TObject);
begin
  if checkbox1.Checked then
    begin
     edittime2.Text:=edittime1.Text;
    end;
end;

procedure Tfrm_input.EditTime1ButtonClick(Sender: TObject);
begin
  edittime1.text:= FormatDateTime('hh:mm',now);
end;

initialization
  {$I input.lrs}

end.

