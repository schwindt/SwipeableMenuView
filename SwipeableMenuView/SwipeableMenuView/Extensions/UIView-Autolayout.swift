//
//  UIView-Autolayout.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 10.02.22.
//

import UIKit

protocol NSLayoutConstraintAttributeValue {
  var attribute: NSLayoutConstraint.Attribute { get }
}

enum LayoutDimensionConstraintType: NSLayoutConstraintAttributeValue {
  case equalHeight
  case equalWidth
  case height
  case width
  case minHeight
  case maxHeight
  case minWidth
  case maxWidth

  var attribute: NSLayoutConstraint.Attribute {
    switch self {
      case .equalHeight, .height, .minHeight, .maxHeight:
        return .height
      case .equalWidth, .width, .minWidth, .maxWidth:
        return .width
    }
  }
}

enum LayoutXAxisAnchorConstraintType: NSLayoutConstraintAttributeValue {
  case leading
  case trailing
  var attribute: NSLayoutConstraint.Attribute {
    switch self {
      case .leading:
        return .leading
      case .trailing:
        return .trailing
    }
  }
}

enum LayoutYAxisAnchorConstraintType: NSLayoutConstraintAttributeValue {
  case top
  case bottom
  var attribute: NSLayoutConstraint.Attribute {
    switch self {
      case .top:
        return .top
      case .bottom:
        return .bottom
    }
  }
}

class BuhlLayoutPriority: NSObject {
  static let low = UILayoutPriority.defaultLow
  static let high = UILayoutPriority.defaultHigh
  static let wanted = UILayoutPriority(UILayoutPriority.required.rawValue - 1)
  static let required = UILayoutPriority.required
}

struct LayoutConstraintFilterType: OptionSet {
  let rawValue: Int
  static let firstItem = LayoutConstraintFilterType(rawValue: 1 << 0)
  static let secondItem = LayoutConstraintFilterType(rawValue: 1 << 1)
  static let firstOrSecondItem: LayoutConstraintFilterType = [.firstItem, .secondItem]
}

extension UIView {
  private func update(constraint: NSLayoutConstraint, attribute: NSLayoutConstraint.Attribute) {
    let attributes: [NSLayoutConstraint.Attribute] = [.leading, .trailing, .top, .bottom]
    let type: LayoutConstraintFilterType = !attributes.contains(attribute) ? .firstItem : .firstOrSecondItem
    var filtered = constraints.filter(type: type, constraint: constraint, view: self)
    if !filtered.isEmpty {
      removeConstraints(filtered)
    } else if let view = superview {
      filtered = view.constraints.filter(type: type, constraint: constraint, view: self)
      if !filtered.isEmpty {
        view.removeConstraints(filtered)
      }
    }
    constraint.isActive = true
    setNeedsUpdateConstraints()
  }

  private func setAutolayout(value: CGFloat, priority: UILayoutPriority, type: LayoutDimensionConstraintType) -> NSLayoutConstraint {
    var constraint: NSLayoutConstraint
    switch type {
      case .minWidth, .minHeight:
        constraint = anchor(for: type).constraint(greaterThanOrEqualToConstant: value)
      case .maxHeight:
        constraint = anchor(for: type).constraint(lessThanOrEqualToConstant: value)
      default:
        constraint = anchor(for: type).constraint(equalToConstant: value)
    }
    constraint.priority = priority
    constraint.isActive = false
    update(constraint: constraint, attribute: type.attribute)
    return constraint
  }

  private func setAutolayout(target view: UIView, priority: UILayoutPriority, multiplier: CGFloat = 1, type: LayoutDimensionConstraintType) -> NSLayoutConstraint {
    let constraint = anchor(for: type).constraint(equalTo: view.anchor(for: type), multiplier: multiplier)
    constraint.priority = priority
    constraint.isActive = false
    update(constraint: constraint, attribute: type.attribute)
    return constraint
  }

  private func setAutolayout(target view: UIView, priority: UILayoutPriority, type: LayoutXAxisAnchorConstraintType, constant: CGFloat) -> NSLayoutConstraint {
    let constraint = view.anchor(for: type).constraint(equalTo: anchor(for: type), constant: constant)
    constraint.priority = priority
    constraint.isActive = false
    update(constraint: constraint, attribute: type.attribute)
    return constraint
  }

  private func setAutolayout(target view: UIView, priority: UILayoutPriority, type: LayoutYAxisAnchorConstraintType, constant: CGFloat) -> NSLayoutConstraint {
    let constraint = view.anchor(for: type).constraint(equalTo: anchor(for: type), constant: constant)
    constraint.priority = priority
    constraint.isActive = false
    update(constraint: constraint, attribute: type.attribute)
    return constraint
  }
}

extension UIView {
  struct LayoutConstraintCreationResult {
    var top: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    var leading: NSLayoutConstraint?
    var trailing: NSLayoutConstraint?
  }

  func anchor(for type: LayoutDimensionConstraintType) -> NSLayoutDimension {
    switch type {
      case .equalHeight, .height, .minHeight, .maxHeight:
        return heightAnchor
      case .equalWidth, .width, .minWidth, .maxWidth:
        return widthAnchor
    }
  }

  func anchor(for type: LayoutXAxisAnchorConstraintType) -> NSLayoutXAxisAnchor {
    switch type {
      case .trailing:
        return trailingAnchor
      case .leading:
        return leadingAnchor
    }
  }

  func anchor(for type: LayoutYAxisAnchorConstraintType) -> NSLayoutYAxisAnchor {
    switch type {
      case .top:
        return topAnchor
      case .bottom:
        return bottomAnchor
    }
  }

  @discardableResult
  func setAutolayout(equalHeight view: UIView, multiplier: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(target: view, priority: priority, multiplier: max(min(multiplier, 1), 0), type: .equalHeight)
  }

  @discardableResult
  func setAutolayout(equalWidth view: UIView, multiplier: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(target: view, priority: priority, multiplier: max(min(multiplier, 1), 0), type: .equalWidth)
  }

  @discardableResult
  func setAutolayout(height value: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(value: max(0, value), priority: priority, type: .height)
  }

  @discardableResult
  func setAutolayout(minHeight value: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(value: max(0, value), priority: priority, type: .minHeight)
  }

  @discardableResult
  func setAutolayout(maxHeight value: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(value: max(0, value), priority: priority, type: .maxHeight)
  }

  @discardableResult
  func setAutolayout(width value: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(value: max(0, value), priority: priority, type: .width)
  }

  @discardableResult
  func setAutolayout(minWidth value: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(value: max(0, value), priority: priority, type: .minWidth)
  }

  @discardableResult
  func setAutolayout(maxWidth value: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(value: max(0, value), priority: priority, type: .maxWidth)
  }

  @discardableResult
  func setAutolayout(trailing view: UIView, constant: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(target: view, priority: priority, type: .trailing, constant: constant)
  }

  @discardableResult
  func setAutolayout(leading view: UIView, constant: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(target: view, priority: priority, type: .leading, constant: constant)
  }

  @discardableResult
  func setAutolayout(bottom view: UIView, constant: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
    return setAutolayout(target: view, priority: priority, type: .bottom, constant: constant)
  }

  @discardableResult
  func setAspectRation(_ ratio: CGFloat) -> NSLayoutConstraint {
    translatesAutoresizingMaskIntoConstraints = false
    return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: ratio, constant: 0)
  }

  @discardableResult
  func pinEdges(to other: UIView, priority: UILayoutPriority? = .required, insets: UIEdgeInsets = .zero, excluding: [NSLayoutConstraint.Attribute] = []) -> LayoutConstraintCreationResult {
    translatesAutoresizingMaskIntoConstraints = false

    var createdConstraints = LayoutConstraintCreationResult()

    if !excluding.contains(.top) {
      let top = topAnchor.constraint(equalTo: other.topAnchor)
      top.priority = priority ?? .required
      top.constant = insets.top
      top.isActive = true
      createdConstraints.top = top
    }

    if !excluding.contains(.leading) {
      let leading = leadingAnchor.constraint(equalTo: other.leadingAnchor)
      leading.priority = priority ?? .required
      leading.constant = insets.left
      leading.isActive = true
      createdConstraints.leading = leading
    }

    if !excluding.contains(.bottom) {
      let bottom = bottomAnchor.constraint(equalTo: other.bottomAnchor)
      bottom.priority = priority ?? .required
      bottom.constant = -insets.bottom
      bottom.isActive = true
      createdConstraints.bottom = bottom
    }

    if !excluding.contains(.trailing) {
      let trailing = trailingAnchor.constraint(equalTo: other.trailingAnchor)
      trailing.priority = priority ?? .required
      trailing.constant = -insets.right
      trailing.isActive = true
      createdConstraints.trailing = trailing
    }

    return createdConstraints
  }

  @discardableResult
  func pinEdgesToSuperView(priority: UILayoutPriority? = .required, insets: UIEdgeInsets = .zero, excluding: [NSLayoutConstraint.Attribute] = []) -> LayoutConstraintCreationResult {
    if let superview = superview {
      return pinEdges(to: superview, priority: priority, insets: insets, excluding: excluding)
    }

    return LayoutConstraintCreationResult()
  }

  func pinEdgesToSuperView(withMargin margin: CGFloat, priority: UILayoutPriority = .required) {
    guard let superview = superview else { return }

    pin(edges: [.leading, .top, .trailing, .bottom], toView: superview, withMargin: margin, priority: priority)
  }

  func pinToSuperViewSafeArea(edges: [NSLayoutConstraint.Attribute], withMargin margin: CGFloat, priority: UILayoutPriority = .required) {
    guard let superview = superview else { return }

    translatesAutoresizingMaskIntoConstraints = false

    for edge in edges {
      if edge == .leading {
        let constraint = leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .trailing {
        let constraint = trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .top {
        let constraint = topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .bottom {
        let constraint = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
        constraint.priority = priority
        constraint.isActive = true
      }
    }
  }

  func pinToSuperView(edges: [NSLayoutConstraint.Attribute], withMargin margin: CGFloat, priority: UILayoutPriority = .required) {
    guard let superview = superview else { return }

    pin(edges: edges, toView: superview, withMargin: margin, priority: priority)
  }

  func pinToSafeArea(edges: [NSLayoutConstraint.Attribute], withMargin margin: CGFloat, priority: UILayoutPriority = .required) {
    guard let superview = superview else { return }

    translatesAutoresizingMaskIntoConstraints = false

    for edge in edges {
      if edge == .leading {
        let constraint = leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .trailing {
        let constraint = trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .top {
        let constraint = topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .bottom {
        let constraint = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
        constraint.priority = priority
        constraint.isActive = true
      }
    }
  }

  func pin(edges: [NSLayoutConstraint.Attribute], toView view: UIView, withMargin margin: CGFloat, priority: UILayoutPriority = .required) {
    translatesAutoresizingMaskIntoConstraints = false

    for edge in edges {
      if edge == .leading {
        let constraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .trailing {
        let constraint = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .top {
        let constraint = topAnchor.constraint(equalTo: view.topAnchor, constant: margin)
        constraint.priority = priority
        constraint.isActive = true
      } else if edge == .bottom {
        let constraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
        constraint.priority = priority
        constraint.isActive = true
      }
    }
  }

  func center(inView view: UIView) {
    translatesAutoresizingMaskIntoConstraints = false

    centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }

  func center(inView view: UIView, attributes: [NSLayoutConstraint.Attribute]) {
    translatesAutoresizingMaskIntoConstraints = false

    for attribute in attributes {
      if attribute == .centerX {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      } else if attribute == .centerY {
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
      }
    }
  }
}

public extension NSLayoutConstraint {
  func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
    let newConstraint = NSLayoutConstraint(item: firstItem as Any,
                                           attribute: firstAttribute,
                                           relatedBy: relation,
                                           toItem: secondItem,
                                           attribute: secondAttribute,
                                           multiplier: multiplier,
                                           constant: constant)
    newConstraint.priority = priority

    NSLayoutConstraint.deactivate([self])
    NSLayoutConstraint.activate([newConstraint])

    return newConstraint
  }
}
