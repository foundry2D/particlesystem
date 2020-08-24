#version 450

#ifdef GL_ES
precision mediump float;
#endif

in vec4 gl_FragCoord;

uniform vec2 u_resolution;
// uniform vec2 u_mouse;
uniform float u_time;

uniform float u_red;
uniform float u_green;
uniform float u_blue;

uniform float u_lifetime;
uniform vec2 u_velocity;
uniform int u_particleShape;// Triangle = 0; Rect = 1; Circle = 2;
uniform int u_emissionRotation;
uniform vec2 u_sizeRange;
uniform vec2 u_transparencyRange;

// uniform int u_particleAmount;
const int particleMax = 1024;
uniform float  u_particles[particleMax];

out vec4 fragColor;

const float PHI = 1.61803398874989484820459; // Φ = Golden Ratio 

float rand(vec2 xy,float seed)
{
    return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}

float randRange(int mini, int maxi){
	
	return mod(round(rand(gl_FragCoord.xy / u_resolution.xy,u_time)),maxi-mini) + mini;
}

float Band(float t, float start, float end, float blur){
	float sStep = smoothstep(start - blur,start + blur,t);
	float eStep = smoothstep(end+blur, end - blur,t); 
	return  sStep * eStep; 

}

float Circle(vec2 uv, vec2 pos,float radius, float blur ){
	float d = length(uv-pos);
	return smoothstep(radius,radius-blur,d);

}

float Rect(vec2 uv, vec2 pos, float size, float blur){
	float band1 = Band(uv.x,pos.x,pos.x+size,blur);
	float band2 = Band(uv.y,pos.y,pos.y+size,blur);

	return band2 * band1;
}

// barycentric method
float Triangle(vec2 uv, vec2 p0, vec2 p1,vec2 p2){
	float s = p0.y * p2.x - p0.x * p2.y + (p2.y - p0.y) * uv.x + (p0.x - p2.x) * uv.y;
    float t = p0.x * p1.y - p0.y * p1.x + (p0.y - p1.y) * uv.x + (p1.x - p0.x) * uv.y;
	if(s < 0 != t < 0){
		return .0;
	}
	 float A = -p1.y * p2.x + p0.y * (p2.x - p1.x) + p0.x * (p1.y - p2.y) + p1.x * p2.y;;
	 if(A < 0 && s <= 0 && s + t >= A){
		 return 1.;
	 }
	 else if(s >= 0 && s + t <= A){
		 return 1.;
	 }
	 return .0;
}
float Tri(vec2 uv, vec2 pos, float size){
	vec2 right = pos;
	right.x += size;
	vec2 top = pos;
	top.x += size * 0.5;
	top.y += - size;
	return Triangle(uv,pos,right,top);
}

void main(){
	vec2 uv = gl_FragCoord.xy / u_resolution.xy;


	uv -= .5;
	uv.x *= u_resolution.x / u_resolution.y;
	
	float delta = u_time / u_lifetime;
	vec2 dir = u_velocity * delta;

	if(u_particles.length() > 0)
		dir += rand(uv,u_particles[0]);
	vec3 col = vec3(u_red,u_green,u_blue)*Tri(uv,dir,.07);
	for(int i = 0; i < u_particles.length();i++){
		// if(u_particles[i] < u_lifetime){
		// 	// dir += rand(uv,i);
		// 	col *= Tri(uv,dir,.07);
		// }
	}
		
	fragColor = vec4(col, 1.0);
}