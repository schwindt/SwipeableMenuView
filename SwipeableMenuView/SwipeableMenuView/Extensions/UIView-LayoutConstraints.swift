//
//  UIView-LayoutConstraints.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 10.02.22.
//

import UIKit

extension Array where Element == NSLayoutConstraint {
  func filter(type: LayoutConstraintFilterType, constraint: NSLayoutConstraint, view: UIView) -> [NSLayoutConstraint] {
    return filter {
      $0 != constraint && $0.relation == constraint.relation &&
        ((type.contains(.firstItem) ? $0.firstAttribute == constraint.firstAttribute && $0.firstItem as? UIView == view : false) ||
          (type.contains(.secondItem) ? $0.secondAttribute == constraint.secondAttribute && $0.secondItem as? UIView == view : false))
    }
  }
}
