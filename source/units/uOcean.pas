unit uOcean;

{$I Elysion.inc}

interface
uses
{ Classes,
 SysUtils,
 ElysionSprite,
 ElysionNode,
 uGlobal,
 uBasic,
 uConfig;}
  Classes,SysUtils, ElysionNode, ElysionSprite, uBasic;

type

{ TOcean }

 TOcean = class(TelNode)
  constructor Create; override;
  private
    oceanSprite: TelParallaxSprite;
  public
    property Sprite : TelParallaxSprite read oceanSprite write OceanSprite;
    procedure Draw(DrawChildren : Boolean = true); override;
    procedure Update(dt : Double); override;
    procedure Move(xSpeed,ySpeed : Double);
end;

implementation

constructor TOcean.Create;
begin
  inherited;
  oceanSprite := TelParallaxSprite.Create;
  oceanSprite.LoadFromFile(GetResImgPath+'background');
end;

procedure TOcean.Draw(DrawChildren: Boolean);
begin
  inherited Draw(DrawChildren);
  oceanSprite.Draw;
end;

procedure TOcean.Update(dt: Double);
begin
  inherited Update(dt);
end;

procedure TOcean.Move(xSpeed, ySpeed: Double);
begin
  Position.X := Position.X + xSpeed;
  Position.Y := Position.Y + ySpeed;
  oceanSprite.Position.X := oceanSprite.Position.X+xSpeed;
  oceanSprite.Position.Y := oceanSprite.Position.Y+ySpeed;
end;

end.

