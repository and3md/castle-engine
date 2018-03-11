{
  Copyright 2016-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Compressing and downscaling textures. }
unit ToolTextureGeneration;

{ Unfortunately, AMDCompressCLI output is broken now.
  See http://castle-engine.sourceforge.net/creating_data_material_properties.php . }
{ $define USE_AMDCompress}

interface

uses CastleUtils, CastleStringUtils,
  ToolProject;

procedure AutoGenerateTextures(const Project: TCastleProject);
procedure AutoGenerateClean(const Project: TCastleProject);

implementation

uses SysUtils,
  CastleURIUtils, CastleMaterialProperties, CastleImages, CastleFilesUtils,
  CastleLog, CastleFindFiles, CastleSoundEngine, CastleTimeUtils,
  ToolUtils;

type
  ECannotFindTool = class(Exception)
  strict private
    FToolName: string;
  public
    constructor Create(const AToolName: string; const C: TTextureCompression);
    property ToolName: string read FToolName;
  end;

constructor ECannotFindTool.Create(const AToolName: string;
  const C: TTextureCompression);
begin
  FToolName := AToolName;
  inherited CreateFmt('Cannot find tool "%s" necessary to make compressed texture format %s',
    [ToolName, TextureCompressionToString(C)]);
end;

type
  TStats = record
    Count: Cardinal;
    CompressionCount: Cardinal;
    CompressionTime: TFloatTime;
    DownscalingCount: Cardinal;
    DownscalingTime: TFloatTime;
    DxtAutoDetectCount: Cardinal;
    DxtAutoDetectTime: TFloatTime;
  end;

{ Auto-detect best DXTn compression format for this image. }
function AutoDetectDxt(const ImageUrl: string; var Stats: TStats): TTextureCompression;
var
  Image: TCastleImage;
  TimeStart: TProcessTimerResult;
begin
  Inc(Stats.DxtAutoDetectCount);
  TimeStart := ProcessTimer;

  Image := LoadImage(ImageUrl);
  try
    case Image.AlphaChannel of
      acNone    : Result:= tcDxt1_RGB;
      acTest    : Result:= tcDxt1_RGBA;
      acBlending: Result:= tcDxt5;
      else raise EInternalError.Create('Unexpected Image.AlphaChannel in AutoDetectDxt');
    end;
  finally FreeAndNil(Image) end;

  Writeln('Autodetected DXTn type for "' + ImageUrl + '": ' +
    TextureCompressionToString(Result));

  Stats.DxtAutoDetectTime := Stats.DxtAutoDetectTime + TimeStart.ElapsedTime;
end;

procedure AutoGenerateTextures(const Project: TCastleProject);

  procedure TryToolExe(var ToolExe: string; const ToolExeAbsolutePath: string);
  begin
    if (ToolExe = '') and FileExists(ToolExeAbsolutePath) then
      ToolExe := ToolExeAbsolutePath;
  end;

  procedure TryToolExePath(var ToolExe: string; const ToolExeName: string;
    const C: TTextureCompression);
  begin
    if ToolExe = '' then
    begin
      ToolExe := FindExe(ToolExeName);
      if ToolExe = '' then
        raise ECannotFindTool.Create(ToolExeName, C);
    end;
  end;

  {$ifdef USE_AMDCompress}
  procedure AMDCompress(const InputFile, OutputFile: string;
    const C: TTextureCompression; const CompressionNameForTool: string);
  var
    {$ifndef MSWINDOWS}
    WineExe: string;
    {$endif}
    ToolExe, InputFlippedFile, OutputTempFile, TempPrefix: string;
    Image: TCastleImage;
    CommandExe: string;
    CommandOptions: TCastleStringList;
  begin
    { On non-Windows, we need wine for this }
    {$ifndef MSWINDOWS}
    WineExe := '';
    TryToolExePath(WineExe, 'wine', C);
    {$endif}

    ToolExe := '';
    {$ifdef MSWINDOWS}
    TryToolExe(ToolExe, 'c:/Program Files/AMD/AMDCompress/AMDCompressCLI.exe');
    TryToolExe(ToolExe, 'c:/Program Files (x86)/AMD/AMDCompress/AMDCompressCLI.exe');
    {$endif}
    {$ifdef UNIX}
    TryToolExe(ToolExe, HomePath + '.wine/drive_c/Program Files/AMD/AMDCompress/AMDCompressCLI.exe');
    TryToolExe(ToolExe, HomePath + '.wine/drive_c/Program Files (x86)/AMD/AMDCompress/AMDCompressCLI.exe');
    {$endif}
    TryToolExePath(ToolExe, 'AMDCompressCLI', C);

    TempPrefix := GetTempFileNamePrefix;

    InputFlippedFile := TempPrefix + '.png';

    { in theory, when DDSFlipped = false, we could just do
      CheckCopyFile(InputFile, InputFlippedFile).
      But then AMDCompressCLI fails to read some png files
      (like flying in dark_dragon). }
    Image := LoadImage(FilenameToURISafe(InputFile));
    try
      if TextureCompressionInfo[C].DDSFlipped then
        Image.FlipVertical;
      SaveImage(Image, FilenameToURISafe(InputFlippedFile));
    finally FreeAndNil(Image) end;

    { this is worse, as it requires ImageMagick }
    // RunCommandSimple(FindExe('convert'), [InputFile, '-flip', InputFlippedFile]);

    OutputTempFile := TempPrefix + 'output' + ExtractFileExt(OutputFile);

    CommandOptions := TCastleStringList.Create;
    try
      {$ifdef MSWINDOWS} CommandExe := ToolExe; CommandOptions.AddRange([
      {$else}            CommandExe := WineExe; CommandOptions.AddRange([ToolExe,
      {$endif}
        '-fd', CompressionNameForTool,
        { we cannot just pass InputFlippedFile, OutputFile to compressonator,
          because it may be running in wine and not understanding Unix absolute paths. }
        ExtractFileName(InputFlippedFile),
        ExtractFileName(OutputTempFile)]);
      { TODO: it doesn't seem to help, DXT1_RGBA is still without
        anything useful in alpha value. Seems like AMDCompressCLI bug,
        or I just don't know how to use the DXT1 options? }
      if C = tcDxt1_RGB then // special options for tcDxt1_RGB
        CommandOptions.AddRange(
          ['-DXT1UseAlpha', '1', '-AlphaThreshold', '0.5']);
      RunCommandSimple(ExtractFilePath(TempPrefix),
        CommandExe, CommandOptions.ToArray);
    finally FreeAndNil(CommandOptions) end;

    CheckRenameFile(OutputTempFile, OutputFile);
    CheckDeleteFile(InputFlippedFile, true);
  end;
  {$endif}

  procedure ATICompressonator(const InputFile, OutputFile: string;
    const C: TTextureCompression; const CompressionNameForTool: string);
  var
    {$ifndef MSWINDOWS}
    WineExe: string;
    {$endif}
    ToolExe, InputFlippedFile, OutputTempFile, TempPrefix, ConvertExe: string;
    //Image: TCastleImage;
  begin
    { On non-Windows, we need wine for this }
    {$ifndef MSWINDOWS}
    WineExe := '';
    TryToolExePath(WineExe, 'wine', C);
    {$endif}

    ToolExe := '';
    {$ifdef MSWINDOWS}
    TryToolExe(ToolExe, 'c:/Program Files/AMD/The Compressonator 1.50/TheCompressonator.exe');
    TryToolExe(ToolExe, 'c:/Program Files (x86)/AMD/The Compressonator 1.50/TheCompressonator.exe');
    {$endif}
    {$ifdef UNIX}
    TryToolExe(ToolExe, HomePath + '.wine/drive_c/Program Files/AMD/The Compressonator 1.50/TheCompressonator.exe');
    TryToolExe(ToolExe, HomePath + '.wine/drive_c/Program Files (x86)/AMD/The Compressonator 1.50/TheCompressonator.exe');
    {$endif}
    TryToolExePath(ToolExe, 'TheCompressonator', C);

    TempPrefix := GetTempFileNamePrefix;

    { Use TGA format in-between (InputFlippedFile has .tga extension), not PNG,
      this increases chances that ATI compressonator will not destroy
      the alpha channel (testcase: escape textures of map/laser, pirate_1/2, pirate_boss,
      bug reproducible when compressing to both "ATITC interpolated alpha"
      and "ATITC explicit alpha" formats). }
    InputFlippedFile := TempPrefix + '.tga';

    // Image := LoadImage(FilenameToURISafe(InputFile));
    // try
    //   if TextureCompressionInfo[C].DDSFlipped then
    //     Image.FlipVertical;
    //   SaveImage(Image, FilenameToURISafe(InputFlippedFile));
    // finally FreeAndNil(Image) end;

    { Convert using ImageMagick.
      - Back when we were using PNG for InputFlippedFile, ImageMagick proved
        more reliable, ATI Compressonator was consistently producing invalid output
        if we didn't use ImageMagick's convert.
      - Now that we use TGA for InputFlippedFile, ImageMagick is the only option
        anyway. We cannot write to TGA for now.
    }
    ConvertExe := '';
    TryToolExePath(ConvertExe, 'convert', C);
    if TextureCompressionInfo[C].DDSFlipped then
      RunCommandSimple(ConvertExe, [InputFile, '-flip', InputFlippedFile])
    else
      RunCommandSimple(ConvertExe, [InputFile, InputFlippedFile]);

    OutputTempFile := TempPrefix + 'output' + ExtractFileExt(OutputFile);

    RunCommandSimple(ExtractFilePath(TempPrefix),
      {$ifdef MSWINDOWS} ToolExe, [
      {$else}            WineExe, [ToolExe,
      {$endif}
      '-convert',
      '-overwrite',
      { we cannot just pass InputFlippedFile, OutputFile to compressonator,
        because it may be running in wine and not understanding Unix absolute paths. }
      ExtractFileName(InputFlippedFile),
      ExtractFileName(OutputTempFile),
      '-codec', 'ATICompressor.dll',
      '+fourCC', CompressionNameForTool]);

    CheckRenameFile(OutputTempFile, OutputFile);
    CheckDeleteFile(InputFlippedFile, true);
  end;

  procedure PVRTexTool(const InputFile, OutputFile: string;
    const C: TTextureCompression; const CompressionNameForTool: string);
  var
    ToolExe: string;
  begin
    ToolExe := '';
    {$ifdef UNIX}
    { Try the standard installation path on Linux.
      On x86_64, try the 64-bit version first, otherwise fallback on 32-bit. }
    {$ifdef CPU64}
    TryToolExe(ToolExe, '/opt/Imagination/PowerVR_Graphics/PowerVR_Tools/PVRTexTool/CLI/Linux_x86_64/PVRTexToolCLI');
    {$endif}
    TryToolExe(ToolExe, '/opt/Imagination/PowerVR_Graphics/PowerVR_Tools/PVRTexTool/CLI/Linux_x86_32/PVRTexToolCLI');
    {$endif}
    { otherwise, assume it's on $PATH }
    TryToolExePath(ToolExe, 'PVRTexToolCLI', C);

    RunCommandSimple(ToolExe,
      ['-f', CompressionNameForTool,
       '-q', 'pvrtcbest',
       '-m', '1',
       { On iOS, it seems that PVRTC textures must be square.
         See
         - https://en.wikipedia.org/wiki/PVRTC
         - https://developer.apple.com/library/ios/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/TextureTool/TextureTool.html
         But this is only an Apple implementation limitation, not a limitation
         of PVRTC1 compression.
         More info on this compression on
         - http://cdn.imgtec.com/sdk-documentation/PVRTC+%26+Texture+Compression.User+Guide.pdf
         - http://blog.imgtec.com/powervr/pvrtc2-taking-texture-compression-to-a-new-dimension

         In practice, forcing texture here to be square is very bad:
         - If a texture is addressed from the top, e.g. in Spine atlas file,
           then it's broken now. So using a texture atlases like 1024x512 from Spine
           would be broken.
         - ... and there's no sensible solution to the above problem.
           We could shift the texture, but then what if something addresses
           it from the bottom?
         - What if something (VRML/X3D or Collada texture coords) addresses
           texture in 0...1 range?
         - To fully work with it, we would have to store original texture
           size somewhere, and it's shift with regards to new compressed texture,
           and support it everywhere where we "interpret" texture coordinates
           (like when reading Spine atlas, or in shaders when sampling
           texture coordinates). Absolutely ugly.

         So, don't do this! Allow rectangular PVRTC textures!
       }
       // '-squarecanvas', '+' ,
       '-flip', 'y', // TODO: use this only when TextureCompressionInfo[C].DDSFlipped
       '-i', InputFile,
       '-o', OutputFile]);
  end;

  procedure NVCompress(const InputFile, OutputFile: string;
    const C: TTextureCompression; const CompressionNameForTool: string);
  var
    ToolExe: string;
  begin
    ToolExe := '';

    { assume it's on $PATH }
    TryToolExePath(ToolExe, 'nvcompress', C);

    RunCommandSimple(ToolExe,
      ['-' + CompressionNameForTool,
       InputFile,
       OutputFile]);
  end;

  procedure AMDCompress_FallbackATICompressonator(
    const InputFile, OutputFile: string;
    const C: TTextureCompression;
    const CompressionNameForAMDCompress,
          CompressionNameForATICompressonator: string);
  begin
    {$ifdef USE_AMDCompress}
    try
      AMDCompress(InputFile, OutputFile, C, CompressionNameForAMDCompress);
      Exit; // if there was no ECannotFindTool exception, then success: exit
    except
      on E: ECannotFindTool do
        Writeln('Cannot find AMDCompressCLI executable. Falling back to ATICompressonator.');
    end;
    {$endif}

    ATICompressonator(InputFile, OutputFile, C, CompressionNameForATICompressonator);
  end;

  procedure NVCompress_FallbackAMDCompress_FallbackATICompressonator(
    const InputFile, OutputFile: string;
    const C: TTextureCompression;
    const CompressionNameForNVCompress,
          CompressionNameForAMDCompress,
          CompressionNameForATICompressonator: string);
  begin
    try
      NVCompress(InputFile, OutputFile, C, CompressionNameForNVCompress);
      Exit; // if there was no ECannotFindTool exception, then success: exit
    except
      on E: ECannotFindTool do
        Writeln('Cannot find nvcompress executable. Falling back to AMDCompressCLI or ATICompressonator.');
    end;

    AMDCompress_FallbackATICompressonator(InputFile, OutputFile, C,
      CompressionNameForAMDCompress,
      CompressionNameForATICompressonator);
  end;

  { Convert both URLs to filenames and check, looking at file modification times
    on disk, whether output should be updated.
    In any case, makes appropriate message to user.
    If the file needs to be updated, makes sure it's output directory exists. }
  function CheckNeedsUpdate(const InputURL, OutputURL: string; out InputFile, OutputFile: string): boolean;
  begin
    InputFile := URIToFilenameSafe(InputURL);
    OutputFile := URIToFilenameSafe(OutputURL);

    Result := (not FileExists(OutputFile)) or (FileAge(OutputFile) < FileAge(InputFile));
    if Result then
    begin
      Writeln(Format('Updating "%s" from input "%s"', [OutputFile, InputFile]));
      CheckForceDirectories(ExtractFilePath(OutputFile));
    end else
    begin
      if Verbose then
        Writeln(Format('Not need to update "%s", it is already newer than input', [OutputFile]));
    end;
  end;

  procedure UpdateTextureScale(const InputURL, OutputURL: string;
    const Scale: Cardinal; var Stats: TStats);
  const
    // equivalent of GLTextureMinSize, but for TextureLoadingScale, not for GLTextureScale
    TextureMinSize = 16;
  var
    InputFile, OutputFile: string;
    Image: TCastleImage;
    NewWidth, NewHeight: Integer;
    TimeStart: TProcessTimerResult;
  begin
    if CheckNeedsUpdate(InputURL, OutputURL, InputFile, OutputFile) then
    begin
      Inc(Stats.DownscalingCount);
      TimeStart := ProcessTimer;

      Image := LoadImage(InputURL);
      try
        if Image.Width < TextureMinSize then
          NewWidth := Image.Width else
          NewWidth := Image.Width shr (Scale - 1);
        if Image.Height < TextureMinSize then
          NewHeight := Image.Height else
          NewHeight := Image.Height shr (Scale - 1);
        if Verbose then
          Writeln(Format('Resizing "%s" from %dx%d to %dx%d',
            [InputURL, Image.Width, Image.Height, NewWidth, NewHeight]));
        Image.Resize(NewWidth, NewHeight, riLanczos);
        SaveImage(Image, OutputURL);
      finally FreeAndNil(Image) end;

      Stats.DownscalingTime := Stats.DownscalingTime + TimeStart.ElapsedTime;
    end;
  end;

  procedure UpdateTextureCompress(const InputURL, OutputURL: string;
    const C: TTextureCompression; var Stats: TStats);
  var
    InputFile, OutputFile: string;
    TimeStart: TProcessTimerResult;
  begin
    if CheckNeedsUpdate(InputURL, OutputURL, InputFile, OutputFile) then
    begin
      Inc(Stats.CompressionCount);
      TimeStart := ProcessTimer;

      case C of
        { For ATICompressonator DXT1:
          tcDxt1_RGB and tcDxt1_RGBA result in the same output file,
          DXT1 is the same compression in both cases, and there's no option
          how to differentiate between this in DDS file. }
        tcDxt1_RGB : NVCompress_FallbackAMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'bc1' , 'DXT1', 'DXT1');
        tcDxt1_RGBA: NVCompress_FallbackAMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'bc1a', 'DXT1', 'DXT1');
        tcDxt3     : NVCompress_FallbackAMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'bc2' , 'DXT3', 'DXT3');
        tcDxt5     : NVCompress_FallbackAMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'bc3' , 'DXT5', 'DXT5');

        tcATITC_RGB                   : AMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'ATC_RGB'              , 'ATC ');
        tcATITC_RGBA_InterpolatedAlpha: AMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'ATC_RGBA_Interpolated', 'ATCI');
        tcATITC_RGBA_ExplicitAlpha    : AMDCompress_FallbackATICompressonator(InputFile, OutputFile, C, 'ATC_RGBA_Explicit'    , 'ATCA');

        tcPvrtc1_4bpp_RGB:  PVRTexTool(InputFile, OutputFile, C, 'PVRTC1_4_RGB');
        tcPvrtc1_2bpp_RGB:  PVRTexTool(InputFile, OutputFile, C, 'PVRTC1_2_RGB');
        tcPvrtc1_4bpp_RGBA: PVRTexTool(InputFile, OutputFile, C, 'PVRTC1_4');
        tcPvrtc1_2bpp_RGBA: PVRTexTool(InputFile, OutputFile, C, 'PVRTC1_2');
        tcPvrtc2_4bpp:      PVRTexTool(InputFile, OutputFile, C, 'PVRTC2_4');
        tcPvrtc2_2bpp:      PVRTexTool(InputFile, OutputFile, C, 'PVRTC2_2');

        tcETC1:             PVRTexTool(InputFile, OutputFile, C, 'ETC1');
                      // or AMDCompress(InputFile, OutputFile, C, 'ETC_RGB');

        else WritelnWarning('GPUCompression', Format('Compressing to GPU format %s not implemented (to update "%s")',
          [TextureCompressionToString(C), OutputFile]));
      end;

      Stats.CompressionTime := Stats.CompressionTime + TimeStart.ElapsedTime;
    end;
  end;

  procedure UpdateTexture(const MatProps: TMaterialProperties;
    const OriginalTextureURL: string; var Stats: TStats);
  var
    UncompressedURL, CompressedURL: string;
    C: TTextureCompression;
    Scale: Cardinal;
    ToGenerate: TTextureCompressionsToGenerate;
    Compressions: TTextureCompressions;
  begin
    Inc(Stats.Count);

    for Scale := 1 to MatProps.AutoScale(OriginalTextureURL) do
    begin
      if Scale <> 1 then
      begin
        UncompressedURL := MatProps.AutoGeneratedTextureURL(OriginalTextureURL, false, Low(TTextureCompression), Scale);
        UpdateTextureScale(OriginalTextureURL, UncompressedURL, Scale, Stats);
      end else
        UncompressedURL := OriginalTextureURL;

      ToGenerate := MatProps.AutoCompressedTextureFormats(OriginalTextureURL);
      Compressions := ToGenerate.Compressions;
      { TODO: we perform AutoDetectDxt call every time.
        Instead, information in auto_generated.xml could allow us to avoid it. }
      if ToGenerate.DxtAutoDetect then
        Include(Compressions, AutoDetectDxt(OriginalTextureURL, Stats));

      for C in Compressions do
      begin
        CompressedURL := MatProps.AutoGeneratedTextureURL(OriginalTextureURL, true, C, Scale);
        { We use the UncompressedURL that was updated previously.
          This way there's no need to scale the texture here. }
        UpdateTextureCompress(UncompressedURL, CompressedURL, C, Stats);
      end;
    end;
  end;

var
  Textures: TCastleStringList;
  I: Integer;
  MatPropsURL: string;
  MatProps: TMaterialProperties;
  Stats: TStats;
begin
  MatPropsURL := FilenameToURISafe(Project.DataPath + 'material_properties.xml');
  if not URIFileExists(MatPropsURL) then
  begin
    Writeln('Material properties file does not exist, so not compressing anything: ' + MatPropsURL);
    Exit;
  end;

  FillChar(Stats, SizeOf(Stats), 0);

  MatProps := TMaterialProperties.Create(false);
  try
    MatProps.URL := MatPropsURL;
    Textures := MatProps.AutoGeneratedTextures;
    try
      for I := 0 to Textures.Count - 1 do
        UpdateTexture(MatProps, Textures[I], Stats);
    finally FreeAndNil(Textures) end;
  finally FreeAndNil(MatProps) end;

  Writeln(Format(
    '%d textures considered to be compressed and/or downscaled.' + NL +
    'Compressions done: %d in %f seconds.' + NL +
    'Downscaling done: %d in %f seconds.' + NL +
    'DXTn auto-detection done: %d in %f seconds.' + NL,
    [Stats.Count,
     Stats.CompressionCount,
     Stats.CompressionTime,
     Stats.DownscalingCount,
     Stats.DownscalingTime,
     Stats.DxtAutoDetectCount,
     Stats.DxtAutoDetectTime
    ]));
end;

procedure CleanDir(const FileInfo: TFileInfo; Data: Pointer;
  var StopSearch: boolean);
begin
  Writeln('Removing ', FileInfo.AbsoluteName);
  RemoveNonEmptyDir(FileInfo.AbsoluteName);
end;

procedure AutoGenerateClean(const Project: TCastleProject);
begin
  FindFiles(Project.DataPath, TMaterialProperties.AutoGeneratedDirName, true,
    @CleanDir, nil, [ffRecursive]);
end;

end.
