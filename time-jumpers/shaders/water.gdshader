shader_type spatial;

// from https://www.shadertoy.com/view/M3lXRM
varying vec3 vert;
varying vec3 normal;

void vertex() 
{
	vert = VERTEX;
	normal = abs(NORMAL);
}


vec3 hash3( vec3  p ) 
{ 
	p = vec3( dot(p,vec3(127.1,311.7, 152.4)), 
			  dot(p,vec3(269.5,183.3, 389.5)), 
			  dot(p,vec3(369.5,283.3, 184.6)) ); 
	return fract(sin(p)*43758.5453); 
}

// The parameter w controls the smoothness
float voronoi( in vec3 x, float w, float offset)
{
	vec3 n = floor( x );
	vec3 f = fract( x );

	float m = 8.0;
	for( int k=-2; k<=2; k++ )
	for( int j=-2; j<=2; j++ )
	for( int i=-2; i<=2; i++ )
	{
		vec3 g = vec3( float(i),float(j), float(k) );
		vec3 o = hash3( n + g );

		// animate
		o = offset + 0.3*sin(0.2 * TIME + 6.2831*o + x);

		// distance to cell
		float d = length(g - f + o);

		// do the smooth min for colors and distances
		float h = clamp( 0.5+0.5*(m-d)/w, 0.0, 1.0 );
		m = mix( m, d, h ) - h*(1.0-h)*w;
	}

	return m;
}


void fragment()
{
	float s = 15.0;
	vec3 uv = 0.5 * round(vert * s) / s;
	vec4 color = vec4(0.0);

	uv = uv * 2.0;
	// Moves the canvas diagonally
	uv.x += TIME * .15;
	uv.y += TIME * .125;
	uv.z += TIME * .125;

	//My color pallete
	vec4 a = vec4(0.0,205.0/255.0,249.0/255.0,1.0);
	vec4 b = vec4(1.000,1.000,1.000,1.0);
	vec4 c = vec4(0.0,57.0/255.0,109.0/255.0,0.8);

	//My first Top Voronoi Noise
	float vNoise = voronoi(uv, 0.001, 0.5);
	float sNoise = voronoi(uv, 0.4, 0.5);
	float fVoronoi =  smoothstep(0.0, 0.01, vNoise-sNoise-0.055);

	// My Second Offset Voronoi Noise
	float vNoise2 = voronoi(uv, 0.001, 0.3);
	float sNoise2 = voronoi(uv, 0.4, 0.3);
	float offsetVoronoi = smoothstep(0.0, 0.01, vNoise2-sNoise2-0.055);

	vec4 bgColor = mix(a,c,offsetVoronoi); // assigns to the offsetVoronoi noise the 2 colors

	// Final Voronoi Noise
	vec4 finalVoronoi = vec4(mix(bgColor, b, fVoronoi));

	ALBEDO = finalVoronoi.rgb;
	ALPHA = finalVoronoi.a;
}