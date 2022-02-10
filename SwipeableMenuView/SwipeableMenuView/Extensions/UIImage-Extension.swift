//
//  UIImage-Extension.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 10.02.22.
//

import UIKit

extension UIImage {
  func tintWith(color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    color.setFill()

    let context = UIGraphicsGetCurrentContext()
    context?.translateBy(x: 0, y: size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    context?.setBlendMode(CGBlendMode.normal)

    let rect = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
    context?.clip(to: rect, mask: cgImage!)
    context?.fill(rect)

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}

extension UIImage {
  func withInset(_ insets: UIEdgeInsets) -> UIImage? {
    let cgSize = CGSize(width: size.width + insets.left * scale + insets.right * scale,
                        height: size.height + insets.top * scale + insets.bottom * scale)

    UIGraphicsBeginImageContextWithOptions(cgSize, false, scale)
    defer { UIGraphicsEndImageContext() }

    let origin = CGPoint(x: insets.left * scale, y: insets.top * scale)
    draw(at: origin)

    return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(renderingMode)
  }
}
