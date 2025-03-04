//
//  File.swift
//  AIRun
//
//  Created by AIRun on 2023/7/11.
//

import Foundation

class BasePresentViewController: BaseViewController {
    var transition: BasePresentTransition!
    init() {
        super.init(nibName: nil, bundle: nil)
        self.transition = BasePresentTransition.init(target: self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
    
}


class BasePresentTransition: NSObject {
    var showFromBottom = true
    var duration = 0.3
    var tapShouldDismiss = true
    var visualBackAlpha = 0.6
    var frameOfPresentedView = CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    weak var targetVC: UIViewController!
    
    init(target: UIViewController) {
        super.init()
        self.targetVC = target
        target.modalPresentationStyle = .custom
        target.transitioningDelegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCorner(corners: UIRectCorner, radius: CGFloat) {
                
        let viewRect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frameOfPresentedView.size)
        let path = UIBezierPath(roundedRect: viewRect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = viewRect
        maskLayer.path = path.cgPath
        let presentedView: UIView = self.targetVC.view!
        presentedView.layer.mask = maskLayer
        presentedView.layer.masksToBounds = true
    }
}

extension BasePresentTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let res = BasePresentationController.init(transition: self, presentedViewController: presented, presentingViewController: presenting)
        return res
    }
}
                            
extension BasePresentTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        if toVC == targetVC {
            presentTransition(transitionContext: transitionContext)
        } else {
            dismissTransition(transitionContext: transitionContext)
        }
    }
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        guard let presentedView = toVC?.view else {
            return
        }
        let containerView = transitionContext.containerView
        containerView.isUserInteractionEnabled = true
        
        let frame = transitionContext.finalFrame(for: toVC!)
        presentedView.bounds = frame
        containerView.addSubview(presentedView)
        
        if showFromBottom {
            presentedView.top = containerView.bottom
        } else {
            presentedView.alpha = 0
            presentedView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        }
        
        fromVC?.beginAppearanceTransition(false, animated: false)
        toVC?.beginAppearanceTransition(true, animated: false)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            if self.showFromBottom {
                presentedView.bottom = containerView.bottom
            } else {
                presentedView.alpha = 1
                presentedView.transform = CGAffineTransform.identity
            }
        } completion: { finish in
            fromVC?.endAppearanceTransition()
            toVC?.endAppearanceTransition()
            transitionContext.completeTransition(true)
        }
    }
    
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let presentedVC = transitionContext.viewController(forKey: .from)
        guard let presentedView = presentedVC?.view else {
            return
        }
        let containerView = transitionContext.containerView

        presentedVC?.beginAppearanceTransition(false, animated: false)
        toVC?.beginAppearanceTransition(true, animated: false)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            if self.showFromBottom {
                presentedView.top = containerView.bottom
            } else {
                presentedView.alpha = 0
                presentedView.transform = CGAffineTransform.init(scaleX: 0.85, y: 0.85)
            }
        } completion: { finish in
            presentedVC?.endAppearanceTransition()
            toVC?.endAppearanceTransition()
            transitionContext.completeTransition(true)
        }
    }
}

// MARK: - BasePresentationController
class BasePresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    
    var transition: BasePresentTransition!

    init(transition: BasePresentTransition, presentedViewController: UIViewController, presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.transition = transition
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        self.presentedView?.bounds = self.transition.frameOfPresentedView
        return self.transition.frameOfPresentedView
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(visualView)
        addTapGestureRecognizer()
        let transitionCoordinator =  self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {return}
            self.visualView.alpha = self.transition.visualBackAlpha
        })

    }
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            visualView.removeFromSuperview()
        }
    }
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator =  self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {return}
            self.visualView.alpha = 0
        })
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            visualView.removeFromSuperview()
        }
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(func__ViewTapGestureRecognizer))
        tap.delegate = self
        visualView.addGestureRecognizer(tap)
    }
    @objc func func__ViewTapGestureRecognizer() {
        self.presentedViewController.dismiss(animated: true)
    }
    lazy var visualView: UIView = {
        let view = UIView.init()
        view.frame = containerView?.bounds ?? CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        view.backgroundColor = UIColor.appBgColor()
        view.alpha = 0
        view.isUserInteractionEnabled = true
        return view
    }()
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.transition.tapShouldDismiss {
            return true
        } else {
            return false
        }
    }
}


