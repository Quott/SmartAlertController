//
//  SAlertViewController.swift
//  SmartAlertController
//
//  Created by Dmitriy Titov on 16.06.2018.
//  Copyright © 2018 DmitriyTitov. All rights reserved.
//

import UIKit

class SAlertViewController: UIViewController {
    
    private let animator = SAnimator()
    private let keyboardObserver = KeyboardObserver()

    var appeared = false {
        didSet {
            container.appeared = appeared
        }
    }
    
    var animationsDuration: Double = 0.2 {
        didSet {
            backgroundView.animationsDuration = animationsDuration
            container.animationsDuration = animationsDuration
        }
    }
    
    fileprivate let backgroundView = SBackgroundView()
    fileprivate let container = SAlertsContainer()
    
    fileprivate var firstLayoutPassed = false
    
    var backgroundPressed: (() -> ())?
    
    // MARK: - Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        baseInit()
    }
    
    func baseInit() {
        container.animator = animator
        modalPresentationStyle = .overFullScreen
        keyboardObserver.keyboardFrameWillChange = { [weak self] (endFrame, duration, options) in
            self?.keyboardFrameChanged(frame: endFrame, duration: duration, options: options)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        
        for view in [backgroundView ,container] {
            self.view.addSubview(view)
        }
        
        container.backgroundPressed = { [weak self] in
            guard let action = self?.backgroundPressed else { return }
            action()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstLayoutPassed {
            appear()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in [backgroundView, container] {
            view.frame = self.view.bounds
        }
        
        if !firstLayoutPassed {
            appear()
            firstLayoutPassed = true
        }
    }
    
    func change(backgrounType type: SBackgroundViewType) {
        backgroundView.change(backgrounType: type)
    }
    
    // MARK: - Appearence
    
    private func appear() {
        ([ backgroundView, container] as [Appearable]).forEach({ $0.appear(animated: true) })
        appeared = true
    }
    
    func dismiss(_ completion: @escaping () -> ()) {
        let views: [Appearable] = [backgroundView, container] as [Appearable]
        UIView.animate(withDuration: animationsDuration,
                       animations: {
                        views.forEach({
                            $0.dismiss()
                        })
        }) { _ in
            self.container.removeAllAlerts()
            super.dismiss(animated: false,
                          completion: nil)
            completion()
            self.appeared = false
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        view.backgroundColor = UIColor.clear;
    }
    
    func set(acceptableVerticalScrollOffset: OffsetRange) {
        container.acceptableVerticalScrollOffset = acceptableVerticalScrollOffset
    }
    
    func set(acceptableHorisontalScrollOffset: OffsetRange) {
        container.acceptableHorisontalScrollOffset = acceptableHorisontalScrollOffset
    }
    
    func set(notAcceptableScrollOffsetReached: @escaping () -> ()) {
        container.notAcceptableOffsetReached = notAcceptableScrollOffsetReached
    }

    func keyboardFrameChanged(frame: CGRect, duration: TimeInterval, options: UIViewAnimationOptions?) {
        container.keyboardVisibleHeight = { (endFrame, containerHeight) in
            if endFrame.origin.y >= containerHeight {
                return 0
            }else{
                return containerHeight - endFrame.origin.y
            }
        }(frame, container.frame.size.height)
        
        container.layoutOnKeyboardVisibleHeightChanged(duration: duration, options: options)
    }
    
}

// MARK: - SManagedAlertViewContainer
extension SAlertViewController: SManagedAlertViewContainer {
    
    func add(alertView alert: UIView, configuration: SConfiguration) {
        container.add(alertView: alert, configuration: configuration)
    }
    
    func remove(alertView alert: UIView) {
        container.remove(alertView: alert)
    }
    
    func removeAllAlerts() {
        container.removeAllAlerts()
    }
    
    func update(alertView alert: UIView) {
        container.update(alertView: alert)
    }
    
    func updateAllAlertViews() {
        container.updateAllAlertViews()
    }
    
    func set(configuration: SConfiguration, toAlertView alert: UIView) {
        container.set(configuration: configuration, toAlertView: alert)
    }
    
}
