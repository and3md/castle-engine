{
  Copyright 2009-2010 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Simple demo of Doppler effect using OpenAL.
  You move the sound source by dragging with mouse over the window,
  velocity is automatically calculated. Try to drag a horizontal line
  through the window to hear the Doppler effect, listener is positioned
  in the center of the window.

  Accepts command-line options from
  http://castle-engine.sourceforge.net/openal_notes.php }
program doppler_demo;

uses SysUtils, VectorMath, GLWindow, GL, GLU, CastleGLUtils,
  CastleOpenAL, ALUtils, ALSoundEngine, ALSoundAllocator, CastleStringUtils;

const
  ALDistanceScaling = 0.02;

var
  Window: TCastleWindowDemo;
  PreviousSourcePosition, SourcePosition, ListenerPosition: TVector3Single;
  Source: TALSound;

procedure Draw(Window: TCastleWindowBase);
begin
  glClear(GL_COLOR_BUFFER_BIT);

  glPointSize(20.0);

  glColor3f(1, 1, 0);
  glBegin(GL_POINTS);
    glVertexv(ListenerPosition);
  glEnd;

  glColor3f(1, 1, 1);
  glBegin(GL_POINTS);
    glVertexv(SourcePosition);
  glEnd;
end;

procedure Timer(Window: TCastleWindowBase);
begin
  alSourceVector3f(Source.ALSource, AL_VELOCITY,
    (SourcePosition - PreviousSourcePosition) * ALDistanceScaling);
  PreviousSourcePosition := SourcePosition;
end;

procedure MouseMove(Window: TCastleWindowBase; NewX, NewY: Integer);
begin
  if mbLeft in Window.MousePressed then
  begin
    SourcePosition := Vector3Single(NewX, Window.Height - NewY);
    Source.Position := SourcePosition * ALDistanceScaling;
    Window.PostRedisplay;
  end;
end;

var
  Buffer: TALBuffer;
begin
  Window := TCastleWindowDemo.Create(Application);

  SoundEngine.ParseParameters;
  SoundEngine.MinAllocatedSources := 1;
  SoundEngine.ALContextOpen;
  try
    Buffer := SoundEngine.LoadBuffer('tone.wav');

    //alDopplerFactor(3.0);

    Source := SoundEngine.AllocateSound(1);
    Source.Buffer := Buffer;
    Source.Looping := true;
    SourcePosition := Vector3Single(200, 300, 0);
    PreviousSourcePosition := SourcePosition;
    Source.Position := SourcePosition * ALDistanceScaling;
    alSourcePlay(Source.ALSource);

    ListenerPosition := Vector3Single(300, 300, 0);
    SoundEngine.UpdateListener(ListenerPosition * ALDistanceScaling,
      Vector3Single(0, 1, 0), Vector3Single(0, 0, 1));

    Application.TimerMilisec := 1000;
    Window.OnTimer := @Timer;
    Window.OnDraw := @Draw;
    Window.OnResize := @Resize2D;
    Window.OnMouseMove := @MouseMove;
    Window.SetDemoOptions(K_F11, CharEscape, true);
    Window.OpenAndRun;
  finally
    SoundEngine.StopAllSources;
    SoundEngine.FreeBuffer(Buffer);
    SoundEngine.ALContextClose;
  end;
end.
