unit mir3_game_scene_logon_info;

interface

{$I DevelopmentDefinition.inc}

uses
{Delphi }  Windows, SysUtils, Classes,
{DirectX}  DXTypes, Direct3D9, D3DX9,
{Game   }  mir3_game_socket, mir3_game_en_decode, mir3_game_language_engine,
{Game   }  mir3_game_gui_definition, mir3_core_controls, mir3_global_config, mir3_game_sound_engine,
{Game   }  mir3_game_file_manager, mir3_game_file_manager_const, mir3_game_engine, mir3_misc_utils;

{ Callback Functions }
procedure LogonInfoGUIEvent(AEventID: LongWord; AControlID: Cardinal; AControl: PMIR3_GUI_Default); stdcall;
procedure LogonInfoGUIHotKeyEvent(AChar: LongWord); stdcall;


type
  TMir3GameSceneLogonInfo = class(TMIR3_GUI_Manager)
  strict private
    FLastMessageError : Integer;
    FWaitTimeInterval : LongInt;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure ResetScene;
    procedure SystemMessage(AMessage: String; AButtons: TMIR3_DLG_Buttons; AEventType: Integer);
    {Event Function}
    procedure Event_System_Ok;
    procedure Event_System_Yes;
    procedure Event_System_No;
    procedure Event_Timer_Expire;
  end;

implementation

uses mir3_game_backend;

  {$REGION ' - TMir3GameSceneLogonInfo :: constructor / destructor   '}
    constructor TMir3GameSceneLogonInfo.Create;
    var
      FSystemForm : TMIR3_GUI_Form;
      FLogonForm  : TMIR3_GUI_Form;
    begin
      inherited Create;
      Self.DebugMode := False;
      Self.SetEventCallback(@LogonInfoGUIEvent);
      Self.SetHotKeyEventCallback(@LogonInfoGUIHotKeyEvent);

      { Create Logon Info Forms and Controls }
      with FGame_GUI_Definition_LogonInfo do
      begin
        case FScreen_Width of
           800 : begin
             FLogonForm  := TMIR3_GUI_Form(Self.AddForm(FLogonInfo_Background_800, True));
             Self.AddControl(FLogonForm, FLogon_Information_Field_800, True);
           end;
          1024 : begin
             FLogonForm  := TMIR3_GUI_Form(Self.AddForm(FLogonInfo_Background_1024, True));
             Self.AddControl(FLogonForm, FLogon_Information_Field_1024, True);
           end;
        end;
        Self.AddControl(FLogonForm, FLogon_Info_Timer, True);
      end;

      { Create System Forms and Controls }
      FSystemForm := TMIR3_GUI_Form(Self.AddForm(FGame_GUI_Definition_System.FSys_Dialog_Info, False));
      Self.AddControl(FSystemForm, FGame_GUI_Definition_System.FSys_Dialog_Text , True);
      Self.AddControl(FSystemForm, FGame_GUI_Definition_System.FSys_Button_Ok   , False);
      Self.AddControl(FSystemForm, FGame_GUI_Definition_System.FSys_Button_Yes  , False);
      Self.AddControl(FSystemForm, FGame_GUI_Definition_System.FSys_Button_No   , False);

      // later use Config file
//      TMIR3_GUI_Panel(GetComponentByID(GUI_ID_LOGON_PANEL_INFO)).Caption := 'Hello'+#10#13+
//                                                                            'this is the new LomCN Mir3 client...\'+
//                                                                            'Completely re-created from begin...\\'+
//                                                                            'Create by Coly, Azura, ElAmO and 1PKRyan\\'+
//                                                                            ' Thank you LomCN staff, for all the help...\\'+
//                                                                            ' Thank you WeMade, for this very nice game...';

      FWaitTimeInterval := 30000;                                                                            ;
    end;
    
    destructor TMir3GameSceneLogonInfo.Destroy;
    begin
    
      inherited;
    end;


    procedure TMir3GameSceneLogonInfo.ResetScene;
    begin
      TMIR3_GUI_Timer(GetComponentByID(GUI_ID_LOGON_TIMER)).SetTimerEnabled(True);
    end;
  {$ENDREGION}

  {$REGION ' - TMir3GameSceneLogonInfo :: Scene Funtions             '}
  procedure TMir3GameSceneLogonInfo.SystemMessage(AMessage: String; AButtons: TMIR3_DLG_Buttons; AEventType: Integer);
  begin
    if mbOK in AButtons then
      TMIR3_GUI_Button(GetComponentByID(GUI_ID_SYSINFO_BUTTON_OK)).Visible := True
    else TMIR3_GUI_Button(GetComponentByID(GUI_ID_SYSINFO_BUTTON_OK)).Visible := False;

    if mbYes in AButtons then
      TMIR3_GUI_Button(GetComponentByID(GUI_ID_SYSINFO_BUTTON_YES)).Visible := True
    else TMIR3_GUI_Button(GetComponentByID(GUI_ID_SYSINFO_BUTTON_YES)).Visible := False;

    if mbNo in AButtons then
      TMIR3_GUI_Button(GetComponentByID(GUI_ID_SYSINFO_BUTTON_NO)).Visible := True
    else TMIR3_GUI_Button(GetComponentByID(GUI_ID_SYSINFO_BUTTON_NO)).Visible := False;

    SetZOrder(TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)));
    TMIR3_GUI_Panel(GetComponentByID(GUI_ID_SYSINFO_PANEL)).Caption := PWideChar(AMessage);
    TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).EventTypeID  := AEventType;
    TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).Visible := True;
  end;
  {$ENDREGION}

  {$REGION ' - TMir3GameSceneLogonInfo :: Event Funktion             '}

    procedure TMir3GameSceneLogonInfo.Event_System_Ok;
    begin
      case TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).EventTypeID of
        0:;
        1: SendMessage(GRenderEngine.GetGameHWND, $0010, 0, 0);
      end;
      case FLastMessageError of
        0:; // TODO : we can handle error better here
      end;
      TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).Visible := False;
    end;

    procedure TMir3GameSceneLogonInfo.Event_System_Yes;
    begin
      case TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).EventTypeID of
        0:;
        1:;
        2: SendMessage(GRenderEngine.GetGameHWND, $0010, 0, 0);
      end;
      TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).Visible := False;
    end;

    procedure TMir3GameSceneLogonInfo.Event_System_No;
    begin
      TMIR3_GUI_Form(GetFormByID(GUI_ID_SYSINFO_DIALOG)).Visible := False;
    end;

     procedure TMir3GameSceneLogonInfo.Event_Timer_Expire;
     begin
       TMIR3_GUI_Timer(GetComponentByID(GUI_ID_LOGON_TIMER)).SetTimerEnabled(False);
       GGameEngine.SceneLogon.ResetScene;
       GGameEngine.FGame_Scene_Step := gsScene_SelChar;//gsScene_Login;
     end;

  {$ENDREGION}

  
  {$REGION ' - Callback Event Function   '}
    procedure LogonInfoGUIEvent(AEventID: LongWord; AControlID: Cardinal; AControl: PMIR3_GUI_Default); stdcall;
    begin
      case AEventID of
        EVENT_BUTTON_UP : begin
          {$REGION ' - EVENT_BUTTON_CLICKED '}
          case AControl.ControlIdentifier of
            (* System Buttons *)
            GUI_ID_SYSINFO_BUTTON_OK   : GGameEngine.SceneLogonInfo.Event_System_Ok;
            GUI_ID_SYSINFO_BUTTON_YES  : GGameEngine.SceneLogonInfo.Event_System_Yes;
            GUI_ID_SYSINFO_BUTTON_NO   : GGameEngine.SceneLogonInfo.Event_System_No;
          end;
          {$ENDREGION}
        end;
        EVENT_TIMER_TIME_EXPIRE : begin
          {$REGION ' - EVENT_BUTTON_CLICKED '}
          case AControl.ControlIdentifier of
            GUI_ID_LOGON_TIMER   : GGameEngine.SceneLogonInfo.Event_Timer_Expire;
          end;
          {$ENDREGION}
        end;
	  end;
    end;

    procedure LogonInfoGUIHotKeyEvent(AChar: LongWord); stdcall;
    begin
      //case Chr(AChar) of
        //'N' : BrowseURL(DeCodeString(GGameEngine.GameLauncherSetting.FRegister_URL));
      //end;
    end;
  {$ENDREGION}

end.