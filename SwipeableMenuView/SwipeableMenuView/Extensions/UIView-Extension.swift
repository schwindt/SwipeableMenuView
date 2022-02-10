//
//  UIView-Extension.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 10.02.22.
//

import UIKit

// MARK: Helper

extension UIView {
  var isLandscape: Bool {
    return UIApplication.shared.statusBarOrientation.isLandscape
  }
}

// MARK: - View Handling

extension UIView {
  func parentView<T: UIView>(of _: T.Type) -> T? {
    guard let view = superview else {
      return nil
    }
    return (view as? T) ?? view.parentView(of: T.self)
  }

  static func getSubviewsOf<T: UIView>(view: UIView) -> [T] {
    var subviews = [T]()

    for subview in view.subviews {
      subviews += getSubviewsOf(view: subview) as [T]

      if let subview = subview as? T {
        subviews.append(subview)
      }
    }

    return subviews // .reversed()
  }
}

extension UIView {
  /** This is the function to get subViews of a view of a particular type
   */
  func subViews<T: UIView>(type _: T.Type) -> [T] {
    var all = [T]()
    for view in subviews {
      if let aView = view as? T {
        all.append(aView)
      }
    }
    return all
  }

  /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
  func allSubViewsOf<T: UIView>(type _: T.Type) -> [T] {
    var all = [T]()
    func getSubview(view: UIView) {
      if let aView = view as? T {
        all.append(aView)
      }
      guard view.subviews.count > 0 else { return }
      view.subviews.forEach { getSubview(view: $0) }
    }
    getSubview(view: self)
    return all
  }
}

extension UIView {
  var currentSelectedTextField: UITextField? {
    return allSubViewsOf(type: UITextField.self).filter { $0.isFirstResponder }.first
  }
}

extension UIView {
  func addTapGestureRecognizer(action: (() -> Void)?) {
    tapAction = action
    isUserInteractionEnabled = true
    let selector = #selector(handleTap)
    let recognizer = UITapGestureRecognizer(target: self, action: selector)
    addGestureRecognizer(recognizer)
  }

  func findViewController() -> UIViewController? {
    if let nextResponder = next as? UIViewController {
      return nextResponder
    } else if let nextResponder = next as? UIView {
      return nextResponder.findViewController()
    } else {
      return nil
    }
  }
}

private extension UIView {
  typealias Action = (() -> Void)

  enum Key { static var id = "tapAction" }

  var tapAction: Action? {
    get {
      return objc_getAssociatedObject(self, &Key.id) as? Action
    }
    set {
      guard let value = newValue else { return }
      let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
      objc_setAssociatedObject(self, &Key.id, value, policy)
    }
  }

  @objc func handleTap(sender _: UITapGestureRecognizer) {
    tapAction?()
  }
}

extension UIView {
  static func spacer(_ size: CGFloat) -> UIView {
    let spacer = UIView()
    spacer.setAutolayout(height: size, priority: .defaultHigh)
    spacer.setAutolayout(width: size, priority: .defaultHigh)
    return spacer
  }
}
