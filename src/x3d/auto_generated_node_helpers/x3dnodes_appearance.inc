{ -*- buffer-read-only: t -*-

  Copyright 2015-2021 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated node properties.

  Do not edit this file manually!
  To add new properties:
  - add them to the text files in tools/internal/x3d-nodes-to-pascal/nodes-specification/ ,
  - and regenerate include files by running x3d-nodes-to-pascal .

  The documentation for properties should go to x3dnodes_documentation.txt . }

{$ifdef read_interface}

  strict private
{$ifndef CASTLE_SLIM_NODES}
    function GetFillProperties: TFillPropertiesNode;
    procedure SetFillProperties(const Value: TFillPropertiesNode);
{$endif not CASTLE_SLIM_NODES}
    function GetLineProperties: TLinePropertiesNode;
    procedure SetLineProperties(const Value: TLinePropertiesNode);
    function GetMaterial: TAbstractMaterialNode;
    procedure SetMaterial(const Value: TAbstractMaterialNode);
    function GetBackMaterial: TAbstractOneSidedMaterialNode;
    procedure SetBackMaterial(const Value: TAbstractOneSidedMaterialNode);
    function GetTexture: TAbstractTextureNode;
    procedure SetTexture(const Value: TAbstractTextureNode);
    function GetTextureTransform: TAbstractTextureTransformNode;
    procedure SetTextureTransform(const Value: TAbstractTextureTransformNode);
    function GetAlphaMode: TAlphaMode;
    procedure SetAlphaMode(const Value: TAlphaMode);
    function GetAlphaCutoff: Single;
    procedure SetAlphaCutoff(const Value: Single);
    function GetShadowCaster: Boolean;
    procedure SetShadowCaster(const Value: Boolean);
    function GetNormalMap: TAbstractTexture2DNode;
    procedure SetNormalMap(const Value: TAbstractTexture2DNode);
{$ifndef CASTLE_SLIM_NODES}
    function GetHeightMap: TAbstractTexture2DNode;
    procedure SetHeightMap(const Value: TAbstractTexture2DNode);
{$endif not CASTLE_SLIM_NODES}
    function GetHeightMapScale: Single;
    procedure SetHeightMapScale(const Value: Single);
    function GetBlendMode: TBlendModeNode;
    procedure SetBlendMode(const Value: TBlendModeNode);
    function GetAlphaChannel: TAutoAlphaChannel;
    procedure SetAlphaChannel(const Value: TAutoAlphaChannel);
  public
    procedure CreateNode; override;
    class function ClassX3DType: string; override;

{$ifndef CASTLE_SLIM_NODES}
    strict private FFdFillProperties: TSFNode;
    { X3D field "fillProperties". } { }
    public property FdFillProperties: TSFNode read FFdFillProperties;
{$endif not CASTLE_SLIM_NODES}
{$ifndef CASTLE_SLIM_NODES}
    { X3D field "fillProperties". } { }
    property FillProperties: TFillPropertiesNode read GetFillProperties write SetFillProperties;
{$endif not CASTLE_SLIM_NODES}

    strict private FFdLineProperties: TSFNode;
    { X3D field "lineProperties". } { }
    public property FdLineProperties: TSFNode read FFdLineProperties;
    { X3D field "lineProperties". } { }
    property LineProperties: TLinePropertiesNode read GetLineProperties write SetLineProperties;

    strict private FFdMaterial: TSFNode;
    { X3D field "material". } { }
    public property FdMaterial: TSFNode read FFdMaterial;
    { X3D field "material". } { }
    property Material: TAbstractMaterialNode read GetMaterial write SetMaterial;

    strict private FFdBackMaterial: TSFNode;
    { X3D field "backMaterial". } { }
    public property FdBackMaterial: TSFNode read FFdBackMaterial;
    { X3D field "backMaterial". } { }
    property BackMaterial: TAbstractOneSidedMaterialNode read GetBackMaterial write SetBackMaterial;

    strict private FFdShaders: TMFNode;
    { X3D field "shaders". } { }
    public property FdShaders: TMFNode read FFdShaders;
    { Set X3D field "shaders". } { }
    procedure SetShaders(const Value: array of TAbstractShaderNode);

    strict private FFdTexture: TSFNode;
    { X3D field "texture". } { }
    public property FdTexture: TSFNode read FFdTexture;
    { X3D field "texture". } { }
    property Texture: TAbstractTextureNode read GetTexture write SetTexture;

    strict private FFdTextureTransform: TSFNode;
    { X3D field "textureTransform". } { }
    public property FdTextureTransform: TSFNode read FFdTextureTransform;
    { X3D field "textureTransform". } { }
    property TextureTransform: TAbstractTextureTransformNode read GetTextureTransform write SetTextureTransform;

    strict private FFdAlphaMode: TSFStringEnum;
    { X3D field "alphaMode". } { }
    public property FdAlphaMode: TSFStringEnum read FFdAlphaMode;
    { X3D field "alphaMode". } { }
    property AlphaMode: TAlphaMode read GetAlphaMode write SetAlphaMode;

    strict private FFdAlphaCutoff: TSFFloat;
    { X3D field "alphaCutoff". } { }
    public property FdAlphaCutoff: TSFFloat read FFdAlphaCutoff;
    { X3D field "alphaCutoff". } { }
    property AlphaCutoff: Single read GetAlphaCutoff write SetAlphaCutoff;

    strict private FFdReceiveShadows: TMFNode;
    { X3D field "receiveShadows". } { }
    public property FdReceiveShadows: TMFNode read FFdReceiveShadows;
    { Set X3D field "receiveShadows". } { }
    procedure SetReceiveShadows(const Value: array of TAbstractPunctualLightNode);

    strict private FFdShadowCaster: TSFBool;
    { X3D field "shadowCaster". } { }
    public property FdShadowCaster: TSFBool read FFdShadowCaster;
    { X3D field "shadowCaster". } { }
    property ShadowCaster: Boolean read GetShadowCaster write SetShadowCaster;

    strict private FFdNormalMap: TSFNode;
    { X3D field "normalMap". } { }
    public property FdNormalMap: TSFNode read FFdNormalMap;
    { X3D field "normalMap". } { }
    property NormalMap: TAbstractTexture2DNode read GetNormalMap write SetNormalMap;

{$ifndef CASTLE_SLIM_NODES}
    strict private FFdHeightMap: TSFNode;
    { X3D field "heightMap". } { }
    public property FdHeightMap: TSFNode read FFdHeightMap;
{$endif not CASTLE_SLIM_NODES}
{$ifndef CASTLE_SLIM_NODES}
    { X3D field "heightMap". } { }
    property HeightMap: TAbstractTexture2DNode read GetHeightMap write SetHeightMap;
{$endif not CASTLE_SLIM_NODES}

    strict private FFdHeightMapScale: TSFFloat;
    { X3D field "heightMapScale". } { }
    public property FdHeightMapScale: TSFFloat read FFdHeightMapScale;
    { X3D field "heightMapScale". } { }
    property HeightMapScale: Single read GetHeightMapScale write SetHeightMapScale;

    strict private FFdBlendMode: TSFNode;
    { X3D field "blendMode". } { }
    public property FdBlendMode: TSFNode read FFdBlendMode;
    { X3D field "blendMode". } { }
    property BlendMode: TBlendModeNode read GetBlendMode write SetBlendMode;

    strict private FFdEffects: TMFNode;
    { X3D field "effects". } { }
    public property FdEffects: TMFNode read FFdEffects;
    { Set X3D field "effects". } { }
    procedure SetEffects(const Value: array of TEffectNode);

    strict private FFdAlphaChannel: TSFStringEnum;
    { X3D field "alphaChannel". } { }
    public property FdAlphaChannel: TSFStringEnum read FFdAlphaChannel;
    { X3D field "alphaChannel". } { }
    property AlphaChannel: TAutoAlphaChannel read GetAlphaChannel write SetAlphaChannel;

{$endif read_interface}

{$ifdef read_implementation}

{ TAppearanceNode ----------------------------------------------- }

{$ifndef CASTLE_SLIM_NODES}
function TAppearanceNode.GetFillProperties: TFillPropertiesNode;
begin
  if FdFillProperties.Value is TFillPropertiesNode then
    Result := TFillPropertiesNode(FdFillProperties.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetFillProperties(const Value: TFillPropertiesNode);
begin
  FdFillProperties.Send(Value);
end;

{$endif not CASTLE_SLIM_NODES}
function TAppearanceNode.GetLineProperties: TLinePropertiesNode;
begin
  if FdLineProperties.Value is TLinePropertiesNode then
    Result := TLinePropertiesNode(FdLineProperties.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetLineProperties(const Value: TLinePropertiesNode);
begin
  FdLineProperties.Send(Value);
end;

function TAppearanceNode.GetMaterial: TAbstractMaterialNode;
begin
  if FdMaterial.Value is TAbstractMaterialNode then
    Result := TAbstractMaterialNode(FdMaterial.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetMaterial(const Value: TAbstractMaterialNode);
begin
  FdMaterial.Send(Value);
end;

function TAppearanceNode.GetBackMaterial: TAbstractOneSidedMaterialNode;
begin
  if FdBackMaterial.Value is TAbstractOneSidedMaterialNode then
    Result := TAbstractOneSidedMaterialNode(FdBackMaterial.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetBackMaterial(const Value: TAbstractOneSidedMaterialNode);
begin
  FdBackMaterial.Send(Value);
end;

procedure TAppearanceNode.SetShaders(const Value: array of TAbstractShaderNode);
var
  L: Integer;
  A: array of TX3DNode;
begin
  L := High(Value) + 1;
  SetLength(A, L);
  if L > 0 then
    Move(Value[0], A[0], L * SizeOf(TAbstractShaderNode));
  FdShaders.Send(A);
end;

function TAppearanceNode.GetTexture: TAbstractTextureNode;
begin
  if FdTexture.Value is TAbstractTextureNode then
    Result := TAbstractTextureNode(FdTexture.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetTexture(const Value: TAbstractTextureNode);
begin
  FdTexture.Send(Value);
end;

function TAppearanceNode.GetTextureTransform: TAbstractTextureTransformNode;
begin
  if FdTextureTransform.Value is TAbstractTextureTransformNode then
    Result := TAbstractTextureTransformNode(FdTextureTransform.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetTextureTransform(const Value: TAbstractTextureTransformNode);
begin
  FdTextureTransform.Send(Value);
end;

function TAppearanceNode.GetAlphaMode: TAlphaMode;
begin
  Result := TAlphaMode(FdAlphaMode.EnumValue);
end;

procedure TAppearanceNode.SetAlphaMode(const Value: TAlphaMode);
begin
  FdAlphaMode.SendEnumValue(Ord(Value));
end;

function TAppearanceNode.GetAlphaCutoff: Single;
begin
  Result := FdAlphaCutoff.Value;
end;

procedure TAppearanceNode.SetAlphaCutoff(const Value: Single);
begin
  FdAlphaCutoff.Send(Value);
end;

procedure TAppearanceNode.SetReceiveShadows(const Value: array of TAbstractPunctualLightNode);
var
  L: Integer;
  A: array of TX3DNode;
begin
  L := High(Value) + 1;
  SetLength(A, L);
  if L > 0 then
    Move(Value[0], A[0], L * SizeOf(TAbstractPunctualLightNode));
  FdReceiveShadows.Send(A);
end;

function TAppearanceNode.GetShadowCaster: Boolean;
begin
  Result := FdShadowCaster.Value;
end;

procedure TAppearanceNode.SetShadowCaster(const Value: Boolean);
begin
  FdShadowCaster.Send(Value);
end;

function TAppearanceNode.GetNormalMap: TAbstractTexture2DNode;
begin
  if FdNormalMap.Value is TAbstractTexture2DNode then
    Result := TAbstractTexture2DNode(FdNormalMap.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetNormalMap(const Value: TAbstractTexture2DNode);
begin
  FdNormalMap.Send(Value);
end;

{$ifndef CASTLE_SLIM_NODES}
function TAppearanceNode.GetHeightMap: TAbstractTexture2DNode;
begin
  if FdHeightMap.Value is TAbstractTexture2DNode then
    Result := TAbstractTexture2DNode(FdHeightMap.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetHeightMap(const Value: TAbstractTexture2DNode);
begin
  FdHeightMap.Send(Value);
end;

{$endif not CASTLE_SLIM_NODES}
function TAppearanceNode.GetHeightMapScale: Single;
begin
  Result := FdHeightMapScale.Value;
end;

procedure TAppearanceNode.SetHeightMapScale(const Value: Single);
begin
  FdHeightMapScale.Send(Value);
end;

function TAppearanceNode.GetBlendMode: TBlendModeNode;
begin
  if FdBlendMode.Value is TBlendModeNode then
    Result := TBlendModeNode(FdBlendMode.Value)
  else
    Result := nil;
end;

procedure TAppearanceNode.SetBlendMode(const Value: TBlendModeNode);
begin
  FdBlendMode.Send(Value);
end;

procedure TAppearanceNode.SetEffects(const Value: array of TEffectNode);
var
  L: Integer;
  A: array of TX3DNode;
begin
  L := High(Value) + 1;
  SetLength(A, L);
  if L > 0 then
    Move(Value[0], A[0], L * SizeOf(TEffectNode));
  FdEffects.Send(A);
end;

function TAppearanceNode.GetAlphaChannel: TAutoAlphaChannel;
begin
  Result := TAutoAlphaChannel(FdAlphaChannel.EnumValue);
end;

procedure TAppearanceNode.SetAlphaChannel(const Value: TAutoAlphaChannel);
begin
  FdAlphaChannel.SendEnumValue(Ord(Value));
end;

class function TAppearanceNode.ClassX3DType: String;
begin
  Result := 'Appearance';
end;

procedure TAppearanceNode.CreateNode;
begin
  inherited;

{$ifndef CASTLE_SLIM_NODES}
  FFdFillProperties := TSFNode.Create(Self, True, 'fillProperties', [TFillPropertiesNode]);
   FdFillProperties.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdFillProperties);
  { X3D specification comment: # NOT-SLIM }
{$endif not CASTLE_SLIM_NODES}

  FFdLineProperties := TSFNode.Create(Self, True, 'lineProperties', [TLinePropertiesNode]);
   FdLineProperties.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdLineProperties);

  FFdMaterial := TSFNode.Create(Self, True, 'material', [TAbstractMaterialNode]);
   FdMaterial.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdMaterial);

  FFdBackMaterial := TSFNode.Create(Self, True, 'backMaterial', [TAbstractOneSidedMaterialNode]);
   FdBackMaterial.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdBackMaterial);

  FFdShaders := TMFNode.Create(Self, True, 'shaders', [TAbstractShaderNode]);
   FdShaders.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdShaders);

  FFdTexture := TSFNode.Create(Self, True, 'texture', [TAbstractTextureNode]);
   FdTexture.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdTexture);

  FFdTextureTransform := TSFNode.Create(Self, True, 'textureTransform', [TAbstractTextureTransformNode]);
   FdTextureTransform.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdTextureTransform);

  FFdAlphaMode := TSFStringEnum.Create(Self, True, 'alphaMode', AlphaModeToString, Ord(amAuto));
   FdAlphaMode.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdAlphaMode);
  { X3D specification comment: ["AUTO"|"OPAQUE"|"MASK"|"BLEND"] enumerated-type: TAlphaMode AlphaModeToString amAuto }

  FFdAlphaCutoff := TSFFloat.Create(Self, True, 'alphaCutoff', 0.5);
   FdAlphaCutoff.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdAlphaCutoff);
  { X3D specification comment: [0,1] }

  FFdReceiveShadows := TMFNode.Create(Self, False, 'receiveShadows', [TAbstractPunctualLightNode]);
   FdReceiveShadows.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdReceiveShadows);

  FFdShadowCaster := TSFBool.Create(Self, True, 'shadowCaster', true);
   FdShadowCaster.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdShadowCaster);

  FFdNormalMap := TSFNode.Create(Self, True, 'normalMap', [TAbstractTexture2DNode]);
   FdNormalMap.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdNormalMap);
  { X3D specification comment: # }

{$ifndef CASTLE_SLIM_NODES}
  FFdHeightMap := TSFNode.Create(Self, True, 'heightMap', [TAbstractTexture2DNode]);
   FdHeightMap.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdHeightMap);
  { X3D specification comment: # NOT-SLIM }
{$endif not CASTLE_SLIM_NODES}

  FFdHeightMapScale := TSFFloat.Create(Self, True, 'heightMapScale', 0.01);
   FdHeightMapScale.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdHeightMapScale);
  { X3D specification comment: must be > 0, meaningful only if heightMap specified }

  FFdBlendMode := TSFNode.Create(Self, True, 'blendMode', [TBlendModeNode]);
   FdBlendMode.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdBlendMode);

  FFdEffects := TMFNode.Create(Self, False, 'effects', [TEffectNode]);
   FdEffects.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdEffects);

  FFdAlphaChannel := TSFStringEnum.Create(Self, True, 'alphaChannel', AlphaToString, Ord(acAuto));
   FdAlphaChannel.ChangeAlways := chVisibleNonGeometry;
  AddField(FFdAlphaChannel);
  { X3D specification comment: ["AUTO"|"NONE"|"TEST"|"BLENDING"] enumerated-type: TAutoAlphaChannel AlphaToString acAuto }

  DefaultContainerField := 'appearance';
end;

{$endif read_implementation}
