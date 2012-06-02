unit timeUpdate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, winsock, windows, inifiles;

type

  { TTimeUp }

  TTimeUp = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListBox1: TListBox;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure MyConnect(host: String){ Private declarations };
    procedure MySend(s: String);
    function MyReceive: String;
    procedure MyDisconnect;
    function MySyncTime(host: String): TDateTime;{ private declarations }
  public
    { public declarations }
  end;

var
  TimeUp: TTimeUp;
  setini:Tinifile;
implementation

{$R *.lfm}
type
  // NTP 数据格式
  tNTPGram = packed record
    head1, head2,//其中,head1为LI VN 及Mode（见图二）;
    head3, head4: Byte;
    RootDelay: Longint;
    RootDisperson: Longint;
    RefID: Longint;
    Ref1, Ref2,
    Org1, Org2,
    Rcv1, Rcv2,
    Xmit1, Xmit2: Longint;//Transmit Timestamp（传输时间戳）
  end;
  // 用于转换本机网络字节顺序;
  lr = packed record
    l1, l2, l3, l4: Byte;
  end;
var
  MySocket: Tsocket;
  fiMaxSockets: Integer;
  MyAddr: TSockAddrIn;
  UDPSize: Integer;
const
  Port = 123;// SNTP端口号必须为123；

  { TTimeUp }

procedure TTimeUp.Button1Click(Sender: TObject);
begin
  if  edit1.Text<>'' then
  label1.Caption := timetostr(MySyncTime(edit1.Text))
  else
  label1.Caption := timetostr(MySyncTime('stdtime.sinica.edu.tw'))
end;

procedure TTimeUp.Button2Click(Sender: TObject);
var
  Fn: String;
      st:tstringlist;
      i:integer;
begin
  try
    st:=tstringlist.create;
  Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  setini:=Tinifile.Create(fn);
  setini.readsection('SNTP',st);
  i:=st.Count;
  fn:='New NTP'+inttostr(i+1);
  setini.writestring('SNTP',fn,edit1.text);
  finally
    setini.free;
    st. free;
  end;
end;

procedure TTimeUp.Button3Click(Sender: TObject);
var
  Fn: String;
    st:tstringlist;
begin
  try
    st:=tstringlist.create;
    Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
    setini:=Tinifile.Create(fn);
    setini.DeleteKey('SNTP',listbox1.items[listbox1.ItemIndex]);
    listbox1.Clear;
    setini.readsection('SNTP',st);
  listbox1.Items.AddStrings(st);
  finally
    setini.free;
  end;

end;


procedure TTimeUp.Edit1DblClick(Sender: TObject);
var
  Fn: String;
      st:tstringlist;
      i:integer;
begin
  try
    st:=tstringlist.create;
  Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  setini:=Tinifile.Create(fn);
  setini.readsection('SNTP',st);
  i:=st.Count;
  fn:='New NTP'+inttostr(i+1);
  setini.writestring('SNTP',fn,edit1.text);
  finally
    setini.free;
    st. free;
  end;
end;


procedure TTimeUp.FormCreate(Sender: TObject);
var
  sData: TWSAData;
  fsStackDescription,Fn: String;
  st:tstringlist;
begin
  label6.caption:=FormatDateTime('yyyy-mm-dd hh:nn:ss',Now);
  try
    st:=tstringlist.create;
    Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  setini:=Tinifile.Create(fn);
  setini.readsection('SNTP',st);
  listbox1.Items.AddStrings(st);
  finally
    st.free;
    setini.free;
  end;
   if WSAStartup($101, sData) = SOCKET_ERROR then
    raise Exception.Create('Winsock Initialization Error.');
  fsStackDescription := StrPas(sData.szDescription);
  UDPSize := sData.iMaxUdpDg;
  fiMaxSockets := sData.iMaxSockets;
  MySocket := INVALID_SOCKET;
end;

procedure TTimeUp.ListBox1Click(Sender: TObject);
var
  Fn: String;
    st:tstringlist;
begin
  try
    st:=tstringlist.create;
    Fn:=ExtractFilePath(Paramstr(0))+'setting.ini';
  setini:=Tinifile.Create(fn);
  edit1.text:=setini.Readstring('SNTP',listbox1.items[listbox1.ItemIndex],'stdtime.sinica.edu.tw');
  finally
    setini.free;
  end;
end;

procedure TTimeUp.Timer1Timer(Sender: TObject);
begin
  label6.caption:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now);
end;



procedure TTimeUp.MyConnect(host: String);
var
  fsPeerAddress: String;
  function ResolveHost(const psHost: String;
    var psIP: String): u_long;//主机名解析成IP地址;
  var
    pa: PChar;
    sa: TInAddr;
    aHost: PHostEnt;
  begin
    psIP := psHost;
    if CompareText(psHost, 'LOCALHOST') = 0 then
    begin
      sa.S_un_b.s_b1 := #127;
      sa.S_un_b.s_b2 := #0;
      sa.S_un_b.s_b3 := #0;
      sa.S_un_b.s_b4 := #1;
      psIP           := '127.0.0.1';
      Result         := sa.s_addr;
    end
    else
    begin
      Result := inet_addr(PChar(psHost));
      if Result = u_long(INADDR_NONE) then
      begin
        aHost := GetHostByName(PChar(psHost));
        pa := aHost^.h_addr_list^;
        sa.S_un_b.s_b1 := pa[0];
        sa.S_un_b.s_b2 := pa[1];
        sa.S_un_b.s_b3 := pa[2];
        sa.S_un_b.s_b4 := pa[3];
        psIP := IntToStr(Ord(sa.S_un_b.s_b1)) + '.' + IntToStr(Ord(sa.S_un_b.s_b2))
          + '.' + IntToStr(Ord(sa.S_un_b.s_b3)) + '.' + IntToStr(Ord(sa.S_un_b.s_b4));
        Result := sa.s_addr;
      end;
    end;
  end;
begin
  MySocket := socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
  //建立套接字,采用UDP/IP协议;
  if MySocket = INVALID_SOCKET then
  begin
    raise Exception.Create('套接字建立失败！');
  end;
  try
    with MyAddr do
    begin //file://时间服务器名字；
      sin_family := PF_INET;
      sin_port := HToNS(Port);
      sin_addr.S_addr := ResolveHost(host, fsPeerAddress);
    end;
  except
    on E:
    Exception do
    begin
      if MySocket <> INVALID_SOCKET then
      begin
        CloseSocket(MySocket);
      end;;
      raise;
    end;
  end;
end;


procedure TTimeUp.MySend(s: String);
begin
  SendTo(MySocket, s[1], Length(s), 0, Myaddr, sizeof(Myaddr));
end;

function TTimeUp.MyReceive: String;//; file://接收服务器时间数据报;
var
  AddrVoid: TSockAddrIn;
  fsUDPBuffer: String;
  i: Integer;
begin
  SetLength(fsUDPBuffer, UDPSize);
  i := SizeOf(AddrVoid);
  Result := Copy(fsUDPBuffer, 1, Recvfrom(Mysocket, fsUDPBuffer[1],
    Length(fsUDPBuffer), 0, AddrVoid, i));
end;

function flip(var n: Longint): Longint;
  //file://网络字节顺序与本机字节顺序转换;
var
  n1, n2: lr;
begin
  n1 := lr(n);
  n2.l1 := n1.l4;
  n2.l2 := n1.l3;
  n2.l3 := n1.l2;
  n2.l4 := n1.l1;
  flip := Longint(n2);
end;

function tzbias: Double; // 获取本地时间区与UTC时间偏差;
{$IFDEF WIN32}
var
  //timeval: TTimeVal;
  // timezone: PTimeZone;
tz : TTimeZoneInformation;  //使用windows unit；
{$ENDIF ~WIN32}
begin
  //Result :=strtofloat(FormatDateTime('ddd, dd mmm yyyy hh:nn:ss',Now));
  //TimeZone := nil;
  //fpGetTimeOfDay (@TimeVal, TimeZone);
  //Result := Result + 'GMT ' + IntToStr(timezone^.tz_minuteswest div 60);
  GetTimeZoneInformation(tz);
  Result := tz.Bias / 1440;
end;

const
  maxint2 = 4294967296.0;
  //end;

function ntp2dt(nsec, nfrac: Longint): tdatetime;
var
  d, d1: Double;
begin
  d := nsec;
  if d < 0 then
    d := maxint2 + d - 1;

  d1 := nfrac;
  if d1 < 0 then
    d1 := maxint2 + d1 - 1;
  d1 := d1 / maxint2;
  d1 := trunc(d1 * 1000) / 1000;
  Result := (d + d1) / 86400;
  Result := Result - tzbias + 2;
end;

procedure dt2ntp(dt: tdatetime; var nsec, nfrac: Longint);
var
  d, d1: Double;
begin
  d := dt + tzbias - 2;
  d := d * 86400;
  d1 := d;
  if d1 > maxint then
  begin
    d1 := d1 - maxint2;
  end;
  nsec := trunc(d1);
  d1 := ((frac(d) * 1000) / 1000) * maxint2;
  if d1 > maxint then
  begin
    d1 := d1 - maxint2;
  end;
  nfrac := trunc(d1);
end;

procedure TTimeUp.MyDisconnect;
begin
  if MySocket <> INVALID_SOCKET then
  begin
    CloseSocket(MySocket);
  end;
end;

function TTimeUp.MySyncTime(host: String): TDateTime;
var
  ng: TNTPGram;
  s: String;
  SysTimeVar: TSystemTime;
begin
  fillchar(ng, sizeof(ng), 0);// file://将 SNTP数据报初始化;
  ng.head1 := $1B;
  // 设置SNTP数据报头为SNTP 协议版本3,模式3(客户机)，即二进制00011011;
  dt2ntp(now, ng.Xmit1, ng.xmit2);//将本机时间转换为数据报时间格式;
  ng.Xmit1 := flip(ng.xmit1);
  ng.Xmit2 := flip(ng.xmit2);
  setlength(s, sizeof(ng));
  move(ng, s[1], sizeof(ng));
  try
    MyConnect(host);
    /////////////////////////////////////////////////////////////////
    label2.caption:=FormatDateTime('hh:nn:ss',Now);
    /////////////////////////////////////////////////////////////////
    MySend(s);
    s := MyReceive;
    move(s[1], ng, sizeof(ng));
    Result := ntp2dt(flip(ng.xmit1), flip(ng.xmit2));
    // 将收到的数据报时间格式转换为本机时间;
    DateTimeToSystemTime(Result, SysTimeVar);
    SetLocalTime(SysTimeVar);// file://同步本地时间;
    MyDisconnect;
  except
    MyDisconnect;
    ShowMessage('时间同步失败!');
    exit;
    //application.Terminate;
  end;
end;


end.

