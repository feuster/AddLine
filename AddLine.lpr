program AddLine;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp;

type

  { TApplication }

  TApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

const
  //Message strings
  STR_AppTitle:     String = 'AddLine';
  STR_Version:      String = '1.0';
  STR_Copyright:    String = '(c) 2019 Alexander Feuster';
  STR_Splitter:     String = '==========================';
  STR_Error:        String = 'Error:   ';
  STR_CPU:          String = {$I %FPCTARGETCPU%};

{ TApplication }

procedure TApplication.DoRun;
var
  ErrorMsg: String;
  FilePath: String;
  TextLine: String;
  Text:     TStringList;
  AllowDup: Boolean;

begin
  // quick check parameters
  ErrorMsg:=CheckOptions('ahf:t:', 'allowduplicates help file: text:');
  if ErrorMsg<>'' then
    begin
      writeln(STR_Splitter);
      writeln(STR_Error);
      ShowException(Exception.Create(ErrorMsg));
      writeln(STR_Splitter);
      writeln('');
      WriteHelp;
      Terminate;
      Exit;
    end;

  // parse parameters
  if HasOption('h', 'help') or (ParamCount=0) then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

  if HasOption('a', 'allowduplicates') then
    AllowDup:=true
  else
    AllowDup:=false;

  //check output file path
  if HasOption('f', 'file') then
    begin
      FilePath:=(GetOptionValue('f', 'file'));
    end
  else
    begin
      writeln(STR_Splitter);
      writeln(STR_Error);
      WriteLn(STR_Error+'No output file specified');
      writeln(STR_Splitter);
      writeln('');
      WriteHelp;
      Terminate;
      Exit;
    end;

  //check output text
  if HasOption('t', 'text') then
    begin
      TextLine:=(GetOptionValue('t', 'text'));
    end
  else
    begin
      writeln(STR_Splitter);
      writeln(STR_Error);
      WriteLn(STR_Error+'Empty or no text line specified');
      writeln(STR_Splitter);
      writeln('');
      WriteHelp;
      Terminate;
      Exit;
    end;

  //add new textline and optionally prevent duplicates
  try
  Text:=TStringList.Create;
  if AllowDup=false then
    begin
      Text.Sorted:=true;
      Text.Duplicates:=dupIgnore;
    end;

  //open text file
  if FileExists(FilePath)=true then
    Text.LoadFromFile(FilePath);

  //store new text file
  Text.Add(TextLine);
  Text.SaveToFile(FilePath);

  //free memory
  finally
  if Text<>NIL then
    Text.Free;
    //terminate application
    Terminate;
  end;
end;

constructor TApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TApplication.WriteHelp;
begin
  { add your help code here }
  writeln(STR_Splitter);
  if STR_CPU='x86_64' then
    writeln(STR_AppTitle+' V'+STR_Version+' (64Bit)')
  else if STR_CPU='i386' then
    writeln(STR_AppTitle+' V'+STR_Version+' (32Bit)')
  else
    writeln(STR_AppTitle+' V'+STR_Version);
  writeln(STR_Copyright);
  writeln(STR_Splitter);
  writeln('');
  writeln('The basic purpose of this tool is to add single text lines to a log file (optional with or without duplicates).');
  writeln('');
  writeln('Help:');
  writeln('Help: ', ExeName, ' -h');
  writeln('Help: ', ExeName, ' --help');
  writeln('');
  writeln('Add text line without duplicates:');
  writeln('Usage: ', ExeName, ' -f "Path_to_File" -t "text line to add"');
  writeln('Usage: ', ExeName, ' --file="Path_to_File" --text="text line to add"');
  writeln('');
  writeln('Add text line with duplicates:');
  writeln('Usage: ', ExeName, ' -f "Path_to_File" -t "text line to add" -a');
  writeln('Usage: ', ExeName, ' --file="Path_to_File" --text="text line to add" --allowduplicates');
end;

var
  Application: TApplication;
begin
  Application:=TApplication.Create(nil);
  Application.Title:='AddLine';
  Application.Run;
  Application.Free;
end.

