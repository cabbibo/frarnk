#define SONGS 7

uniform float time;
uniform sampler2D t_audio;
uniform vec4 links[SONGS];
uniform vec4 activeLink;
uniform vec4 hoveredLink;

uniform sampler2D t_matcap;
uniform sampler2D t_normal;
uniform sampler2D t_text;
uniform float textRatio;
uniform float interfaceRadius;

uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

uniform float songVal;

varying vec3 vPos;
varying vec3 vCam;
varying vec3 vNorm;

varying vec3 vMNorm;
varying vec3 vMPos;

varying vec2 vUv;

vec3 bulbPos[5];


$uvNormalMap
$semLookup
$hsv


// Branch Code stolen from : https://www.shadertoy.com/view/ltlSRl
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float MAX_TRACE_DISTANCE = 6.0;             // max trace distance
const float INTERSECTION_PRECISION = 0.01;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 10;
const float PI = 3.14159;

const vec3 moonPos = vec3( -3. , 3. , -3.);



$smoothU
$opU
$sdCapsule
$sdBox
$sdSphere
$sdHexPrism
$triNoise3D




// from  https://www.shadertoy.com/view/XtjSDK
vec3 mapP( vec3 p )
{

    vec4 grow = vec4( sin(time) , sin(time),sin(time) ,sin(time)) + vec4(1.,1.,1.,1.);
    grow *= .2 + .3 * sin(time*.3);
    p.xyz += .400*sin(   (.4) * 1.*p.yzx )*grow.x;
    p.xyz += 0.300*sin(  (.4) * 2.0*p.yzx )*grow.y;
    p.xyz += 0.250*sin(  (.4) * 4.0*p.yzx )*grow.z;
    p.xyz += 0.100*sin(  (.4) * 5.0*p.yzx )*grow.w;
    return p;
}



float centerBlob1( vec3 pos  ){

  //pos.x += .1 * sin( pos.x * 20. );
  //pos.y += .1 * sin( pos.y * 20. );
  //pos.z += .1 * sin( pos.z * 20. );

  float dis = length( texture2D( t_audio , vec2( mod(length( pos ) *1.,.5) , 0.) ) );

  float b = sdSphere( pos , .3 );
 
  return  b - dis * .1 * ((songVal / float(SONGS))*3.+1.);


}



float centerBlob2( vec3 pos  ){

  float m = 100000.;

  float dis = length( texture2D( t_audio , vec2( abs(sin(length( pos ) * 2.)), 0.) ) );

  for( int i = 0; i < 5; i++ ){

    float d = sdSphere( pos - bulbPos[i], .2 + dis * .1 );

    m = smoothU( vec2( m , 0. ) , vec2( d , 0. ) , .2 ).x;

  }
 
  return  m; //b - dis * .2;
}

float centerBlob3( vec3 pos  ){

  float dis = length( texture2D( t_audio , vec2( abs(sin(length( pos ) * 2.)), 0.) ) );

  float d = sdHexPrism( pos , vec2( .2 + dis * .1 , 1. + dis * .1  )) ;

 
  return  d; //b - dis * .2;
}

//--------------------------------
// Modelling 
//--------------------------------
vec2 map( vec3 pos ){  

    vec3 og = pos;

    vec2 res = vec2( 1000000. , 0. );



    pos = mapP( pos );
    res = vec2(sdCapsule( pos , vec3( -.5 , -1. , 0. ), vec3( -.5 , 2.,0.), .3 ),1.);
    res = smoothU( res , vec2(sdCapsule( pos , vec3( -.5 , 0.5 , 0. ), vec3( 1. , 0.5,0.), .3 ),1.), .1);
    res = smoothU( res , vec2(sdCapsule( pos , vec3( -.5 ,2., 0. ), vec3( 1. , 2.,0.), .3 ),1.), .1);

    res += .2 * triNoise3D( pos * .8, 1. , time );
    res -= .4 * triNoise3D( pos * .2, 1. , time );
    res -= .1 * triNoise3D( pos * 2.2, 1. , time );



    res = opU( res , vec2(sdCapsule( pos , vec3( -1.2 ,3., 0. ), vec3( 1. , 0.,0.), .1 ),10.));
    res = opU( res , vec2(sdCapsule( pos , vec3( -1.2 ,2., 0. ), vec3( 1. , -1.,0.), .1 ),10.));
    res = opU( res , vec2(sdCapsule( pos , vec3( -1.2 ,1., 0. ), vec3( 1. , -2.,0.), .1 ),10.));

    return res;
    
}


$calcIntersection
$calcNormal
$calcAO




void main(){



  vec3 fNorm = uvNormalMap( t_normal , vPos , vUv , vNorm , 10.6 , .5 * songVal / float(SONGS)  );

  vec3 ro = vPos;
  vec3 rd = normalize( vPos - vCam );

  vec3 p = vec3( 0. );
  vec3 col =  vec3( 0. );

  float m = max(0.,dot( -rd , fNorm ));

  //col += fNorm * .5 + .5;

  vec3 refr = refract( rd , fNorm , .8 ) ;

  vec2 res = calcIntersection( ro , refr );

  if( res.y > -.5 ){

    p = ro + refr * res.x;
    vec3 n = calcNormal( p );


    vec3 mat = texture2D( t_matcap , semLookup( refr , n , modelViewMatrix , normalMatrix ) ).xyz;

    col += hsv( dot( rd , n ) * .4  , 1. , 1. );//n * .5 + .5;
    col += hsv( res.y * 10. , 1. , 1.);
    col *= 1. * mat;

  

    vec3 aCol = texture2D( t_audio , vec2( dot( -n , rd ) , 0.) ).xyz;

    col *= aCol + .5;
    col *= (res.y-.8) * 10.;
    //col -= texture2D( t_audio , vec2(  abs( n.x ) , 0. ) ).xyz;


  }else{
    discard;
  }





  gl_FragColor = vec4( col , 1. );

}

















