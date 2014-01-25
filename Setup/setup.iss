; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppID={{D68EB024-CAE5-40F2-A9B5-C6501416A914}
AppName=PrimeComm: Alternative Windows utility for your HP Prime
AppVersion=v0.9 b1
AppPublisher=Erwin Ried
AppPublisherURL=http://ried.cl/
AppSupportURL=https://github.com/eried/PrimeComm
AppUpdatesURL=https://github.com/eried/PrimeComm
DefaultDirName={pf}\PrimeComm\
DefaultGroupName=PrimeComm
OutputDir=setup
OutputBaseFilename=PrimeComm_setup
;Compression=none
Compression=lzma2/ultra64
SolidCompression=true
DisableProgramGroupPage=yes
ChangesAssociations=true
InternalCompressLevel=Fast
UsePreviousAppDir=false
ChangesEnvironment=true
ShowLanguageDialog=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "hpprgmfiletype"; Description: "Associate .hpprgm files"; GroupDescription: "File Associations:"

[Files]
Source: "files\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs;

[Icons]
Name: "{group}\PrimeComm"; Filename: {app}\PrimeComm.exe; 
Name: "{userdesktop}\PrimeComm"; Filename: {app}\PrimeComm.exe; Tasks: desktopicon; 

;[Registry]
;Root: HKCR; SubKey: xapfile\shell\open\; ValueType: string; ValueName: command; ValueData: "{app}\wp7-deploy.exe"; Flags: UninsDeleteKey; Tasks: xapfiletype;
;Root: HKCR; SubKey: .xap; ValueType: string; ValueName: ""; ValueData: xapfile; Flags: UninsDeleteKey; Tasks: xapfiletype;
;Root: HKCU; SubKey: software\classes\xapfile\shell\open\; ValueType: string; ValueName: Command; ValueData: "{app}\wp7-deploy.exe"; Flags: UninsDeleteKey; Tasks: xapfiletype;
;Root: HKCU; SubKey: software\classes\.xap; ValueType: string; ValueName: ""; ValueData: xapfile; Flags: UninsDeleteKey; Tasks: xapfiletype;
;Root: HKLM; SubKey: software\classes\xapfile\shell\open\; ValueType: string; ValueName: Command; ValueData: "{app}\wp7-deploy.exe"; Flags: UninsDeleteKey; Tasks: xapfiletype;
;Root: HKLM; SubKey: software\classes\.xap; ValueType: string; ValueName: ""; ValueData: xapfile; Flags: UninsDeleteKey; Tasks: xapfiletype;

[Registry]
Root: HKCR; Subkey: ".hpprgm"; ValueType: string; ValueName: ""; ValueData: "hpprgmfile"; Flags: UninsDeleteKey; Tasks: hpprgmfiletype; 
Root: HKCR; Subkey: "hpprgmfile"; ValueType: string; ValueName: ""; ValueData: ""; Flags: UninsDeleteKey; Tasks: hpprgmfiletype; 
Root: HKCR; Subkey: "hpprgmfile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\hpprgm.ico"; Flags: UninsDeleteKey; Tasks: hpprgmfiletype;
Root: HKCR; Subkey: "hpprgmfile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PrimeComm.exe"" ""%1"""; Flags: UninsDeleteKey; Tasks: hpprgmfiletype;


[code]
function IsDotNetDetected(version: string; service: cardinal): boolean;
// Indicates whether the specified version and service pack of the .NET Framework is installed.
//
// version -- Specify one of these strings for the required .NET Framework version:
//    'v1.1.4322'     .NET Framework 1.1
//    'v2.0.50727'    .NET Framework 2.0
//    'v3.0'          .NET Framework 3.0
//    'v3.5'          .NET Framework 3.5
//    'v4\Client'     .NET Framework 4.0 Client Profile
//    'v4\Full'       .NET Framework 4.0 Full Installation
//
// service -- Specify any non-negative integer for the required service pack level:
//    0               No service packs required
//    1, 2, etc.      Service pack 1, 2, etc. required
var
    key: string;
    install, serviceCount: cardinal;
    success: boolean;
begin
    key := 'SOFTWARE\Microsoft\NET Framework Setup\NDP\' + version;
    // .NET 3.0 uses value InstallSuccess in subkey Setup
    if Pos('v3.0', version) = 1 then begin
        success := RegQueryDWordValue(HKLM, key + '\Setup', 'InstallSuccess', install);
    end else begin
        success := RegQueryDWordValue(HKLM, key, 'Install', install);
    end;
    // .NET 4.0 uses value Servicing instead of SP
    if Pos('v4', version) = 1 then begin
        success := success and RegQueryDWordValue(HKLM, key, 'Servicing', serviceCount);
    end else begin
        success := success and RegQueryDWordValue(HKLM, key, 'SP', serviceCount);
    end;
    result := success and (install = 1) and (serviceCount >= service);
end;

function InitializeSetup(): Boolean;
begin
    if not IsDotNetDetected('v4\Client', 0) then begin
        MsgBox('This program requires Microsoft .NET Framework 4.0 Client Profile.'#13#13
            'Please use Windows Update, look for the required Framework and run this setup again.', mbInformation, MB_OK);
        result := false;
    end else
        result := true;
end;

[Run]
;Filename: "{app}\drivers\DriverHelper.exe"; Tasks: installdrivers
;Filename: "{app}\erw\SetPath.exe"; Parameters: "-a ""{app}\hardware\tools\avr\bin"" -r hardware\tools\avr\bin"; Flags: RunMinimized
Filename: "{app}\PrimeComm.exe"; Flags: postinstall; Description: "Open PrimeComm after closing the setup"

[UninstallRun]
;Filename: {app}\erw\SetPath.exe; Parameters: "-r hardware\tools\avr\bin"; Flags: RunHidden; 