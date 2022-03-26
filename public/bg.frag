#ifdef GL_ES
precision mediump float;
#endif
uniform mediump vec2 uResolution;
uniform float uTime;

float rand(vec2 st){
	return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float rand (in float x) {
    return fract(sin(x)*1e4);
}

float noise(float x){
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0*f); 
    return mix(rand(i),rand(i+1.0),u);
}

float cloud(vec2 st){
  float top = 0.5*noise(abs(sin(uTime*0.5))*st.x*st.y)+0.2;
  float seed = smoothstep(top,0.0,abs(st.x-st.y));
  float color = 0.3 + noise(uTime)*noise(st.x)*0.3 ;
  return noise(seed)*color;
}

void main(){
  vec3 color0 = vec3(0.125,0.102,0.161); 
  vec3 color1 = vec3(0.125,0.350,0.662); 
  vec3 color2 = vec3(0.905,0.772,0.392); 
  vec3 color3 = vec3(0.00,0.40,0.60);    
  
  float scale = uResolution.x/uResolution.y;
  vec2 st = gl_FragCoord.xy/uResolution.xy;
  
  vec3 blend = mix(color1,color0,st.y*1.2) + color3*cloud(st); 
  
  float divide = noise(st.x*5.0)*0.1 + 0.2;
  float st2 = smoothstep(divide,divide-0.3,st.y); 
  vec3 blend3 = mix(blend,color2,st2);

  float mountain_gap = scale * 10.0;
  float mountain = smoothstep(st.y+0.005,st.y,noise(st.x*mountain_gap)*0.15+0.01);
  
  float star_scale = 500.0 ; // 星星大小
  vec2 st_star = floor(st * vec2(scale,1.0) * star_scale);
  float star_seed = 0.1 * smoothstep(0.4*star_scale,0.0,abs(st_star.x-st_star.y*scale)) + 0.01;
  float stars = step(rand(st_star),star_seed);
  float anim_stars = stars*noise(uTime*sin(rand(st_star.x))*cos(rand(st_star.y))*3.0);
    
  gl_FragColor = vec4((blend3+anim_stars*0.8)*mountain,1.0);
}