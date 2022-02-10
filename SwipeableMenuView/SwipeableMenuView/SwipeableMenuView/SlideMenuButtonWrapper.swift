//
//  SlideMenuButtonWrapper.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 08.02.22.
//

import UIKit

struct SlideMenuViewButtonWrapperConfig {
  static let buttonAlphaInOneButtonMode = 0.33
  
  init(buttonMode: ButtonMode) {
    self.buttonMode = buttonMode
  }
  
  enum ButtonMode: Equatable {
    case zero
    case one(SlideMenuViewButtonConfig)
    case two(SlideMenuViewButtonConfig, SlideMenuViewButtonConfig)
    
    var value: String? {
      return String(describing: self).components(separatedBy: "(").first
    }
    
    static func == (lhs: ButtonMode, rhs: ButtonMode) -> Bool {
      lhs.value == rhs.value
    }
  }
  
  private(set) var buttonMode: ButtonMode
}

class SlideMenuButtonWrapper: UIView {
  private(set) var config: SlideMenuViewButtonWrapperConfig?
  private(set) var firstButton: SlideMenuButton?
  private(set) var secondButton: SlideMenuButton?
  
  init(slideMenuViewButtonWrapperConfig: SlideMenuViewButtonWrapperConfig) {
    config = slideMenuViewButtonWrapperConfig
    super.init(frame: .zero)
    applyToUI()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    applyToUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    applyToUI()
  }
  
  private func applyToUI() {
    guard let config = config else {
      return
    }
    
    switch config.buttonMode {
    case .zero:
      firstButton = nil
      secondButton = nil
      
    case let .one(slideMenuViewButtonConfig):
      firstButton = SlideMenuButton(slideMenuViewButtonConfig: slideMenuViewButtonConfig)
      secondButton = nil
      guard let firstButton = firstButton else { return }
      addSubview(firstButton)
      firstButton.pinEdgesToSuperView()
      firstButton.alpha = SlideMenuViewButtonWrapperConfig.buttonAlphaInOneButtonMode
      
    case let .two(firstSlideMenuViewButtonConfig, secondSlideMenuViewButtonConfig):
      firstButton = SlideMenuButton(slideMenuViewButtonConfig: firstSlideMenuViewButtonConfig)
      secondButton = SlideMenuButton(slideMenuViewButtonConfig: secondSlideMenuViewButtonConfig)
      guard let firstButton = firstButton, let secondButton = secondButton else { return }
      
      addSubview(firstButton)
      firstButton.pinEdgesToSuperView()
      
      addSubview(secondButton)
      secondButton.pinToSuperView(edges: [.top, .bottom, .trailing], withMargin: 0)
      secondButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    }
  }
}
