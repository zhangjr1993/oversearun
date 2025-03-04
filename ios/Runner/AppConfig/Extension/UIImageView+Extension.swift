//
//  UIImageView+Extension.swift
//  AIRun
//
//  Created by Bolo on 2025/1/17.
//

import Foundation

extension UIImageView {
        
//    func setUrlImage(urlStr: String,
//                     placeImg: UIImage? = UIImage.basicPlaceholderImg(),
//                     options: KingfisherOptionsInfo? = nil,
//                     loadFinish: ((_ isSucceed: Bool, _ image: UIImage?) -> Void)? = nil) {
//
//        if urlStr.isValidStr {
//            var tempUrl = urlStr
//            if !urlStr.hasPrefix("https://") && !urlStr.hasPrefix("http://"){
//                tempUrl = APPManager.default.config.staticUrlDomain + "/\(urlStr)"
//            }
//            self.kf.setImage(with: URL(string: tempUrl), placeholder: placeImg, options: options) { result in
//                if loadFinish != nil {
//                    let image = try? result.get().image
//                    loadFinish!(true, image)
//                }
//            }
//        }else {
//            self.image = placeImg
//        }
//    }
    
    func loadNetImage(url: String,
                      cropType: ImageCropType? = nil,
                      defaultImage: UIImage? = UIImage.basicPlaceholderImg(),
                      options: KingfisherOptionsInfo? = nil,
                      downloadFinish: ((_ isSucceed: Bool, _ image: UIImage?) -> Void)? = nil) {
        
        guard url.isValidStr else {
            self.image = defaultImage
            return
        }
        
        var tempUrl = url
        if !url.hasPrefix("https://") && !url.hasPrefix("http://"){
            tempUrl = APPManager.default.config.staticUrlDomain + "/\(url)"
        }
        
        var tempOptions = options
        if options == nil {
            tempOptions = [
                .cacheOriginalImage,
                .backgroundDecode,
                .memoryCacheExpiration(.seconds(300)),
                .diskCacheExpiration(.days(7))
            ]
        }
        
        if let cropType {
            switch cropType {
            case .maximumEdge(let imgSize):
                let processer = MaxEdgeImageProcessor.init(targetSize: imgSize)
                tempOptions?.append(.processor(processer))
            case .equalProportion:
                let processer = EqualProportionImageProcessor.init()
                tempOptions?.append(.processor(processer))
            }
        }
        
        self.kf.setImage(with: URL(string: tempUrl),
                         placeholder: defaultImage,
                         options: tempOptions) { result in
            if let completion = downloadFinish {
                let image = try? result.get().image
                completion(true, image)
            }
        }
    }
}
