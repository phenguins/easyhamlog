unit Logdisplay;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, EditBtn, DBGrids;

type

  { Tfrm_logdisp }

  Tfrm_logdisp = class(TForm)
    Button1: TButton;
    Button2: TButton;
    datesince: TButton;
    DateEdit1: TDateEdit;
    DBGrid1: TDBGrid;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frm_logdisp: Tfrm_logdisp;

implementation

initialization
  {$I logdisplay.lrs}

end.

