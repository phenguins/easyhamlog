program datalink;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, DM, SQLDBLaz, runtimetypeinfocontrols, input, dbDir, datadisplay,
  timeUpdate, Logdisplay, itemselect;


{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM1, DM1);
  Application.CreateForm(TFrm_display, Frm_display);
  Application.CreateForm(Tfrm_input, frm_input);
  Application.CreateForm(Tfrmdbfile, frmdbfile);
  Application.CreateForm(TTimeUp,TimeUp);
  Application.CreateForm(Tfrm_logdisp, frm_logdisp);
  //Application.CreateForm(Tfrm_itemselect, frm_itemselect);
  Application.Run;

end.


