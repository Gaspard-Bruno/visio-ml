extension Operation {

  static var validCombinations: [[Operation]] {[
    [.flip],
    [.scale],
    [.rotate],
    [.background],
    [.blur],
    [.monochrome],
    [.emboss],
    [.noise],
    [.crop],
    [.cutout],
    [.flip, .scale, .rotate, .monochrome, .background, .noise],
    [.flip, .scale, .rotate, .blur, .background, .noise],
    [.flip, .scale, .rotate, .emboss, .background, .noise],
    [.flip, .scale, .rotate, .monochrome, .background],
    [.flip, .scale, .rotate, .blur, .background],
    [.flip, .scale, .rotate, .emboss, .background],
    [.flip, .scale, .rotate, .monochrome, .noise],
    [.flip, .scale, .rotate, .blur, .noise],
    [.flip, .scale, .rotate, .emboss, .noise],
    [.flip, .scale, .rotate, .monochrome],
    [.flip, .scale, .rotate, .blur],
    [.scale, .rotate, .emboss],
    [.scale, .rotate, .monochrome, .background, .noise],
    [.scale, .rotate, .blur, .background, .noise],
    [.scale, .rotate, .emboss, .background, .noise],
    [.scale, .rotate, .monochrome, .background],
    [.scale, .rotate, .blur, .background],
    [.scale, .rotate, .emboss, .background],
    [.scale, .rotate, .monochrome, .noise],
    [.scale, .rotate, .blur, .noise],
    [.scale, .rotate, .emboss, .noise],
    [.scale, .rotate, .monochrome],
    [.scale, .rotate, .blur],
    [.scale, .rotate, .emboss],
    [.flip, .rotate, .monochrome, .background, .noise],
    [.flip, .rotate, .blur, .background, .noise],
    [.flip, .rotate, .emboss, .background, .noise],
    [.flip, .rotate, .monochrome, .background],
    [.flip, .rotate, .blur, .background],
    [.flip, .rotate, .emboss, .background],
    [.flip, .rotate, .monochrome, .noise],
    [.flip, .rotate, .blur, .noise],
    [.flip, .rotate, .emboss, .noise],
    [.flip, .rotate, .monochrome],
    [.flip, .rotate, .blur],
    [.rotate, .emboss],
    [.rotate, .monochrome, .background, .noise],
    [.rotate, .blur, .background, .noise],
    [.rotate, .emboss, .background, .noise],
    [.rotate, .monochrome, .background],
    [.rotate, .blur, .background],
    [.rotate, .emboss, .background],
    [.rotate, .monochrome, .noise],
    [.rotate, .blur, .noise],
    [.rotate, .emboss, .noise],
    [.rotate, .monochrome],
    [.rotate, .blur],
    [.rotate, .emboss],
    [.flip, .scale, .monochrome, .background, .noise],
    [.flip, .scale, .blur, .background, .noise],
    [.flip, .scale, .emboss, .background, .noise],
    [.flip, .scale, .monochrome, .background],
    [.flip, .scale, .blur, .background],
    [.flip, .scale, .emboss, .background],
    [.flip, .scale, .monochrome, .noise],
    [.flip, .scale, .blur, .noise],
    [.flip, .scale, .emboss, .noise],
    [.flip, .scale, .monochrome],
    [.flip, .scale, .blur],
    [.scale, .emboss],
    [.scale, .monochrome, .background, .noise],
    [.scale, .blur, .background, .noise],
    [.scale, .emboss, .background, .noise],
    [.scale, .monochrome, .background],
    [.scale, .blur, .background],
    [.scale, .emboss, .background],
    [.scale, .monochrome, .noise],
    [.scale, .blur, .noise],
    [.scale, .emboss, .noise],
    [.scale, .monochrome],
    [.scale, .blur],
    [.scale, .emboss],
    [.flip, .monochrome, .background, .noise],
    [.flip, .blur, .background, .noise],
    [.flip, .emboss, .background, .noise],
    [.flip, .monochrome, .background],
    [.flip, .blur, .background],
    [.flip, .emboss, .background],
    [.flip, .monochrome, .noise],
    [.flip, .blur, .noise],
    [.flip, .emboss, .noise],
    [.flip, .monochrome],
    [.flip, .blur],
    [.rotate, .emboss],
    [.rotate, .monochrome, .background, .noise],
    [.rotate, .blur, .background, .noise],
    [.rotate, .emboss, .background, .noise],
    [.rotate, .monochrome, .background],
    [.rotate, .blur, .background],
    [.rotate, .emboss, .background],
    [.rotate, .monochrome, .noise],
    [.rotate, .blur, .noise],
    [.rotate, .emboss, .noise],
    [.rotate, .monochrome],
    [.rotate, .blur],
    [.rotate, .emboss],
    [.flip, .scale, .rotate, .monochrome, .background, .noise, .crop],
    [.flip, .scale, .rotate, .blur, .background, .noise, .crop],
    [.flip, .scale, .rotate, .emboss, .background, .noise, .crop],
    [.flip, .scale, .rotate, .monochrome, .background, .crop],
    [.flip, .scale, .rotate, .blur, .background, .crop],
    [.flip, .scale, .rotate, .emboss, .background, .crop],
    [.flip, .scale, .rotate, .monochrome, .noise, .crop],
    [.flip, .scale, .rotate, .blur, .noise, .crop],
    [.flip, .scale, .rotate, .emboss, .noise, .crop],
    [.flip, .scale, .rotate, .monochrome, .crop],
    [.flip, .scale, .rotate, .blur, .crop],
    [.scale, .rotate, .emboss, .crop],
    [.scale, .rotate, .monochrome, .background, .noise, .crop],
    [.scale, .rotate, .blur, .background, .noise, .crop],
    [.scale, .rotate, .emboss, .background, .noise, .crop],
    [.scale, .rotate, .monochrome, .background, .crop],
    [.scale, .rotate, .blur, .background, .crop],
    [.scale, .rotate, .emboss, .background, .crop],
    [.scale, .rotate, .monochrome, .noise, .crop],
    [.scale, .rotate, .blur, .noise, .crop],
    [.scale, .rotate, .emboss, .noise, .crop],
    [.scale, .rotate, .monochrome, .crop],
    [.scale, .rotate, .blur, .crop],
    [.scale, .rotate, .emboss, .crop],
    [.flip, .rotate, .monochrome, .background, .noise, .crop],
    [.flip, .rotate, .blur, .background, .noise, .crop],
    [.flip, .rotate, .emboss, .background, .noise, .crop],
    [.flip, .rotate, .monochrome, .background, .crop],
    [.flip, .rotate, .blur, .background, .crop],
    [.flip, .rotate, .emboss, .background, .crop],
    [.flip, .rotate, .monochrome, .noise, .crop],
    [.flip, .rotate, .blur, .noise, .crop],
    [.flip, .rotate, .emboss, .noise, .crop],
    [.flip, .rotate, .monochrome, .crop],
    [.flip, .rotate, .blur, .crop],
    [.rotate, .emboss, .crop],
    [.rotate, .monochrome, .background, .noise, .crop],
    [.rotate, .blur, .background, .noise, .crop],
    [.rotate, .emboss, .background, .noise, .crop],
    [.rotate, .monochrome, .background, .crop],
    [.rotate, .blur, .background, .crop],
    [.rotate, .emboss, .background, .crop],
    [.rotate, .monochrome, .noise, .crop],
    [.rotate, .blur, .noise, .crop],
    [.rotate, .emboss, .noise, .crop],
    [.rotate, .monochrome, .crop],
    [.rotate, .blur, .crop],
    [.rotate, .emboss, .crop],
    [.flip, .scale, .monochrome, .background, .noise, .crop],
    [.flip, .scale, .blur, .background, .noise, .crop],
    [.flip, .scale, .emboss, .background, .noise, .crop],
    [.flip, .scale, .monochrome, .background, .crop],
    [.flip, .scale, .blur, .background, .crop],
    [.flip, .scale, .emboss, .background, .crop],
    [.flip, .scale, .monochrome, .noise, .crop],
    [.flip, .scale, .blur, .noise, .crop],
    [.flip, .scale, .emboss, .noise, .crop],
    [.flip, .scale, .monochrome, .crop],
    [.flip, .scale, .blur, .crop],
    [.scale, .emboss, .crop],
    [.scale, .monochrome, .background, .noise, .crop],
    [.scale, .blur, .background, .noise, .crop],
    [.scale, .emboss, .background, .noise, .crop],
    [.scale, .monochrome, .background, .crop],
    [.scale, .blur, .background, .crop],
    [.scale, .emboss, .background, .crop],
    [.scale, .monochrome, .noise, .crop],
    [.scale, .blur, .noise, .crop],
    [.scale, .emboss, .noise, .crop],
    [.scale, .monochrome, .crop],
    [.scale, .blur, .crop],
    [.scale, .emboss, .crop],
    [.flip, .monochrome, .background, .noise, .crop],
    [.flip, .blur, .background, .noise, .crop],
    [.flip, .emboss, .background, .noise, .crop],
    [.flip, .monochrome, .background, .crop],
    [.flip, .blur, .background, .crop],
    [.flip, .emboss, .background, .crop],
    [.flip, .monochrome, .noise, .crop],
    [.flip, .blur, .noise, .crop],
    [.flip, .emboss, .noise, .crop],
    [.flip, .monochrome, .crop],
    [.flip, .blur, .crop],
    [.rotate, .emboss, .crop],
    [.rotate, .monochrome, .background, .noise, .crop],
    [.rotate, .blur, .background, .noise, .crop],
    [.rotate, .emboss, .background, .noise, .crop],
    [.rotate, .monochrome, .background, .crop],
    [.rotate, .blur, .background, .crop],
    [.rotate, .emboss, .background, .crop],
    [.rotate, .monochrome, .noise, .crop],
    [.rotate, .blur, .noise, .crop],
    [.rotate, .emboss, .noise, .crop],
    [.rotate, .monochrome, .crop],
    [.rotate, .blur, .crop],
    [.rotate, .emboss, .crop],
    [.flip, .scale, .rotate, .monochrome, .background, .noise, .cutout],
    [.flip, .scale, .rotate, .blur, .background, .noise, .cutout],
    [.flip, .scale, .rotate, .emboss, .background, .noise, .cutout],
    [.flip, .scale, .rotate, .monochrome, .background, .cutout],
    [.flip, .scale, .rotate, .blur, .background, .cutout],
    [.flip, .scale, .rotate, .emboss, .background, .cutout],
    [.flip, .scale, .rotate, .monochrome, .noise, .cutout],
    [.flip, .scale, .rotate, .blur, .noise, .cutout],
    [.flip, .scale, .rotate, .emboss, .noise, .cutout],
    [.flip, .scale, .rotate, .monochrome, .cutout],
    [.flip, .scale, .rotate, .blur, .cutout],
    [.scale, .rotate, .emboss, .cutout],
    [.scale, .rotate, .monochrome, .background, .noise, .cutout],
    [.scale, .rotate, .blur, .background, .noise, .cutout],
    [.scale, .rotate, .emboss, .background, .noise, .cutout],
    [.scale, .rotate, .monochrome, .background, .cutout],
    [.scale, .rotate, .blur, .background, .cutout],
    [.scale, .rotate, .emboss, .background, .cutout],
    [.scale, .rotate, .monochrome, .noise, .cutout],
    [.scale, .rotate, .blur, .noise, .cutout],
    [.scale, .rotate, .emboss, .noise, .cutout],
    [.scale, .rotate, .monochrome, .cutout],
    [.scale, .rotate, .blur, .cutout],
    [.scale, .rotate, .emboss, .cutout],
    [.flip, .rotate, .monochrome, .background, .noise, .cutout],
    [.flip, .rotate, .blur, .background, .noise, .cutout],
    [.flip, .rotate, .emboss, .background, .noise, .cutout],
    [.flip, .rotate, .monochrome, .background, .cutout],
    [.flip, .rotate, .blur, .background, .cutout],
    [.flip, .rotate, .emboss, .background, .cutout],
    [.flip, .rotate, .monochrome, .noise, .cutout],
    [.flip, .rotate, .blur, .noise, .cutout],
    [.flip, .rotate, .emboss, .noise, .cutout],
    [.flip, .rotate, .monochrome, .cutout],
    [.flip, .rotate, .blur, .cutout],
    [.rotate, .emboss, .cutout],
    [.rotate, .monochrome, .background, .noise, .cutout],
    [.rotate, .blur, .background, .noise, .cutout],
    [.rotate, .emboss, .background, .noise, .cutout],
    [.rotate, .monochrome, .background, .cutout],
    [.rotate, .blur, .background, .cutout],
    [.rotate, .emboss, .background, .cutout],
    [.rotate, .monochrome, .noise, .cutout],
    [.rotate, .blur, .noise, .cutout],
    [.rotate, .emboss, .noise, .cutout],
    [.rotate, .monochrome, .cutout],
    [.rotate, .blur, .cutout],
    [.rotate, .emboss, .cutout],
    [.flip, .scale, .monochrome, .background, .noise, .cutout],
    [.flip, .scale, .blur, .background, .noise, .cutout],
    [.flip, .scale, .emboss, .background, .noise, .cutout],
    [.flip, .scale, .monochrome, .background, .cutout],
    [.flip, .scale, .blur, .background, .cutout],
    [.flip, .scale, .emboss, .background, .cutout],
    [.flip, .scale, .monochrome, .noise, .cutout],
    [.flip, .scale, .blur, .noise, .cutout],
    [.flip, .scale, .emboss, .noise, .cutout],
    [.flip, .scale, .monochrome, .cutout],
    [.flip, .scale, .blur, .cutout],
    [.scale, .emboss, .cutout],
    [.scale, .monochrome, .background, .noise, .cutout],
    [.scale, .blur, .background, .noise, .cutout],
    [.scale, .emboss, .background, .noise, .cutout],
    [.scale, .monochrome, .background, .cutout],
    [.scale, .blur, .background, .cutout],
    [.scale, .emboss, .background, .cutout],
    [.scale, .monochrome, .noise, .cutout],
    [.scale, .blur, .noise, .cutout],
    [.scale, .emboss, .noise, .cutout],
    [.scale, .monochrome, .cutout],
    [.scale, .blur, .cutout],
    [.scale, .emboss, .cutout],
    [.flip, .monochrome, .background, .noise, .cutout],
    [.flip, .blur, .background, .noise, .cutout],
    [.flip, .emboss, .background, .noise, .cutout],
    [.flip, .monochrome, .background, .cutout],
    [.flip, .blur, .background, .cutout],
    [.flip, .emboss, .background, .cutout],
    [.flip, .monochrome, .noise, .cutout],
    [.flip, .blur, .noise, .cutout],
    [.flip, .emboss, .noise, .cutout],
    [.flip, .monochrome, .cutout],
    [.flip, .blur, .cutout],
    [.rotate, .emboss, .cutout],
    [.rotate, .monochrome, .background, .noise, .cutout],
    [.rotate, .blur, .background, .noise, .cutout],
    [.rotate, .emboss, .background, .noise, .cutout],
    [.rotate, .monochrome, .background, .cutout],
    [.rotate, .blur, .background, .cutout],
    [.rotate, .emboss, .background, .cutout],
    [.rotate, .monochrome, .noise, .cutout],
    [.rotate, .blur, .noise, .cutout],
    [.rotate, .emboss, .noise, .cutout],
    [.rotate, .monochrome, .cutout],
    [.rotate, .blur, .cutout],
    [.rotate, .emboss, .cutout],
  ]}
}
