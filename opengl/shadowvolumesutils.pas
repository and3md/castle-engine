{
  Copyright 2007 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with "Kambi VRML game engine"; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{ TShadowVolumesHelper class. }
unit ShadowVolumesUtils;

interface

uses VectorMath, Boxes3d, OpenGLh;

type
  { This class is a bag for various utilities usefull
    when implementing shadow volumes that didn't fit elsewhere. }
  TShadowVolumesHelper = class
  private
    IsFrustumLightBox: boolean;
    FrustumLightBox: TBox3d;

    FWrapAvailable: boolean;
    FStencilOpIncrWrap, FStencilOpDecrWrap: TGLenum;
  public
    property WrapAvailable: boolean read FWrapAvailable;

    { These will ideally be initialized to GL_INCR/DECR_WRAP (available
      in OpenGL >= 2.0) or GL_INCR/DECR_WRAP_EXT (available if EXT_stencil_wrap).
      Actually values with and without _EXT are the same.

      If OpenGL will not have these available, then they will be equal to
      old GL_INCR/DECT constants (without wrapping).

      These are set by InitGL. WrapAvailable says whether
      they were set to _WRAP_ versions.

      @groupBegin }
    property StencilOpIncrWrap: TGLenum read FStencilOpIncrWrap;
    property StencilOpDecrWrap: TGLenum read FStencilOpDecrWrap;
    { @groupEnd }

    { Call this when OpenGL context is initialized, this will set some things.
      For now, this sets StencilOpIncrWrap, StencilOpDecrWrap. }
    procedure InitGL;

    { Use this before using ShadowMaybeVisible. This prepares some things
      (so that each ShadowMaybeVisible call doesn't have to) and
      all subsequent ShadowMaybeVisible calls assume that Frustum and
      MainLightPosition are the same. }
    procedure FrustumCullingInit(
      const Frustum: TFrustum;
      const MainLightPosition: TVector4Single);

    { This checks whether you need to render shadow of the object inside Box.
      @false means that (assuming Frustum and MainLightPosition values given
      in FrustumCullingInit) camera for sure doesn't see the shadow, so you
      don't have to render it. }
    function ShadowMaybeVisible(const Box: TBox3d): boolean;

    { TODO: For now, this is set by you (should be auto detected later).
      This says whether we want to use z-pass or z-fail technique. }
    ZFail: boolean;

    { These set glStencilOpSeparate (suitable for both front and
      back faces) or glStencil (suitable only for front or only for back faces)
      as appropriate.

      Use this before rendering shadow volumes.
      It uses ZFail to decide what setup is necessary.
      It also uses StencilOpIncrWrap / StencilOpDecrWrap as needed. }
    procedure SetStencilOpSeparate;
    procedure SetStencilOpForFront;
    procedure SetStencilOpForBack;
  end;

implementation

uses SysUtils, KambiUtils, KambiStringUtils, KambiLog;

procedure TShadowVolumesHelper.InitGL;
begin
  { calcualte WrapAvailable, StencilOpIncrWrap, StencilOpDecrWrap }
  FWrapAvailable := (GLVersion.Major >= 2) or GL_EXT_stencil_wrap;
  if WrapAvailable then
  begin
    FStencilOpIncrWrap := GL_INCR_WRAP_EXT;
    FStencilOpDecrWrap := GL_DECR_WRAP_EXT;
  end else
  begin
    FStencilOpIncrWrap := GL_INCR;
    FStencilOpDecrWrap := GL_DECR;
  end;

  { This looks hacky, but actually this is how it should be:
    - with Mesa versions 6.x (tested with 6.4.1, 6.5.1, 6.5.2),
      glStencilOpSeparate is not nil, but it doesn't work.
    - Same thing happens with NVidia legacy 96xx drivers (reported
      version is "1.5.8 NVIDIA 96.43.01").
    I guess that's OK (I mean, it's not Mesa/NVidia bug), as I should look
    for glStencilOpSeparate only if GL version is >= 2. }
  if GLVersion.Major <= 1 then
    glStencilOpSeparate := nil;

  if Log then
    WritelnLogMultiline('Shadow volumes initialization',
      Format('GL_INCR/DECR_WRAP_EXT available: %s' + nl +
             'glStencilOpSeparate available: %s',
            [ BoolToStr[WrapAvailable],
              BoolToStr[glStencilOpSeparate <> nil] ]));
end;

procedure TShadowVolumesHelper.FrustumCullingInit(
  const Frustum: TFrustum;
  const MainLightPosition: TVector4Single);
var
  MainLightPosition3: TVector3Single absolute MainLightPosition;
begin
  IsFrustumLightBox := (MainLightPosition[3] = 1) and
    ( (Frustum[fpFar][0] <> 0) or
      (Frustum[fpFar][1] <> 0) or
      (Frustum[fpFar][2] <> 0) );

  { TODO: this is very lame frustum culling.
    1. First of all, this works only for positional lights.
    2. Second, this represents the sum of
       Frustum + light position as a box3d --- while a convex hull of max
       9 points would be more optimal.
    3. Third, it doesn't work for frustum with infinite far plane
       (and this is practically neededfor z-fail approach).
       (CalculateFrustumPoints, and so FrustumAndPointBoundingBox,
       cannot work with such frustum).
  }

  if IsFrustumLightBox then
    FrustumLightBox := FrustumAndPointBoundingBox(Frustum, MainLightPosition3);
end;

function TShadowVolumesHelper.ShadowMaybeVisible(const Box: TBox3d): boolean;
begin
  { Frustum culling for shadow volumes:
    If the light is positional (so we have FrustumLightBox),
    and Box is outside FrustumLightBox, there's
    no need to render shadow quads for this creature.
    This is a very usefull optimization in certain cases
    (level with many creatures, spread evenly on the level;
    on "The Castle" Doom level, for example, it wasn't hard to find place
    where this optimization improved FPS to 40 from 17). }
  Result := (not IsFrustumLightBox) or Boxes3dCollision(Box, FrustumLightBox);
end;

procedure TShadowVolumesHelper.SetStencilOpSeparate;
begin
  if ZFail then
  begin
    glStencilOpSeparate(GL_FRONT, GL_KEEP, StencilOpIncrWrap, GL_KEEP);
    glStencilOpSeparate(GL_BACK , GL_KEEP, StencilOpDecrWrap, GL_KEEP);
  end else
  begin
    glStencilOpSeparate(GL_FRONT, GL_KEEP, GL_KEEP, StencilOpIncrWrap);
    glStencilOpSeparate(GL_BACK , GL_KEEP, GL_KEEP, StencilOpDecrWrap);
  end;
end;

procedure TShadowVolumesHelper.SetStencilOpForFront;
begin
  if ZFail then
    glStencilOp(GL_KEEP, StencilOpIncrWrap, GL_KEEP) else
    { For each fragment that passes depth-test, *increase* it's stencil value. }
    glStencilOp(GL_KEEP, GL_KEEP, StencilOpIncrWrap);
end;

procedure TShadowVolumesHelper.SetStencilOpForBack;
begin
  if ZFail then
    glStencilOp(GL_KEEP, StencilOpDecrWrap, GL_KEEP) else
    { For each fragment that passes depth-test, *decrease* it's stencil value. }
    glStencilOp(GL_KEEP, GL_KEEP, StencilOpDecrWrap);
end;

end.
