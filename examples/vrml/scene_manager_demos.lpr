{
  Copyright 2010-2010 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Demo of using SceneManager. Shows how you can add many 3D objects to
  SceneManager.Items tree. For simpler usage,
  see simplest_vrml_browser.lpr first.

  This reads a couple of 3D files from ../../../kambi_vrml_test_suite/
  directory, thus assuming you have
  [http://vrmlengine.sourceforge.net/kambi_vrml_test_suite.php]
  downladed and unpacked such that directories "kambi_vrml_test_suite"
  and "kambi_vrml_game_engine".

  That said, do not hesitate to just replace filenames of 3D models
  here with own models, and generally experiment freely with this program :)
}
program scene_manager_demos;

{$apptype CONSOLE}

uses KambiUtils, GLWindow, ProgressUnit, ProgressGL, VectorMath, Base3D,
  VRMLScene, VRMLGLScene, VRMLErrors, KambiSceneManager, VRMLGLAnimation,
  VRMLNodes, GL3D;

var
  Window: TGLUIWindow;
  SceneManager: TKamSceneManager;
  Scene, Scene2: TVRMLGLScene;
  Animation: TVRMLGLAnimation;
  Translation: T3DTranslated;
  TranslatedItems: T3DList;
  Scene2Transform: TNodeTransform_2;
begin
  Window := TGLUIWindow.Create(Application);

  VRMLWarning := @VRMLWarning_Write;

  { initialize SceneManager }
  SceneManager := TKamSceneManager.Create(Window);
  Window.Controls.Add(SceneManager);

  { initialize first Scene }
  Scene := TVRMLGLScene.Create(SceneManager);
//  Scene.Load('../../../kambi_vrml_test_suite/vrml_2/castle_with_lights_and_camera.wrl');
//  Scene.Load('../../../kambi_vrml_test_suite/x3d/touch_sensor_tests.x3dv');
  Scene.Load('models/castle_y_up.x3dv');
  { This makes scene octrees, allowing collision detection in (possibly)
    dynamic scene (ssDynamicCollisions) and frustum culling
    optimization when rendering (ssRendering). }
  Scene.Spatial := [ssRendering, ssDynamicCollisions];
  { This makes our 3D scene interactive, reacting to key and mouse
    presses, processing VRML/X3D script nodes etc. }
  Scene.ProcessEvents := true;

  { add Scene to SceneManager }
  { Add your scene to SceneManager.Items. This is essential,
    it makes the scene actually rendered, animated etc. }
  SceneManager.Items.Add(Scene);
  { Set the scene as SceneManager.MainScene. This is optional
    (you do have to set SceneManager.MainScene), but usually desired.
    MainScene is used in various moments when we need a single designated 3D
    object to do some task. For example, default camera location is taken
    from Viewpoint VRML/X3D node inside the MainScene. }
  SceneManager.MainScene := Scene;

  { To have some more fun with SceneManager, let's add more 3D objects to it.
    Let's suppose we want to have SceneManager.Items to be a tree:

    SceneManager.Items
    |- Scene
    |- Translation
       |- TranslatedItems
          |- Scene2
          |- Animation
  }

  { initialize Translation }
  Translation := T3DTranslated.Create(SceneManager);
  Translation.Translation := Vector3Single(5, 3, 60);
  SceneManager.Items.Add(Translation);

  { initialize TranslatedItems list }
  TranslatedItems := T3DList.Create(SceneManager);
  Translation.Child := TranslatedItems;

  { initialize a 2nd scene, just because we can }
  Scene2 := TVRMLGLScene.Create(SceneManager);
//  Scene2.Load('../../../kambi_vrml_test_suite/x3d/inline_url_change.x3dv');
//  Scene2.Load('../../../kambi_vrml_test_suite/x3d/touch_sensor_tests.x3dv');
//  Scene2.Load('../../../kambi_vrml_test_suite/x3d/anchor_test.x3dv');
//  Scene2.Load('../../../kambi_vrml_test_suite/x3d/kambi_extensions/kambi_script_ball_game.x3dv');
  Scene2.Load('../../../kambi_vrml_test_suite/x3d/kambi_extensions/kambi_script_particles.x3dv');
  Scene2.Spatial := [ssRendering, ssDynamicCollisions];
  Scene2.ProcessEvents := true;
{  Scene2.Attributes.WireframeEffect := weWireframeOnly;} { render this as wireframe }
  TranslatedItems.Add(Scene2);

  { let's now show that you can process 3D model graph after loading:
    let's add a rotation inside VRML model in Scene2 }
  Scene2Transform := TNodeTransform_2.Create('', '');
  Scene2Transform.FdRotation.Axis := Vector3Single(1, 0, 0);
  Scene2Transform.FdRotation.RotationRad := -Pi/2;
  Scene2Transform.FdChildren.AddItem(Scene2.RootNode);
  Scene2.RootNode := Scene2Transform;
  Scene2.ChangedAll; { notify Scene2 that RootNode contents changed }

  { initialize Animation }
  Animation := TVRMLGLAnimation.Create(SceneManager);
  Animation.LoadFromFile('../../../kambi_vrml_test_suite/kanim/raptor.kanim', false, true);
  Animation.FirstScene.Spatial := [ssRendering, ssDynamicCollisions];
  TranslatedItems.Add(Animation);

  Window.InitAndRun;
end.
