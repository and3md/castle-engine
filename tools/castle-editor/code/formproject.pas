{
  Copyright 2018-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Project form (@link(TProjectForm)). }
unit FormProject;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DOM, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, ComCtrls, ShellCtrls, StdCtrls, ValEdit, ProjectUtils,
  Types, Contnrs,
  // for TOIPropertyGrid usage
  ObjectInspector, PropEdits, PropEditUtils, GraphPropEdits,
  // CGE units
  CastleControl, CastleUIControls, CastlePropEdits, CastleDialogs,
  // castle-editor units
  EditorUtils;

type
  { Main project management. }
  TProjectForm = class(TForm)
    MenuItemDesign: TMenuItem;
    OpenDesignDialog: TCastleOpenDialog;
    MenuItemOpenDesign: TMenuItem;
    MenuItemSeparator201: TMenuItem;
    MenuItemNewDesignTransform: TMenuItem;
    MenuItemNewDesignUserInterface: TMenuItem;
    SaveDesignDialog: TCastleSaveDialog;
    ControlsTree: TTreeView;
    LabelHierarchy: TLabel;
    MenuItemSaveAsDesign: TMenuItem;
    MenuItemSaveDesign: TMenuItem;
    PanelLeft: TPanel;
    LabelControlSelected: TLabel;
    ListOutput: TListBox;
    MainMenu1: TMainMenu;
    MenuItemSeparator101: TMenuItem;
    MenuItemBreakProcess: TMenuItem;
    MenuItemSeprator100: TMenuItem;
    MenuItemAutoGenerateClean: TMenuItem;
    MenuItemAutoGenerateTextures: TMenuItem;
    MenuItemPackageSource: TMenuItem;
    MenuItemModeRelease: TMenuItem;
    MenuItemPackage: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItemModeDebug: TMenuItem;
    MenuItemSeparator3: TMenuItem;
    MenuItemSeparator2: TMenuItem;
    MenuItemReference: TMenuItem;
    MenuItemManual: TMenuItem;
    MenuItemCgeWww: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemSeparator: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemClean: TMenuItem;
    MenuItemOnlyRun: TMenuItem;
    MenuItemCompileRun: TMenuItem;
    MenuItemCompile: TMenuItem;
    MenuItemSwitchProject: TMenuItem;
    MenuItemRun: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemQuit: TMenuItem;
    PageControlBottom: TPageControl;
    ControlProperties: TPageControl;
    PanelRight: TPanel;
    PanelAboveTabs: TPanel;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    SplitterBetweenFiles: TSplitter;
    Splitter2: TSplitter;
    SplitterLeft: TSplitter;
    SplitterRight: TSplitter;
    TabFiles: TTabSheet;
    TabOutput: TTabSheet;
    ProcessUpdateTimer: TTimer;
    TabEvents: TTabSheet;
    TabSimple: TTabSheet;
    TabAdvanced: TTabSheet;
    procedure ControlsTreeSelectionChanged(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListOutputClick(Sender: TObject);
    procedure MenuItemAutoGenerateCleanClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemAutoGenerateTexturesClick(Sender: TObject);
    procedure MenuItemBreakProcessClick(Sender: TObject);
    procedure MenuItemCgeWwwClick(Sender: TObject);
    procedure MenuItemCleanClick(Sender: TObject);
    procedure MenuItemCompileClick(Sender: TObject);
    procedure MenuItemCompileRunClick(Sender: TObject);
    procedure MenuItemManualClick(Sender: TObject);
    procedure MenuItemModeDebugClick(Sender: TObject);
    procedure MenuItemNewDesignUserInterfaceClick(Sender: TObject);
    procedure MenuItemNewDesignTransformClick(Sender: TObject);
    procedure MenuItemOnlyRunClick(Sender: TObject);
    procedure MenuItemOpenDesignClick(Sender: TObject);
    procedure MenuItemPackageClick(Sender: TObject);
    procedure MenuItemPackageSourceClick(Sender: TObject);
    procedure MenuItemQuitClick(Sender: TObject);
    procedure MenuItemReferenceClick(Sender: TObject);
    procedure MenuItemModeReleaseClick(Sender: TObject);
    procedure MenuItemSaveAsDesignClick(Sender: TObject);
    procedure MenuItemSaveDesignClick(Sender: TObject);
    procedure MenuItemSwitchProjectClick(Sender: TObject);
    procedure ProcessUpdateTimerTimer(Sender: TObject);
  private
    ProjectName: String;
    ProjectPath, ProjectPathUrl: String;
    BuildMode: TBuildMode;
    OutputList: TOutputList;
    RunningProcess: TAsynchronousProcessQueue;
    InspectorSimple, InspectorAdvanced, InspectorEvents: TOIPropertyGrid;
    PropertyEditorHook: TPropertyEditorHook;
    DesignUrl: String;
    { Root saved/loaded to component file }
    DesignRoot: TComponent;
    { Owner of all components saved/loaded to component file,
      also temporary scene manager for .castle-transform.
      Everything specific to this hierarchy in CastleControl. }
    DesignOwner: TComponent;
    DesignModified: Boolean;
    CastleControl: TCastleControlCustom;
    procedure BuildToolCall(const Commands: array of String);
    function ComponentCaption(const C: TComponent): String;
    { calculate Selected list, non-nil <=> non-empty }
    procedure GetSelected(out Selected: TComponentList;
      out SelectedCount: Integer);
    procedure DesignModifiedNotification(Sender: TObject);
    procedure InspectorSimpleFilter(Sender: TObject; aEditor: TPropertyEditor;
      var aShow: boolean);
    procedure PropertyGridModified(Sender: TObject);
    procedure SaveDesign(const Url: string);
    { Changes DesignRoot, DesignUrl and all the associated user-interface. }
    procedure OpenDesign(const NewDesignRoot, NewDesignOwner: TComponent;
      const NewDesignUrl: String);
    procedure OpenDesign(const NewDesignUrl: String);
    procedure SetEnabledCommandRun(const AEnabled: Boolean);
    procedure FreeProcess;
    procedure UpdateDesign(const Root: TComponent);
    procedure UpdateSelectedControl;
    procedure UpdateFormCaption;
    { Propose saving the hierarchy.
      Returns should we continue (user did not cancel). }
    function ProposeSaveDesign: Boolean;
  public
    procedure OpenProject(const ManifestUrl: String);
  end;

var
  ProjectForm: TProjectForm;

implementation

{$R *.lfm}

uses TypInfo,
  CastleXMLUtils, CastleLCLUtils, CastleOpenDocument, CastleURIUtils,
  CastleFilesUtils, CastleUtils, X3DNodes, CastleVectors, CastleColors,
  CastleScene, CastleSceneManager, Castle2DSceneManager,
  CastleTransform, CastleControls, CastleDownload, CastleApplicationProperties,
  CastleLog, CastleComponentSerialize,
  FormChooseProject, ToolUtils;

procedure TProjectForm.MenuItemQuitClick(Sender: TObject);
begin
  // TODO ask only if unsaved things
//  if YesNoBox('Quit the editor?') then
    Application.Terminate;
end;

procedure TProjectForm.MenuItemReferenceClick(Sender: TObject);
begin
  OpenURL('https://castle-engine.io/apidoc/html/index.html');
end;

procedure TProjectForm.MenuItemModeReleaseClick(Sender: TObject);
begin
  BuildMode := bmRelease;
  MenuItemModeRelease.Checked := true;
end;

procedure TProjectForm.SaveDesign(const Url: string);
begin
  if DesignRoot is TCastleUserInterface then
    UserInterfaceSave(TCastleUserInterface(DesignRoot), Url)
  else
  if DesignRoot is TCastleTransform then
    TransformSave(TCastleTransform(DesignRoot), Url)
  else
    raise EInternalError.Create('We can only save DesignRoot that descends from TCastleUserInterface or TCastleTransform');
  DesignModified := false;
  UpdateFormCaption;
end;

procedure TProjectForm.OpenDesign(const NewDesignRoot, NewDesignOwner: TComponent;
  const NewDesignUrl: String);

  procedure ClearDesign;
  begin
    ControlsTree.Items.Clear;
    UpdateSelectedControl;
    CastleControl.Controls.Clear;
    DesignRoot := nil;

    // this actually frees everything inside DesignRoot
    FreeAndNil(DesignOwner);
  end;

var
  Background: TCastleSimpleBackground;
  TempSceneManager: TCastleSceneManager;
begin
  ClearDesign;

  if NewDesignRoot is TCastleUserInterface then
  begin
    CastleControl.Controls.InsertFront(NewDesignRoot as TCastleUserInterface)
  end else
  if NewDesignRoot is TCastleTransform then
  begin
    TempSceneManager := TCastleSceneManager.Create(NewDesignOwner);
    TempSceneManager.Transparent := true;
    TempSceneManager.Items.Add(NewDesignRoot as TCastleTransform);
    CastleControl.Controls.InsertFront(TempSceneManager);
  end else
    raise EInternalError.Create('DesignRoot from file does not descend from TCastleUserInterface or TCastleTransform');

  // make background defined
  Background := TCastleSimpleBackground.Create(NewDesignOwner);
  Background.Color := Vector4(0.5, 0.5, 0.5, 1);
  CastleControl.Controls.InsertBack(Background);

  // replace DesignXxx variables, once loading successfull
  DesignRoot := NewDesignRoot;
  DesignUrl := NewDesignUrl;
  DesignOwner := NewDesignOwner;
  DesignModified := DesignUrl = ''; // when opening '', mark new hierarchy modified
  // TODO: is this correct? what should be set here?
  PropertyEditorHook.LookupRoot := DesignOwner;

  UpdateDesign(DesignRoot);
  UpdateFormCaption;
end;

procedure TProjectForm.OpenDesign(const NewDesignUrl: String);
var
  NewDesignRoot, NewDesignOwner: TComponent;
  Mime: String;
begin
  NewDesignOwner := TComponent.Create(Self);

  Mime := URIMimeType(NewDesignUrl);
  if Mime = 'text/x-castle-user-interface' then
    NewDesignRoot := UserInterfaceLoad(NewDesignUrl, NewDesignOwner)
  else
  if Mime = 'text/x-castle-transform' then
    NewDesignRoot := TransformLoad(NewDesignUrl, NewDesignOwner)
  else
    raise Exception.CreateFmt('Unrecognized file extension %s (MIME type %s)',
      [ExtractFileExt(NewDesignUrl), Mime]);

  OpenDesign(NewDesignRoot, NewDesignOwner, NewDesignUrl);
end;

procedure TProjectForm.MenuItemSaveAsDesignClick(Sender: TObject);
begin
  // TODO -- disable when DesignRoot = nil

  if DesignRoot is TCastleUserInterface then
    SaveDesignDialog.DefaultExt := 'castle-user-interface'
  else
  if DesignRoot is TCastleTransform then
    SaveDesignDialog.DefaultExt := 'castle-transform'
  else
    raise EInternalError.Create('DesignRoot does not descend from TCastleUserInterface or TCastleTransform');

  SaveDesignDialog.Url := DesignUrl;
  if SaveDesignDialog.Execute then
  begin
    SaveDesign(SaveDesignDialog.Url);
    DesignUrl := SaveDesignDialog.Url; // after successfull save
    UpdateFormCaption;
    // TODO: save DesignUrl somewhere? CastleEditorSettings.xml?
  end;
end;

procedure TProjectForm.MenuItemSaveDesignClick(Sender: TObject);
begin
  if DesignUrl = '' then
    MenuItemSaveAsDesignClick(Sender)
  else
    SaveDesign(DesignUrl);
end;

procedure TProjectForm.MenuItemCgeWwwClick(Sender: TObject);
begin
  OpenURL('https://castle-engine.io/');
end;

procedure TProjectForm.MenuItemAboutClick(Sender: TObject);
begin
  // TODO
  // Show logo, website link, Patreon link,
  // Copyright Michalis Kamburelis and many contributors (thank you!)
  // Show current (runtime) CGE, FPC version
  // Show CGE, FPC version when compiling editor
end;

procedure TProjectForm.MenuItemAutoGenerateTexturesClick(Sender: TObject);
begin
  BuildToolCall(['auto-generate-textures']);
end;

procedure TProjectForm.MenuItemBreakProcessClick(Sender: TObject);
begin
  if RunningProcess = nil then
    raise EInternalError.Create('It should not be possible to call this when RunningProcess = nil');

  OutputList.AddSeparator;
  OutputList.AddLine('Forcefully killing the process.', okError);
  FreeProcess;
end;

procedure TProjectForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  // TODO ask only if unsaved things
  //if YesNoBox('Quit the editor?') then
    Application.Terminate;
end;

procedure TProjectForm.ControlsTreeSelectionChanged(Sender: TObject);
begin
  UpdateSelectedControl;
end;

procedure TProjectForm.FormCreate(Sender: TObject);

  function CommonInspectorCreate: TOIPropertyGrid;
  begin
    Result := TOIPropertyGrid.Create(Self);
    Result.PropertyEditorHook := PropertyEditorHook;
    Result.Align := alClient;
    Result.OnModified := @PropertyGridModified;
    Result.CheckboxForBoolean := true;
    Result.PreferredSplitterX := 150;
    Result.ValueFont.Bold := true;
    Result.ShowGutter := false;
    Result.OnModified := @DesignModifiedNotification;
  end;

begin
  OutputList := TOutputList.Create(ListOutput);

  PropertyEditorHook := TPropertyEditorHook.Create(Self);

  InspectorSimple := CommonInspectorCreate;
  InspectorSimple.Parent := TabSimple;
  InspectorSimple.OnEditorFilter := @InspectorSimpleFilter;
  InspectorSimple.Filter := tkProperties;

  InspectorAdvanced := CommonInspectorCreate;
  InspectorAdvanced.Parent := TabAdvanced;
  InspectorAdvanced.Filter := tkProperties;

  InspectorEvents := CommonInspectorCreate;
  InspectorEvents.Parent := TabEvents;
  InspectorEvents.Filter := tkMethods;

  CastleControl := TCastleControlCustom.Create(Self);
  CastleControl.Parent := PanelAboveTabs;
  CastleControl.Align := alClient;
end;

procedure TProjectForm.FormDestroy(Sender: TObject);
begin
  ApplicationDataOverride := '';
  FreeProcess;
  FreeAndNil(OutputList);
end;

procedure TProjectForm.ListOutputClick(Sender: TObject);
begin
  // TODO: just to source code line in case of error message here
end;

procedure TProjectForm.MenuItemAutoGenerateCleanClick(Sender: TObject);
begin
  BuildToolCall(['auto-generate-clean']);
end;

procedure TProjectForm.MenuItemCleanClick(Sender: TObject);
begin
  BuildToolCall(['clean']);
end;

procedure TProjectForm.MenuItemCompileClick(Sender: TObject);
begin
  BuildToolCall(['compile']);
end;

procedure TProjectForm.MenuItemCompileRunClick(Sender: TObject);
begin
  if ProposeSaveDesign then
    BuildToolCall(['compile', 'run']);
end;

procedure TProjectForm.MenuItemManualClick(Sender: TObject);
begin
  OpenURL('https://castle-engine.io/manual_intro.php');
end;

procedure TProjectForm.MenuItemModeDebugClick(Sender: TObject);
begin
  BuildMode := bmDebug;
  MenuItemModeDebug.Checked := true;
end;

procedure TProjectForm.MenuItemNewDesignUserInterfaceClick(Sender: TObject);
var
  NewRoot: TCastleUserInterfaceRect;
  NewDesignOwner: TComponent;
begin
  NewDesignOwner := TComponent.Create(Self);

  // TODO: Allow choosing starting class?
  NewRoot := TCastleUserInterfaceRect.Create(NewDesignOwner);
  NewRoot.Name := 'Group1';
  NewRoot.FullSize := true;
  OpenDesign(NewRoot, NewDesignOwner, '');
end;

procedure TProjectForm.MenuItemNewDesignTransformClick(Sender: TObject);
var
  NewRoot: TCastleTransform;
  NewDesignOwner: TComponent;
begin
  NewDesignOwner := TComponent.Create(Self);

  // TODO: Allow choosing starting class?
  // TODO: after adding new scenes, trasforms, adjust camera?
  NewRoot := TCastleTransform.Create(NewDesignOwner);
  NewRoot.Name := 'Transform1';
  OpenDesign(NewRoot, NewDesignOwner, '');
end;

procedure TProjectForm.MenuItemOnlyRunClick(Sender: TObject);
begin
  if ProposeSaveDesign then
    BuildToolCall(['run']);
end;

procedure TProjectForm.MenuItemOpenDesignClick(Sender: TObject);
begin
  OpenDesignDialog.Url := DesignUrl;
  if OpenDesignDialog.Execute then
    OpenDesign(OpenDesignDialog.Url);
end;

procedure TProjectForm.MenuItemPackageClick(Sender: TObject);
begin
  BuildToolCall(['package']);
end;

procedure TProjectForm.MenuItemPackageSourceClick(Sender: TObject);
begin
  BuildToolCall(['package-source']);
end;

procedure TProjectForm.MenuItemSwitchProjectClick(Sender: TObject);
begin
  // TODO ask only if unsaved things
  //if YesNoBox('Close this editor project?') then

  Free; // do not call Close, to avoid OnCloseQuery
  ChooseProjectForm.Show;
end;

procedure TProjectForm.ProcessUpdateTimerTimer(Sender: TObject);
begin
  if RunningProcess <> nil then
  begin
    RunningProcess.Update;
    if not RunningProcess.Running then
      FreeProcess;
  end;
end;

procedure TProjectForm.FreeProcess;
begin
  FreeAndNil(RunningProcess);
  SetEnabledCommandRun(true);
  ProcessUpdateTimer.Enabled := false;
end;

procedure TProjectForm.BuildToolCall(const Commands: array of String);
var
  BuildToolExe, ModeString, Command: String;
  QueueItem: TAsynchronousProcessQueue.TQueueItem;
begin
  if RunningProcess <> nil then
    raise EInternalError.Create('It should not be possible to call this when RunningProcess <> nil');

  BuildToolExe := FindExe('castle-engine');
  if BuildToolExe = '' then
  begin
    EditorUtils.ErrorBox('Cannot find build tool (castle-engine) on $PATH environment variable.');
    Exit;
  end;

  case BuildMode of
    bmDebug  : ModeString := '--mode=debug';
    bmRelease: ModeString := '--mode=release';
    else raise EInternalError.Create('BuildMode?');
  end;

  SetEnabledCommandRun(false);
  OutputList.Clear;
  PageControlBottom.ActivePage := TabOutput;
  ProcessUpdateTimer.Enabled := true;

  RunningProcess := TAsynchronousProcessQueue.Create;
  RunningProcess.OutputList := OutputList;

  for Command in Commands do
  begin
    QueueItem := TAsynchronousProcessQueue.TQueueItem.Create;
    QueueItem.ExeName := BuildToolExe;
    QueueItem.CurrentDirectory := ProjectPath;
    QueueItem.Parameters.Add(ModeString);
    QueueItem.Parameters.Add(Command);
    RunningProcess.Queue.Add(QueueItem);
  end;

  RunningProcess.Start;
end;

procedure TProjectForm.SetEnabledCommandRun(const AEnabled: Boolean);
begin
  MenuItemCompile.Enabled := AEnabled;
  MenuItemCompileRun.Enabled := AEnabled;
  MenuItemOnlyRun.Enabled := AEnabled;
  MenuItemClean.Enabled := AEnabled;
  MenuItemPackage.Enabled := AEnabled;
  MenuItemPackageSource.Enabled := AEnabled;
  MenuItemAutoGenerateTextures.Enabled := AEnabled;
  MenuItemAutoGenerateClean.Enabled := AEnabled;
  MenuItemBreakProcess.Enabled := not AEnabled;
end;

procedure TProjectForm.UpdateFormCaption;
var
  DesignName: String;
begin
  // calculate DesignName
  if DesignUrl <> '' then
    DesignName := ExtractURIName(DesignUrl)
  else
  if DesignRoot is TCastleTransform then
    DesignName := 'New Transform'
  else
  if DesignRoot is TCastleUserInterface then
    DesignName := 'New User Interface'
  else
    // generic, should not happen now
    DesignName := 'New Component';

  Caption := '[' + Iff(DesignModified, '*', '') + DesignName + '] ' +
    SQuoteLCLCaption(ProjectName) + ' | Castle Game Engine';
end;

function TProjectForm.ProposeSaveDesign: Boolean;
var
  Mr: TModalResult;
begin
  Result := true;

  { call SaveChanges to be sure to have good DesignModified value.
    Otherwise when editing e.g. TCastleButton.Caption,
    you can press F9 and have DesignModified = false,
    because DesignModifiedNotification doesn't occur because we actually
    press "tab" to focus another control. }
  InspectorSimple.SaveChanges;
  InspectorAdvanced.SaveChanges;
  InspectorEvents.SaveChanges;

  if DesignModified then
  begin
    Mr := MessageDlg('Save Design',
      'Design "' + DesignUrl + '" was modified but not saved yet. Save it before running the application?',
      mtConfirmation, mbYesNoCancel, 0);
    case Mr of
      mrYes: MenuItemSaveDesign.Click;
      mrCancel: Result := false;
    end;
  end;
end;

procedure TProjectForm.OpenProject(const ManifestUrl: String);
var
  ManifestDoc: TXMLDocument;
begin
  ManifestDoc := URLReadXML(ManifestUrl);
  try
    ProjectName := ManifestDoc.DocumentElement.AttributeString('name');
  finally FreeAndNil(ManifestDoc) end;

  ProjectPathUrl := ExtractURIPath(ManifestUrl);
  ProjectPath := URIToFilenameSafe(ProjectPathUrl);

  { override ApplicationData interpretation, and castle-data:/xxx URL,
    while this project is open. }
  ApplicationDataOverride := CombineURI(ProjectPathUrl, 'data/');
  OpenDesignDialog.InitialDir := URIToFilenameSafe(ApplicationDataOverride);
  SaveDesignDialog.InitialDir := URIToFilenameSafe(ApplicationDataOverride);

  ShellTreeView1.Root := ProjectPath;

  // initialize CastleControl
  // TODO: This should follow the auto-scale settings of loaded file
  CastleControl.Container.UIReferenceWidth := 1600;
  CastleControl.Container.UIReferenceHeight := 900;
  CastleControl.Container.UIScaling := usEncloseReferenceSize;

  // start
  MenuItemNewDesignUserInterfaceClick(nil);

  // It's too easy to change it visually and forget, so we set it from code
  PageControlBottom.ActivePage := TabFiles;
  SetEnabledCommandRun(true);
  ControlProperties.ActivePage := TabSimple;

  BuildMode := bmDebug;
  MenuItemModeDebug.Checked := true;
end;

function TProjectForm.ComponentCaption(const C: TComponent): String;

  function ClassCaption(const C: TClass): String;
  begin
    Result := C.ClassName;

    // hide some internal classes by instead displaying ancestor name
    if (C = TControlGameSceneManager) or
       (C = TSceneManagerWorld) or
       (Result = 'TSceneManagerWorldConcrete') then
      Result := ClassCaption(C.ClassParent);
  end;

begin
  Result := C.Name + ' (' + ClassCaption(C.ClassType) + ')';
end;

procedure TProjectForm.InspectorSimpleFilter(Sender: TObject;
  aEditor: TPropertyEditor; var aShow: boolean);
begin
  AShow := (aEditor.GetPropInfo <> nil) and
    (
      (aEditor.GetPropInfo^.Name = 'URL') or
      (aEditor.GetPropInfo^.Name = 'Name') or
      (aEditor.GetPropInfo^.Name = 'Caption')
    );
end;

procedure TProjectForm.PropertyGridModified(Sender: TObject);
var
  SelectedComponent: TComponent;
  Selected: TComponentList;
  SelectedCount: Integer;
begin
  // when you modify component Name in PropertyGrid, update it in the ControlsTree
  Assert(ControlsTree.Selected <> nil);
  Assert(ControlsTree.Selected.Data <> nil);
  Assert(TObject(ControlsTree.Selected.Data) is TComponent);
  SelectedComponent := TComponent(ControlsTree.Selected.Data);

  ControlsTree.Selected.Text := ComponentCaption(SelectedComponent);

  { update also LabelControlSelected }
  GetSelected(Selected, SelectedCount);
  try
    if SelectedCount = 1 then
      LabelControlSelected.Caption := 'Selected:' + NL + ComponentCaption(Selected[0]);
  finally FreeAndNil(Selected) end;
end;

procedure TProjectForm.UpdateDesign(const Root: TComponent);

  function AddTransform(const Parent: TTreeNode; const T: TCastleTransform): TTreeNode;
  var
    S: String;
    I: Integer;
  begin
    S := ComponentCaption(T);
    Result := ControlsTree.Items.AddChildObject(Parent, S, T);
    for I := 0 to T.Count - 1 do
      AddTransform(Result, T[I]);
  end;

  function AddControl(const Parent: TTreeNode; const C: TCastleUserInterface): TTreeNode;
  var
    S: String;
    I: Integer;
    SceneManager: TCastleSceneManager;
  begin
    S := ComponentCaption(C);
    Result := ControlsTree.Items.AddChildObject(Parent, S, C);
    for I := 0 to C.ControlsCount - 1 do
      AddControl(Result, C.Controls[I]);

    if C is TCastleSceneManager then
    begin
      SceneManager := TCastleSceneManager(C);
      AddTransform(Result, SceneManager.Items);
    end;
  end;

var
  Node: TTreeNode;
begin
  ControlsTree.Items.Clear;

  if Root is TCastleUserInterface then
    Node := AddControl(nil, Root as TCastleUserInterface)
  else
  if Root is TCastleTransform then
    Node := AddTransform(nil, Root as TCastleTransform)
  else
    raise EInternalError.Create('Cannot UpdateDesign with other classes than TCastleUserInterface or TCastleTransform');

  // show expanded by default
  Node.Expand(true);

  UpdateSelectedControl;
end;

procedure TProjectForm.GetSelected(out Selected: TComponentList;
  out SelectedCount: Integer);

  function SelectedFromNode(const Node: TTreeNode): TComponent;
  var
    SelectedObject: TObject;
    //SelectedControl: TCastleUserInterface;
    //SelectedTransform: TCastleTransform;
  begin
    SelectedObject := nil;
    Result := nil;
    //SelectedControl := nil;
    //SelectedTransform := nil;

    if Node <> nil then
    begin
      SelectedObject := TObject(Node.Data);
      if SelectedObject is TComponent then
      begin
        Result := TComponent(SelectedObject);
        //if SelectedComponent is TCastleUserInterface then
        //  SelectedControl := TCastleUserInterface(SelectedComponent)
        //else
        //if SelectedComponent is TCastleTransform then
        //  SelectedTransform := TCastleTransform(SelectedComponent);
      end;
    end;
  end;

var
  I: Integer;
  C: TComponent;
begin
  Selected := nil;

  for I := 0 to ControlsTree.SelectionCount - 1 do
  begin
    C := SelectedFromNode(ControlsTree.Selections[I]);
    if C <> nil then
    begin
      if Selected = nil then
        Selected := TComponentList.Create(false);
      Selected.Add(C);
    end;
  end;

  if Selected <> nil then
    SelectedCount := Selected.Count
  else
    SelectedCount := 0;
end;

procedure TProjectForm.DesignModifiedNotification(Sender: TObject);
begin
  DesignModified := true;
  UpdateFormCaption;
end;

procedure TProjectForm.UpdateSelectedControl;
var
  Selected: TComponentList;
  SelectionForOI: TPersistentSelectionList;
  I, SelectedCount: Integer;
begin
  GetSelected(Selected, SelectedCount);
  try
    case SelectedCount of
      0: LabelControlSelected.Caption := 'Nothing Selected';
      1: LabelControlSelected.Caption := 'Selected:' + NL + ComponentCaption(Selected[0]);
      else LabelControlSelected.Caption := 'Selected:' + NL + IntToStr(SelectedCount) + ' components';
    end;

    ControlProperties.Visible := SelectedCount <> 0;
    ControlProperties.Enabled := SelectedCount <> 0;

    SelectionForOI := TPersistentSelectionList.Create;
    try
      for I := 0 to SelectedCount - 1 do
        SelectionForOI.Add(Selected[I]);
      InspectorSimple.Selection := SelectionForOI;
      InspectorAdvanced.Selection := SelectionForOI;
      InspectorEvents.Selection := SelectionForOI;
    finally FreeAndNil(SelectionForOI) end;
  finally FreeAndNil(Selected) end;
end;

initialization
  // initialize CGE log
  ApplicationProperties.ApplicationName := 'castle-editor';
  InitializeLog;

  { Enable using our property edits e.g. for TCastleScene.URL }
  CastlePropEdits.Register;
  PropertyEditorsAdviceDataDirectory := true;
end.
