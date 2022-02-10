//
//  SlideMenuButton.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 08.02.22.
//

import UIKit

struct SlideMenuViewButtonConfig {
  var backgroundColor: UIColor
  var instantFireBackgroundColor: UIColor?
  var image: UIImage
  var action: (() -> Void)?
}

class SlideMenuButton: BaseButton {
  var instantFireMode: Bool = false {
    didSet {
      backgroundColor = instantFireMode ? config?.instantFireBackgroundColor : config?.backgroundColor
    }
  }
  
  private(set) var config: SlideMenuViewButtonConfig?
  
  init(slideMenuViewButtonConfig: SlideMenuViewButtonConfig) {
    config = slideMenuViewButtonConfig
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
  
  override func prepareForInterfaceBuilder() {
    applyToUI()
  }
  
  private func applyToUI() {
    guard let config = config else { return }
    
    setImage(config.image, for: .normal)
    instantFireMode = false
    contentHorizontalAlignment = .left
    titleLabel?.lineBreakMode = .byClipping
    imageView?.contentMode = .left
    
    contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    
    //    var oink = UIButton.Configuration.plain()
    //    oink.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
    //    configuration = oink
  }
}
