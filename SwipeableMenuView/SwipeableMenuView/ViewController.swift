//
//  ViewController.swift
//  SwipeableMenuView
//
//  Created by Christian Schwindt on 10.02.22.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupConstraints()
  }
  
  var mainStackView: UIStackView = {
    let view = UIStackView()
    view.alignment = .fill
    view.distribution = .fill
    view.axis = .vertical
    view.spacing = 10
    return view
  }()
  
  
  var createTestCell: UIView {
    let view = UIView()
    view.setAutolayout(height: 60, priority: .required)
    
    let contentView = UIView()
    contentView.backgroundColor = .blue
    
    let activeColor = UIColor.init(named: "red_active") ?? .red
    let inactiveColor = UIColor.init(named: "red_inactive") ?? .red
    let image = UIImage(named: "delete")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate).tintWith(color: .white)
    
    let leftSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .one(.init(backgroundColor: inactiveColor , instantFireBackgroundColor: activeColor, image:image , action: {
      print("oink")
    })))
    
    let rightSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .one(.init(backgroundColor: activeColor, instantFireBackgroundColor: activeColor, image: image, action: {
      print("oink")
    })))
    let slideMenuView = SlideMenuView(leftMenuConfig: leftSlideMenuConfig, rightMenuConfig: rightSlideMenuConfig, contentView: contentView)
    view.addSubview(slideMenuView)
    slideMenuView.pinEdgesToSuperView()
    
    return view
  }
  
  var createTestCell2: UIView {
    let view = UIView()
    view.setAutolayout(height: 60, priority: .required)
    
    let contentView = UIView()
    contentView.backgroundColor = .blue
    
    let firstLeftConfig = SlideMenuViewButtonConfig(backgroundColor: .gray, instantFireBackgroundColor: .red, image: UIImage(named: "delete")!) {
      print("fire 1")
    }
    let secondLeftConfig = SlideMenuViewButtonConfig(backgroundColor: .black, instantFireBackgroundColor: .red, image: UIImage(named: "delete")!) {
      print("fire 2")
    }
    
    let leftSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .two(firstLeftConfig, secondLeftConfig))
    
    let firstRightConfig = SlideMenuViewButtonConfig(backgroundColor: .gray, instantFireBackgroundColor: .red, image: UIImage(named: "delete")!)
    let secondRightConfig = SlideMenuViewButtonConfig(backgroundColor: .black, instantFireBackgroundColor: .red, image: UIImage(named: "delete")!)
    
    let rightSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .two(firstRightConfig, secondRightConfig))
    let slideMenuView = SlideMenuView(leftMenuConfig: leftSlideMenuConfig, rightMenuConfig: rightSlideMenuConfig, contentView: contentView)
    view.addSubview(slideMenuView)
    slideMenuView.pinEdgesToSuperView()
    
    return view
  }
  
  var createTestCell3: UIView {
    let view = UIView()
    view.setAutolayout(height: 60, priority: .required)
    
    let contentView = UIView()
    contentView.backgroundColor = .blue
    
    let leftSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    let rightSlideMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .one(.init(backgroundColor: .gray, instantFireBackgroundColor: .red, image: UIImage(named: "delete")!)))
    let slideMenuView = SlideMenuView(leftMenuConfig: leftSlideMenuConfig, rightMenuConfig: rightSlideMenuConfig, contentView: contentView)
    view.addSubview(slideMenuView)
    slideMenuView.pinEdgesToSuperView()
    
    return view
  }
  
  func setupUI(){
    self.view.addSubview(mainStackView)
    mainStackView.addArrangedSubview(createTestCell)
    mainStackView.addArrangedSubview(createTestCell2)
    mainStackView.addArrangedSubview(createTestCell3)
  }
  
  func setupConstraints() {
    mainStackView.pinToSafeArea(edges: [.leading, .top, .trailing], withMargin: 20)
  }
  
}


