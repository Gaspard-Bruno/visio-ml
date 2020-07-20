import Foundation

extension Formatter {

  static var integer: some Formatter {
    let nf = NumberFormatter()
    nf.allowsFloats = false
    nf.minimumIntegerDigits = 1
    nf.maximumIntegerDigits = 3
    nf.maximumSignificantDigits = 3
    nf.maximum = 100
    nf.minimum = 1
    return nf
  }

  static var pixel: some Formatter {
    let nf = NumberFormatter()
    nf.allowsFloats = false
    nf.minimumIntegerDigits = 1
    nf.maximumIntegerDigits = 5
    nf.maximumSignificantDigits = 5
    nf.maximum = 99999
    nf.minimum = 1
    return nf
  }


  static var decimal: some Formatter {
    let nf = NumberFormatter()
    nf.allowsFloats = true
    nf.minimumIntegerDigits = 1
    nf.maximumIntegerDigits = 6
    nf.maximumSignificantDigits = 6
    nf.maximum = 999999
    nf.minimum = 0
    nf.maximumFractionDigits = 2
    nf.minimumFractionDigits = 0
    return nf
  }

}

