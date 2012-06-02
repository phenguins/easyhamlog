unit DM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, dbf, sqlite3conn, FileUtil,
  LResources, Forms, Controls, Dialogs,Process;

type

  { TDM1 }

  TDM1 = class(TDataModule)
    DS2: TDatasource;
    DS1: TDatasource;
    Qry1: TSQLQuery;
    Con1: TSQLite3Connection;
    qry2: TSQLQuery;
    Trans1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  DM1: TDM1;

implementation

{ TDM1 }
function sqlite3_backup_init(pDest:integer; DestName:string;pSource:integer;SourceName:string):integer;stdcall;external 'sqlite3.dll';
function sqlite3_backup_step(pDest:integer;p:integer):integer;stdcall;external 'sqlite3.dll';
function sqlite3_backup_finish(pDest:integer):integer;stdcall;external 'sqlite3.dll';

procedure TDM1.DataModuleCreate(Sender: TObject);
var FolderTmp,cmdline: string;
p:TProcess;
begin
  try
    FolderTmp:= ExtractFileDir(Application.ExeName);
    //FolderTmp:= FolderTmp + '\test.slt';
    FolderTmp:= FolderTmp + '\log.db';
    if not FileExists(FolderTmp) then
    begin
      cmdline:=ExtractFileDir(Application.ExeName);
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
    end;
    Con1.databasename:=FolderTmp;
    Con1.Connected:=true;
  except
    MessageDlg('提示:' + #13 + '载入数据库时发生错误', mtError, [mbok], 0);
    Halt;
  end;
end;



initialization
  {$I dm.lrs}

end.

