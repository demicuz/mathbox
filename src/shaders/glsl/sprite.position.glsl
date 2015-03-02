uniform vec2 spriteOffset;
uniform float spriteScale;
uniform float spriteDepth;
uniform float spriteSnap;

uniform vec2 renderOdd;
uniform float renderScale;
uniform float renderScaleInv;
uniform float pixelUnit;

attribute vec4 position4;
attribute vec2 sprite;

varying vec2 vSprite;
varying float vPixelSize;

// External
vec3 getPosition(vec4 xyzw);
vec4 getSprite(vec4 xyzw);

vec3 getSpritePosition() {
  vec3 center = getPosition(position4);
  vec4 atlas = getSprite(position4);

  // Sprite goes from -1..1, width = 2.
  // -1..1 -> -0.5..0.5
  vec2 halfSprite = sprite * .5;
  vec2 halfFlipSprite = vec2(halfSprite.x, -halfSprite.y);

  // Assign UVs
  vSprite = atlas.xy + atlas.zw * (halfFlipSprite + .5);

  // Depth blending
  // TODO: orthographic camera
  // Workaround: set depth = 0
  float z = -center.z;
  float depth = mix(z, 1.0, spriteDepth);
  
  // Match device/unit mapping 
  float size = pixelUnit * spriteScale;
  float depthSize = depth * size;

  // Calculate pixelSize for anti-aliasing
  float pixelSize = (spriteDepth > 0.0 ? depthSize / z : size);
  vPixelSize = pixelSize;

  // Position sprite
  vec2 atlasOdd = fract(atlas.zw / 2.0);
  vec2 offset = (spriteOffset + halfSprite * atlas.zw) * depthSize;
  if (spriteSnap > 0.5) {
    // Snap to pixel
    return vec3(((floor(center.xy / center.z * renderScale) + renderOdd + atlasOdd) * center.z + offset) * renderScaleInv, center.z);
  }
  else {
    // Place directly
    return center + vec3(offset * renderScaleInv, 0.0);
  }

}
