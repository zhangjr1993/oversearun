//
//  AppImageProcessor.swift
//  AIRun
//
//  Created by Bolo on 2025/1/17.
//

import Foundation

// MARK: - 最大边
struct MaxEdgeImageProcessor: ImageProcessor {
    let identifier: String
    
    let targetSize: CGSize
    
    let targetPoint: CGPoint
    
    init(targetSize: CGSize, targetPoint: CGPoint = .zero) {
        self.targetPoint = targetPoint
        self.targetSize = targetSize
        self.identifier = "com.airun.ALMaxEdgeImageProcessor(\(targetSize))"
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return autoreleasepool { () -> UIImage? in
                let sourceSize = image.size
                
                // 计算缩放比例
                let widthRatio = targetSize.width / sourceSize.width
                let heightRatio = targetSize.height / sourceSize.height
                let scale = max(widthRatio, heightRatio)
                
                // 计算新的尺寸
                let scaledSize = CGSize(
                    width: sourceSize.width * scale,
                    height: sourceSize.height * scale
                )
                
                // 创建绘图上下文
                UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
                defer {
                    UIGraphicsEndImageContext()
                }
                
                image.draw(in: CGRect(x: targetPoint.x, y: targetPoint.y, width: scaledSize.width, height: scaledSize.height))
                
                return UIGraphicsGetImageFromCurrentImageContext()
            }

        case .data:
            return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}

// MARK: - 等边
struct EqualProportionImageProcessor: ImageProcessor {
    let identifier: String
        
    let point: CGPoint
    
    init(targetPoint: CGPoint = .zero) {
        self.point = targetPoint
        self.identifier = "com.airun.ALEqualProportionImageProcessor(MaxEdge)"
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return autoreleasepool { () -> UIImage? in
                let maxEdge = min(image.size.width, image.size.height)

                
                // 创建绘图上下文
                UIGraphicsBeginImageContextWithOptions(CGSize(width: maxEdge, height: maxEdge), false, UIScreen.main.scale)
                defer {
                    UIGraphicsEndImageContext()
                }
                
                image.draw(in: CGRect(x: point.x, y: point.y, width: image.size.width, height: image.size.height))
                return UIGraphicsGetImageFromCurrentImageContext()
            }

        case .data:
            return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}
