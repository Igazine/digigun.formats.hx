package digigun.formats.image;

/**
 * Identifies a graphics API family that may consume image or texture data.
 */
enum abstract GraphicsApi(String) from String to String {
  /** Desktop OpenGL and OpenGL ES style upload targets. */
  var OpenGL = "opengl";

  /** WebGL style upload targets. */
  var WebGL = "webgl";

  /** Vulkan style upload targets. */
  var Vulkan = "vulkan";

  /** Apple Metal style upload targets. */
  var Metal = "metal";

  /** Direct3D 11 style upload targets. */
  var Direct3D11 = "d3d11";
}
