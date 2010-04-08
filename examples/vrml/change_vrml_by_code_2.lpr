{
  Copyright 2008-2010 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Somewhat more involved version of change_vrml_by_code.lpr,
  this constructs VRML graph by code and then animates it by code
  (showing a little more interesting animation, sin*cos displayed in 3D). }

{ $define LOG}

program change_vrml_by_code_2;

uses VectorMath, VRMLNodes, GL, GLU, GLWindow,
  KambiUtils, SysUtils, KambiGLUtils, VRMLGLScene, Cameras, KambiSceneManager,
  KambiFilesUtils, VRMLErrors, Quaternions {$ifdef LOG} ,KambiLog {$endif};

var
  Glw: TGLUIWindow;
  SceneManager: TKamSceneManager;
  Scene: TVRMLGLScene;

const
  XCount = 15;
  YCount = 15;

var
  Transform: array [0 .. XCount - 1, 0 .. YCount - 1] of TNodeTransform_2;

procedure Idle(glwin: TGLWindow);
var
  I, J: Integer;
begin
  { We want to keep track of current time here (for calculating
    below). It's most natural to just use Scene.Time property for this.
    (Scene.Time is already incremented for us by SceneManager.) }

  for I := 0 to XCount - 1 do
    for J := 0 to YCount - 1 do
    begin
      Transform[I, J].FdTranslation.Value[2] := 2 *
        Sin(I / 2  + Scene.Time.Seconds) *
        Cos(J / 2 + Scene.Time.Seconds);
      //Scene.ChangedField(Transform[I, J].FdTranslation);
    end;

  { For large XCount * YCount, ChangedAll may be faster than ChangedField
    after each change (as ChangedField for Transform tries to do intelligent
    analysis of what was changed by this transform, and this analysis
    is unfortunately slow when changing hundreths of transforms). }
  Scene.ChangedAll;
end;

function CreateVrmlGraph: TNodeGroup_2;
var
  Shape: TNodeShape;
  Mat: TNodeMaterial_2;
  I, J: Integer;
begin
  Result := TNodeGroup_2.Create('', '');

  Mat := TNodeMaterial_2.Create('', '');
  Mat.FdDiffuseColor.Value := Vector3Single(1, 1, 0);

  Shape := TNodeShape.Create('', '');
  Shape.FdAppearance.Value := TNodeAppearance.Create('', '');
  Shape.Appearance.FdMaterial.Value := Mat;
  Shape.FdGeometry.Value := TNodeBox.Create('', '');

  for I := 0 to XCount - 1 do
    for J := 0 to YCount - 1 do
    begin
      Transform[I, J] := TNodeTransform_2.Create('', '');
      Transform[I, J].FdTranslation.Value := Vector3Single(I * 2, J * 2, 0);
      Transform[I, J].FdChildren.AddItem(Shape);

      Result.FdChildren.AddItem(Transform[I, J]);
    end;
end;

begin
  Glw := TGLUIWindow.Create(Application);

  Parameters.CheckHigh(0);
  VRMLWarning := @VRMLWarning_Write;

  { We use a lot of boxes, so make their rendering fastest. }
  Detail_RectDivisions := 0;

  Scene := TVRMLGLScene.Create(nil);
  try
    Scene.Load(CreateVrmlGraph, true);
    Scene.Optimization := roSeparateShapesNoTransform;

    {$ifdef LOG}
    InitializeLog('1.0');
    Scene.LogChanges := true;
    {$endif}

    { make SceneManager with our Scene }
    SceneManager := TKamSceneManager.Create(Glw);
    Glw.Controls.Add(SceneManager);
    SceneManager.MainScene := Scene;
    SceneManager.Items.Add(Scene);

    { init SceneManager.Camera }
    SceneManager.Camera := TExamineCamera.Create(Glw);
    (SceneManager.Camera as TExamineCamera).Init(Scene.BoundingBox);
    { set more interesting view by default }
    (SceneManager.Camera as TExamineCamera).Rotations := QuatFromAxisAngle(
      Normalized(Vector3Single(1, 1, 0)), Pi/4);

    Glw.OnIdle := @Idle;
    Glw.InitAndRun;
  finally Scene.Free end;
end.
