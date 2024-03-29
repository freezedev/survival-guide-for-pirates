unit ElysionSprite;

interface

{$I Elysion.inc}

uses
  Classes,
  SysUtils,
  OpenURLUtil,
  {$IFDEF USE_DGL_HEADER}
  dglOpenGL,
  {$ELSE}
  gl, glu, glext,
  {$ENDIF}

  ElysionObject,
  ElysionContent,
  ElysionLogger,
  ElysionUtils,
  ElysionNode,
  ElysionTexture,
  ElysionTypes,
  ElysionAnimTypes,
  ElysionRendering,
  ElysionTimer,
  ElysionInput,
  ElysionApplication;

type
  TelSpriteList = class;

  TelSprite = class(TelNode)
    private
      fHyperLink: String;
      fTexture, fMask: TelTexture;
      fClipRect: TelRect;
      fBlendMode: TelBlendMode;
      fBoundingBox: TelBoundingBox;
      fCustomBBox: TelRect;

      function GetFilename(): String; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      function GetTransparent(): Boolean; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure SetTransparent(Value: Boolean); {$IFDEF CAN_INLINE} inline; {$ENDIF}

      function GetTextureWidth(): Integer; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      function GetTextureHeight(): Integer; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      function GetAspectRatio(): Single; {$IFDEF CAN_INLINE} inline; {$ENDIF}
    protected
      function GetWidth(): Integer; Override;
      function GetHeight(): Integer; Override;

      function GetMouseDown(): Boolean; Override;
      function GetMouseUp(): Boolean; Override;
      function GetMouseMove(): Boolean; Override;
      function GetMouseOver(): Boolean; Override;
      function GetMouseOut(): Boolean; Override;
      function GetDragStart(): Boolean; Override;
      function GetDragging(): Boolean; Override;
      function GetDragEnd(): Boolean; Override;
      function GetClick(): Boolean; Override;
      function GetRightClick(): Boolean; Override;
      function GetDblClick(): Boolean; Override;
    public
      constructor Create; Override;
      destructor Destroy; Override;

      function LoadFromFile(const aFilename: String): Boolean; Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      function LoadFromFile(const aFilename: String; aClipRect: TelRect): Boolean; Overload;

      procedure LoadFromTexture(aTexture: TelTexture); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure LoadFromTexture(aTexture: TelTexture; aClipRect: TelRect); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      procedure LoadFromStream(aStream: TStream); {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure SaveToStream(aStream: TStream); {$IFDEF CAN_INLINE} inline; {$ENDIF}

      procedure ClipImage(aRect: TelRect);

      procedure SetColorKey(aColor: TelColor); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure SetColorKey(aPoint: TelVector2i); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      function OnPoint(Coord: TelVector2f): Boolean;

      procedure Move(aPoint: TelVector2f); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure Move(aPoint: TelVector2i); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure Move(aPoint: TelVector3f); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      function Collides(Other: TelSprite; AllowInvisibleObjects: Boolean = false): Boolean; Overload;
      function Collides(Others: array of TelSprite; AllowInvisibleObjects: Boolean = false): Integer; Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      function Collides(Others: TelSpriteList; AllowInvisibleObjects: Boolean = false): Integer; Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      procedure Draw(DrawChildren: Boolean = true); Override;
      procedure Update(dt: Double = 0.0); Override;

      property ClipRect: TelRect read fClipRect; // Use ClipImage to set ClipRect
      // Custom Bounding Box
      property CustomBBox: TelRect read fCustomBBox write fCustomBBox;
    published
      property AspectRatio: Single read GetAspectRatio;

      property BlendMode: TelBlendMode read fBlendMode write fBlendMode;
      property BoundingBox: TelBoundingBox read fBoundingBox write fBoundingBox;

      property Filename: String read GetFilename;

      property HyperLink: String read fHyperLink write fHyperLink;

      property Texture: TelTexture read fTexture write fTexture;
      property Mask: TelTexture read fMask write fMask;

      property TextureWidth: Integer read GetTextureWidth;
      property TextureHeight: Integer read GetTextureHeight;

      property Transparent: Boolean read GetTransparent write SetTransparent;

      property Width: Integer read GetWidth;
      property Height: Integer read GetHeight;
  end;

  TelShadedSprite = class(TelSprite)
    private
        shader : TelShader;
    public
        
        function LoadShaders( vshader : string; pshader : string ): Boolean;
        procedure Draw(DrawChildren: Boolean = true); override;
        
  end;
  
  { TelParallaxSprite }

  TelParallaxDirection = (dtUp, dtDown, dtLeft, dtRight);

  TelParallaxSprite = class(TelSprite)
    private
      fSpeed: Single;
      fPaused: Boolean;
      fDirection: TelParallaxDirection;
      fInternalPosition: TelVector3f;
      // Used by draw-function. Do not change it elsewhere!
      fRecursion : Boolean;
    public
      constructor Create; Override;
      destructor Destroy; Override;

      procedure Start(); {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure Stop(); {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure Pause(); {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure UnPause(); {$IFDEF CAN_INLINE} inline; {$ENDIF}

      procedure Draw(DrawChildren: Boolean = true); override;
      procedure Update(dt: Double = 0.0); Override;
    published
      property Direction: TelParallaxDirection read fDirection write fDirection;
      property Speed: Single read fSpeed write fSpeed;
  end;

  { TelMovingSprite }

  TelMovingSprite = class(TelSprite)
  private
    fPaused: Boolean;
  public
    procedure Update(dt: Double = 0.0); Override;
  public
    Velocity: TelVector2f;
  published
    property Paused: Boolean read fPaused write fPaused;
  end;

  { TelSpriteSheet }

  TelSpriteSheet = class(TelSprite)
    private
      fMaxFrames, fFrame: Integer;
      fTimer: TelTimer;
      fFrameSize: TelSize;
      fLoop: Boolean;

      fAnimationList: TStringList;
      fAnimFrames: array of Integer;

      function GetColumns: Integer;
      function GetMaxFrames: Integer;
      function GetRows: Integer;
      procedure SetColumns(AValue: Integer);
      procedure SetRows(AValue: Integer);

      procedure UpdateSpritesheet;
    public
      constructor Create; Override;
      destructor Destroy; Override;

      // Define animation in pixels
      procedure Define(AnimName: String; aRect: TelRect); Overload;
      // Define animation in frames
      procedure Define(AnimName: String; StartFrame, EndFrame: Integer); Overload;
      // Define specific frames
      procedure Define(AnimName: String; Frammes: array of Integer); Overload;

      // Plays complete sprite sheet
      procedure Play(Length: Integer = 1000); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}

      // Plays specific sprite sheet animations
      procedure Play(AnimName: String; Length: Integer = 1000); Overload; {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure Stop(); {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure Pause(); {$IFDEF CAN_INLINE} inline; {$ENDIF}
      procedure UnPause(); {$IFDEF CAN_INLINE} inline; {$ENDIF}

      procedure Draw(DrawChildren: Boolean = true); Override;
      procedure Update(dt: Double = 0.0); Override;

      procedure RandomFrame();

      property FrameSize: TelSize read fFrameSize write fFrameSize;
    published
      property Frame: Integer read fFrame write fFrame;

      property MaxFrames: Integer read GetMaxFrames;

      property Columns: Integer read GetColumns write SetColumns;
      property Rows: Integer read GetRows write SetRows;

      property Loop: Boolean read fLoop write fLoop;
  end;

TelSpriteList = class(TelObject)
  private
    FSpriteList: TList;
    Head: String[13];

    function Get(Index: Integer): TelSprite;
    function GetPos(Index: String): Integer;
    procedure Put(Index: Integer; const Item: TelSprite);
    procedure PutS(Index: String; const Item: TelSprite);
    function GetS(Index: String): TelSprite;
    function GetCount: integer;
  public
    constructor Create; Override;
    destructor Destroy; Override;

    procedure Insert(Index: Integer; Sprite: TelSprite);
    function  Add(Sprite: TelSprite): Integer;
    procedure Delete(Index: Integer);
    procedure LoadFromStream(Stream : TFileStream);
    procedure SaveToStream(Stream : TFileStream);

    procedure LoadFromFile(Filename: String);
    procedure SaveToFile(Filename: String);

    property Items[Index: Integer]: TelSprite read Get write Put; default;
    property Find[Index: String]: TelSprite read GetS write PutS;
  published
    property Count: Integer read GetCount;
end;

implementation

uses
  ElysionGraphics;

{ TelMovingSprite }
       
function TelShadedSprite.LoadShaders( vshader : string; pshader : string ): Boolean;
var plist, vlist : TStringList;
begin
    plist := TStringList.Create();
    vlist := TStringList.Create();
    
    plist.LoadFromFile( pshader );
    vlist.LoadFromFile( vshader );
    
    shader := TelShader.Create( vlist.Text, plist.Text );
    
    result := shader.Compile();

    shader.Map( Texture, 'texture');
    shader.Update;

    WriteLn( IntToStr( Integer(result) ));
end;


procedure TelShadedSprite.Draw(DrawChildren: Boolean );
var loc : TelVector3i;
begin
  if ((Visible) and (not Texture.Empty)) then
  begin

  	loc.X := Width;
  	loc.Y := Height;
  	
  	fWidth := fWidth *  Integer(Round(Scale.X) + 1);
  	fHeight := fHeight * Integer(Round(Scale.Y) + 1);
  
    shader.BindShader;
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glEnable(GL_TEXTURE_2D);

    glPushMatrix;
      glColor3f(1, 1, 1);
      glBindTexture(GL_TEXTURE_2D, Self.Texture.TextureID);
      if Transparent then
      begin
        glEnable(GL_ALPHA_TEST);
        glAlphaFunc(GL_GREATER, 0.1);
      end;

  	glTranslatef((ParentPosition.X + Position.X - Margin.Left - Border.Left.Width - Padding.Left + Origin.X) * ActiveWindow.ResScale.X,
                     (ParentPosition.Y + Position.Y - Margin.Top - Border.Top.Width - Padding.Top + Origin.Y) * ActiveWindow.ResScale.Y, ParentPosition.Z);

  	if Abs(Rotation.Angle) >= 360.0 then Rotation.Angle := 0.0;

  	if Rotation.Angle <> 0.0 then glRotatef(Rotation.Angle, Rotation.Vector.X, Rotation.Vector.Y, Rotation.Vector.Z);

      case BlendMode of
        bmAdd: glBlendFunc(GL_ONE, GL_ONE);
        bmNormal: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        bmSub: glBlendFunc(GL_ZERO, GL_ONE);
      end;
      glEnable(GL_BLEND);
    
  	glColor4f(Color.R / 255, Color.G / 255, Color.B / 255, Alpha / 255);
  //	glScalef(Scale.X * ActiveWindow.ResScale.X, Scale.Y * ActiveWindow.ResScale.Y, 1);
    
      glBegin(GL_QUADS);
        
        glTexCoord2f(0, 1); 		
        glVertex3f(Position.X / ActiveWindow.Width - 1  , Position.Y / ActiveWindow.Height, -Position.Z);
        
        glTexCoord2f(0, 0); 
        glVertex3f( Position.X / ActiveWindow.Width- 1 , (Position.Y + fHeight) /  ActiveWindow.Height,  -Position.Z);
        
        glTexCoord2f(1, 0); 
        glVertex3f((Position.X + fWidth) / ActiveWindow.Width - 1 , (Position.Y + fHeight) /  ActiveWindow.Height, -Position.Z);
        
        glTexCoord2f(1,1);
        glVertex3f((Position.X + fWidth) / ActiveWindow.Width - 1 , Position.Y / ActiveWindow.Height, -Position.Z);
     
      glEnd;
        
        
    glPopMatrix;
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);

    shader.UnbindShader;
    
    fWidth := loc.X;
    fHeight := loc.Y;
  end;
  
end;        

procedure TelMovingSprite.Update(dt: Double = 0.0);
begin
  inherited;

  if not Self.Paused then Self.Move(Velocity, dt);
end;

constructor TelSprite.Create;
begin
  inherited;

  Texture := TelTexture.Create;
  Mask := TelTexture.Create;

  BlendMode := bmNormal;
  fBoundingBox := bbDefault;

end;

destructor TelSprite.Destroy;
begin
  Texture.Destroy;
  Mask.Destroy;

  inherited;
end;

function TelSprite.GetFilename(): String;
begin
  Result := Texture.Filename;
end;

function TelSprite.GetTransparent(): Boolean;
begin
  Result := Texture.Transparent;
end;

procedure TelSprite.SetTransparent(Value: Boolean);
begin
  Texture.Transparent := Value;
end;

function TelSprite.GetMouseDown(): Boolean;
begin
  inherited;

  Result := ((MouseOver) and (Input.Mouse.Down));
end;

function TelSprite.GetMouseUp(): Boolean;
begin
  inherited;

  Result := ((MouseOver) and (Input.Mouse.Up));
end;

function TelSprite.GetMouseMove(): Boolean;
begin
  inherited;

  Result := ((MouseOver) and (Input.Mouse.Motion));
end;

function TelSprite.GetMouseOver(): Boolean;
var
  tempRect: TelRect;
begin
  inherited;

  {$IFDEF CAN_METHODS}
    if ((Self.BoundingBox = bbCustom) and (Self.CustomBBox.IsEmpty())) then Self.BoundingBox := bbDefault;
  {$ELSE}
    if ((Self.BoundingBox = bbCustom) and (IsRectEmpty(Self.CustomBBox)) then Self.BoundingBox := bbDefault;
  {$ENDIF}

  case Self.BoundingBox of
    bbDefault:
    begin
      tempRect.X := Self.Position.X * ActiveWindow.ResScale.X;
      tempRect.Y := Self.Position.Y * ActiveWindow.ResScale.Y;
      tempRect.W := fClipRect.W * ActiveWindow.ResScale.X;
      tempRect.H := fClipRect.H * ActiveWindow.ResScale.Y;

      {$IFDEF CAN_METHODS}
        Result := tempRect.ContainsVector(ActiveWindow.Cursor);
      {$ELSE}
        Result := RectContainsVector(fClipRect, ActiveWindow.Cursor);
      {$ENDIF}
    end;

    bbCustom:
    begin
      tempRect.X := (Self.Position.X + Self.CustomBBox.X) * ActiveWindow.ResScale.X;
      tempRect.Y := (Self.Position.Y + Self.CustomBBox.Y) * ActiveWindow.ResScale.Y;
      tempRect.W := Self.CustomBBox.W * ActiveWindow.ResScale.X;
      tempRect.H := Self.CustomBBox.H * ActiveWindow.ResScale.Y;

      {$IFDEF CAN_METHODS}
        Result := tempRect.ContainsVector(ActiveWindow.Cursor);
      {$ELSE}
        Result := RectContainsVector(fClipRect, ActiveWindow.Cursor);
      {$ENDIF}
    end;

    bbPixel:
    begin
      Result := PixelTest(Self, makeRect(ActiveWindow.Cursor.X, ActiveWindow.Cursor.Y, 1, 1));
    end;
  end;

end;

function TelSprite.GetMouseOut(): Boolean;
begin
  inherited;

  Result := not GetMouseOver();
end;

function TelSprite.GetDragStart(): Boolean;
begin
  inherited GetDragStart;

  //if (MouseDown and MouseMove) then fDidDragStart := true;
  //if (MouseUp) then if fDidDragStart then fDidDragStart := false;

  Result := fDidDragStart;
end;

function TelSprite.GetDragging(): Boolean;
begin
  inherited;

  if fDidDragStart then
  begin
    fDidDragging := (MouseMove);
  end;

  fDidDragStart := not fDidDragging;

  Result := fDidDragging;
end;

function TelSprite.GetDragEnd(): Boolean;
begin
  inherited GetDragEnd;

  if (fDidDragging and MouseUp) then
  begin
    Result := true;

    fDidDragging := false;
    if fDidDragStart then fDidDragStart := false;
  end;
end;

function TelSprite.GetClick(): Boolean;
begin
  inherited;

  Result := ((MouseOver) and (Input.Mouse.LeftClick));
end;

function TelSprite.GetRightClick(): Boolean;
begin
  inherited;

  Result := ((MouseOver) and (Input.Mouse.RightClick()));
end;

function TelSprite.GetDblClick(): Boolean;
begin
  inherited;

  Result := ((MouseOver) and (Input.Mouse.DblClick));
end;

function TelSprite.GetTextureWidth(): Integer;
begin
  Result := Texture.Width;
end;

function TelSprite.GetTextureHeight(): Integer;
begin
  Result := Texture.Height;
end;

function TelSprite.GetAspectRatio(): Single;
begin
  Result := Texture.AspectRatio;
end;

function TelSprite.GetWidth(): Integer;
begin
  Result := Trunc(ClipRect.W);
end;

function TelSprite.GetHeight(): Integer;
begin
  Result := Trunc(ClipRect.H);
end;

function TelSprite.LoadFromFile(const aFilename: String): Boolean;
begin
  Result := Self.LoadFromFile(aFilename, makeRect(0, 0, -1, -1));
end;

function TelSprite.LoadFromFile(const aFilename: String; aClipRect: TelRect): Boolean;
var
  Directory: String;
  OptExtension: String; //< Optional extension
begin

  if ({(aFilename <> (Directory + Content.RootDirectory + Self.Filename)) and} (aFilename <> '')) then
  begin
    Directory := ExtractFilePath(ParamStr(0));
    OptExtension := '';

    if not FileExists(Directory + Content.RootDirectory + aFilename) then
    begin
      if GetFilenameExtension(aFilename) = '' then
      begin
        // Order: Least favorite image format to best texture format
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.bmp')) then OptExtension := '.bmp';

        {$IFDEF USE_VAMPYRE}
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.gif')) then OptExtension := '.gif';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.pcx')) then OptExtension := '.pcx';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.tif')) then OptExtension := '.tif';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.tiff')) then OptExtension := '.tiff';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.xpm')) then OptExtension := '.xpm';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.psd')) then OptExtension := '.psd';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.jpg')) then OptExtension := '.jpg';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.jpeg')) then OptExtension := '.jpeg';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.png')) then OptExtension := '.png';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.tga')) then OptExtension := '.tga';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.dds')) then OptExtension := '.dds';
        {$ENDIF}

        {$IFDEF USE_SDL_IMAGE}
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.gif')) then OptExtension := '.gif';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.pcx')) then OptExtension := '.pcx';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.tif')) then OptExtension := '.tif';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.tiff')) then OptExtension := '.tiff';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.xpm')) then OptExtension := '.xpm';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.jpg')) then OptExtension := '.jpg';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.jpeg')) then OptExtension := '.jpeg';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.png')) then OptExtension := '.png';
        if FileExists(LowerCase(Directory + Content.RootDirectory + aFilename + '.tga')) then OptExtension := '.tga';
        {$ENDIF}
      end;
    end;

    if FileExists(Directory + Content.RootDirectory + aFilename + OptExtension) then
    begin
      Self.Texture := TextureManager.CreateNewTexture(Directory + Content.RootDirectory + aFilename + OptExtension);

      if aClipRect.X < 0 then aClipRect.X := 0;
      if aClipRect.Y < 0 then aClipRect.Y := 0;
      if aClipRect.W <= 0 then aClipRect.W := TextureWidth;
      if aClipRect.H <= 0 then aClipRect.H := TextureHeight;


      ClipImage(aClipRect);

      // Sets origin to center
      Origin := Center(Self);

      //FAnim.W := GetSurfaceWidth div Trunc(FClipRect.W);
      //FAnim.H := GetSurfaceHeight div Trunc(FClipRect.H);

      //FMaxFrames := Trunc(FAnim.W) * Trunc(FAnim.H);

      Result := true;
    end else if isLoggerActive then Self.Log('File not found: ' + Directory + Content.RootDirectory + aFilename + OptExtension);

  end;
end;

procedure TelSprite.LoadFromTexture(aTexture: TelTexture);
begin
  fTexture := aTexture;
end;

procedure TelSprite.LoadFromTexture(aTexture: TelTexture; aClipRect: TelRect);
begin
  LoadFromTexture(aTexture);
  ClipImage(aClipRect);
end;

procedure TelSprite.LoadFromStream(aStream: TStream);
begin
  Texture.LoadFromStream(aStream);
end;

procedure TelSprite.SaveToStream(aStream: TStream);
begin
  Texture.SaveToStream(aStream);
end;

procedure TelSprite.ClipImage(aRect: TelRect);
begin
  if (fClipRect.X <> aRect.X) then fClipRect.X := aRect.X;
  if (fClipRect.Y <> aRect.Y) then fClipRect.Y := aRect.Y;

  if (fClipRect.W <> aRect.W) then
  begin
    fClipRect.W := aRect.W;
  end;

  if (fClipRect.H <> aRect.H) then
  begin
    fClipRect.H := aRect.H;
  end;
end;

procedure TelSprite.SetColorKey(aColor: TelColor);
begin
  Texture.SetColorKey(aColor);
end;

procedure TelSprite.SetColorKey(aPoint: TelVector2i);
begin
  Texture.SetColorKey(aPoint);
end;

function TelSprite.OnPoint(Coord: TelVector2f): Boolean;
var
  marLeft, marTop, marRight, marBottom: Single;
  padLeft, padTop, padRight, padBottom: Single;
  borLeft, borTop, borRight, borBottom: Single;
begin

  if edMargin in Decorations then
  begin
    marLeft := Margin.Left;
    marTop := Margin.Top;
    marRight := Margin.Right;
    marBottom := Margin.Bottom;
  end else
  begin
    marLeft := 0;
    marTop := 0;
    marRight := 0;
    marBottom := 0;
  end;

  if edPadding in Decorations then
  begin
    padLeft := Padding.Left;
    padTop := Padding.Top;
    padRight := Padding.Right;
    padBottom := Padding.Bottom;
  end else
  begin
    padLeft := 0;
    padTop := 0;
    padRight := 0;
    padBottom := 0;
  end;

  if edBorder in Decorations then
  begin
    borLeft := Border.Left.Width;
    borTop := Border.Top.Width;
    borRight := Border.Right.Width;
    borBottom := Border.Bottom.Width;
  end else
  begin
    borLeft := 0;
    borTop := 0;
    borRight := 0;
    borBottom := 0;
  end;

  Result := ((Coord.X >= (AbsolutePosition.X - Origin.X - marLeft - borLeft - padLeft) * Scale.X * ActiveWindow.ResScale.X) and
             (Coord.Y >= (AbsolutePosition.Y - Origin.Y - marTop - borTop - padTop) * Scale.Y * ActiveWindow.ResScale.Y) and
             (Coord.X < (AbsolutePosition.X - Origin.X + ClipRect.W + marRight + borRight + padRight) * Scale.X * ActiveWindow.ResScale.X) and
             (Coord.Y < (AbsolutePosition.Y - Origin.Y + ClipRect.H + marBottom + borBottom + padBottom) * Scale.Y * ActiveWindow.ResScale.Y));
end;

procedure TelSprite.Move(aPoint: TelVector2f);
begin
  Position.Add(makeV3f(aPoint.X, aPoint.Y, 0.0));
end;

procedure TelSprite.Move(aPoint: TelVector2i);
begin
  Position.Add(makeV3f(aPoint.X, aPoint.Y, 0.0));
end;

procedure TelSprite.Move(aPoint: TelVector3f);
begin
  Position.Add(aPoint);
end;

function TelSprite.Collides(Other: TelSprite; AllowInvisibleObjects: Boolean = false): Boolean;
begin
  if Self.BoundingBox = Other.BoundingBox then
  begin
    case BoundingBox of
      bbDefault: Result := CollisionTest(Self, Other, AllowInvisibleObjects);
      bbCustom: Result := CollisionTest(Self.CustomBBox, Other.CustomBBox);
      bbPixel: Result := PixelTest(Self, Other, AllowInvisibleObjects);
    end;
  end else
  begin
    // Default bounding box <-> Custom bounding box
    if ((Self.BoundingBox = bbDefault) and (Other.BoundingBox = bbCustom)) then Result := CollisionTest(Self.ClipRect, Other.CustomBBox);
    if ((Self.BoundingBox = bbCustom) and (Other.BoundingBox = bbDefault)) then Result := CollisionTest(Other.CustomBBox, Self.ClipRect);

    // Default bounding box <-> Pixel
    if ((Self.BoundingBox = bbDefault) and (Other.BoundingBox = bbPixel)) then Result := PixelTest(Other, Self, AllowInvisibleObjects);
    if ((Self.BoundingBox = bbPixel) and (Other.BoundingBox = bbDefault)) then Result := PixelTest(Self, Other, AllowInvisibleObjects);

    // Custom bounding box <-> Pixel
    if ((Self.BoundingBox = bbCustom) and (Other.BoundingBox = bbPixel)) then Result := PixelTest(Other, Self.CustomBBox, AllowInvisibleObjects);
    if ((Self.BoundingBox = bbPixel) and (Other.BoundingBox = bbCustom)) then Result := PixelTest(Self, Other.CustomBBox, AllowInvisibleObjects);
  end;
end;

function TelSprite.Collides(Others: array of TelSprite; AllowInvisibleObjects: Boolean = false): Integer;
var
  i, Collided: Integer;
begin
  if Length(Others) = 0 then begin
    Result := 0;
    Exit;
  end;
  Collided := 0;

  for i := 0 to Length(Others) - 1 do
  begin
    if Self.Collides(Others[i], AllowInvisibleObjects) then Collided := Collided + 1;

    Result := Collided;
  end;
end;

function TelSprite.Collides(Others: TelSpriteList; AllowInvisibleObjects: Boolean = false): Integer;
var
  i, Collided: Integer;
begin
  if Others.Count = 0 then begin
    Result := 0;
    Exit;
  end;
  Collided := 0;

  for i := 0 to Others.Count - 1 do
  begin
    if Self.Collides(Others[i], AllowInvisibleObjects) then Collided := Collided + 1;

    Result := Collided;
  end;
end;

procedure TelSprite.Draw;
begin

  if ((Visible) and (not Texture.Empty)) then
  begin
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glEnable(GL_TEXTURE_2D);

    glPushMatrix;
      glColor3f(1, 1, 1);
      glBindTexture(GL_TEXTURE_2D, Self.Texture.TextureID);
      if Transparent then
      begin
        glEnable(GL_ALPHA_TEST);
        glAlphaFunc(GL_GREATER, 0.1);
      end;

  	glTranslatef((ParentPosition.X + Position.X - Margin.Left - Border.Left.Width - Padding.Left + Origin.X) * ActiveWindow.ResScale.X,
                     (ParentPosition.Y + Position.Y - Margin.Top - Border.Top.Width - Padding.Top + Origin.Y) * ActiveWindow.ResScale.Y, ParentPosition.Z);

  	if Abs(Rotation.Angle) >= 360.0 then Rotation.Angle := 0.0;

  	if Rotation.Angle <> 0.0 then glRotatef(Rotation.Angle, Rotation.Vector.X, Rotation.Vector.Y, Rotation.Vector.Z);

      case BlendMode of
        bmAdd: glBlendFunc(GL_ONE, GL_ONE);
        bmNormal: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        bmSub: glBlendFunc(GL_ZERO, GL_ONE);
      end;
      glEnable(GL_BLEND);

  	glColor4f(Color.R / 255, Color.G / 255, Color.B / 255, Alpha / 255);
  	glScalef(Scale.X * ActiveWindow.ResScale.X, Scale.Y * ActiveWindow.ResScale.Y, 1);

        DrawQuad(Texture.Width, Texture.Height,
                 fClipRect.X, fClipRect.Y, fClipRect.W, fClipRect.H,
                 -Origin.X, -Origin.Y, Self.Width, Self.Height,
                 Position.Z);
      //DrawQuad(TelVector2i.Create(TextureWidth, TextureHeight), FClipRect, TelRect.Create(-Offset.Rotation.X, -Offset.Rotation.Y, Width, Height), Position.Z);

      //DrawQuad(200, 200, 200, 200, 0);

      glDisable(GL_BLEND);
      if Transparent then glDisable(GL_ALPHA_TEST);
    glPopMatrix;

    glBindTexture(GL_TEXTURE_2D, 0);

    glDisable(GL_TEXTURE_2D);
  end;

  // Super is called here, because it should draw the object sprite before it draws its children
  inherited;
end;

procedure TelSprite.Update(dt: Double = 0.0);
begin
  inherited;

  if (HyperLink <> '') and GetClick then OpenURL(HyperLink);
end;


constructor TelSpriteSheet.Create;
begin
  inherited;

  fTimer := TelTimer.Create;
  fFrame := 0;

  fAnimationList := TStringList.Create;
  fAnimationList.NameValueSeparator := ':';

  fTimer.OnEvent := Self.UpdateSpritesheet;
  fLoop := false;
end;

function TelSpriteSheet.GetMaxFrames: Integer;
begin
  Result := Columns * Rows;
end;

function TelSpriteSheet.GetColumns: Integer;
begin
  Result := Self.TextureWidth div Self.FrameSize.Width;
end;

function TelSpriteSheet.GetRows: Integer;
begin
  Result := Self.TextureHeight div Self.FrameSize.Height;
end;

procedure TelSpriteSheet.SetColumns(AValue: Integer);
begin
  Self.FrameSize.Width := Self.TextureWidth div AValue;
end;

procedure TelSpriteSheet.SetRows(AValue: Integer);
begin
  Self.FrameSize.Height := Self.TextureHeight div AValue;
end;

procedure TelSpriteSheet.UpdateSpritesheet;
begin

end;

destructor TelSpriteSheet.Destroy;
begin
  fTimer.Destroy;

  inherited;
end;

procedure TelSpriteSheet.Define(AnimName: String; aRect: TelRect);
var
  tmpStartFrame, tmpEndFrame: Integer;
begin
  tmpStartFrame := (Trunc(aRect.X) * Columns) + (Trunc(aRect.Y) * Rows);
  tmpEndFrame := Trunc(aRect.X + aRect.W) * Columns + Trunc(aRect.Y + aRect.H) * Rows;

  fAnimationList.Add(AnimName + ':' + IntToStr(tmpStartFrame) + ' ' + IntToStr(tmpEndFrame));
end;

procedure TelSpriteSheet.Define(AnimName: String; StartFrame, EndFrame: Integer);
begin
  fAnimationList.Add(AnimName + ':' + IntToStr(StartFrame) + ' ' + IntToStr(EndFrame));
end;

procedure TelSpriteSheet.Define(AnimName: String; Frammes: array of Integer);
begin

end;

procedure TelSpriteSheet.Play(Length: Integer = 1000);
begin
  //fAnimFrames := [0];
  //fEndFrame := GetMaxFrames;

  fTimer.Interval := Length div GetMaxFrames;
end;

procedure TelSpriteSheet.Play(AnimName: String; Length: Integer = 1000);
begin
  fAnimationList.Values[AnimName];

  Self.Log(fAnimationList.Values[AnimName]);
  //fTimer.Interval := ;
end;

procedure TelSpriteSheet.Stop();
begin
  fTimer.Stop();
end;

procedure TelSpriteSheet.Pause();
begin
  fTimer.Pause();
end;

procedure TelSpriteSheet.UnPause();
begin
  fTimer.UnPause();
end;

procedure TelSpriteSheet.Draw();
begin
  inherited Draw();
end;

procedure TelSpriteSheet.Update(dt: Double);
begin
  inherited Update(dt);

  fTimer.Update(dt);
  Self.ClipImage(makeRect(fFrame div Columns, fFrame mod Rows, FrameSize.Width, FrameSize.Height));
end;

procedure TelSpriteSheet.RandomFrame();
begin
  fFrame := Random(GetMaxFrames) + 1;
end;

//
// TelSpriteList
//

constructor TelSpriteList.Create;
begin
  inherited;

  FSpriteList := TList.Create;
  Head := 'TelSpriteList';
end;

destructor TelSpriteList.Destroy;
var
  Counter : integer;
begin

  for Counter := 0 to FSpriteList.Count - 1 do
  begin
    TelSprite(FSpriteList[Counter]).Destroy;
  end;
  FSpriteList.Free;

  inherited Destroy;

end;

function TelSpriteList.GetCount: Integer;
begin
  Result := FSpriteList.Count;
end;

procedure TelSpriteList.Insert(Index: Integer; Sprite: TelSprite);
begin
  if ((Index >= 0) and (Index <= FSpriteList.Count - 1)) then FSpriteList.Insert(Index, Sprite)
  else begin
    if Index > FSpriteList.Count - 1 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList: Index > Count');
    if Index < 0 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList : Index < Count');
  end;
end;

function TelSpriteList.Add(Sprite: TelSprite): Integer;
begin
  Result := FSpriteList.Add(Sprite);
end;

procedure TelSpriteList.Delete(Index: Integer);
var
  TmpSprite: TelSprite;
begin
  if ((Index >= 0) and (Index <= FSpriteList.Count - 1)) then
  begin
    TmpSprite := Get(Index);
    TmpSprite.Destroy;
    FSpriteList.Delete(Index);
  end
  else begin
    if Index > FSpriteList.Count - 1 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList: Index > Count');
    if Index < 0 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList : Index < Count');
  end;

end;

function TelSpriteList.Get(Index: Integer): TelSprite;
begin
  if ((Index >= 0) and (Index <= FSpriteList.Count - 1)) then Result := TelSprite(FSpritelist[Index])
  else begin
    if Index > FSpriteList.Count - 1 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList: Index > Count');
    if Index < 0 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList : Index < Count');
  end;

end;

function TelSpriteList.GetPos(Index: String): Integer;
Var a, TMP: Integer;
Begin
  Try
    For a := 0 To FSpriteList.Count - 1 Do
    Begin
      if Items[a].Name <> Index then TMP := -1
      else begin
        TMP := a;
        Break;
      end;
    End;
  Finally
    Result := TMP;
  End;

end;

procedure TelSpriteList.Put(Index: Integer; const Item: TelSprite);
var
  TmpSprite: TelSprite;
begin
  if ((Index >= 0) and (Index <= FSpriteList.Count - 1)) then
  begin
    TmpSprite := Get(Index);
    TmpSprite.Destroy;
    Insert(Index, Item);
  end
  else begin
    if Index > FSpriteList.Count - 1 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList: Index > Count');
    if Index < 0 then if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList : Index < Count');
  end;

end;

Function TelSpriteList.GetS(Index: String): TelSprite;
Var TMP: Integer;
Begin
  TMP := GetPos(Index);
  if TMP >= 0 then Result := TelSprite(FSpriteList[TMP])
			  else Result := nil;
End;

Procedure TelSpriteList.PutS(Index: String; const Item: TelSprite);
var
  TMP: Integer;
  TmpSprite: TelSprite;
Begin
  if (Index <> '') then
  begin
    TmpSprite := GetS(Index);
	if TmpSprite <> nil then
	begin
	  TMP := GetPos(Index);
      TmpSprite.Destroy;
      Insert(TMP, Item);
	end
    else if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList: Index does not exist');
  end
  else if IsLoggerActive then TelLogger.GetInstance.WriteLog('SpriteList: Index string is empty');
End;

procedure TelSpriteList.LoadFromStream(Stream: TFileStream);
var
  TmpHead: String[13];
  loop : integer;
  ImgBuf : TelSprite;
begin
  TmpHead := '';
  loop := 0;

  Stream.Read(TmpHead, SizeOf(TmpHead));

  if TmpHead <> Head then
  begin
    if IsLoggerActive then TelLogger.GetInstance.WriteLog('Could not load file: Wrong file');
  end else
  begin
    Stream.Read(loop, SizeOf(Integer));

    FSpriteList.Count := loop;

    for loop := 0 to FSpriteList.Count - 1 do
    begin
      ImgBuf := TelSprite.Create;
      ImgBuf.LoadFromStream(Stream);
      FSpriteList.Insert(0, ImgBuf);
    end;
  end;

end;


procedure TelSpriteList.SaveToStream( Stream : TFileStream );
var
  loop : integer;
begin
  Stream.Write(Head, SizeOf(Head));
  Stream.Write(FSpriteList.Count, SizeOf(Integer));

  for loop := 0 to FSpriteList.Count - 1 do
  begin
    TelSprite(FSpriteList[loop]).SaveToStream(Stream);
  end;

end;

procedure TelSpriteList.SaveToFile(Filename: String);
var
  FileHndl: TFileStream;
begin
  FileHndl := TFileStream.Create( Filename, fmCreate );

  SaveToStream(FileHndl);

  FileHndl.Free;
end;

procedure TelSpriteList.LoadFromFile(Filename: String);
var
  FileHndl: TFileStream;
  Counter: integer;
begin

  for Counter := 0 to FSpriteList.Count - 1 do
  begin
    TelSprite(FSpriteList[Counter]).Destroy;
  end;

  FileHndl := TFileStream.Create(FileName, fmOpenRead);

  loadFromStream(FileHndl);

  FileHndl.Free;
end;

{ TelParallaxSprite }

constructor TelParallaxSprite.Create;
begin
  inherited Create;
  fRecursion := true;
end;

destructor TelParallaxSprite.Destroy;
begin
  inherited Destroy;
end;

procedure TelParallaxSprite.Start();
begin
  fPaused := false;
end;

procedure TelParallaxSprite.Stop();
begin
  fPaused := true;
end;

procedure TelParallaxSprite.Pause();
begin
  fPaused := true;
end;

procedure TelParallaxSprite.UnPause();
begin
  fPaused := false;
end;

procedure TelParallaxSprite.Draw();
var i,j,leftMissing, rightMissing, upMissing, downMissing : Integer; formerX, formerY : Single; rotateMe : boolean;
begin
  inherited Draw;
  // Immediately exit after draw: This is not the recursive call.
  if(not fRecursion) then Exit;
  fRecursion := false;
  // Ensure that the texture is bigger than the screen's width and height.
  // +2 because one picture can be partially visible, the second additional picture is guaranteed not to be seen.
  formerX := Position.X;
  formerY := Position.Y;

  //TODO: Ermitteln, wie viel nach links / rechts; oben / unten fehlt. Wenn das Bild zu weit außen ist, nach (0,0) verschieben (mindert Speicherbedarf).
  leftMissing := Trunc(Position.X / Width)+1;
  rightMissing := (ActiveWindow.Width - Trunc((Position.X+ Width)/Width)) +1;
  upMissing := Trunc(Position.Y / Height) +1;
  downMissing := (ActiveWindow.Height - Trunc((Position.Y + Height) / Height)) +1;

  if(leftMissing > 2) then
    formerX := Abs(ActiveWindow.Width-Position.X);
//  Position := MakeV3f(0,0,0);
  if(upMissing > 2)  then
    formerY := Abs(ActiveWindow.Height-Position.Y);
//  Position := MakeV3f(0,0,0);

  //  Draw shapes missing to completely fill the scene. Reset the sprite to its former coordinates after each run.

  for i := 0 to leftMissing do
  begin
    for j := 0 to upMissing do
    begin
    Position  := MakeV3f(formerX-(Width*i),formerY-j*Height);
       // if(j mod 2 = 1)then
       // Rotate(180);
    Draw;
    end;
  end;
  Position := MakeV3f(formerX, formerY);
  // Position 0 has already been taken by loop above (for i := 0 to leftMissing)
  for i := 1 to rightMissing do
  begin
    for j := 0 to upMissing do
    begin
      Position  := MakeV3f(i*Width+formerX,formerY-j*Height);
      Draw;
    end;
  end;
  Rotate(0);

  Position := MakeV3f(formerX, formerY);
  {for i := 0 to upMissing do
  begin
    Position := MakeV3f(formerX,formerY-i*Height);
    Draw;
  end;}

  Position := MakeV3f(formerX, formerY);
  for i := 0 to downMissing do
  begin
    Position := MakeV3f(formerX,formerY+i*Height);
    Draw;
  end;

  Position := MakeV3f(formerX, formerY);

  // Only the recursive call gets to here.
  fRecursion := true;
end;


procedure TelParallaxSprite.Update(dt: Double);
begin
  inherited Update(dt);
  case fDirection of
   dtUp: Position.Y := Position.Y -fSpeed*dt;
   dtDown: Position.Y := Position.Y +fSpeed*dt;
   dtLeft: Position.X := Position.X -fSpeed*dt;
   dtRight: Position.X := Position.X +fSpeed*dt;
  end;
end;

end.
