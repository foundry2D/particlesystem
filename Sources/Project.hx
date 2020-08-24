package;

import kha.arrays.Float32Array;
import kha.graphics4.TextureUnit;
import kha.Framebuffer;
import kha.Color;
import kha.Assets;
import kha.Scheduler;
import kha.Scaler;
import kha.Shaders;
import kha.System;
import kha.Image;
import kha.input.Mouse;
import kha.math.FastVector2;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import kha.graphics2.Graphics;

import zui.Zui;
import zui.Id;

class Project {
	var backbuffer:Image;
	var pipeline:PipelineState;

	var resolution:FastVector2;
	var mouse:FastVector2;

	var resolutionID:ConstantLocation;
	var mouseID:ConstantLocation;
	var timeID:ConstantLocation;

	var ui:Zui;

	var velocity:FastVector2;

	final maxParticles:Int;
	var particles:Float32Array;
	var particleAmount:Int;

	var red:Float;
	var green:Float;
	var blue:Float;

	var lifetimeID:ConstantLocation;
	var velocityID:ConstantLocation;
	
	var particlesID:ConstantLocation;
	var particleAmountID:ConstantLocation;

	var redID:ConstantLocation;
	var greenID:ConstantLocation;
	var blueID:ConstantLocation;

	public function new(){
		backbuffer = Image.createRenderTarget(Main.WIDTH, Main.HEIGHT);

		ui = new Zui({font: kha.Assets.fonts.font_default});

		setupShader();

		resolution = new FastVector2(Main.WIDTH, Main.HEIGHT);
		velocity = new FastVector2(0.0,-10.0);
		mouse = new FastVector2();

		particleAmount = 1;
		maxParticles = 1024;
		particles = new Float32Array(maxParticles);
		
		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
	}

	var lastTime:Float;
	var dt:Float;
	public function update():Void {
		dt = Scheduler.realTime() - lastTime;
		lastTime = Scheduler.realTime();
		timeCount += dt;
		for(i in 0...particleAmount){
			particles[i] +=dt; 
		}
		if(timeCount > lifetimeHandle.value){
			timeCount = 0.0;
		}
	}

	var timeCount:Float;
	public function render(framebuffer:Framebuffer):Void {
		
		backbuffer.g4.begin();
		backbuffer.g4.setPipeline(pipeline);
		
		backbuffer.g4.setVector2(resolutionID, resolution);
		backbuffer.g4.setVector2(mouseID, mouse);		

		backbuffer.g4.setFloat(timeID, timeCount);


		backbuffer.g4.setInt(particleAmountID,particleAmount);
		backbuffer.g4.setFloats(particlesID,particles);
		
		if(lifetimeHandle.changed){
			backbuffer.g4.setFloat(lifetimeID, lifetimeHandle.value);
		}

		if(velocityChanged){
			backbuffer.g4.setVector2(velocityID, velocity);
		}

		backbuffer.g4.setFloat(redID, red);
		backbuffer.g4.setFloat(greenID, green);
		backbuffer.g4.setFloat(blueID, blue);
		backbuffer.g4.end();


		backbuffer.g2.begin();
		backbuffer.g2.pipeline = pipeline;
		backbuffer.g2.fillRect(0, 0, Main.WIDTH, Main.HEIGHT);
		backbuffer.g2.end();
		

		framebuffer.g2.begin();
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();

		gui(framebuffer.g2);
	}

	public function onMouseDown(button:Int, x:Int, y:Int):Void {
		mouse.x = x;
		mouse.y = y;
	}

	public function onMouseUp(button:Int, x:Int, y:Int):Void {
		mouse.x = x;
		mouse.y = y;
	}

	public function onMouseMove(x:Int, y:Int, mx:Int, my:Int):Void {
		mouse.x = x;
		mouse.y = y;
	}

	function setupShader(){
		pipeline = new PipelineState();
		pipeline.vertexShader = Shaders.painter_colored_vert;
		pipeline.fragmentShader = Shaders.shaderTest_frag;

		var structure = new VertexStructure();
		structure.add('vertexPosition', VertexData.Float3);
		structure.add('vertexColor', VertexData.Float4);

		pipeline.inputLayout = [structure];

		pipeline.compile();

		resolutionID = pipeline.getConstantLocation('u_resolution');
		mouseID = pipeline.getConstantLocation('u_mouse');
		timeID = pipeline.getConstantLocation('u_time');

		lifetimeID = pipeline.getConstantLocation('u_lifetime');
		velocityID = pipeline.getConstantLocation('u_velocity');

		particlesID = pipeline.getConstantLocation("u_particles");
		particleAmountID = pipeline.getConstantLocation("u_particleAmount");

		redID = pipeline.getConstantLocation('u_red');
		greenID = pipeline.getConstantLocation('u_green');
		blueID = pipeline.getConstantLocation('u_blue');
	}

	var lifetimeHandle = Id.handle({value:1.0});
	var velocityChanged:Bool = true;
	public function gui(graphics:Graphics){
		ui.begin(graphics);
		if (ui.window(Id.handle(), 0, 0, 128, 512,true)){
			if (ui.panel(Id.handle({selected: true}), 'controls')){
				red = ui.slider(Id.handle({value: 1.0}), 'red', 0, 1, true, 100);
				green = ui.slider(Id.handle(), 'green', 0, 1, true, 100);
				blue = ui.slider(Id.handle(), 'blue', 0, 1, true, 100);
				ui.slider(lifetimeHandle,"lifetime",0.0,100,true);
				var velXH = Id.handle({value: velocity.x});
				var velYH = Id.handle({value: velocity.y});
				ui.text("Velocity:");
				ui.row([0.5,0.5]);
				velocity.x = ui.slider(velXH,"X",-10.0,10.0,true,1/10)/10;
				velocity.y = ui.slider(velYH,"Y",-10.0,10.0,true,1/10)/10;
				velocityChanged = velXH.changed || velYH.changed;
			}
		}
		ui.end();
	}
}