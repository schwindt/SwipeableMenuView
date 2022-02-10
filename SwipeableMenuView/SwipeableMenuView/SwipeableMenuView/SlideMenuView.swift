//
//  SlideMenuView.swift
//  SteuerPhone
//
//  Created by Christian Schwindt on 08.02.22.
//

import UIKit

class SlideMenuView: UIView {
  // MARK: public
  
  let leftMenuConfig: SlideMenuViewButtonWrapperConfig
  let rightMenuConfig: SlideMenuViewButtonWrapperConfig
  
  // MARK: privates
  
  private var panStart: CGPoint = .zero
  private var correctionValue: CGFloat = 0
  private var vibratedForActivated: Bool = false
  private var vibratedForDeactivated: Bool = true
  
  private var pannableViewLeadingAnchor: NSLayoutConstraint?
  
  // Die eigentliche Content View die verschoben wird
  // und von außerhalb gesetzt wird
  private var contentView: UIView
  
  // Diese View bekommt einen UIPanGestureRecognizer und lässt sich
  // dann verschieben
  private lazy var pannableView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(contentView)
    contentView.pinEdgesToSuperView()
    
    return view
  }()
  
  lazy var rightMenuWrapperView: SlideMenuButtonWrapper = {
    SlideMenuButtonWrapper(slideMenuViewButtonWrapperConfig: rightMenuConfig)
  }()
  
  lazy var leftMenuWrapperView: SlideMenuButtonWrapper = {
    SlideMenuButtonWrapper(slideMenuViewButtonWrapperConfig: leftMenuConfig)
  }()
  
  /// Erster Barriere Punkt der zu unterschiedlichen Aktionen führt je nach config
  var firstBarrierPoint: CGFloat {
    pannableView.frame.width / 4
  }
  
  /// Zweiter Barriere Punkt der zu unterschiedlichen Aktionen führt je nach config
  var secondBarrierPoint: CGFloat {
    pannableView.frame.width / 3
  }
  
  init(leftMenuConfig: SlideMenuViewButtonWrapperConfig? = nil, rightMenuConfig: SlideMenuViewButtonWrapperConfig? = nil, contentView: UIView) {
    self.leftMenuConfig = leftMenuConfig ?? SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    self.rightMenuConfig = rightMenuConfig ?? SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    self.contentView = contentView
    super.init(frame: .zero)
    applyToUI()
  }
  
  override init(frame: CGRect) {
    leftMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    rightMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    contentView = UIView()
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    leftMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    rightMenuConfig = SlideMenuViewButtonWrapperConfig(buttonMode: .zero)
    contentView = UIView()
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  private func applyToUI() {
    setupUI()
    setupConstraints()
    setupActions()
  }
  
  // MARK: Build UI
  
  private func setupUI() {
    let panGestureRecognizer = PanDirectionGestureRecognizer(direction: .horizontal, target: self, action: #selector(didPan(_:)))
    panGestureRecognizer.delegate = self
    
    pannableView.addGestureRecognizer(panGestureRecognizer)
    
    leftMenuWrapperView.alpha = 0
    rightMenuWrapperView.alpha = 0
    
    addSubview(leftMenuWrapperView)
    addSubview(rightMenuWrapperView)
    addSubview(pannableView)
  }
  
  private func setupConstraints() {
    pannableView.pinToSuperView(edges: [.top, .bottom], withMargin: 0)
    pannableView.setAutolayout(equalWidth: self, multiplier: 1, priority: .required)
    pannableViewLeadingAnchor = pannableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
    pannableViewLeadingAnchor?.isActive = true
    
    leftMenuWrapperView.pinToSuperView(edges: [.leading, .top, .bottom], withMargin: 0)
    let leftTrailing = leftMenuWrapperView.trailingAnchor.constraint(equalTo: pannableView.leadingAnchor, constant: 8) // 8 Da die ContantView einen CornerRadius hat
    leftTrailing.priority = .defaultHigh
    leftTrailing.isActive = true
    
    rightMenuWrapperView.pinToSuperView(edges: [.trailing, .top, .bottom], withMargin: 0)
    let rightLeading = rightMenuWrapperView.leadingAnchor.constraint(equalTo: pannableView.trailingAnchor, constant: -8) // -8 Da die ContantView einen CornerRadius hat
    rightLeading.priority = .defaultHigh
    rightLeading.isActive = true
  }
  
  private func setupActions() {
    leftMenuWrapperView.firstButton?.setTapAction(completion: { [weak self] _ in
      self?.movePannableView(constant: 0)
      self?.leftMenuWrapperView.firstButton?.config?.action?()
    })
    
    leftMenuWrapperView.secondButton?.setTapAction(completion: { [weak self] _ in
      self?.movePannableView(constant: 0)
      self?.leftMenuWrapperView.secondButton?.config?.action?()
    })
    
    rightMenuWrapperView.firstButton?.setTapAction(completion: { [weak self] _ in
      self?.movePannableView(constant: 0)
      self?.rightMenuWrapperView.firstButton?.config?.action?()
    })
    
    rightMenuWrapperView.secondButton?.setTapAction(completion: { [weak self] _ in
      self?.movePannableView(constant: 0)
      self?.rightMenuWrapperView.secondButton?.config?.action?()
    })
  }
  
  // MARK: UIPanGestureRecognizer Delegate
  
  @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: pannableView)
    
    switch gesture.state {
    case .began:
      vibratedForActivated = false
      correctionValue = pannableViewLeadingAnchor?.constant ?? 0
    case .changed:
      
      let xMovementOfGesture = translation.x
      let correctedXMovement = correctionValue + xMovementOfGesture
      
      // Prüfe ob eine Verschiebung nach LINKS (über den "Rand") erlaubt ist, so dass die
      // rechte Menu View sichtbar werden würde
      if correctedXMovement < 0, rightMenuConfig.buttonMode == .zero {
        // Falls der Nutzer sehr schnell zur Seite pinched
        // andernfalls würde die view nicht richtig "schließen"
        movePannableView(constant: 0)
        break
      }
      
      // Prüfe ob eine Verschiebung nach RECHTS (über den "Rand") erlaubt ist, so dass die
      // linke Menu View sichtbar werden würde
      if correctedXMovement > 0, leftMenuConfig.buttonMode == .zero {
        // Falls der Nutzer sehr schnell zur Seite pinched
        // andernfalls würde die view nicht richtig "schließen"
        movePannableView(constant: 0)
        break
      }
      
      pannableViewLeadingAnchor?.constant = correctedXMovement
      
      checkForBreakThrough(correctedXMovement: correctedXMovement)
      
    case .ended,
        .cancelled:
      
      let xMovementOfGesture = translation.x
      let correctedXMovement = correctionValue + xMovementOfGesture
      
      // Prüfe ob eine Verschiebung in die jeweilige Richtung erlaubt ist
      if correctedXMovement < 0, rightMenuConfig.buttonMode == .zero { break }
      if correctedXMovement > 0, leftMenuConfig.buttonMode == .zero { break }
      
      gesturePanEnded(correctedXMovement: correctedXMovement)
      
    default:
      break
    }
  }
  
  private func gesturePanEnded(correctedXMovement: CGFloat) {
    // links oder rechts muss mehr als firstBarrierPoint geschoben worden sein
    // andernfalls snappt alles wieder zurück auf 0
    if abs(correctedXMovement) < firstBarrierPoint {
      movePannableView(constant: 0)
      return
    }
    
    let wrapperView = correctedXMovement < 0 ? rightMenuWrapperView : leftMenuWrapperView
    guard let config = wrapperView.config else { return }
    
    switch config.buttonMode {
    case .zero:
      break
    case .one:
      if let button = wrapperView.firstButton {
        // PannableView zurück schieben und übergebene Action feuern
        button.touchUpInsideCompletion?(button)
      }
      
    case .two:
      
      let vorzeichenFactor = correctedXMovement / abs(correctedXMovement) // 1 oder -1
      
      // wurde nach links oder rechts mehr als der firstBarrierPoint geschoben rastet die
      // PannableView im secondBarrierPoint ein
      if abs(correctedXMovement) > firstBarrierPoint {
        movePannableView(constant: vorzeichenFactor * secondBarrierPoint)
      }
      
      // Hier könnte noch weiteres Verhalten eingebaut werden
    }
  }
  
  // MARK: Move View Animations
  
  private func movePannableView(constant: CGFloat) {
    pannableViewLeadingAnchor?.constant = constant
    
    if constant == 0 {
      UIView.animate(withDuration: 0.5) {
        self.leftMenuWrapperView.alpha = 0
        self.rightMenuWrapperView.alpha = 0
      }
    }
    
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.3, initialSpringVelocity: 0.2, options: [.curveEaseInOut]) {
      self.layoutIfNeeded()
    }
  }
  
  // MARK: Handle BreakThroughs
  
  private func checkForBreakThrough(correctedXMovement: CGFloat) {
    let wrapperView = correctedXMovement < 0 ? rightMenuWrapperView : leftMenuWrapperView
    guard let config = wrapperView.config else { return }
    
    wrapperView.alpha = 1.0
    
    switch config.buttonMode {
    case .zero:
      break
    case .one:
      if abs(correctedXMovement) > abs(firstBarrierPoint), vibratedForActivated == false {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        vibratedForActivated = true
        vibratedForDeactivated = false
        
        wrapperView.firstButton?.alpha = 1.0
        wrapperView.firstButton?.instantFireMode = true
      }
      if abs(correctedXMovement) < abs(firstBarrierPoint), vibratedForDeactivated == false {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        vibratedForActivated = false
        vibratedForDeactivated = true
        
        wrapperView.firstButton?.alpha = SlideMenuViewButtonWrapperConfig.buttonAlphaInOneButtonMode
        wrapperView.firstButton?.instantFireMode = false
      }
      
    case .two:
      break
    }
  }
}

extension SlideMenuView: UIGestureRecognizerDelegate {
  func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
    return true
  }
}
