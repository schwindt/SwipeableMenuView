//
//  BaseButton.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 05.11.20.
//

import UIKit

class BaseButton: UIButton {
  var touchUpInsideCompletion: ((UIButton) -> Void)?

  func setTapAction(completion: ((UIButton) -> Void)?) {
    touchUpInsideCompletion = completion

    // This doesn't work correctly:
    //    addTarget(self, action: #selector(PlausiCheckBox.buttonPressed(sender:)), for: .touchUpInside)
    addTapGestureRecognizer { [weak self] in
      guard let self = self else { return }
      self.buttonPressed(sender: self)
    }
  }

  @objc
  private func buttonPressed(sender: UIButton!) {
    touchUpInsideCompletion?(sender)
  }
}
