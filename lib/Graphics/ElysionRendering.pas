{*

					--------------	Elysion Rendering System -------------

	The Elysion Rendering System is a next-gen 2d renderer with post-processing, lights and shadow support in a two dimensional room.
	The ESR constists of the following sub-system:


	1.						--  Elysion Shader System  --

	The Elysion Shader-System is a low-level abstraction interface for native shader access for GLSL, the Open GL Shading Language.
	In these days shaders, expecially post-processing shaders, are very important to games and visual applications, interactive and
	realtime applications.

	The ESS( Elysion Shader System) encapsulses OpenGL vertex and pixel shader functionality and provides an easy interface to 
	interact with low-level shaders and the shader files itself. The ESS has the following structure:

		* TelVertexShader:
			An abstract interface to GLSL vertex shaders, which are necassary for tranformations in a three dimensional room.
			The vertex shader is only for tranformations, special effects such lighting and shadows are possible with 
			TelPixelShader.

		* TelPixelShader:
			Represents a low level interface to GLSL pixel shaders, which are necessary for special effects and all pixel based
			operations.

		-- Both Shader interfaces are only dataholder and are not able to do advanced operations like rendering or annotations parsing --

		* TelRenderTarget:
			Implements a simple interface to OpenGL rendertargets, which are needed for advanced post-processing shaders. 
			The class itself is only a data holder and has no advanced funtionality.

		* TelShaderParser:
			Parses a shader for special annotations which are described by the user. Annotations are a simple way to store additional
			data in a shader. All annotations are JSON based.

		* TelShaderCompiler:
			The shader compiler compiles shader in realtime and creates also hash-tags for compiled shaders. The shader compiler
			reacts automatic on shader source shaders and compiles the shader again( based on sha1/crc32 ).

	
	2. 						-- Elysion FX System --

	The Elysion FX System is a high-level post-processing framework for two dimensional rooms. It's based on the ESS and consists mostly out of
	pixel shaders and rendertargets.

	The Elysion FX System has the following structure:

		* TelEffect:
			The TelEffect class is based on a JSON-based special effect file which is a container for different pixel shaders, their parameters
			and effect conditions. The TelEffect is also only a data-holder and has no advanced functionality. 

		* TelEffectPipeline:
			The effect pipeline is a connected sequence of different effects and rendertargets. It connects different special effects.

		* TelEffectAnimator:
			The effect animator is a animated transition between two effects and applies rules to specific effects. 

	
	3.						-- Elysion Renderers --

	The Elysion Renderers System is a collection of different special-case optimized renderers for shader-based objects.

		* TelShadedSprite:
			Is sprite with material information for lighting and basic shader support.

		* TelShadedScene:
			Implements a scene structure based on shaders and connects sprites with the special effects system.

		* TelAbstractRenderer:
			Is a not-implemented interface of a basic renderer and all important function. This interface is implemented
			for special cases.

		* TelForwardRenderer:
			Is a typical forward renderer which renders a scene onto the screen. 

			

	

	!Important! The hole Elysion-Rendering System is not implemented yet.
*}


unit ElysionRendering;

interface

{$I Elysion.inc}

uses
  ElysionUtils,
  ElysionObject,
  ElysionApplication,
  ElysionTypes,
  ElysionColor,
  ElysionInput,
  ElysionTimer,
  ElysionNode,
  ElysionTexture,
  ElysionContent,
  ElysionLogger,

  {$IFDEF USE_DGL_HEADER}
  dglOpenGL,
  {$ELSE}
  gl, glu, glext,
  {$ENDIF}
  SDL,
  SDLUtils,
  //SDLTextures,

  SysUtils,
  OpenURLUtil,
  Classes;

type
    
    
    TelShader = class   
        private
            
            {*
                OpenGL Core Variables
            *}   
            program_id : GLuint;      // program id
            vertexshader_id : GLuint; // vertex shader id
            pixelshader_id  : GLuint; // pixel shader  id
            
            is_compiled : Boolean;
            is_linked   : Boolean;  
            
            pixel_source : String; // Pixel Shader Source
            vertex_source : String;// Vertex Shader Source
                
            texture_counter : Integer;
            
        public
        
        
            constructor Create( vertex : String; pixel : String );
        
            function Map( val : TelTexture; name : String ): Boolean; overload;
            function Map( val : Single; name : String ) : Boolean; overload;
            function Map( val : Integer; name : String ) : Boolean; overload;
            function Map( val : TelVector3f; name : string ): Boolean; overload;
            function Map( val : TelVector2f; name : String ): Boolean; overload;
            function Map( val : Boolean; name : String ): Boolean; overload;
            function Map( val : String; name : String ): Boolean; overload;
            function MapT( val : INteger; name : String ): Boolean;
                        
            function BindShader : Boolean;
            function UnbindShader : Boolean;
            
            function Compile : Boolean;
            function Update  : Boolean;            
                        
            function SetPixelShader( source : String ): Boolean;
            function SetVertexShader( source : String ): Boolean;

    end;
    
    
    TelRenderTarget = class
        private
            target_id : GLuint; 
            rbo : GLuint;
            tex : GLuint;
            width : Integer;
            height : Integer;       
        public
            
            constructor Create( fwidth, fheight : Integer ); 
            
            function BindRenderTarget : Boolean;
            function GetTex : GLuint;
            function UnbindRenderTarget : Boolean;
    end;
    
    
    TelPostProcess = class
        private
            shader : TelShader;
            target : TelRenderTarget;
        public
            constructor Create( ps : String; vs : String );
            
            function BeginProcess : Boolean;
            function EndProcess   : Boolean;
            
            function Draw : Boolean;
            
            function GetShader : TelShader;
            function GetRenderTarget : TelRenderTarget;
    end;



implementation

function TelShader.MapT( val : Integer; name : string ): Boolean;
var loc : GLint;
begin
    if ( is_compiled ) then begin
        glActiveTexture( GL_TEXTURE0 + texture_counter );
        glBindTexture( GL_TEXTURE_2D, val );
        
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform1i( loc, texture_counter );
        
        glBindTexture(GL_TEXTURE_2D, 0);
        
        texture_counter := texture_counter + 1;
        result := true;
    end else begin
        result := false;
    end;

end;

function TelPostProcess.Draw : Boolean;
begin
      glActiveTexture(GL_TEXTURE0);       
      glEnable(GL_TEXTURE_2D);
      
      shader.BindShader;
      
      glBindTexture(GL_TEXTURE_2D,target.tex); 
            
      glBegin(GL_QUADS);
        
        glTexCoord2f(0, 1); 		
        glVertex2f(-1,-1);
        
        glTexCoord2f(0, 0); 
        glVertex2f(-1,ActiveWindow.Height);
        
        glTexCoord2f(1, 0); 
        glVertex2f(ActiveWindow.Width,ActiveWindow.Height);
        
        glTexCoord2f(1,1);
        glVertex2f(ActiveWindow.Width,0);
     
      glEnd;
      
      shader.UnbindShader;  
      
      glBindTexture(GL_TEXTURE_2D, 0);
      glDisable(GL_TEXTURE_2D);
end;

constructor TelPostProcess.Create( ps : String; vs : String );
var l1, l2 : TStringList;
begin
    l1 := TStringList.Create;
    l2 := TStringList.Create;
    
    l1.LoadFromFile(ps);
    l2.LoadFromFile(vs);
    
    shader := TelShader.Create(l2.Text,l1.Text);
    shader.Compile();
    
    target := TelRenderTarget.Create( ActiveWindow.Width, ActiveWindow.Height );
    shader.MapT(target.tex, 'texture');
end;

function TelPostProcess.BeginProcess : Boolean;
begin
    target.BindRenderTarget;
    glViewport(0,0,ActiveWindow.Width, ActiveWindow.Height );
    glDrawBuffer(GL_COLOR_ATTACHMENT0);
    glClearColor(0,0,0,0);
    glClear( GL_COLOR_BUFFER_BIT );
end;

function TelPostProcess.EndProcess : Boolean;
begin
    target.UnbindRenderTarget;      
end;

function TelPostProcess.GetShader : TelShader;
begin
    result := shader;
end;

function TelPostProcess.GetRenderTarget : TelRenderTarget;
begin
    result := target;
end;

function TelRenderTarget.GetTex : GLuint;
begin
    result := tex;
end;

constructor TelRenderTarget.Create( fwidth, fheight : Integer );
begin
    width := fwidth;
    height := fheight;   
    
    glActiveTexture(GL_TEXTURE0);
    glEnable(GL_TEXTURE_2D);
    
    glGenTextures(1, @tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0); // place multisampling here too!
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glGenFramebuffers(1, @target_id );
    glBindFramebuffer(GL_FRAMEBUFFER, target_id );
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, 0);
    
    if ( glCheckFramebufferStatusEXT(GL_FRAMEBUFFER) = GL_FRAMEBUFFER_COMPLETE ) then begin
        WriteLn('Successfully Compiled');
    end;
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDisable(GL_TEXTURE_2D);
end;

function TelRenderTarget.BindRenderTarget : Boolean;
begin
    glBindFramebuffer(GL_FRAMEBUFFER, target_id);
end;

function TelRenderTarget.UnbindRenderTarget : Boolean;
begin
    glBindFramebuffer(GL_FRAMEBUFFER,0);
end;
            
constructor TelShader.Create( vertex : String; pixel : String );
begin
    texture_counter := 0;
    program_id := 0;
    vertexshader_id := 0;
    pixelshader_id := 0;
    is_compiled := true;
    is_linked := true;
    pixel_source := pixel;
    vertex_source := vertex;
end;

function TelShader.Update : Boolean;
begin
    if ( is_compiled ) then begin
        BindShader;
        UnbindShader;
        result := true;
    end else 
        result := false;
end;            
        
function TelShader.Map( val : Single; name : String ) : Boolean;
var loc : GLint;
begin
    if ( is_compiled ) then begin
        BindShader;
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform1f( loc, val  );
        UnbindShader;
        result := true;
    end else begin
        result := false;
    end;
end;


function TelShader.Map( val : TelTexture; name : String ) : Boolean; 
var loc : GLint;
begin
    if ( is_compiled ) then begin
        glActiveTexture( GL_TEXTURE0 + texture_counter );
        glBindTexture( GL_TEXTURE_2D, val.TextureId );
        
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform1i( loc, texture_counter );
        
        glBindTexture(GL_TEXTURE_2D, 0);
        
        texture_counter := texture_counter + 1;
        result := true;
    end else begin
        result := false;
    end;
end;            

function TelShader.Map( val : Integer; name : String ) : Boolean; 
var loc : GLint;
begin
    if ( is_compiled ) then begin
        BindShader;
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform1i( loc, val );
        UnbindShader;
        result := true;
    end else begin
        result := false;
    end;
end;
            

function TelShader.Map( val : TelVector3f; name : string ): Boolean;
var loc : GLint;
begin
    if ( is_compiled ) then begin
        BindShader;
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform3f( loc, val.x, val.y, val.z );
        UnbindShader;
        result := true;
    end else begin
        result := false;
    end;
end;
            

function TelShader.Map( val : TelVector2f; name : String ): Boolean;
var loc : GLint;
begin
    if ( is_compiled ) then begin
        BindShader;
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform2f( loc, val.x, val.y);
        UnbindShader;
        result := true;
    end else begin
        result := false;
    end;
end;
            

function TelShader.Map( val : Boolean; name : String ): Boolean;
var loc : GLint;
begin
    if ( is_compiled ) then begin
        BindShader;
        loc := glGetUniformLocation( program_id, PChar(name) );
        glUniform1i( loc, Integer(val) );
        UnbindShader;
        result := true;
    end else begin
        result := false;
    end;

end;
            
function TelShader.Map( val : String; name : String ): Boolean;
begin
    result := false;
end;
            
function TelShader.BindShader : Boolean;
begin
    if ( is_compiled ) then begin
        glUseProgram( program_id );
        result := true;
    end else 
        result := false; 
end;
            
function TelShader.UnbindShader : Boolean;
begin
    if ( is_compiled ) then begin
        glUseProgram( 0 );
        result := true;
    end else 
        result := false; 
end;
                        
function TelShader.Compile : Boolean;
var sz : Integer;
  blen, slen: GLInt;
  InfoLog: PGLCharARB;
begin
    program_id := 0;
    
    // Compile Vertex Shader
    vertexshader_id := glCreateShader(GL_VERTEX_SHADER);
    glShaderSource( vertexshader_id, 1, @(vertex_source), @sz );
    glCompileShader( vertexshader_id );
    
    // Compile Vertex Shader
    pixelshader_id := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource( pixelshader_id, 1, @(pixel_source), @sz );
    glCompileShader( pixelshader_id );

    // Create Program
    program_id := glCreateProgram();
    glAttachShader(  program_id, vertexshader_id );
    glAttachShader(  program_id, pixelshader_id );
    
    glLinkProgram(program_id);
      
      glGetShaderiv(vertexshader_id, GL_INFO_LOG_LENGTH , @blen);
      if blen > 1 then
      begin
        GetMem(InfoLog, blen * SizeOf(GLCharARB));
        glGetShaderInfoLog(vertexshader_id, blen, slen, InfoLog);
        WriteLn('Vertex: ' + PChar(InfoLog));
        Dispose(InfoLog);
      end;

      glGetShaderiv(pixelshader_id, GL_INFO_LOG_LENGTH , @blen);
      if blen > 1 then
      begin
        GetMem(InfoLog, blen * SizeOf(GLCharARB));
        glGetShaderInfoLog(pixelshader_id, blen, slen, InfoLog);
        WriteLn('Pixel: ' + PChar(InfoLog));
        Dispose(InfoLog);
      end;          
    is_linked := glIsProgram( program_id );
    is_compiled := true;//glIsProgram( program_id );
    result := glIsProgram( program_id );
end;            
           
function TelShader.SetPixelShader( source : String ): Boolean;
begin
    pixel_source := source;
end;        

function TelShader.SetVertexShader( source : String ): Boolean;
begin
    vertex_source := source;
end;


end.


