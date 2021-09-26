//
// TeenWolf 2 
// Theme by Mahuti
// vs. 2
// 
// I stole Yaron's screenglow and shader stuff yet again. I do this so often I should make it a module fe.load_module("stuff_i_stole_from_yaron") 
// 
// 
local order = 0 
class UserConfig {
	
	</ label="Selected System", 
		help="Select a system name for this display, or select auto if your selected ROMLIST is named EXACTLY the same as one of the option names", 
		order=order++, 
        per_display="true",
		options="auto, Atari 2600, Intellivision, Nintendo NES, Nintendo SNES, Nintendo 64, Sega Master System, Sega Genesis, ScummVM, Sony Playstation, Generic TV, Generic PC" /> 
		console="Nintendo NES"; 
 
    </ label="TV Type", 
		help="Choose auto, or a specific screen for this layout", 
		order=order++, 
        per_display="true",
		options="Auto, Old TV, New TV, PC" /> 
		selected_tv="Auto"; 
        
    </ label="Posters", 
		help="Choose auto to match posters to consoles, random or none", 
		order=order++, 
        per_display="true",
		options="Auto, Random, None" /> 
		posters="Auto"; 
    
    </ label="Show CRT bloom or lottes shaders", 
        help="Enable bloom or lottes effects for the snap video, if user device supports GLSL shaders", 
        options="No,CRT Bloom,CRT Lottes", 
        per_display="true",
        order=order++  /> 
        enable_snap_shader="CRT Lottes";

    </ label="Show CRT screen glow ", 
		help="Enable screen glow effect for the snap video, if user device supports GLSL shaders", 
		options="No,Light,Medium,Strong", 
        per_display="true",
        order=order++ /> 
        enable_crt_screenglow="No";
    
    </ label="Show CRT scanlines", 
        help="Show CRT scanline effect", 
        options="No,Light,Medium,Dark", 
        per_display="true",
        order=order++ /> 
        enable_crt_scanline="Light";
    
	</ label="Game Titles", 
		help="Select game title style", 
		order=order++, 
        per_display="true",
		options="show wheel images, text titles, no titles" /> 
		game_titles="show wheel images";
		
	</ label="Show Playtime", 
		help="Show game playtime", 
		order=order++, 
        per_display="true",
		options="yes, no" /> 
		show_playtime="no"; 

	</ label="Cartridge Folder", 
		help="Choose folder that stores Cartridge art. Not all consoles use cartridge art.", 
		order=order++, 
        per_display="true",
		options="cartridge, marquee, none" /> 
		cartridge_folder="cartridge"; 
		
	</ label="Boxart Folder", 
		help="Choose folder that stores Boxart Images", 
		order=order++, 
        per_display="true",
		options="boxart, flyer, none" /> 
		boxart_folder = "boxart"; 
 
    </ label="Boxart Shadows", 
		help="Show shadows underneath boxart", 
		order=order++,   
        per_display="true",
		options="yes, no" /> 
		boxart_shadows="yes"; 

		
}
local dummytxt = fe.add_text("",0,0,0,0) // this fixes non-loading (empty) issue due to overlarge graphics. 

local config = fe.get_config()
 
// modules
fe.load_module("fade")
fe.load_module("file") 
fe.load_module("preserve-art") 
fe.load_module("pos") // positioning & scaling module
fe.load_module("shadow-glow")

local prefs = {}
local images = {}
local artwork = {}
local surface = {}

if (config["console"] != "auto")
{
    prefs.console <- config["console"]
} 
else
{
    local console_name = ["Atari 2600, Intellivision, Nintendo NES, Nintendo SNES, Nintendo 64, Sega Master System, Sega Genesis, ScummVM, Sony Playstation, Generic TV, Generic PC"]
    if (fe.list.name in console_name){
            prefs.console <- fe.list.name
    }else
    {
        prefs.console <- "Generic TV"
    }
}


prefs.console <- config["console"]
prefs.tv <-  config["selected_tv"]
prefs.boxart_shadows <-  config["boxart_shadows"]
prefs.boxart_folder <-  config["boxart_folder"]
prefs.show_playtime <-  config["show_playtime"]
prefs.game_titles <-  config["game_titles"]
prefs.cartridge_folder <-  config["cartridge_folder"]
prefs.posters <-  config["posters"]

local snap_x, snap_y, snap_w, snap_h, cart_x, cart_y, cart_width, cart_height, cart_pinch_x, cart_pinch_y, boxart, boxart_x, boxart_y, boxart_width, boxart_height, boxart_shadows, boxart_shadow, boxart_folder, wheel_x, wheel_y, wheel_width, wheel_height, console_image, console_x, console_y, console_width, console_height, console_overlay, console_overlay_x, console_overlay_y, console_overlay_width, console_overlay_height, controller, controller_x, controller_y, controller_width, controller_height, cart_preserve_aspect_ratio, screen, screen_x, screen_y, screen_width, screen_height, bg_x, bg_y, posData, scale, stretch, beginning_offset_x, beginning_offset_y, console, tv, show_playtime, game_titles, cartridge, cartridge_folder, poster_shadow, bg, bg_grid, poster_shadow_orig_height, poster_left, poster_right, poster1, poster2, poster1_width, poster1_height, poster1_x, poster1_y, poster2_width, poster2_height, poster2_x, poster2_y, poster_left_width, poster_left_height, poster_right_width, poster_right_height, snap, snap_video, scanlines_srf, crt_scanlines, black_background, posters, posters_alpha, wall

// scaled positioning
posData =  {
    base_width = 1920.0,
    base_height = 1080.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "scale"
    debug = false,
}
scale = Pos(posData)
 
// scaled positioning
posData =  {
    base_width = 1920.0,
    base_height = 1080.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "stretch"
    debug = false,
}
stretch = Pos(posData)
 
beginning_offset_x = 0
beginning_offset_y = 0
   
if (is_vertical())
{
    scale.flip_defaults()
    stretch.flip_defaults()
        
   // beginning_offset_x = 245
    // beginning_offset_y = 0
}


function random(minNum, maxNum) {
    return floor(((rand() % 1000 ) / 1000.0) * (maxNum - (minNum - 1)) + minNum);
}
function randomf(minNum, maxNum) {
    return (((rand() % 1000 ) / 1000.0) * (maxNum - minNum) + minNum).tofloat();
}
function random_file(path) {
	
	local dir = DirectoryListing( path );
	local dir_array = []; 
	foreach ( key, value in dir.results )
	{
	    try
	    {
	        local name = value.slice( path.len() + 1, value.len() );

			// bad mac!
			if (name.find("._") == null)
			{
				dir_array.append(value); 
			}

	    }catch ( e )
	    {
	        // print(  value );
	    }
	}
	return dir_array[random(0, dir_array.len()-1)]; 
}

function file_exists( path )
{
	try{ file(path, "r"); return true;} catch(e){return false;}
}
 
/* 
function set_titles( )
{
	// Title
	local title = fe.add_text("[Title]", scale.x(18), scale.y(18), scale.width(317), scale.height(32));
	title.charsize = 24;
	title.set_rgb(247, 35, 0);
	title.font =  console + "/" + "font"; 
} 
*/ 


screen_x = 450
screen_y = -120
screen_width = 1166
screen_height = 1030
bg_x = 150
bg_y = 400
    
snap_x = 0
snap_y = 0 
snap_w = 640 
snap_h = 480 

cart_x = 69
cart_y = 739 
cart_width=263 
cart_height=50

cart_pinch_x = 0
cart_pinch_y = 0  
cart_preserve_aspect_ratio = true 

boxart_x = 0 
boxart_y = 0 
boxart_width = 281 
boxart_height = 396 

wheel_x = 984 
wheel_y = 941 
wheel_width = 336 
wheel_height = 127 

console_x = 340
console_y = -268
console_width = 705
console_height = 410
   
console_overlay_x = 0
console_overlay_y = 0
console_overlay_width = 200
console_overlay_height = 200
    
controller_x = -110
controller_y = 65
controller_width = 531
controller_height = 185 

switch (prefs.console)
{
	case "Atari 2600":
		cart_pinch_x = -3
		cart_width=173
		cart_height=31 

        //cart_width=263 
		//cart_height=50
		cart_x = -6
		cart_y = -181
            
		cart_preserve_aspect_ratio =  false 
        console_y = -232
        controller_y = 55
		boxart_x = 160 
		boxart_y = 150 
        boxart_width = 281 
        boxart_height = 396 
		prefs.tv = "rabbit_ears"
        poster1="atari_missile_command.jpg"
        poster2="atari2.jpg"    
		break

    case "Intellivision":
        prefs.tv="rabbit_ears"
        poster1="intellivision_heman.jpg"
        poster2="intellivision_tron.jpg"
        console_y= -248
        console_x=  260
        boxart_x = 110
        boxart_y = 140

        cart_width=99 
		cart_height=157
		cart_x = -137
		cart_y = -120
            
		cart_preserve_aspect_ratio =  false 


        break 
            
	case "Nintendo NES":
        console_x = 205
        console_y = -120
                    
		cart_width=263 
		cart_height=50
		cart_x = -45
		cart_y = -19
		cart_preserve_aspect_ratio = false 
		
		boxart_x = 120 
		boxart_y = 140 
        boxart_width = 281 
        boxart_height = 385 

		prefs.tv = "rabbit_ears"
        poster1="nes_mario_bros.jpg"
        poster2="nes_bw.jpg"
		break
		
	case "Nintendo SNES":    
        console_x = 100
        console_y = -100
        
        cart_width=307 
		cart_height=290
		cart_x = 0
		cart_y = -120
		cart_preserve_aspect_ratio = false 

        
        console_overlay_width = 0
        console_overlay_height = 0
        console_overlay_x = 0
        console_overlay_y = 0
            
        controller_y = 25
		boxart_x = 100 
		boxart_y = 140 
        boxart_width = 400 
        boxart_height = 292 
        poster1="snes_super_mario3.jpg"
        poster2="snes_mario_map.jpg"
		prefs.tv = "rabbit_ears"
		break
		
	case "Nintendo 64":
        console_x = 200
        console_y = -100
        
        cart_width=278 
		cart_height=182
		cart_x = 0
		cart_y = -180 
		cart_preserve_aspect_ratio = false 

		boxart_x = 30 
		boxart_y = 200 
        boxart_width = 400 
        boxart_height = 292 

        controller_y = 25
        controller_x = -170    
        poster1="n64_zelda.jpg"
        poster2="n64_007.jpg"
		prefs.tv = "sony"
		break
                        
 	case "Sega Master System":
		cart_width=225 
		cart_height=135
		cart_x = 120
		cart_y = -71 
        
        boxart_x = 160 
		boxart_y = 150 

        console_y = -88
        console_x = 350
        controller_y = 53
		wheel_x = 1068 
		cart_preserve_aspect_ratio = false 
        prefs.tv="rabbit_ears"
        poster1="sms_wonder_boy.jpg"
        poster2="sms_sonic.jpg"
		break 
            
	case "Sega Genesis":
		cart_width=239 
		cart_height=135
		cart_x = 60
		cart_y = -140 
		wheel_x = 1068 

		boxart_x = 140 
		boxart_y = 180 
        
        console_y = -58
        console_x = 210
        controller_y = 3
        controller_x = -180
        cart_preserve_aspect_ratio = false 
        prefs.tv = "sony"
        poster1="genesis_sonic.jpg"
        poster2="genesis_streets_of_rage.jpg"
		break 

    case "Generic TV":
		prefs.tv = "rabbit_ears"
        poster1="movies_terminator.jpg"
        poster2="movies_star_wars.jpg"
		break
		
    case "Generic PC":
		prefs.tv = "pc"
        poster1="movies_terminator.jpg"
        poster2="movies_star_wars.jpg"
		break
            
    case "Sony Playstation":
		cart_width=278 
		cart_height=182
		cart_x = 45
		cart_y = 502 
        
        console_x = 210
        console_y = -50
            
        controller_x = -230
        controller_y = -25
		boxart_x = 100 
		boxart_y = 170 
        boxart_width = 292 
        boxart_height = 292 
	    prefs.tv="sony"
        poster1="playstation_final_fantasy.jpg"
        poster2="playstation_gta.jpg"
		break

	case "ScummVM":
		boxart_x = 0 
		boxart_y = 0 
		
		wheel_x = 1020 
		wheel_y = 951 
		prefs.tv = "pc"
        poster1="scummvm_sam_and_max.jpg"
        poster2="scummvm_monkey_island.jpg"
		break 
	default:
		
} 
    
if (config["selected_tv"] !="Auto")
{
    if (config["selected_tv"]=="Old TV")
    {
        prefs.tv="rabbit_ears"
    }
    if (config["selected_tv"]=="New TV")
    {
        prefs.tv="sony"
    }
    if (config["selected_tv"]=="PC")
    {
        prefs.tv="pc"
    }
}

//tv = "rabbit_ears"   
switch(prefs.tv)
{
    case "rabbit_ears": 
        screen_x = 110
        screen_y = -115
        screen_width = 1166
        screen_height = 1030
        
        bg_x = 245
        bg_y = 295
            
        snap_x = -85
        snap_y = -40
        break
    case "sony":
        screen_x = 11
        screen_y = 32  
        screen_width = 903
        screen_height = 808

        bg_x = 140
        bg_y = 335
            
        snap_x = 20
        snap_y = -80 
        snap_h = 470 
            
        break
    case "pc":
        screen_x = -20
        screen_y = -02
        screen_width = 1222
        screen_height = 1010
        bg_x = 180
        bg_y = 260
        snap_y = 165 
        snap_x = 626    
		snap_w = 610 
		snap_h = 460 
        console_x = 200
        console_y = -550
        break
}


//Background
//images.bg_grid <- fe.add_image("Position Grid Black.jpg", 0, 0, scale.width(1920), scale.height(1080))
images.wall <- fe.add_image("assets/painted_wall_white.jpg",0,0, fe.layout.width, fe.layout.height)
images.wall.set_rgb(19,25,31)//dark-blue
//wall.set_rgb(255,0,0)//red
//wall.set_rgb(179,178,130)//yellow-white

//images.positioning <- fe.add_image("positioning2.jpg", 0, 0, scale.width(1920), scale.height(1080))
//images.positioning.alpha = 255

posters_alpha= 255
if (prefs.posters =="None")
{
    posters_alpha = 0
}
else if (prefs.posters == "Random")
{
    poster1 = random_file(fe.script_dir + "assets/posters")
    poster2 = random_file(fe.script_dir + "assets/posters")
    do {
        poster2 = random_file(fe.script_dir + "assets/posters")
    }
    while(poster2 == poster1)
}
else
{
    poster1 = "assets/posters/" + poster1
    poster2 = "assets/posters/" + poster2
}

images.poster_left <- fe.add_image( poster1)
images.poster_left.alpha = posters_alpha
images.poster_left.mipmap = true
    
poster_left_width = images.poster_left.subimg_width
poster_left_height = images.poster_left.subimg_height

images.poster_right <- fe.add_image( poster2)
images.poster_right.alpha = posters_alpha
images.poster_right.mipmap = true

poster_right_width = images.poster_right.subimg_width
poster_right_height = images.poster_right.subimg_height

images.poster_shadow <- fe.add_image("assets/poster_shadow.png",0,0)
//poster_shadow.alpha = 0

images.bg <- fe.add_image("assets/desk.png",0,0, scale.width(3000), scale.height(2592))
images.bg.mipmap = true
    
black_background = fe.add_text("",0,0,0,0)
black_background.set_bg_rgb(1,1,1)
    
surface.snap <- fe.add_surface(scale.width(snap_w),scale.height(snap_h))

images.screen <- fe.add_image("assets/monitors/"+prefs.tv+".png", scale.x(screen_x),scale.y(screen_y),scale.width(screen_width), scale.height(screen_height))
images.screen.mipmap = true
    
images.controller <- fe.add_image("assets/consoles/"+prefs.console+"/controller.png", scale.x(controller_x),scale.y(controller_y))
images.controller.width = scale.width(images.controller.subimg_width)
images.controller.height = scale.height(images.controller.subimg_height)
images.controller.mipmap = true
        
images.console_image <- fe.add_image("assets/consoles/"+prefs.console+"/console.png", scale.x(console_x),scale.y(console_y))
images.console_image.width=scale.width(images.console_image.subimg_width)
images.console_image.height = scale.height(images.console_image.subimg_height)
images.console_image.mipmap = true
    
///////////////////////////////////////////////////////
//		   CARTRIDGES
///////////////////////////////////////////////////////


artwork.cartridge <- fe.add_artwork(prefs.cartridge_folder, scale.x(cart_x), scale.y(cart_y), scale.width(cart_width), scale.height(cart_height))
artwork.cartridge.preserve_aspect_ratio = true;

if (cart_preserve_aspect_ratio == false)
{
    artwork.cartridge.preserve_aspect_ratio = false;
}
if (cart_pinch_x != 0)
{
    artwork.cartridge.pinch_x = cart_pinch_x; 
}
if (cart_pinch_y != 0)
{
    artwork.cartridge.pinch_y = cart_pinch_y; 
}
artwork.cartridge.trigger = Transition.EndNavigation;

if (prefs.cartridge_folder =="none")
{
    artwork.cartridge.alpha=0
}

if (prefs.console == "Intellivision")
{
    artwork.cartridge2 <- fe.add_artwork(prefs.cartridge_folder, scale.x(cart_x), scale.y(cart_y), scale.width(cart_width), scale.height(cart_height))
}




images.console_overlay <- fe.add_image("assets/consoles/"+prefs.console+"/overlay_mask.png", scale.x(console_overlay_x),scale.y(console_overlay_y))
images.console_overlay.width = scale.width(images.console_overlay.subimg_width)
images.console_overlay.height = scale.height(images.console_overlay.subimg_height)
images.console_overlay.mipmap = true
    
///////////////////////////////////////////////////////
//			BOXART
///////////////////////////////////////////////////////

images.stand <- fe.add_image("assets/stand/stand1/stand.png", 0,0,scale.width(286), scale.height(346) )

surface.boxart_surface <- fe.add_surface(scale.width(boxart_width),scale.height(boxart_height))
artwork.boxart <- surface.boxart_surface.add_artwork(prefs.boxart_folder, 0,0, scale.width(boxart_width),scale.height(boxart_height))
artwork.boxart.trigger = Transition.EndNavigation



///////////////////////////////////////////////////////
//		WHEEL LOGO / TITLES
///////////////////////////////////////////////////////
 
 /*
if ( game_titles == "show wheel images" )
{    
    local wheel_imgs = FadeArt("wheel", 0, 0, scale.width(wheel_width), scale.height(wheel_height),wheel)
    wheel.zorder=20
    wheel.x=scale.x(0,"center",wheel,boxart )
    wheel.y=scale.y(15,"top",wheel,boxart,"bottom" )
}
if (game_titles =="text titles"){
	// Title
	local title = fe.add_text("[Title]", scale.x(1067), scale.y(978), scale.width(244), scale.height(181))
	title.align = Align.Right
	title.charsize = 24
	title.set_rgb(247, 35, 0)
	title.font =  prefs.console + "/" + "font" 
}  
 */ 
 
///////////////////////////////////////////////////////
//			PLAY TIME
///////////////////////////////////////////////////////
 
 /* 
if (show_playtime == "yes")
{
	// Playtime
	local playtime = fe.add_text("[Title] Playcount:[PlayedCount] Time:[PlayedTime]", scale.x(16), scale.y(993), scale.width(700),scale.height(39))
	playtime.align = Align.Left
	playtime.charsize = 20
	playtime.set_rgb(255, 255, 255)
}
*/ 

    
///////////////////////////////////////////////////////
//		SNAP & SNAP OVERLAYS
///////////////////////////////////////////////////////


surface.snap.width=scale.width(snap_w)
surface.snap.height=scale.height(snap_h)
 
surface.snap.x = scale.x(snap_x, "center", surface.snap)
surface.snap.y = scale.y(snap_y, "center", surface.snap)
       
artwork.snap_video <- surface.snap.add_artwork("snap", 0, 0, scale.width(snap_w), scale.height(snap_h))
artwork.snap_video.trigger = Transition.EndNavigation

// snap shader effects  
if ( config["enable_snap_shader"] != "No" && ShadersAvailable == 1)
{
	if ( config["enable_snap_shader"] == "CRT Bloom")
	{
		local sh = fe.add_shader( Shader.Fragment, "shaders/bloom_shader.frag" )
		sh.set_texture_param("bgl_RenderedTexture") 
		surface.snap.shader = sh
	}
	
	if ( config["enable_snap_shader"] == "CRT Lottes")
	{
		local shader_lottes = null
		
		shader_lottes=fe.add_shader(
			Shader.VertexAndFragment,
			"shaders/CRT-geom.vsh",
			"shaders/CRT-geom.fsh")
			
		// APERATURE_TYPE
		// 0 = VGA style shadow mask.
		// 1.0 = Very compressed TV style shadow mask.
		// 2.0 = Aperture-grille.
		shader_lottes.set_param("aperature_type", 1.0)
		shader_lottes.set_param("hardScan", 0.0)   // Hardness of Scanline -8.0 = soft -16.0 = medium
		shader_lottes.set_param("hardPix", -2.0)     // Hardness of pixels in scanline -2.0 = soft, -4.0 = hard
		shader_lottes.set_param("maskDark", 0.9)     // Sets how dark a "dark subpixel" is in the aperture pattern.
		shader_lottes.set_param("maskLight", 0.3)    // Sets how dark a "bright subpixel" is in the aperture pattern
		shader_lottes.set_param("saturation", 1.1)   // 1.0 is normal saturation. Increase as needed.
		shader_lottes.set_param("tint", 0.0)         // 0.0 is 0.0 degrees of Tint. Adjust as needed.
		shader_lottes.set_param("distortion", 0.15)		// 0.0 to 0.2 seems right
		shader_lottes.set_param("cornersize", 0.04)  // 0.0 to 0.1
		shader_lottes.set_param("cornersmooth", 80)  // Reduce jagginess of corners
		shader_lottes.set_texture_param("texture")
		
		artwork.snap_video.shader = shader_lottes
		
		fe.add_transition_callback( "shader_transitions" )
		function shader_transitions( ttype, var, ttime ) {
			switch ( ttype )
			{
			case Transition.ToNewList:	
			case Transition.EndNavigation:
				//artwork.snap_video.width = snap_surface.subimg_width
				//artwork.snap_video.height = snap_surface.subimg_height
				// Play with these settings to get a good final image
				artwork.snap_video.shader.set_param("color_texture_sz", surface.snap.width, surface.snap.height)
				artwork.snap_video.shader.set_param("color_texture_pow2_sz", surface.snap.width, surface.snap.height)
				break
			}
			return false
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Shader - Screen Glow
// check if GLSL shaders are available on this system
if( config["enable_crt_screenglow"] != "No" && ShadersAvailable == 1 )
{
    // shadow parameters
    local shadow_radius = 1600
    local shadow_xoffset = 0
    local shadow_yoffset = 0
    local shadow_alpha = 255
    local shadow_downsample = 0

    if( config["enable_crt_screenglow"] == "Light" )
    {
        shadow_downsample=0.04
        shadow_xoffset = scale.x(300)
        shadow_yoffset = scale.y(300)
    }
    else if( config["enable_crt_screenglow"] == "Medium" )
    {
        shadow_downsample=0.03
        shadow_xoffset = scale.x(200)
        shadow_yoffset = scale.y(250)
    }
    else if( config    ["enable_crt_screenglow"] == "Strong" )
    {
        shadow_downsample=0.02
        shadow_xoffset = scale.x(100)
        shadow_yoffset = scale.y(150)
    }

    // creation of first surface with safeguards area
    local xsurf1 = fe.add_surface (shadow_downsample * (artwork.snap_video.width + 2*shadow_radius), shadow_downsample * (artwork.snap_video.height + 2*shadow_radius))

    // add a clone of the picture to topmost surface
    local pic1 = xsurf1.add_clone(artwork.snap_video)
    pic1.set_pos(shadow_radius*shadow_downsample,shadow_radius*shadow_downsample,artwork.snap_video.width*shadow_downsample,artwork.snap_video.height*shadow_downsample)

    // creation of second surface
    local xsurf2 = fe.add_surface (xsurf1.width, xsurf1.height)

    // nesting of surfaces
    xsurf1.visible = false
    xsurf1 = xsurf2.add_clone(xsurf1)

    xsurf1.visible = true

    // define and apply blur shaders
    local blursizex = 1.0/xsurf2.width
    local blursizey = 1.0/xsurf2.height
    local kernelsize = shadow_downsample * (shadow_radius * 2) + 1
    local kernelsigma = shadow_downsample * shadow_radius * 0.3

    local shaderH1 = fe.add_shader( Shader.Fragment, fe.script_dir + "gauss_kernsigma_o.glsl" )
    shaderH1.set_texture_param( "texture")
    shaderH1.set_param("kernelData", kernelsize, kernelsigma)
    shaderH1.set_param("offsetFactor", blursizex, 0.0)
    xsurf1.shader = shaderH1

    local shaderV1 = fe.add_shader( Shader.Fragment, fe.script_dir + "gauss_kernsigma_o.glsl" )
    shaderV1.set_texture_param( "texture")
    shaderV1.set_param("kernelData", kernelsize, kernelsigma)
    shaderV1.set_param("offsetFactor", 0.0, blursizey)
    xsurf2.shader = shaderV1

    // apply black color and alpha channel to shadow
    pic1.alpha=shadow_alpha
    pic1.width=21
    pic1.height=16

    // reposition and upsample shadow surface stack
    xsurf2.set_pos (artwork.snap_video.x-shadow_radius+shadow_xoffset,artwork.snap_video.y-shadow_radius+shadow_yoffset, artwork.snap_video.width + 2 * shadow_radius , artwork.snap_video.height + 2 * shadow_radius)
}

 
// scanline default
if (config["enable_crt_scanline"] != "No")
{
    local scan_art

    scanlines_srf = fe.add_surface( fe.layout.width, fe.layout.height )
    scanlines_srf.set_pos( 0,0 )
    scanlines_srf.zorder=4
        
    if( ScreenWidth < 1920 )
    {
        scan_art = fe.script_dir + "scanlines_640.png"
    }
    else  // 1920 res or higher
    {
        scan_art = fe.script_dir + "scanlines_1920.png"
    }
    crt_scanlines = scanlines_srf.add_image( scan_art, surface.snap.x, surface.snap.y, surface.snap.width, surface.snap.height )
    crt_scanlines.preserve_aspect_ratio = false

    if( config["enable_crt_scanline"] == "Light" )
    {
        if( ScreenWidth < 1920 )
            crt_scanlines.alpha = 20
        else
            crt_scanlines.alpha = 50
    }
    if( config["enable_crt_scanline"] == "Medium" )
    {
        if( ScreenWidth < 1920 )
            crt_scanlines.alpha = 40
        else
            crt_scanlines.alpha = 100
    }
    if( config["enable_crt_scanline"] == "Dark" )
    {
        crt_scanlines.alpha = 200
    }
}
function set_crt_size()
{
    if (config["enable_crt_scanline"] != "No")
    {
        crt_scanlines.width = surface.snap.width
        crt_scanlines.height =surface.snap.height  
        crt_scanlines.x = surface.snap.x
        crt_scanlines.y = surface.snap.y
    }
}


set_crt_size()

images.poster_shadow.width = fe.layout.width
images.poster_shadow.height = scale.height(images.poster_shadow.subimg_height)

images.screen.x = scale.x(screen_x,"center",images.screen,surface.snap,"center")
images.screen.y = scale.y(screen_y,"center",images.screen,surface.snap,"center")

black_background.x = surface.snap.x
black_background.y = surface.snap.y
black_background.width = surface.snap.width
black_background.height = surface.snap.height

images.bg.x = scale.x(bg_x,"center",images.bg,surface.snap,"center")
images.bg.y = scale.y(bg_y,"center",images.bg,surface.snap,"center")

images.console_image.x=scale.x(console_x,"right",images.console_image,surface.snap,"left")
images.console_image.y=scale.y(console_y,"top",images.console_image,surface.snap,"bottom")

images.console_overlay.x = scale.x(console_overlay_x, "center", images.console_overlay, images.console_image, "center")
images.console_overlay.y = scale.y(console_overlay_y, "center", images.console_overlay, images.console_image, "center")
    
images.controller.x=scale.x(controller_x,"left",images.controller,images.console_image,"right")
images.controller.y=scale.y(controller_y,"center",images.controller,images.console_image,"center")

artwork.cartridge.x = scale.x(cart_x,"center",artwork.cartridge, images.console_image,"center" )
artwork.cartridge.y = scale.y(cart_y,"center",artwork.cartridge, images.console_image,"center" )
if (prefs.console == "Intellivision")
{
    artwork.cartridge2.x = scale.x(cart_x +264,"center",artwork.cartridge, images.console_image,"center" )
    artwork.cartridge2.y = scale.y(cart_y,"center",artwork.cartridge, images.console_image,"center" )
}   
images.poster_left.width=scale.width(poster_left_width.tofloat())
images.poster_left.height=scale.height(poster_left_height.tofloat())
    
images.poster_right.width=scale.width(poster_right_width)
images.poster_right.height = scale.height(poster_right_height)
                                
images.poster_left.x=scale.x(-75,"right",images.poster_left,null,"center")
images.poster_left.y=scale.y(-380,"bottom",images.poster_left)

images.poster_right.x=scale.x(75,"left",images.poster_right, images.poster_left,"right")
images.poster_right.y=scale.y(0,"bottom",images.poster_right, images.poster_left,"bottom")


images.rough_box <- surface.boxart_surface.add_image("assets/stand/stand1/rough_box.png", 0,0,scale.width(362),scale.height(372))

local ds 

surface.boxart_surface.x = scale.x(boxart_x, "left", surface.boxart_surface, surface.snap, "right")
surface.boxart_surface.y = scale.y(boxart_y, "bottom", surface.boxart_surface, surface.snap, "bottom")

artwork.boxart.x = 0
artwork.boxart.y = 0

surface.boxart_surface.pinch_x = -10
surface.boxart_surface.skew_x = -1

ds = DropShadow( surface.boxart_surface, 62, scale.x(0), scale.y(-25), 220 )
artwork.boxart.zorder = artwork.boxart.zorder -2


images.rough_box.x = scale.x(0,"middle",images.rough_box, surface.boxart_surface,"middle")
images.rough_box.y = scale.y(0,"middle", images.rough_box, surface.boxart_surface, "middle")
images.rough_box.blend_mode = BlendMode.Multiply 
             
/*
function boxart_transition( ttype, var, ttime )
{
    if ( ttype == Transition.FromOldSelection)
    {
        boxart_rendered = false
        //return false
    }
    if (  ttype == Transition.EndNavigation || ttype== Transition.ToNewList )
    {
        if (boxart_rendered == false)
        {
                
            boxart_rendered = true
            return true
        }
        return false
    }
    return false;
}
fe.add_transition_callback( "boxart_transition" );
*/ 

images.stand_overlay <- fe.add_image("assets/stand/stand1/overlay_mask.png", 0,0,scale.width(286), scale.height(346) )

images.stand.x = images.stand_overlay.x = scale.x(0,"middle",images.stand,surface.boxart_surface,"middle")
images.stand.y = images.stand_overlay.y = scale.y(80,"bottom",images.stand,surface.boxart_surface,"bottom")                

function game_details_text(){
    local game_details_text = ""
    
    if( fe.game_info( Info.Year )!="" &&  fe.game_info( Info.Category )!="" )
    {
        game_details_text = fe.game_info( Info.Year ) + " - " + fe.game_info( Info.Category )
    }
    else if (fe.game_info( Info.Category )!=""){
        game_details_text = fe.game_info( Info.Category )
    }
    else
    {
        game_details_text = fe.game_info( Info.Year )
    }   
    
    return fe.game_info( Info.Name) + " " + game_details_text
}


local game_details = fe.add_text( "[!game_details_text]", scale.x(24), scale.y(594), scale.width(670), scale.height(20) )	
game_details.alpha = 120
scale.set_font_height(24,game_details, "Left")
game_details.y  = scale.y(-20, "bottom", game_details)
