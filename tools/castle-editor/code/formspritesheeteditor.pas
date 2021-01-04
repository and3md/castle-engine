unit FormSpriteSheetEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, ActnList, StdCtrls, Spin, Menus,
  CastleControl, CastleDialogs, CastleScene, CastleSpriteSheet, CastleVectors,
  CastleViewport,
  DataModuleIcons;

type
  TSpriteSheetEditorForm = class(TForm)
    ActionMoveAnimationEnd: TAction;
    ActionMoveAnimationTop: TAction;
    ActionMoveAnimationDown: TAction;
    ActionMoveAnimationUp: TAction;
    ActionMoveFrameEnd: TAction;
    ActionMoveFrameTop: TAction;
    ActionMoveFrameDown: TAction;
    ActionMoveFrameUp: TAction;
    ActionAddAnimation: TAction;
    ActionAddFrame: TAction;
    ActionRenameAnimation: TAction;
    ActionDeleteAnimation: TAction;
    ActionDeleteFrame: TAction;
    ActionSaveSpriteSheetAs: TAction;
    ActionSaveSpriteSheet: TAction;
    ActionNewSpriteSheet: TAction;
    ActionOpenSpriteSheet: TAction;
    ActionListSpriteSheet: TActionList;
    CastleControlPreview: TCastleControlBase;
    CastleOpenImageDialog: TCastleOpenImageDialog;
    ImageAtlasSizeWarning: TImage;
    ImageListFrames: TImageList;
    LabelAtlasWarning: TLabel;
    LabelAtlasSizeError: TLabel;
    LabelMaximumAtlasSize: TLabel;
    LabelNoFrameToShow: TLabel;
    ListViewAnimations: TListView;
    MainMenuItemAddAnimation: TMenuItem;
    MainMenuItemDeleteAnimation: TMenuItem;
    MainMenuItemMoveFrameUp: TMenuItem;
    MainMenuItemMoveFrameDown: TMenuItem;
    MainMenuItemMoveFrameTop: TMenuItem;
    MainMenuItemMoveFrameEnd: TMenuItem;
    MainMenuItemAddFrame: TMenuItem;
    MainMenuItemDeleteFrame: TMenuItem;
    N1: TMenuItem;
    MenuItemRenameAnimation: TMenuItem;
    MenuItemFrameMenu: TMenuItem;
    MenuItemAnimationMenu: TMenuItem;
    MenuItemAnimationEnd: TMenuItem;
    MenuItemAnimationTop: TMenuItem;
    MenuItemAnimationDown: TMenuItem;
    MenuItemMoveAnimationUp: TMenuItem;
    MenuItemMoveEnd: TMenuItem;
    MenuItemMoveFrameToTop: TMenuItem;
    MenuItemMoveFrameDown: TMenuItem;
    MenuItemMoveFrameUp: TMenuItem;
    MenuItemAddAnimation: TMenuItem;
    MenuItemAddFrame: TMenuItem;
    MenuItemRename: TMenuItem;
    MenuItemDeleteAnimation: TMenuItem;
    MenuItemDeleteFrame: TMenuItem;
    OpenDialog: TCastleOpenDialog;
    PanelPreviewHead: TPanel;
    PopupMenuAnimations: TPopupMenu;
    PopupMenuFrames: TPopupMenu;
    RadioAnimation: TRadioButton;
    RadioFrame: TRadioButton;
    SaveDialog: TCastleSaveDialog;
    FloatSpinEditFPS: TFloatSpinEdit;
    LabelPreview: TLabel;
    LabelFrames: TLabel;
    LabelAnimations: TLabel;
    LabelFPS: TLabel;
    ListViewFrames: TListView;
    MainMenu: TMainMenu;
    MenuItemNew: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    MenuItemSaveAs: TMenuItem;
    MenuItemFile: TMenuItem;
    PanelFPS: TPanel;
    PanelRight: TPanel;
    PanelMiddle: TPanel;
    PanelTop: TPanel;
    PanelLeft: TPanel;
    SpeedButtonOpenSpriteSheet: TSpeedButton;
    SpeedButtonNewSpriteSheet: TSpeedButton;
    SpeedButtonAddAnimation: TSpeedButton;
    SpeedButtonSaveSpriteSheet: TSpeedButton;
    SpeedButtonRemoveAnimation: TSpeedButton;
    SpeedButtonSaveSpriteSheetAs: TSpeedButton;
    SpinEditMaxAtlasSize: TSpinEdit;
    SplitterRight: TSplitter;
    SplitterLeft: TSplitter;
    procedure ActionAddAnimationExecute(Sender: TObject);
    procedure ActionAddAnimationUpdate(Sender: TObject);
    procedure ActionAddFrameExecute(Sender: TObject);
    procedure ActionAddFrameUpdate(Sender: TObject);
    procedure ActionMoveAnimationDownExecute(Sender: TObject);
    procedure ActionMoveAnimationDownUpdate(Sender: TObject);
    procedure ActionMoveAnimationEndExecute(Sender: TObject);
    procedure ActionMoveAnimationEndUpdate(Sender: TObject);
    procedure ActionMoveAnimationTopExecute(Sender: TObject);
    procedure ActionMoveAnimationTopUpdate(Sender: TObject);
    procedure ActionMoveAnimationUpExecute(Sender: TObject);
    procedure ActionMoveAnimationUpUpdate(Sender: TObject);
    procedure ActionMoveFrameDownExecute(Sender: TObject);
    procedure ActionMoveFrameDownUpdate(Sender: TObject);
    procedure ActionMoveFrameEndExecute(Sender: TObject);
    procedure ActionMoveFrameEndUpdate(Sender: TObject);
    procedure ActionMoveFrameTopExecute(Sender: TObject);
    procedure ActionMoveFrameTopUpdate(Sender: TObject);
    procedure ActionMoveFrameUpExecute(Sender: TObject);
    procedure ActionMoveFrameUpUpdate(Sender: TObject);
    procedure ActionNewSpriteSheetExecute(Sender: TObject);
    procedure ActionOpenSpriteSheetExecute(Sender: TObject);
    procedure ActionDeleteAnimationExecute(Sender: TObject);
    procedure ActionDeleteAnimationUpdate(Sender: TObject);
    procedure ActionDeleteFrameExecute(Sender: TObject);
    procedure ActionDeleteFrameUpdate(Sender: TObject);
    procedure ActionRenameAnimationExecute(Sender: TObject);
    procedure ActionRenameAnimationUpdate(Sender: TObject);
    procedure FloatSpinEditFPSChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewAnimationsEdited(Sender: TObject; Item: TListItem;
      var AValue: string);
    procedure ListViewAnimationsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewFramesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure RadioFrameChange(Sender: TObject);
    procedure SpinEditMaxAtlasSizeChange(Sender: TObject);
    procedure SpinEditMaxAtlasSizeEditingDone(Sender: TObject);
  private
    type
      TPreviewMode = (pmAnimation, pmFrame);
      { Enum just for readability }
      TForceFileRegen = (ffgDoForceFileRegen, ffgDontForceFileRegen);

    const
      MaxFrameSize = 256;
      DefaultFrameSize = 128;

    var
      FSpriteSheet: TCastleSpriteSheet;
      FPreviewScene: TCastleScene;
      FViewport: TCastleViewport;
      FWindowTitle: String;
      FrameIconSize: TVector2Integer; // current frame size in list view

    // Returns true if sprite sheet is closed
    function CloseSpriteSheet: Boolean;
    procedure AssignEventsToSpriteSheet;

    procedure ClearAnimations;
    procedure LoadAnimations(const SpriteSheet: TCastleSpriteSheet);
    function AddAnimationToListView(const Animation: TCastleSpriteSheetAnimation):
      TListItem;
    procedure LoadAnimation(const Animation: TCastleSpriteSheetAnimation);
    function GetCurrentAnimation: TCastleSpriteSheetAnimation;

    procedure ClearFrames;
    function AddFrameToListView(const Frame: TCastleSpriteSheetFrame;
      const FrameNo: Integer): TListItem;
    procedure LoadFrames(const Animation: TCastleSpriteSheetAnimation);
    function GetSelectedFrame: TCastleSpriteSheetFrame;

    { Returns current preview mode }
    function GetCurrentPreviewMode: TPreviewMode;
    { Shows or hides some preview controls. Just to have this switch in
      one place. }
    procedure ShowPreviewControl(const MakeVisible: Boolean);
    { Creates viewport and scene for preview }
    procedure CreatePreviewUIIfNeeded;
    { Updates current preview. If PreviewModesToUpdate is pmAnimation
      value of ForcePreviewFileRegen controls sprite sheet file should be forced
      to regenrate/reload. Note that it will be regenerated even if you don't
      set it force when it's obvoius (eg. for frames). }
    procedure UpdatePreview(const PreviewModesToUpdate: TPreviewMode;
      const ForcePreviewFileRegen: TForceFileRegen);
    { Regenerates and load animation temp file }
    procedure RegenerateAnimationPreviewFile;
    { Regenerates and load frame temp file }
    procedure RegenerateFramePreviewFile(const Frame: TCastleSpriteSheetFrame);

    procedure UpdateWindowCaption;
    procedure SetAtlasError(const Message: String);
    procedure SetAtlasWarning(const Message: String);

    { Check atlas size }
    function CheckAtlasMinSize: Boolean;

    // events:

    procedure ModifiedStateChanged(Sender: TObject);

    procedure AnimationAdded(NewAnimation: TCastleSpriteSheetAnimation);
    procedure BeforeAnimationRemoved(AnimationToRemove: TCastleSpriteSheetAnimation);

    procedure FrameAdded(NewFrame: TCastleSpriteSheetFrame);
    procedure BeforeAnimationFrameRemoved(FrameToRemove: TCastleSpriteSheetFrame);
    procedure FrameMoved(const Frame: TCastleSpriteSheetFrame;
      const OldIndex, NewIndex: Integer);
    procedure AnimationMoved(const Animation: TCastleSpriteSheetAnimation;
      const OldIndex, NewIndex: Integer);
    procedure MaxAtlasSizeChanged(const MaxWidth, MaxHeight: Integer);

  public
    procedure OpenSpriteSheet(const URL: String);
    procedure NewSpriteSheet;
  end;

var
  SpriteSheetEditorForm: TSpriteSheetEditorForm;

implementation

{$R *.lfm}

uses GraphType, IntfGraphics, Math,
  CastleImages, CastleLog, CastleUtils, CastleURIUtils,
  EditorUtils,
  FormProject;

{ TSpriteSheetEditorForm }

procedure TSpriteSheetEditorForm.ActionNewSpriteSheetExecute(Sender: TObject);
begin
  NewSpriteSheet;
end;

procedure TSpriteSheetEditorForm.ActionAddFrameUpdate(Sender: TObject);
begin
  ActionAddFrame.Enabled := GetCurrentAnimation <> nil;
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationDownExecute(Sender: TObject
  );
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  FSpriteSheet.MoveAnimationDown(Animation);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationDownUpdate(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  ActionMoveAnimationDown.Enabled := (Animation <> nil)
    and (FSpriteSheet.AnimationIndex(Animation) <> FSpriteSheet.AnimationCount - 1);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationEndExecute(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  FSpriteSheet.MoveAnimationToEnd(Animation);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationEndUpdate(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  ActionMoveAnimationEnd.Enabled := (Animation <> nil)
    and (FSpriteSheet.AnimationIndex(Animation) <> FSpriteSheet.AnimationCount - 1);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationTopExecute(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  FSpriteSheet.MoveAnimationToTop(Animation);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationTopUpdate(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  ActionMoveAnimationTop.Enabled := (Animation <> nil)
    and (FSpriteSheet.AnimationIndex(Animation) <> 0);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationUpExecute(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  FSpriteSheet.MoveAnimationUp(Animation);
end;

procedure TSpriteSheetEditorForm.ActionMoveAnimationUpUpdate(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  ActionMoveAnimationUp.Enabled := (Animation <> nil)
    and (FSpriteSheet.AnimationIndex(Animation) <> 0);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameDownExecute(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  Frame := GetSelectedFrame;

  if (Animation = nil) or (Frame = nil) then
    Exit;

  Animation.MoveFrameDown(Frame);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameDownUpdate(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
begin
  Frame := GetSelectedFrame;
  ActionMoveFrameDown.Enabled := (Frame <> nil)
    and (Frame.Animation.FrameIndex(Frame) < Frame.Animation.FrameCount - 1);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameEndExecute(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  Frame := GetSelectedFrame;

  if (Animation = nil) or (Frame = nil) then
    Exit;

  Animation.MoveFrameToEnd(Frame);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameEndUpdate(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
begin
  Frame := GetSelectedFrame;
  ActionMoveFrameEnd.Enabled := (Frame <> nil)
    and (Frame.Animation.FrameIndex(Frame) < Frame.Animation.FrameCount - 1);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameTopExecute(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  Frame := GetSelectedFrame;

  if (Animation = nil) or (Frame = nil) then
    Exit;

  Animation.MoveFrameToTop(Frame);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameTopUpdate(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
begin
  Frame := GetSelectedFrame;
  ActionMoveFrameTop.Enabled := (Frame <> nil)
    and (Frame.Animation.FrameIndex(Frame) > 0);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameUpExecute(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  Frame := GetSelectedFrame;

  if (Animation = nil) or (Frame = nil) then
    Exit;

  Animation.MoveFrameUp(Frame);
end;

procedure TSpriteSheetEditorForm.ActionMoveFrameUpUpdate(Sender: TObject);
var
  Frame: TCastleSpriteSheetFrame;
begin
  Frame := GetSelectedFrame;
  ActionMoveFrameUp.Enabled := (Frame <> nil)
    and (Frame.Animation.FrameIndex(Frame) > 0);
end;

procedure TSpriteSheetEditorForm.ActionAddFrameExecute(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  if CastleOpenImageDialog.Execute then
  begin
    Animation.AddFrame(CastleOpenImageDialog.URL);
  end;
end;

procedure TSpriteSheetEditorForm.ActionAddAnimationUpdate(Sender: TObject);
begin
  ActionAddAnimation.Enabled := FSpriteSheet <> nil;
end;

procedure TSpriteSheetEditorForm.ActionAddAnimationExecute(Sender: TObject);
begin
  FSpriteSheet.AddAnimation(FSpriteSheet.ProposeAnimationName);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.ActionOpenSpriteSheetExecute(Sender: TObject);
begin
  if not CloseSpriteSheet then
    Exit;
  if OpenDialog.Execute then
    OpenSpriteSheet(OpenDialog.URL);
end;

procedure TSpriteSheetEditorForm.ActionDeleteAnimationExecute(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  FSpriteSheet.RemoveAnimation(Animation);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.ActionDeleteAnimationUpdate(Sender: TObject);
begin
  ActionDeleteAnimation.Enabled := (GetCurrentAnimation <> nil);
end;

procedure TSpriteSheetEditorForm.ActionDeleteFrameExecute(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
  Frame: TCastleSpriteSheetFrame;
begin
  Animation := GetCurrentAnimation;
  if Animation = nil then
    Exit;

  Frame := GetSelectedFrame;
  Animation.RemoveFrame(Frame);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.ActionDeleteFrameUpdate(Sender: TObject);
begin
  ActionDeleteFrame.Enabled := (GetSelectedFrame <> nil);
end;

procedure TSpriteSheetEditorForm.ActionRenameAnimationExecute(Sender: TObject);
begin
  ListViewAnimations.Selected.EditCaption;
end;

procedure TSpriteSheetEditorForm.ActionRenameAnimationUpdate(Sender: TObject);
begin
  ActionRenameAnimation.Enabled := (GetCurrentAnimation <> nil);
end;

procedure TSpriteSheetEditorForm.FloatSpinEditFPSChange(Sender: TObject);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;
  Assert(Animation <> nil,
    'Animation should never be nil when SpinEditFPS is enabled');
  Animation.FramesPerSecond := FloatSpinEditFPS.Value;
  { To change frames per second file must be regenerated. }
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.FormCreate(Sender: TObject);
begin
  FSpriteSheet := nil;
  FWindowTitle := SpriteSheetEditorForm.Caption;
  SetAtlasError('');
  SetAtlasWarning('');
  NewSpriteSheet;
end;

procedure TSpriteSheetEditorForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSpriteSheet);
end;

procedure TSpriteSheetEditorForm.ListViewAnimationsEdited(Sender: TObject;
  Item: TListItem; var AValue: string);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := TCastleSpriteSheetAnimation(Item.Data);

  if Animation.Name = AValue then
    Exit;

  if FSpriteSheet.HasAnimation(AValue) then
  begin
    EditorUtils.ErrorBox('Animation "' + AValue + '" already exist.');
    AValue := Animation.Name;
    Exit;
  end;

  Animation.Name := AValue;
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.ListViewAnimationsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  Animation: TCastleSpriteSheetAnimation;
begin
  Animation := GetCurrentAnimation;

  if Animation <> nil then
    LoadAnimation(Animation);
end;

procedure TSpriteSheetEditorForm.ListViewFramesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  { In case of changing frames, animation preview should be ok
    (frame preview is always regenerated). }
  UpdatePreview(GetCurrentPreviewMode, ffgDontForceFileRegen);
end;

procedure TSpriteSheetEditorForm.RadioFrameChange(Sender: TObject);
begin
  { In case of changing from frame preview to animation preview,
    animation preview can be outdated so we force file regeneration }
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.SpinEditMaxAtlasSizeChange(Sender: TObject);
begin
end;

procedure TSpriteSheetEditorForm.SpinEditMaxAtlasSizeEditingDone(Sender: TObject
  );
begin
  FSpriteSheet.SetMaxAtlasSize(SpinEditMaxAtlasSize.Value,
    SpinEditMaxAtlasSize.Value);
end;

function TSpriteSheetEditorForm.CloseSpriteSheet: Boolean;
begin
  // TODO: ask for save
  ClearFrames;
  ClearAnimations;
  FreeAndNil(FSpriteSheet);
  Result := True;
end;

procedure TSpriteSheetEditorForm.AssignEventsToSpriteSheet;
begin
  FSpriteSheet.OnModifiedStateChanged := @ModifiedStateChanged;
  FSpriteSheet.OnAnimationAdded := @AnimationAdded;
  FSpriteSheet.OnAnimationMoved := @AnimationMoved;
  FSpriteSheet.BeforeAnimationRemoved := @BeforeAnimationRemoved;
  FSpriteSheet.OnFrameAdded := @FrameAdded;
  FSpriteSheet.OnFrameMoved := @FrameMoved;
  FSpriteSheet.BeforeFrameRemoved := @BeforeAnimationFrameRemoved;
  FSpriteSheet.OnMaxAtlasSizeChanged := @MaxAtlasSizeChanged;
end;

procedure TSpriteSheetEditorForm.LoadAnimations(const SpriteSheet: TCastleSpriteSheet);
var
  I: Integer;
begin
  for I := 0 to SpriteSheet.AnimationCount - 1 do
    AddAnimationToListView(SpriteSheet.AnimationByIndex(I));

  if SpriteSheet.AnimationCount > 0 then
    ListViewAnimations.ItemIndex := 0;
end;

function TSpriteSheetEditorForm.AddAnimationToListView(
  const Animation: TCastleSpriteSheetAnimation): TListItem;
var
  ListItem: TListItem;
begin
  ListItem := ListViewAnimations.Items.Add;
  ListItem.Caption := Animation.Name;
  ListItem.Data := Animation;
  Result := ListItem;
end;

procedure TSpriteSheetEditorForm.LoadAnimation(const Animation: TCastleSpriteSheetAnimation);
begin
  FloatSpinEditFPS.Value := Animation.FramesPerSecond;
  ClearFrames;
  LoadFrames(Animation);
  UpdatePreview(GetCurrentPreviewMode, ffgDontForceFileRegen);
end;

procedure TSpriteSheetEditorForm.ClearFrames;
begin
  ListViewFrames.Items.Clear;
end;

function TSpriteSheetEditorForm.AddFrameToListView(
  const Frame: TCastleSpriteSheetFrame; const FrameNo: Integer): TListItem;
var
  ListItem: TListItem;
  ResizedFrameImage: TCastleImage;
  Bitmap: TBitmap;
  IntfImage: TLazIntfImage;
  ImageIndex: Integer;

  function FrameImageToLazImage(const FrameImage: TCastleImage;
    const Width, Height: Integer): TLazIntfImage;
  var
    RawImage: TRawImage;
    Y: Integer;
    RowSize: Integer;
    SourceRow: PByte;
    DestRow: PByte;
  begin
    // https://wiki.freepascal.org/Developing_with_Graphics#Working_with_TLazIntfImage.2C_TRawImage_and_TLazCanvas

    // TODO: Support other image format than RGBA
    RawImage.Init;
    RawImage.Description.Init_BPP32_R8G8B8A8_BIO_TTB(Width, Height);
    RawImage.CreateData(True);
    RowSize := FrameImage.Width * 4;

    // go to last row
    SourceRow := PByte(FrameImage.RawPixels) + RowSize * Height;
    DestRow := RawImage.Data;

    for Y := Height - 1 downto 0 do
    begin
      Dec(SourceRow, RowSize);
      Move(SourceRow^, DestRow^, RowSize);
      Inc(DestRow, RowSize);
    end;

    Result := TLazIntfImage.Create(0, 0);
    Result.SetRawImage(RawImage);
  end;

begin
  ResizedFrameImage := nil;
  IntfImage := nil;
  Bitmap := nil;
  try
    // TODO:  better scaling alghoritm
    ResizedFrameImage := Frame.MakeResized(FrameIconSize.X, FrameIconSize.Y);

    IntfImage := FrameImageToLazImage(ResizedFrameImage, FrameIconSize.X,
      FrameIconSize.Y);

    Bitmap := TBitmap.Create;
    Bitmap.LoadFromIntfImage(IntfImage);
    ImageIndex := ImageListFrames.Add(Bitmap, nil);
  finally
    FreeAndNil(ResizedFrameImage);
    FreeAndNil(IntfImage);
    FreeAndNil(Bitmap);
  end;

  ListItem := ListViewFrames.Items.Add;
  ListItem.Caption := IntToStr(FrameNo) + ' - ' + IntToStr(Frame.FrameWidth) +
    'x' + IntToStr(Frame.FrameHeight);
  ListItem.Data := Frame;
  ListItem.ImageIndex := ImageIndex;
  Result := ListItem;
end;

procedure TSpriteSheetEditorForm.LoadFrames(const Animation: TCastleSpriteSheetAnimation);
var
  I: Integer;

  procedure PrepareImageList;
  begin
    ImageListFrames.Clear;

    { ListView can have only one size of images so we need decide about size. }

    FrameIconSize := Animation.GetBigestFrameSize(MaxFrameSize, MaxFrameSize);

    if (FrameIconSize.X = 0) or (FrameIconSize.Y = 0) then
    begin
      FrameIconSize.X := DefaultFrameSize;
      FrameIconSize.Y := DefaultFrameSize;
    end;

    ImageListFrames.Width := FrameIconSize.X;
    ImageListFrames.Height := FrameIconSize.Y;
  end;

begin
  PrepareImageList;

  for I := 0 to Animation.FrameCount - 1 do
    AddFrameToListView(Animation.Frame[I], I);
end;

function TSpriteSheetEditorForm.GetSelectedFrame: TCastleSpriteSheetFrame;
begin
  if ListViewFrames.ItemIndex < 0 then
    Exit(nil);

  { TODO: add frame button - add condition here!!! }

  Result := TCastleSpriteSheetFrame(ListViewFrames.Items[ListViewFrames.ItemIndex].Data);
end;

function TSpriteSheetEditorForm.GetCurrentPreviewMode: TPreviewMode;
begin
  if RadioAnimation.Checked then
    Result:= pmAnimation
  else
    Result:= pmFrame;
end;

procedure TSpriteSheetEditorForm.ShowPreviewControl(const MakeVisible: Boolean);
begin
  CastleControlPreview.Visible := MakeVisible;
  LabelNoFrameToShow.Visible := not MakeVisible;
end;

procedure TSpriteSheetEditorForm.CreatePreviewUIIfNeeded;
begin
  if FPreviewScene = nil then
  begin
    FViewport := TCastleViewport.Create(Application);
    FViewport.FullSize := true;
    FViewport.AutoCamera := true;
    FViewport.AutoNavigation := true;
    CastleControlPreview.Controls.InsertFront(FViewport);


    FPreviewScene := TCastleScene.Create(FViewport);

    FViewport.Items.Add(FPreviewScene);
    FViewport.Items.MainScene := FPreviewScene;
  end;
end;

procedure TSpriteSheetEditorForm.UpdatePreview(
  const PreviewModesToUpdate: TPreviewMode;
  const ForcePreviewFileRegen: TForceFileRegen);

  procedure LoadFrameInPreview(
    const Frame: TCastleSpriteSheetFrame);
  begin
    if Frame = nil then
    begin
      ShowPreviewControl(false);
      Exit;
    end;
    RegenerateFramePreviewFile(Frame);
    FPreviewScene.Exists := true;
    ShowPreviewControl(true);
  end;

  procedure LoadAnimationInPreview(
    const Animation: TCastleSpriteSheetAnimation);
  begin
    ShowPreviewControl(true);
    if FPreviewScene = nil then
      RegenerateAnimationPreviewFile;

    if (Animation = nil) or (Animation.FrameCount = 0) or
      (not CheckAtlasMinSize) then
    begin
      FPreviewScene.Exists := false;
      FPreviewScene.StopAnimation
    end else
    begin
      FPreviewScene.Exists := true;
      FPreviewScene.PlayAnimation(Animation.Name, true, true);
    end;
  end;

begin
  case PreviewModesToUpdate of
    pmAnimation:
      begin
        { only when we know file should change }
        if ForcePreviewFileRegen = ffgDoForceFileRegen then
          RegenerateAnimationPreviewFile;
        LoadAnimationInPreview(GetCurrentAnimation);
      end;
    pmFrame:
      LoadFrameInPreview(GetSelectedFrame);
  end;
end;

function TSpriteSheetEditorForm.GetCurrentAnimation: TCastleSpriteSheetAnimation;
begin
  if ListViewAnimations.ItemIndex < 0 then
    Exit(nil);

  Result := TCastleSpriteSheetAnimation(ListViewAnimations.Items[ListViewAnimations.ItemIndex].Data);
end;

procedure TSpriteSheetEditorForm.RegenerateAnimationPreviewFile;
var
  TempURL: String;
begin
  try
    CreatePreviewUIIfNeeded;
    if not CheckAtlasMinSize then
      Exit;

    TempURL := URIIncludeSlash(ProjectForm.ProjectPathUrl) + 'temp/preview.castle-sprite-sheet';
    ForceDirectories(ExtractFilePath(URIToFilenameSafe(TempURL)));

    FSpriteSheet.Save(TempURL, true);

    FPreviewScene.Load(TempURL);
  except
    on E: Exception do
    begin
      ErrorBox(E.Message);
    end;
  end;
end;

procedure TSpriteSheetEditorForm.RegenerateFramePreviewFile(const Frame: TCastleSpriteSheetFrame);
var
  TempURL: String;
begin
  TempURL := URIIncludeSlash(ProjectForm.ProjectPathUrl) + 'temp/frame_preview.png';
  ForceDirectories(ExtractFilePath(URIToFilenameSafe(TempURL)));
  Frame.SaveFrameImage(TempURL);

  CreatePreviewUIIfNeeded;

  FPreviewScene.Load(TempURL);
end;

procedure TSpriteSheetEditorForm.UpdateWindowCaption;
var
  ModifiedMark: String;
  FileName: String;
begin
  if FSpriteSheet = nil then
  begin
    SpriteSheetEditorForm.Caption := FWindowTitle;
    Exit;
  end;

  if FSpriteSheet.IsModified then
    ModifiedMark := '*'
  else
    ModifiedMark := '';

  if FSpriteSheet.URL = '' then
    FileName := 'unknown'
  else
    FileName := FSpriteSheet.URL;

  SpriteSheetEditorForm.Caption := FWindowTitle + ' - ' + ModifiedMark +
    FileName;
end;

procedure TSpriteSheetEditorForm.SetAtlasError(const Message: String);
begin
  LabelAtlasSizeError.Caption := Message;
end;

procedure TSpriteSheetEditorForm.SetAtlasWarning(const Message: String);
begin
  ImageAtlasSizeWarning.Visible := (Message <> '');
  LabelAtlasWarning.Caption := Message;
end;

function TSpriteSheetEditorForm.CheckAtlasMinSize: Boolean;
var
  MinAtlasWidth, MinAtlasHeight: Integer;
begin
  FSpriteSheet.GetMinAtlasSize(MinAtlasWidth, MinAtlasHeight);

  if (MinAtlasWidth > FSpriteSheet.MaxAtlasWidth) or
    (MinAtlasHeight > FSpriteSheet.MaxAtlasHeight) then
  begin
    SetAtlasError(Format(
      'Max atlas size to small to fit all frames %d needed.',
      [Max(MinAtlasWidth, MinAtlasHeight)])
    );
    Exit(false);
  end;
  SetAtlasError('');

  { check power of two }
  if not IsPowerOf2(Max(FSpriteSheet.MaxAtlasHeight,
    FSpriteSheet.MaxAtlasWidth)) then
    SetAtlasWarning('We adwise using power of 2 size.')
  else
    SetAtlasWarning('');

  Result := true;
end;

procedure TSpriteSheetEditorForm.ModifiedStateChanged(Sender: TObject);
begin
  UpdateWindowCaption;
end;

procedure TSpriteSheetEditorForm.BeforeAnimationRemoved(
  AnimationToRemove: TCastleSpriteSheetAnimation);
var
  I: Integer;
  ItemIndex: Integer;
begin
  if AnimationToRemove = GetCurrentAnimation then
  begin
    ClearFrames;
    ItemIndex := ListViewAnimations.ItemIndex;
    ListViewAnimations.Items.Delete(ItemIndex);

    { Select next animation }
    if ListViewAnimations.Items.Count > 0 then
    begin
      if ListViewAnimations.Items.Count > ItemIndex then
        ListViewAnimations.ItemIndex := ItemIndex
      else
        ListViewAnimations.ItemIndex := ListViewAnimations.Items.Count - 1;
    end;

    Exit;
  end;

  { When not current animation was removed }
  for I := ListViewAnimations.Items.Count - 1 downto 0 do
  begin
    if TObject(ListViewAnimations.Items[i].Data) = AnimationToRemove then
    begin
      ListViewAnimations.Items.Delete(I);
      Exit;
    end;
  end;
end;

procedure TSpriteSheetEditorForm.BeforeAnimationFrameRemoved(
  FrameToRemove: TCastleSpriteSheetFrame);
var
  I: Integer;
begin
  if FrameToRemove.Animation <> GetCurrentAnimation then
    Exit;

  for I := ListViewFrames.Items.Count - 1 downto 0 do
  begin
    if TCastleSpriteSheetFrame(ListViewFrames.Items[I].Data) = FrameToRemove then
      ListViewFrames.Items.Delete(I);
  end;
end;

procedure TSpriteSheetEditorForm.FrameMoved(
  const Frame: TCastleSpriteSheetFrame; const OldIndex, NewIndex: Integer);
begin
  ListViewFrames.Items.Move(OldIndex, NewIndex);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.AnimationMoved(
  const Animation: TCastleSpriteSheetAnimation; const OldIndex,
  NewIndex: Integer);
begin
  ListViewAnimations.Items.Move(OldIndex, NewIndex);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.MaxAtlasSizeChanged(const MaxWidth,
  MaxHeight: Integer);
begin
  SpinEditMaxAtlasSize.Value := Max(MaxWidth, MaxHeight);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.AnimationAdded(
  NewAnimation: TCastleSpriteSheetAnimation);
begin
  ListViewAnimations.Selected := AddAnimationToListView(NewAnimation);
end;

procedure TSpriteSheetEditorForm.FrameAdded(NewFrame: TCastleSpriteSheetFrame);
begin
  if NewFrame.Animation <> GetCurrentAnimation then
    Exit;

  { Add frame on last position }
  AddFrameToListView(NewFrame, NewFrame.Animation.FrameCount);
  UpdatePreview(GetCurrentPreviewMode, ffgDoForceFileRegen);
end;

procedure TSpriteSheetEditorForm.ClearAnimations;
begin
  ListViewAnimations.Items.Clear;
end;

procedure TSpriteSheetEditorForm.OpenSpriteSheet(const URL: String);
begin
  try
    if not CloseSpriteSheet then
      Exit;
    FSpriteSheet :=  TCastleSpriteSheet.Create;
    FSpriteSheet.OnModifiedStateChanged := @ModifiedStateChanged;
    FSpriteSheet.Load(URL);
    UpdateWindowCaption;
    LoadAnimations(FSpriteSheet);
    AssignEventsToSpriteSheet;
  except
    on E:Exception do
    begin
      ErrorBox(E.Message);
    end;
  end;
end;

procedure TSpriteSheetEditorForm.NewSpriteSheet;
begin
  try
    if not CloseSpriteSheet then
      Exit;
    FSpriteSheet :=  TCastleSpriteSheet.Create;
    UpdateWindowCaption;
    LoadAnimations(FSpriteSheet);
    AssignEventsToSpriteSheet;
  except
    on E:Exception do
    begin
      ErrorBox(E.Message);
    end;
  end;
end;

end.

