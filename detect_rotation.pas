program detect_rotation;

uses
  ctypes, xlib, x, xrandr, unixtype, sysutils;

type
  PXRRScreenChangeNotifyEvent = ^TXRRScreenChangeNotifyEvent;
  TXRRScreenChangeNotifyEvent = record
    _type: cint;
    serial: culong;
    send_event: TBool;
    display: PDisplay;
    window: TWindow;
    root: TWindow;
    timestamp: TTime;
    config_timestamp: TTime;
    size_index: cint;
    subpixel_order: cint;
    rotation: cuint;
    width: cint;
    height: cint;
    mwidth: cint;
    mheight: cint;
  end;

var
  display: PDisplay;
  screen: cint;
  rootWindow: TWindow;
  eventBase, errorBase: cint;
  event: TXEvent;
  xrrEvent: PXRRScreenChangeNotifyEvent;
  eventCount: integer;

begin
  display := XOpenDisplay(nil);
  if display = nil then
  begin
    WriteLn('Unable to open X display');
    Halt(1);
  end;

  if not XRRQueryExtension(display, @eventBase, @errorBase) then
  begin
    WriteLn('XRandR extension not supported');
    XCloseDisplay(display);
    Halt(1);
  end;

  rootWindow := XRootWindow(display, XDefaultScreen(display));
  XRRSelectInput(display, rootWindow, RRScreenChangeNotifyMask);

  eventCount := 0;

  while True do
  begin
    XNextEvent(display, @event);
    if event._type = eventBase + RRScreenChangeNotify then
    begin
      Inc(eventCount);
      if (eventCount mod 3) = 0 then
      begin
        xrrEvent := PXRRScreenChangeNotifyEvent(@event);
        WriteLn('Screen change detected:');
        WriteLn('  Rotation: ', xrrEvent^.rotation);
        WriteLn('  Size: ', xrrEvent^.width, 'x', xrrEvent^.height);

        // redraw the application UI here based on the new size and rotation
      end;
    end;
  end;

  XCloseDisplay(display);
end.
