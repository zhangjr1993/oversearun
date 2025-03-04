import UIKit

class AICustomPresentationController: UIPresentationController {
    
    // MARK: - Properties
    private let initialHeight: CGFloat
    private let maxHeight: CGFloat
    private let dismissHeight: CGFloat
    
    private var currentHeight: CGFloat
    private var isInteractive = false
    private var isDraggingFromHandle = false
    private var isTableViewAtTop = true
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var handleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(handleView)
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "btn_back_White"), for: .normal)
        button.addTarget(self, action: #selector(handleBackButtonTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    // MARK: - Initialization
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         initialHeight: CGFloat,
         maxHeight: CGFloat,
         dismissHeight: CGFloat) {
        self.initialHeight = initialHeight
        self.maxHeight = maxHeight
        self.dismissHeight = dismissHeight
        self.currentHeight = initialHeight
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // MARK: - Overrides
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0,
                     y: containerView.bounds.height - currentHeight,
                     width: containerView.bounds.width,
                     height: currentHeight)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        // Add dimming view
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)
        
        // Add handle container with larger touch area
        handleContainer.frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: 44)
        handleView.frame = CGRect(x: (containerView.bounds.width - 40) / 2,
                                y: 8,
                                width: 40,
                                height: 5)
        presentedView?.addSubview(handleContainer)
        
        // Add back button
        backButton.frame = CGRect(x: 11, y: 8, width: 34, height: 44)
        presentedView?.addSubview(backButton)
        
        // Add pan gesture to both handle container and presented view
        handleContainer.addGestureRecognizer(panGesture)
        presentedView?.addGestureRecognizer(panGesture)
        
        // Corner radius for presented view
        presentedView?.layer.cornerRadius = 12
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.layer.masksToBounds = true
        
        // Animate dimming view
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 0.0
        }
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmingView.frame = containerView?.bounds ?? .zero
        
        // Update UI elements visibility based on height
        updateUIElementsVisibility()
    }
    
    // MARK: - Private Methods
    private func updateUIElementsVisibility() {
        let isAtMaxHeight = abs(currentHeight - maxHeight) < 1.0
        handleView.isHidden = isAtMaxHeight
        backButton.isHidden = !isAtMaxHeight
    }
    
    @objc private func handleBackButtonTap() {
        presentedViewController.dismiss(animated: true)
//        animateHeight(to: initialHeight)
    }
    
    // MARK: - Public Methods
    func adjustHeight(for scrollView: UIScrollView) {
        guard !isInteractive else { return }
        
        let offsetY = scrollView.contentOffset.y
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        // 更新tableView是否在顶部的状态
        isTableViewAtTop = offsetY <= 0
        
        if currentHeight == maxHeight {
            // 在最大高度时，只有当tableView在顶部并且继续向下滑动时才处理
            if isTableViewAtTop && velocity > 0 {
                animateHeight(to: initialHeight)
                scrollView.setContentOffset(.zero, animated: false)
            }
        } else if currentHeight == initialHeight && velocity < 0 {
            // 在初始高度时，向上滑动展开到最大高度
            animateHeight(to: maxHeight)
        }
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else { return }
        
        let translation = gesture.translation(in: presentedView)
        isDraggingFromHandle = gesture.view == handleContainer
        
        switch gesture.state {
        case .began:
            isInteractive = true
            
        case .changed:
            let newHeight = currentHeight - translation.y
            
            // 如果在最大高度，不是从handle拖拽，并且tableView不在顶部，则不处理向上拖拽
            if currentHeight == maxHeight && !isDraggingFromHandle && !isTableViewAtTop && translation.y < 0 {
                gesture.setTranslation(.zero, in: presentedView)
                return
            }
            
            // Constrain the height between dismissHeight and maxHeight
            currentHeight = min(maxHeight, max(dismissHeight, newHeight))
            containerViewDidLayoutSubviews()
            
            gesture.setTranslation(.zero, in: presentedView)
            
        case .ended, .cancelled:
            isInteractive = false
            let velocity = gesture.velocity(in: presentedView)
            
            // 处理手势结束时的状态
            if velocity.y > 1000 || currentHeight <= dismissHeight {
                // 快速上滑或低于消失阈值时关闭
                presentedViewController.dismiss(animated: true)
            } else if currentHeight > initialHeight || velocity.y < -500 {
                // 高于初始高度或快速下滑时展开到最大高度
                animateHeight(to: maxHeight)
            } else {
                // 在消失和初始高度之间时恢复到初始高度
                animateHeight(to: initialHeight)
            }
            
        default:
            break
        }
    }
    
    private func animateHeight(to height: CGFloat) {
        guard !isInteractive else { return }
        
        currentHeight = height
        UIView.animate(withDuration: 0.3,
                      delay: 0,
                      options: .curveEaseOut,
                      animations: { [weak self] in
            self?.containerViewDidLayoutSubviews()
        })
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AICustomPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                          shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果是从handle拖拽，始终允许手势
        if gestureRecognizer == panGesture && isDraggingFromHandle {
            return true
        }
        
        // 否则，只有当tableView在顶部时才允许同时识别
        return isTableViewAtTop
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AICustomPresentationController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
} 
