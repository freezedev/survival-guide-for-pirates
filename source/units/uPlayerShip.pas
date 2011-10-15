unit uPlayerShip;

interface

uses
  ElysionTypes,
  ElysionApplication,
  ElysionScene,
  ElysionLogger,
  ElysionColor,
  ElysionSprite,
  ElysionTrueTypeFont,
  ElysionTimer,
  ElysionInput,
  ElysionUtils,

  SysUtils,
  uBasic;

const
  VELOCITY_FACTOR = 50;

type

  TPlayerKeys = (pkArrowKeys, pkWSAD, pkGamepad);

  { TPlayerShip }

  TPlayerShip = class(TShip)
  private
    fPlayerKeys: TPlayerKeys;
  public
    procedure Update(dt: Double); Override;
  public
    property Keys: TPlayerKeys read fPlayerKeys write fPlayerKeys;
  end;

implementation

{ TPlayerShip }

procedure TPlayerShip.Update(dt: Double);
begin
  inherited Update(dt);

  Self.Velocity.Clear;

  case PlayerKeys of
    pkArrowKeys:
      begin
        if (Input.Keyboard.IsKeyDown(Key.Up)) then Self.Velocity.Y := Self.Velocity.Y - VELOCITY_FACTOR;
        if (Input.Keyboard.IsKeyDown(Key.Down)) then Self.Velocity.Y := Self.Velocity.Y + VELOCITY_FACTOR;
        if (Input.Keyboard.IsKeyDown(Key.Left)) then Self.Velocity.X := Self.Velocity.X - VELOCITY_FACTOR;
        if (Input.Keyboard.IsKeyDown(Key.Right)) then Self.Velocity.X := Self.Velocity.X + VELOCITY_FACTOR;
      end;
    pkWSAD:
      begin
        if (Input.Keyboard.IsKeyDown(Key.W)) then Self.Velocity.Y := Self.Velocity.Y - VELOCITY_FACTOR;
        if (Input.Keyboard.IsKeyDown(Key.S)) then Self.Velocity.Y := Self.Velocity.Y + VELOCITY_FACTOR;
        if (Input.Keyboard.IsKeyDown(Key.A)) then Self.Velocity.X := Self.Velocity.X - VELOCITY_FACTOR;
        if (Input.Keyboard.IsKeyDown(Key.D)) then Self.Velocity.X := Self.Velocity.X + VELOCITY_FACTOR;
      end;
    pkGamepad:
      begin
        if (Input.XBox360Controller.LStick.Up) then Self.Velocity.Y := Self.Velocity.Y - VELOCITY_FACTOR;
        if (Input.XBox360Controller.LStick.Down) then Self.Velocity.Y := Self.Velocity.Y + VELOCITY_FACTOR;
        if (Input.XBox360Controller.LStick.Left) then Self.Velocity.X := Self.Velocity.X - VELOCITY_FACTOR;
        if (Input.XBox360Controller.LStick.Right) then Self.Velocity.X := Self.Velocity.X + VELOCITY_FACTOR;
      end;
  end;
end;

end.
