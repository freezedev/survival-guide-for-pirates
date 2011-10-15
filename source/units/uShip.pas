unit uShip;

interface

{$I Elysion.inc}

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
  ElysionGauge,

  SysUtils,
  uBasic;

type
  TShipDirection = (sdUp, sdDown, sdLeft, sdRight, sdUpLeft, sdUpRight, sdDownLeft, sdDownRight);

  { TShip }

  TShip = class(TelNode)
  private
    fSprite: TelSprite;
    fDirection: TShipDirection;
    fVelocity: TelVector2f;

    fLife: TelGaugeInt;
    fMunition: TelGaugeInt;

    procedure SetDirection(aDirection: TShipDirection); {$IFDEF CAN_INLINE} inline; {$ENDIF}
  public
    constructor Create;
    destructor Destroy;

    procedure Shoot(); virtual;

    procedure Draw; Override;
    procedure Update(dt: Double); Override;
  public
    property Velocity: TelVector2f read fVelocity write fVelocity;
  published
    property Life: TelGaugeInt read fLife write fLife;
    property Munition: TelGaugeInt read fMunition write fMunition;

    property Sprite: TelSprite read fSprite write fSprite;
    property Direction: TShipDirection read fDirection write SetDirection;
  end;

implementation



{ TShip }

procedure TShip.SetDirection(aDirection: TShipDirection);
begin
  fDirection := aDirection;

  case aDirection of
    sdUp: fSprite.ClipImage(makeRect(0, 0, 80, 80));
    sdDown: fSprite.ClipImage(makeRect(320, 0, 80, 80));
    sdLeft: fSprite.ClipImage(makeRect(480, 0, 80, 80));
    sdRight: fSprite.ClipImage(makeRect(160, 0, 80, 80));
    sdUpLeft: fSprite.ClipImage(makeRect(560, 0, 80, 80));
    sdUpRight: fSprite.ClipImage(makeRect(80, 0, 80, 80));
    sdDownLeft: fSprite.ClipImage(makeRect(240, 0, 80, 80));
    sdDownRight: fSprite.ClipImage(makeRect(400, 0, 80, 80));
  end;

end;

constructor TShip.Create;
begin
  fSprite := TelSprite.Create;
  fSprite.LoadFromFile(GetResImgPath + 'ship');
  SetDirection(sdUp);

  fLife := TelGaugeInt.Create(0, 100, 100);
  fMunition := TelGaugeInt.Create(0, 10, 10);
end;

destructor TShip.Destroy;
begin
  fSprite.Destroy;
end;

procedure TShip.Shoot;
begin
  // TODO: Add shooting!!!!
end;

procedure TShip.Draw;
begin
  fSprite.Draw();
end;

procedure TShip.Update(dt: Double);
begin
  Self.Position.X := Self.Position.X + (Velocity.X * dt);
  Self.Position.Y := Self.Position.Y + (Velocity.Y * dt);

  fSprite.Position := Self.Position;
  fSprite.Update();
end;

end.
