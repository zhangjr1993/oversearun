//
//  UIImage+Extension.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import Foundation
import Accelerate

// 渐变色方向
enum GradientType {
    case topToBottom
    case leftToRight
    case midToMid
}

extension UIImage {
    
    static func createColorImg(color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return img!
    }
    
    // 创建颜色图片
    static func createColorImg(color: UIColor, size: CGSize, radius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: radius)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.addPath(path.cgPath)
        context?.fillPath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /// 按钮背景图
    static func createButtonImage(type: ButtonBackgroundColorType, size: CGSize, direction: GradientType = .leftToRight, isEnable: Bool = true, isCorner: CGFloat = 0) -> UIImage {
        
        let colors: Array<CGColor>
        switch type {
        case .normal:
            colors = UIColor.appGradientColor()
        case .disableNormal:
            colors = UIColor.appGradientDisColor()
        case .lightGray:
            colors = [UIColor.whiteColor(alpha: 0.05).cgColor, UIColor.whiteColor(alpha: 0.05).cgColor]
        }
        
        let img = UIImage.createGradientImg(colors: colors, size: size, type: direction)
        if isCorner == 0 {
            return img
        }
        
        return img.isRoundCorner(isCorner)
    }
    
    // 创建渐变色图片
    static func createGradientImg(colors: Array<CGColor>, size: CGSize, type: GradientType = .leftToRight) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let graidentLayer = CAGradientLayer.init()
        graidentLayer.colors = colors
        if type == .leftToRight {
            graidentLayer.startPoint = CGPoint(x: 0, y: 0)
            graidentLayer.endPoint = CGPoint(x: 1, y: 0)
        }else if type == .topToBottom {
            graidentLayer.startPoint = CGPoint(x: 0, y: 0)
            graidentLayer.endPoint = CGPoint(x: 0, y: 1)
        }else {
            graidentLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            graidentLayer.endPoint = CGPoint(x: -0.5, y: 0.5)
        }
        if colors.count == 3 {
            graidentLayer.locations = [0, 0.48, 1]
        }
        
        graidentLayer.frame = CGRect(x: 0, y: 0, width: ceil(size.width), height: ceil(size.height))
        let context = UIGraphicsGetCurrentContext()
        graidentLayer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func isRoundCorner(_ radius: CGFloat = 24) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.addPath(UIBezierPath(roundedRect: rect,
                                          byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: radius, height: radius)).cgPath)
            context.clip()
            self.draw(in: rect)
            context.drawPath(using: .stroke)
            let output = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return output!
        }
        
        return UIImage()
    }
    
    // 图片饱和度，0灰色
    func adjustSaturation(saturation: CGFloat) -> UIImage? {
        guard saturation != 1.0 else { return self }
        
        let inputImage = CIImage(image: self)
        let saturationFilter = CIFilter(name: "CIColorControls")!
        saturationFilter.setDefaults()
        saturationFilter.setValue(inputImage, forKey: kCIInputImageKey)
        saturationFilter.setValue(saturation, forKey: "inputSaturation")
        
        let processedImage = saturationFilter.outputImage!
        let outputImage = UIImage(ciImage: processedImage)
        
        return outputImage
    }
    
    // 修改图片填充色
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func fiterImage() -> UIImage? {
        // 1. 创建CIImage
        let ciImage = CIImage(image: self)
        
        // 2. 创建滤镜CIFilter
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        
        // 2.1. 将CIImage输入到滤镜中
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        // 可以通过该方法查看我们可以设置的值（如模糊度等）
        print(blurFilter?.attributes ?? [:] )
        
        // 2.2 设置模糊度
        blurFilter?.setValue(10, forKey: "inputRadius")
        
        // 2.3 将处理好的图片输出
        let outCiImage = blurFilter?.value(forKey: kCIOutputImageKey) as? CIImage
        
        // 3. CIContext（option参数为nil代表用CPU渲染，若想用GPU渲染请查看此参数）
        let context = CIContext(options: nil)
        
        // 4. 获取CGImage句柄
        if let outCiImage2 = outCiImage, let outCGImage = context.createCGImage(outCiImage2, from: outCiImage2.extent) {
            // 5. 获取最终的图片
            let blurImage = UIImage(cgImage: outCGImage)
            
            return blurImage
        }
        return nil
    }
         
    func blurImage(blur: CGFloat) -> UIImage? {

        var temBlur = blur
        if temBlur < 0 || temBlur > 1 {
            temBlur = 0.5
        }
        var boxSize: Int = Int(temBlur * 100)
        boxSize = boxSize - (boxSize % 2) + 1
        
        let image = self.cgImage
        let inProvider = image?.dataProvider

        let height = vImagePixelCount((image?.height)!)
        let width = vImagePixelCount((image?.width)!)
        let rowBytes = image?.bytesPerRow

        var inBitmapData = inProvider?.data
        let inData = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes!)

        let outData = malloc((image?.bytesPerRow)! * (image?.height)!)
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes!)

        var error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        inBitmapData = nil
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: outBuffer.data, width: Int(outBuffer.width), height: Int(outBuffer.height), bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: (image?.bitmapInfo.rawValue)!, releaseCallback: {(ptr1, ptr2) in
        }, releaseInfo: outData)!
        var imageRef = context.makeImage()
        let bluredImage = UIImage(cgImage: imageRef!)
        imageRef = nil
        free(outData)
        context.flush()
        context.synchronize()
        return bluredImage
    }
    
    func compressImage(maxLength: Int) -> Data? {

        var compress: CGFloat = 1
        var data = self.jpegData(compressionQuality: compress)
        while (data?.count)! > maxLength && compress > 0.01 {
            compress -= 0.1
            data = self.jpegData(compressionQuality: compress)
        }
        return data
    }
}

extension UIImage {
    static func imgNamed(name: String) -> UIImage {
        
        var ret = UIImage.init(named: name)
        if ret == nil {
            printLog(message: name)
            let placeName = "icon_img_place"
            ret = UIImage.init(named: placeName)
        }
        return ret!
    }
    
    static func basicPlaceholderImg() -> UIImage {
        let placeName = "icon_img_place"
        return imgNamed(name: placeName)
    }
  
    
    static func resizedImageWithName(name: String, edge: UIEdgeInsets) -> UIImage {
        let ret: UIImage = UIImage.init(named: name)!
        return ret.resizableImage(withCapInsets: edge, resizingMode: .stretch)
    }
    
    static func isEnoughImageSize(with targetSize: CGSize) -> Bool {
        var enough = false
        if targetSize.width > 500 && targetSize.height > 500 {
            enough = true
        }
        return enough
    }
}






extension UIImage {
    
    // 重设图片大小
    func reSizeImage(reSize: CGSize)-> UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    // 等比率缩放
    func scaleImage(scaleSize: CGFloat)-> UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }

    /// 通过指定图片最长边，获得等比例的图片size
    func scaleImage(imageLength: CGFloat) -> CGSize {
        var newWidth: CGFloat = self.size.width
        var newHeight: CGFloat = self.size.height
        let width = self.size.width
        let height = self.size.height
        if (width > imageLength || height > imageLength) {
            if (width > height) {
                newWidth = imageLength
                newHeight = newWidth * height / width
            }else if (height > width) {
                newHeight = imageLength
                newWidth = newHeight * width / height
            }else {
                newWidth = imageLength
                newHeight = imageLength
            }
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /// 按图片控件比例裁剪图片
    func cropScaleImage(imgVRatio: CGFloat) -> UIImage? {
        var newW = self.size.width
        var newH = self.size.height
        let imgRatio = newW / newH
        if imgVRatio > imgRatio {
            newH = newW/imgVRatio
        }else {
            newW = newH*imgVRatio
        }
        let sourceImageRef = self.cgImage
        let rect = CGRect(x: 0, y: 0, width: newW, height: newH)
        guard let newImageRef: CGImage = sourceImageRef?.cropping(to: rect)
        else {
            return nil
        }
        let newImage = UIImage(cgImage: newImageRef)
        return newImage
    }
    
    func cropMaxEdgeImage() -> UIImage? {
        let maxEdge = min(self.size.width, self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxEdge, height: maxEdge), false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let croped = UIGraphicsGetImageFromCurrentImageContext()
        return croped
    }
    
    func cropMaxWidthImage(maxWidth: CGFloat) -> UIImage? {
        let scale = maxWidth / self.size.width
        // 新高度
        let newHeight = self.size.height * scale
        let targetSize = CGSize(width: maxWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func cropTargetImage(targetSize: CGSize) -> UIImage? {
        let sourceSize = self.size
        
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
        
        self.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()

    }
    
}
