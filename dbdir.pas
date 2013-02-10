unit dbDir;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls,Process ;

type

  { TfrmDBfile }

  TfrmDBfile = class(TForm)
    btn_backup: TButton;
    btn_restore: TButton;
    chk1: TCheckBox;
    Label1: TLabel;
    lst1: TListBox;
    procedure btn_backupClick(Sender: TObject);
    procedure btn_restoreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    DBpath : string;
    procedure FillList(Alist:TListBox);

    { private declarations }
  public
    { public declarations }
  end; 

var
  frmdbfile: Tfrmdbfile;

implementation
uses dm;
{ TfrmDBfile }

procedure TfrmDBfile.btn_backupClick(Sender: TObject);
var //t:TFormatSettings;
    time,cmdline,s:string;
    p:TProcess;
begin
  //if lst1.ItemIndex>0 then
  //begin
    time:=FormatDateTime('yyyymmdd-hhmmss',Now);
  s:=ExtractFilePath(Application.ExeName)+'backup\';
  if not DirectoryExists(s) then MkDir(s);
  s:=s+time+'log.db';
  dm1.con1.Connected:=False;
  cmdline:=ExtractFileDir(Application.ExeName);
  if chk1.Checked then
  begin
    //cmdline:=FindDefaultExecutablePath(application.exename);
    //尝试使用sqlite的内置备份实现，现无法正常备份，使用简单的复制完成
    //cmdline:=cmdline+'\sqlite3 '+
    //cmdline+'\log.db ".dump" > '+
    //cmdline+'\backup\'+time+'.db';
    cmdline:='"'+cmdline+'\7z"'+
    ' a -tzip "'+cmdline+'\backup\'+time+'.7z" "'+
    DBpath+'" -r';
    //cmdline:=cmdline+'\sqlite3';
    //ExecuteProcess(cmdline,[' log.db ".dump>" log.sql']);

    p:=TProcess.Create(nil);                {第一句，告诉程序初始化}
    p.CommandLine:=cmdline;                 {第二句，说明所调用程序的路径。注意：由于几乎所有的区域，因此路径名不得包含任何中文，若想实现中文路径名的调用，恐怕只有使用中国人自己的语言——汉语编程。}
    p.Options:=p.Options+[poNoConsole];    {第三句，作用不明}
    p.Execute;                              {第四句，外部程序从此句开始被程序调用}
    p.Free;                                 {第五句，外部程序执行完毕后，程序再执行本句关闭外部程序}
    Application.MessageBox('数据库备份成功', '提示', 0);
  end else
  begin
    if not CopyFile(DBpath,s,false) then
      Application.MessageBox('数据库备份错误，请重启程序', '错误', 0)
    else
    Application.MessageBox('数据库备份成功', '提示', 0);
  end;
  //end;
  DM1.con1.Connected:=True;
  FillList(lst1);
  self.Hide;
end;

procedure TfrmDBfile.btn_restoreClick(Sender: TObject);
var SBackFileName,AFileName,cmdline,s:string;
        p:TProcess;
begin
  if lst1.ItemIndex>0 then
  begin
     AFileName:=DBpath;
  s:=ExtractFilePath(ParamStr(0))+'backup\';
  SBackFileName:=s+lst1.Items[lst1.itemindex];
  if sbackfilename<>'' then
  begin
    dm1.con1.Close;
    DM1.con1.Connected:=false;
    if ExtractFileExt(SBackFileName)='.db' then
    begin
      CopyFile((SBackFileName),(AFileName),false);
    Application.MessageBox('数据库已经恢复完成', '提示', 0);
    end else
    begin
      cmdline:=ExtractFileDir(Application.ExeName);
      cmdline:='"'+cmdline+'\7z" e '+
      '"'+SBackFileName+'" -o'+
      '"'+cmdline+'" -r -y';
      p:=TProcess.Create(nil);
      p.CommandLine:=cmdline;
      p.Options:=p.Options+[poNoConsole];
      p.Execute;
      p.Free;
      Application.MessageBox('数据库已经恢复完成', '提示', 0);
    end;
    DM1.con1.Connected:=True;
    lst1.Update;
  end;
  end;
  DM1.con1.Connected:=True;
  self.Hide;
end;

procedure TfrmDBfile.FormCreate(Sender: TObject);
//var     time:string;
begin
  DBpath:=ExtractFilePath(ParamStr(0))+'log.db';
  FillList(lst1);
  //GetLocaleFormatSettings(0,t);//取得当前时间
  //time:=FormatDateTime('yyyy-mm-dd hh:mm:ss',
  //  FileDateToDateTime(FileAge(DBpath)));
end;

procedure TfrmDBfile.FormShow(Sender: TObject);
begin
    FillList(lst1);
end;

procedure TfrmDBfile.FillList(Alist: TListBox);
var sr:TSearchRec;
    s:string;
begin
  Alist.Clear;
  s:=ExtractFilePath(ParamStr(0))+'backup\*.db';
  if FindFirst(s,faAnyFile,sr)=0 then
  begin
    repeat
      lst1.Items.Add(ExtractFileName(sr.Name));
    until FindNext(sr)<>0;
    FindClose(sr);
  end;
  s:=ExtractFilePath(ParamStr(0))+'backup\*.7z';
  if FindFirst(s,faAnyFile,sr)=0 then
  begin
    repeat
      lst1.Items.Add(ExtractFileName(sr.Name));
    until FindNext(sr)<>0;
    FindClose(sr);
  end;
end;





initialization
  {$I dbdir.lrs}

end.

