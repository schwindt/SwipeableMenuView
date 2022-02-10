//
//  PanDirectionGestureRecognizer.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 10.02.22.
//  Copyright © 2022 Buhl Data Service GmbH. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

enum PanDirection {
  case vertical
  case horizontal
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
  let direction: PanDirection

  init(direction: PanDirection, target: AnyObject, action: Selector) {
    self.direction = direction
    super.init(target: target, action: action)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)

    if state == .began {
      let vel = velocity(in: view)
      switch direction {
        case .horizontal where abs(vel.y) > abs(vel.x):
          state = .cancelled
        case .vertical where abs(vel.x) > abs(vel.y):
          state = .cancelled
        default:
          break
      }
    }
  }
}
