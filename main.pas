unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  DBGrids, StdCtrls, Grids, Menus, DbCtrls, ExtCtrls, Interfaces, db, sqldb,
  inifiles,Process;

type

  { TFrm_display }

  TFrm_display = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    DBGrid1: TDBGrid;
    dlgSave1: TSaveDialog;
    FontDialog1: TFontDialog;
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem2: TMenuItem;
    Menu_creatDB: TMenuItem;
    Menubackup: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenubackupClick(Sender: TObject);
    procedure Menu_creatDBClick(Sender: TObject);
    procedure SortQuery(Column:TColumn);
    procedure MakeDBGridColumnsAutoFixItsWidth(objDBGrid: TDBGrid);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Frm_display: TFrm_display;
  setini:Tinifile;

implementation
uses dm,input,dbdir,datadisplay,timeUpdate,logdisplay,itemselect;

{ TFrm_display }

procedure TFrm_display.FormCreate(Sender: TObject);
var fn:string;
i:word;
W:integer;
begin
  SysLocale.PriLangID:=1;
  DateSeparator:='-';
  LongDateFormat:='yyyy-mm-dd';
  ShortDateFormat:='yyyy-mm-dd';
  TimeSeparator:=':';
  LongTimeFormat:='hh:nn:ss';
  TimeAMString:='上午';
  TimePMString:='下午';
  //
  Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  setini:=Tinifile.Create(fn);
  dbgrid1.Font.Name:=setini.ReadString('Font','name','Bitstream Vera Sans Mono');
  dbgrid1.Font.Height:=setini.ReadInteger('Font','height',10);
  dbgrid1.Font.Color:=setini.ReadInteger('Font','color',0);
  setini.Destroy;
  //
  dbgrid1.DataSource:=dm.DM1.DS1;
  //
  //for i:=255 downto 0 do
  //begin
  //image1.canvas.Brush.Color:=$00000000+i*$10000;
  //image1.canvas.FillRect(rect(0,round(y),
  //  image1.left+image1.width,round(y+dy)));
  //y:=y+dy;
  //end;
  with image2.Canvas do
  begin
    clear;
    pen.Color:=clwhite;
    pen.Style:=pssolid;
    pen.Width:=1;
    font.Size:=8;
    brush.Color:=clBtnFace;
    rectangle(-1,-1,width+1,height+1);
    //brush.Color:=clBtnFace;
    W:=Image2.Width div 2 - Textwidth('o');
     font.Name:='幼圆';
      font.size:=9;
    for i:=1 to 12 do
      if i<10 then
        Image2.Canvas.TextOut(w+round(w*sin(i/12.0*2*pi))+1,w-round(w*cos(i/12.0*2*pi))+1,' '+inttostr(i))
      else
        Image2.Canvas.TextOut(w+round(w*sin(i/12.0*2*pi))+1,w-round(w*cos(i/12.0*2*pi))+1,inttostr(i));
  end;
end;

procedure TFrm_display.MenuItem10Click(Sender: TObject);
begin
  application.Terminate;
end;

procedure TFrm_display.MenubackupClick(Sender: TObject);
begin
  dbdir.frmdbfile.Show;
end;

procedure TFrm_display.Menu_creatDBClick(Sender: TObject);
var //t:TFormatSettings;
    time,s,cmdline:string;
     p:TProcess;
begin
  if (application.MessageBox('新建数据库将会清除所有原有的数据，程序将自动'+
  '备份原有数据库后再进行该操作。','注意',0)>0)
  then begin
    time:=FormatDateTime('yyyymmdd-hhmmss',Now);
    s:=ExtractFilePath(Application.ExeName)+'backup\';
    if not DirectoryExists(s) then MkDir(s);
    s:=s+time+'-FORNewlog.db';
    dm1.con1.Connected:=False;
    CopyFile(ExtractFilePath(ParamStr(0))+'log.db',s,false);
    deletefile(ExtractFilePath(ParamStr(0))+'log.db');
    cmdline:=ExtractFileDir(Application.ExeName);
      cmdline:='"'+cmdline+'\7z" e '+
      '"'+cmdline+'\backup\log_db.7z"'+
      ' -o'+'"'+cmdline+'" -r -y';
      p:=TProcess.Create(nil);
      p.CommandLine:=cmdline;
      p.Options:=p.Options+[poNoConsole];
      p.Execute;
      p.Free;
      Application.MessageBox('已经创建全新数据库', '提示', 0);
      dm1.Con1.Connected:=false;
       dm1.Con1.Connected:=true;
  end;
end;

procedure TFrm_display.Button1Click(Sender: TObject);
begin
Application.CreateForm(Tfrm_itemselect,frm_itemselect);
frm_itemselect.show;
end;

procedure TFrm_display.Button2Click(Sender: TObject);
begin
    if fontdialog1.Execute then
  begin
  dbgrid1.Font:=fontdialog1.Font;
  setini:=Tinifile.Create(ExtractFilePath(Paramstr(0))+'setting.ini');
  if fontdialog1.Font.Name<>'' then
  setini.WriteString('Font','name',fontdialog1.Font.Name);
  setini.WriteInteger('Font','Height',fontdialog1.Font.Height);
  setini.WriteInteger('Font','color', fontdialog1.Font.Color);
  setini.Destroy;
  end;
end;

procedure TFrm_display.Button3Click(Sender: TObject);
begin
  Application.CreateForm(TTimeUp, TimeUp);
  timeup.show;
end;



procedure TFrm_display.Button4Click(Sender: TObject);
begin
  frm_input.Show;
end;

procedure TFrm_display.Button5Click(Sender: TObject);
begin
  with dm.dm1.qry1 do
  try
    Close;
    SQL.Text := 'insert into [main] (CALL,mode,qso_date,qso_date_off,rst_sent,'
    +'rst_rcvd,address) '+
    'VALUES (:call,:cw,:date,:timeoff,:s,:r,:addr)';
    Params.ParamByName('CALL').value:='bi3ll';
    Params.ParamByName('cw').value:='cw';
    Params.ParamByName('date').value:=FormatDateTime('yyyy-mm-dd',now);
    //Params.ParamByName('timeon').value:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now);
    Params.ParamByName('timeoff').value:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now);
    Params.ParamByName('r').value:='599';
    Params.ParamByName('s').value:='599';
    Params.ParamByName('addr').value:='格子';
    ExecSQL;
    update;
  finally
    Close;
    sql.Clear;
  end;
dm.dm1.Trans1.Commit;
button6.Click;
end;

procedure TFrm_display.Button6Click(Sender: TObject);
begin
  dm.dm1.qry1.Close;
  dm.dm1.qry1.SQL.text:='select * from [main]';
  dm.dm1.qry1.open;
  Frm_display.Caption:='现有记录'+inttostr(dm.dm1.ds1.DataSet.RecordCount)+'条';
  MakeDBGridColumnsAutoFixItsWidth(dbgrid1);
end;

procedure TFrm_display.Button7Click(Sender: TObject);
var j:Integer;
    stlist:TStringList;
    s,s1:string;
begin
  dm.dm1.qry1.close;
  dm.dm1.qry1.SQL.Text:='select * from [main]';
  dm.dm1.qry1.Open;
  //dm.dm1.ds1.DataSet.Open;
  try
    stlist:=TStringList.Create;
    dm.dm1.ds1.DataSet.First;
    while not dm.DM1.DS1.DataSet.EOF do
    //for i := 0 to dm.dm1.ds1.DataSet.RecordCount-1   do
    begin
    s:='';
      for j := 0 to dm.dm1.ds1.DataSet.Fields.Count-1 do
      begin
        s1:=Trim(dm.dm1.ds1.DataSet.Fields[j].AsString);
        if s1<>'' then
        begin
        if dm.dm1.ds1.DataSet.Fields[j].FieldName='QSO_DATE' then
          s1:=FormatDatetime('yyyymmdd',StrToDatetime(s1));
        //if dm.dm1.ds1.DataSet.Fields[j].FieldName='TIME_ON' then
        //  s1:=FormatDateTime('yyyymmdd hhnnss',StrToDateTime(s1));
        if dm.dm1.ds1.DataSet.Fields[j].FieldName='qso_date_OFF' then
          s1:=FormatDateTime('yyyymmdd hhnnss',StrToDateTime(s1));
        s:=s+'<'+ dm.dm1.ds1.DataSet.Fields[j].FieldName+':'+
           inttostr(Length(s1))+'>'+s1+' ' ;
        end;
      end;
    s:=s+'<EOR>';
    stlist.Add(s);
    dm.dm1.ds1.DataSet.Next;
    end;
  finally
    if dlgSave1.Execute then
    //if dlgsave1.FileName<>'' then
      if not fileexists(dlgsave1.FileName) then
      stlist.SaveToFile(dlgSave1.FileName+'.adi');
    stlist.free;
  end;
end;

procedure TFrm_display.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var i :integer;
begin
  //if (dbgrid1.DataSource.DataSet.RecNo mod 2) = 0 then
  //  dbgrid1.Canvas.Brush.Color := clskyblue
  //else
  //  dbgrid1.Canvas.Brush.Color := cl3DLight;
  dbgrid1.Canvas.Pen.Mode := pmMask;
   //(Sender as TDBGrid).DefaultDrawColumnCell(Rect,DataCol,Column,State);


    if gdSelected in State then Exit;
  //定义表头的字体和背景颜色：
    for i :=0 to DBGrid1.Columns.Count-1 do
    begin
     (Sender as TDBGrid).Columns[i].Title.Font.Name :='黑体'; //字体
     (Sender as TDBGrid).Columns[i].Title.Font.Size :=12; //字体大小
     (Sender as TDBGrid).Columns[i].Title.Font.Color :=clnavy; //字体颜色(红色)
     (Sender as TDBGrid).Columns[i].Title.Color :=$00DBFDF2; //背景色(绿色)
    end;

  //隔行改变网格背景色：
  if dm.dm1.qry1.RecNo mod 2 = 0 then    //原TQuery改为Qry1
    (Sender as TDBGrid).Canvas.Brush.Color := $00FFFAEE //定义背景颜色
  else
    (Sender as TDBGrid).Canvas.Brush.Color := $00FDFCFA;//RGB(200, 220, 220); //定义背景颜色
  //定义网格线的颜色：
    (Sender as TDBGrid).Canvas.FillRect(Rect);
    (Sender as TDBGrid).DefaultDrawColumnCell(Rect,DataCol,Column,State);
  {with DBGrid1.Canvas do //画 cell 的边框
    begin
      Pen.Color := $00ff0000; //定义画笔颜色(蓝色)
      MoveTo(Rect.Left, Rect.Bottom); //画笔定位
      LineTo(Rect.Right, Rect.Bottom); //画蓝色的横线
      Pen.Color := $0000ff00; //定义画笔颜色(绿色)
      MoveTo(Rect.Right, Rect.Top); //画笔定位
      LineTo(Rect.Right, Rect.Bottom); //画绿色的竖线
    end;  }
  if Column.Field.DataType in [ftUnknown,ftMemo,ftFmtMemo,ftWideMemo]then
  begin
    (Sender as TDBGrid).Canvas.FillRect(Rect);
    (Sender as TDBGrid).Canvas.TextOut(Rect.Left,Rect.Top,
    Copy(column.field.AsString, 1, 50));
 //(Sender as TDBGrid).Canvas.TextRect(Rect,Rect.Left,Rect.Top,Column.Field.AsString);
  end ;
// if (State = [gdSelected]) then //选中行用红色显示
//(Sender as TDBGrid).Canvas.Brush.color:=clRed;
//(Sender as TDBGrid).Canvas.pen.mode:=pmMask;
//DbGrid1.DefaultDrawColumnCell (Rect,DataCol,Column,State);


end;

procedure TFrm_display.DBGrid1TitleClick(Column: TColumn);
begin
  sortquery(column);
end;

procedure TFrm_display.SortQuery(Column:TColumn);
var
SqlStr,myFieldName,TempStr: string;
OrderPos: integer;
SavedParams: TParams;
begin
if not (Column.Field.FieldKind in [fkData,fkLookup]) then exit;
if Column.Field.FieldKind =fkData then
  myFieldName := UpperCase(Column.Field.FieldName)
else
  myFieldName := UpperCase(Column.Field.KeyFields);
while Pos(myFieldName,';')<>0 do
myFieldName := copy(myFieldName,1,Pos(myFieldName,';')-1)+ ',' + copy(myFieldName,Pos(myFieldName,';')+1,100);
with TSQLQuery(TDBGrid(Column.Grid).DataSource.DataSet) do //原TQuery改为TZQuery
begin
  SqlStr := UpperCase(Sql.Text);
  // if pos(myFieldName,SqlStr)=0 then exit;
  if ParamCount>0 then
  begin
   SavedParams := TParams.Create;
   SavedParams.Assign(Params);
  end;
  OrderPos := pos('ORDER',SqlStr);
  if (OrderPos=0) or (pos(myFieldName,copy(SqlStr,OrderPos,100))=0) then
   TempStr := ' Order By ' + myFieldName + ' Asc'
  else if pos('ASC',SqlStr)=0 then
   TempStr := ' Order By ' + myFieldName + ' Asc'
  else
   TempStr := ' Order By ' + myFieldName + ' Desc';
  if OrderPos<>0 then SqlStr := Copy(SqlStr,1,OrderPos-1);
  SqlStr := SqlStr + TempStr;
  Active := False;
  Sql.Clear;
  Sql.Text := SqlStr;
  if ParamCount>0 then
  begin
   Params.AssignValues(SavedParams);
   SavedParams.Free;
  end;
  //Prepare;
  Open;
end;

end;

procedure TFrm_display.MakeDBGridColumnsAutoFixItsWidth(objDBGrid: TDBGrid);
var
  cc: integer;
  i, tmpLength: integer;
  objDataSet: TDataSet;
  s:string;
  aDgCLength: array of integer;
begin
  cc := objDbGrid.Columns.Count - 1;
  objDataSet := objDbGrid.DataSource.DataSet;
  setlength(aDgCLength, cc + 1);
  //取標題字段的長度
  for i := 0 to cc do
  begin
    aDgCLength[i] := objDbGrid.canvas.textwidth(objDbGrid.Columns[i].Title.Caption);//取標題字段的長度
  end;
  objDataSet.First;
  while not objDataSet.Eof do
  begin
   //取列中每個字段的長度
    for i := 0 to cc do
    begin
   // 取列中每個字段的長度﹐并比較標題長度和字段的長度
       s:=objDataSet.Fields.Fields[i].AsString;
      tmplength:= objDBGrid.Canvas.TextWidth(s) ;
      if tmpLength > aDgCLength[i]
        then aDgCLength[i] := tmpLength;
    end;
    objDataSet.Next;
  end;
  for i := 0 to cc do
    objDbGrid.Columns[i].Width := aDgCLength[i]+10;
  objDBGrid.Refresh;
end;

procedure TFrm_display.Timer1Timer(Sender: TObject);
var
  mynow :Tdatetime;
  hour,min,sec,msec:word;
  vh,vm,vs:real;
  PoiLong:integer;
begin
  mynow:=now;
  decodetime(mynow,hour,min,sec,msec);
  vm:=min/60.0*2*pi;
  vh:=hour/12.0*2*pi+(vm/12);
  vs:=sec/60.0*2*pi;
  with Image1.Canvas do
  begin
    clear;
    brush.Color:=clBtnFace;
    rectangle(-1,-1,width+1,height+1);
    PoiLong:=image1.Width div 2;
    pen.color:=clblue;
   // pen.Color:=clActiveCaption;
      pen.Width:=3;
      moveto(PoiLong, PoiLong);
      lineto(PoiLong+round(PoiLong/1.5*sin(vh)),PoiLong-round(PoiLong/1.5*cos(vh)));
       pen.Width:=2;
      moveto(PoiLong, PoiLong);
      lineto(PoiLong+round(PoiLong/1 *sin(vm)),PoiLong-round(PoiLong/1*cos(vm)));
       pen.Width:=1;
      moveto(PoiLong, PoiLong);
      lineto(PoiLong+round(PoiLong/0.5 *sin(vs)),PoiLong-round(PoiLong/0.5*cos(vs)));
  end;
end;

initialization
  {$I main.lrs}

end.

