unit AllKambiOpenGLUnits;

{ This is automatically generated unit, useful to compile all units
  in this directory (and OS-specific subdirectories like
  unix/, linux/, and win32/).
  Don't edit.
  Don't use this unit in your programs, it's just not for this.
  Generated by Kambi's Elisp function all-units-in-dir. }

interface

uses
  beziercurve,
  curve,
  glmenu,
  glsoundmenu,
  glw_demo,
  glw_navigated,
  glw_win,
  glwindow,
  glwindowrecentmenu,
  glwininputs,
  glwinmessages,
  glwinmodes,
  kambiglut,
  kambiglutils,
  openglbmpfonts,
  openglfonts,
  openglh,
  openglttfonts,
  progressgl,
  shadowvolumesutils,
  timemessages,
  {$ifdef UNIX}
  kambixf86vmode,
  xlibutils
  {$endif UNIX}
  {$ifdef WIN32}
  glwindowwinapimenu,
  openglwindowsfonts
  {$endif WIN32}
  ;

implementation

end.
