import Foundation
import UIKit

class TypewriterAnimationManager {
    
    private var displayLink: CADisplayLink?
    private var currentIndex: Int = 0
    private var fullText: String = ""
    private var attributedText: NSAttributedString?
    private var updateCallback: ((String) -> Void)?
    private var completionCallback: (() -> Void)?
    private var characterDelay: TimeInterval = 0.01
    private var lastUpdateTime: TimeInterval = 0
    
    private var isAnimating: Bool = false
    
    func startAnimation(text: String, attributedText: NSAttributedString? = nil, characterDelay: TimeInterval = 0.05, update: @escaping (String) -> Void, completion: (() -> Void)? = nil) {
        stopAnimation()
        
        self.fullText = text
        self.attributedText = attributedText
        self.characterDelay = characterDelay
        self.updateCallback = update
        self.completionCallback = completion
        self.currentIndex = 0
        self.lastUpdateTime = CACurrentMediaTime()
        self.isAnimating = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func pauseAnimation() {
        displayLink?.isPaused = true
    }
    
    func resumeAnimation() {
        lastUpdateTime = CACurrentMediaTime()
        displayLink?.isPaused = false
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
        currentIndex = 0
    }
    
    @objc private func updateAnimation() {
        guard isAnimating else { return }
        
        let currentTime = CACurrentMediaTime()
        guard (currentTime - lastUpdateTime) >= characterDelay else { return }
        
        if currentIndex < fullText.count {
            let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
            let substring = String(fullText[...index])
            updateCallback?(substring)
            currentIndex += 1
            lastUpdateTime = currentTime
        } else {
            stopAnimation()
            completionCallback?()
        }
    }
    
    deinit {
        stopAnimation()
    }
} 
