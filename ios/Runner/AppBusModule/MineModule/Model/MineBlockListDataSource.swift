//
//  MineBlockListDataSource.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class MineBlockListTitleImageItemModel: JXSegmentedTitleItemModel {
    var normalImageInfo: String?
    var selectedImageInfo: String?
    var imageSize: CGFloat = 12 * 2
    var isImageZoomEnabled: Bool = false
    var imageNormalZoomScale: CGFloat = 0
    var imageCurrentZoomScale: CGFloat = 0
    var imageSelectedZoomScale: CGFloat = 0
    var normalImage: UIImage?
    var selectedImage: UIImage?
}

class MineBlockListDataSource: JXSegmentedTitleDataSource {
    /// 数量需要和item的数量保持一致。可以是ImageName或者图片网络地址
    var normalImageInfos: [String]?
    /// 数量需要和item的数量保持一致。可以是ImageName或者图片网络地址。如果不赋值，选中时就不会处理图片切换。
    var selectedImageInfos: [String]?
    /// 图片尺寸比文字多出来的部分
    var imageSize: CGFloat = 12 * 2
    /// 是否开启图片缩放
    var isImageZoomEnabled: Bool = false
    /// 图片缩放选中时的scale
    var imageSelectedZoomScale: CGFloat = 1.2
    /// 直接设置图片
    var normalImage: UIImage?
    /// 直接设置图片
    var selectedImage: UIImage?
    
    override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
        return MineBlockListTitleImageItemModel()
    }

    override func preferredRefreshItemModel(_ itemModel: JXSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let itemModel = itemModel as? MineBlockListTitleImageItemModel else {
            return
        }

        itemModel.normalImageInfo = normalImageInfos?[index]
        itemModel.selectedImageInfo = selectedImageInfos?[index]
        itemModel.imageSize = imageSize
        itemModel.isImageZoomEnabled = isImageZoomEnabled
        itemModel.imageNormalZoomScale = 1
        itemModel.imageSelectedZoomScale = imageSelectedZoomScale
        itemModel.normalImage = normalImage
        itemModel.selectedImage = selectedImage

        if index == selectedIndex {
            itemModel.imageCurrentZoomScale = itemModel.imageSelectedZoomScale
        }else {
            itemModel.imageCurrentZoomScale = itemModel.imageNormalZoomScale
        }
    }

    override func preferredSegmentedView(_ segmentedView: JXSegmentedView, widthForItemAt index: Int) -> CGFloat {
        let width = super.preferredSegmentedView(segmentedView, widthForItemAt: index)
        return width + imageSize
    }

//    public override func segmentedView(_ segmentedView: JXSegmentedView, widthForItemContentAt index: Int) -> CGFloat {
//        let width = super.segmentedView(segmentedView, widthForItemContentAt: index)
//        return width + imageSize
//    }

    //MARK: - JXSegmentedViewDataSource
    override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(MineBlockListTitleImageCell.self, forCellWithReuseIdentifier: "cell")
    }

    override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }

    override func refreshItemModel(_ segmentedView: JXSegmentedView, leftItemModel: JXSegmentedBaseItemModel, rightItemModel: JXSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)

        guard let leftModel = leftItemModel as? MineBlockListTitleImageItemModel, let rightModel = rightItemModel as? MineBlockListTitleImageItemModel else {
            return
        }
        if isImageZoomEnabled && isItemTransitionEnabled {
            leftModel.imageCurrentZoomScale = JXSegmentedViewTool.interpolate(from: imageSelectedZoomScale, to: 1, percent: CGFloat(percent))
            rightModel.imageCurrentZoomScale = JXSegmentedViewTool.interpolate(from: 1, to: imageSelectedZoomScale, percent: CGFloat(percent))
        }
    }

    override func refreshItemModel(_ segmentedView: JXSegmentedView, currentSelectedItemModel: JXSegmentedBaseItemModel, willSelectedItemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)

        guard let myCurrentSelectedItemModel = currentSelectedItemModel as? MineBlockListTitleImageItemModel, let myWillSelectedItemModel = willSelectedItemModel as? MineBlockListTitleImageItemModel else {
            return
        }

        myCurrentSelectedItemModel.imageCurrentZoomScale = myCurrentSelectedItemModel.imageNormalZoomScale
        myWillSelectedItemModel.imageCurrentZoomScale = myWillSelectedItemModel.imageSelectedZoomScale
    }
}

class MineBlockListTitleImageCell: JXSegmentedTitleCell {
    public let imageView = UIImageView()
    private var currentImageInfo: String?

    override func prepareForReuse() {
        super.prepareForReuse()

        currentImageInfo = nil
    }

    override func commonInit() {
        super.commonInit()

        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        contentView.bringSubviewToFront(titleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let myItemModel = itemModel as? MineBlockListTitleImageItemModel else {
            return
        }

        
        titleLabel.center = CGPoint(x: contentView.bounds.size.width/2, y: contentView.bounds.size.height/2)
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: contentView.bounds.size.width, height: 26))
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
    }

    override func reloadData(itemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let myItemModel = itemModel as? MineBlockListTitleImageItemModel else {
            return
        }

        titleLabel.isHidden = false
        imageView.isHidden = false

        var normalImageInfo = myItemModel.normalImageInfo
        if myItemModel.isSelected && myItemModel.selectedImageInfo != nil {
            normalImageInfo = myItemModel.selectedImageInfo
        }

        if normalImageInfo != nil && normalImageInfo != currentImageInfo {
            imageView.image = UIImage(named: normalImageInfo!)
        }
        if myItemModel.normalImage != nil, myItemModel.selectedImage != nil {
            imageView.image = myItemModel.isSelected ? myItemModel.selectedImage : myItemModel.normalImage
        }

        if myItemModel.isImageZoomEnabled {
            imageView.transform = CGAffineTransform(scaleX: myItemModel.imageCurrentZoomScale, y: myItemModel.imageCurrentZoomScale)
        }else {
            imageView.transform = .identity
        }

        setNeedsLayout()
    }
}
