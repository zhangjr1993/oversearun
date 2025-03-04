//
//  HomeCommonTagsView.swift
//  AIRun
//
//  Created by Bolo on 2025/1/21.
//

import UIKit

enum HomeCommonTagsViewType {
    case homelist
    case aiHome
    case diyList
}

struct HomeCommonTagsSize {
    /// 内边距
    var edge: CGFloat
    /// 高度
    var height: CGFloat
    /// 透明度
    var font: UIFont
    /// 透明度
    var alpha: CGFloat
    /// 左右间距
    var itemSpace: CGFloat
    /// 上下间距
    var lineSpace: CGFloat
    /// 最大宽度
    var width: CGFloat
}

class HomeCommonTagsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func adaptFrame(type: HomeCommonTagsViewType) -> HomeCommonTagsSize {
        switch type {
        case .homelist:
            return HomeCommonTagsSize(edge: 12, height: 16, font: .regularFont(size: 12), alpha: 0.38, itemSpace: 4, lineSpace: 6, width: UIScreen.homeListHeaderWidth - 16)
        case .aiHome:
            return HomeCommonTagsSize(edge: 24, height: 24, font: .regularFont(size: 15), alpha: 0.6, itemSpace: 8, lineSpace: 8, width: UIScreen.screenWidth-32)
        case .diyList:
            return HomeCommonTagsSize(edge: 12, height: 16, font: .regularFont(size: 12), alpha: 0.6, itemSpace: 4, lineSpace: 4, width: UIScreen.screenWidth - 98 - 52)
        }
    }
}

extension HomeCommonTagsView {
    @discardableResult
    func configure(tags: [String], type: HomeCommonTagsViewType) -> CGFloat {
        
        let adapt = adaptFrame(type: type)
        
        // 清除现有的标签
        self.removeAllSubviews()
            
        // 添加新的标签
        var rect = CGRect(x: 0, y: 0, width: 0, height: adapt.height)
        tags.indices.forEach { index in

            let label = UILabel()
            label.font = adapt.font
            label.textColor = .whiteColor(alpha: adapt.alpha)
            label.textAlignment = .center
            label.backgroundColor = UIColor.init(hexStr: "#333333")
            label.layer.cornerRadius = adapt.height/2
            label.layer.masksToBounds = true
            label.text = tags[index]
            label.tag = index
            
            let size = label.sizeThatFits(CGSize(width: CGFLOAT_MAX, height: adapt.height))
            rect.size = CGSize(width: size.width+adapt.edge, height: adapt.height)
            
            if rect.origin.x + rect.size.width > adapt.width {
                rect.origin = CGPoint(x: 0, y: CGRectGetMaxY(rect)+adapt.lineSpace)
            }
            
            label.frame = rect
            rect.origin.x = CGRectGetMaxX(rect) + adapt.itemSpace

            self.addSubview(label)
        }
        return CGRectGetMaxY(rect)
    }
}
