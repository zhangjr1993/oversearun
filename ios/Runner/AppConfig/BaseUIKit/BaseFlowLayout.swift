//
//  BaseFlowLayout.swift
//  AIRun
//
//  Created by Bolo on 2025/1/20.
//

import Foundation

// MARK: - 标签
class TagLabelsCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}

// MARK: - 瀑布流
@objc protocol WaterfallsCollectionViewLayoutDelegate: NSObjectProtocol {
    /// collectionItem高度
    func heightForRowAtIndexPath(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat

    /// 每个section 列数（默认2列）
    @objc optional func columnNumber(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> Int
    
    /// header高度（默认为0）
    @objc optional func referenceSizeForHeader(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> CGSize
    
    /// footer高度（默认为0）
    @objc optional func referenceSizeForFooter(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> CGSize
    
    /// 每个section 边距（默认为0）
    @objc optional func insetForSection(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> UIEdgeInsets
    
    /// 每个section item上下间距（默认为0）
    @objc optional func lineSpacing(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> CGFloat
    
    /// 每个section item左右间距（默认为0）
    @objc optional func interitemSpacing(collectionView collection: UICollectionView, layout: WaterfallsCollectionViewLayout, section: Int) -> CGFloat
}

class WaterfallsCollectionViewLayout: UICollectionViewLayout {
    
    weak var flowDelegae: WaterfallsCollectionViewLayoutDelegate?
    
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    private var sectionInsets: UIEdgeInsets = .zero
    private var columnCount: Int = 2
    private var lineSpacing: CGFloat = 0
    private var interitemSpacing: CGFloat = 0
    private var headerSize: CGSize = .zero
    private var footerSize: CGSize = .zero

    // 存放attribute的数组
    private var attrsArray: [UICollectionViewLayoutAttributes] = []
    // 存放每个section中各个列的最后一个高度
    private var columnHeights: [CGFloat] = []
    // collectionView的Content的高度
    private var contentHeight: CGFloat = 0
    // 记录上个section高度最高一列的高度
    private var lastContentHeight: CGFloat = 0
    // 每个section的header与上个section的footer距离
    private var spacingWithLastSection: CGFloat = 0
    
    override func prepare() {
        super.prepare()
        self.contentHeight = 0
        self.lastContentHeight = 0
        self.spacingWithLastSection = 0
        self.lineSpacing = 0
        self.sectionInsets = .zero
        self.columnHeights.removeAll()
        self.attrsArray.removeAll()
        
        let sectionCount = self.collectionView!.numberOfSections
        // 遍历section
        for idx in 0..<sectionCount {
            let indexPath = IndexPath(item: 0, section: idx)
            if let columnCount = self.flowDelegae?.columnNumber?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
                self.columnCount = columnCount
            }
            if let inset = self.flowDelegae?.insetForSection?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
                self.sectionInsets = inset
            }
           
            // 生成header
            let itemCount = self.collectionView!.numberOfItems(inSection: idx)
            let headerAttri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            if let header = headerAttri {
                self.attrsArray.append(header)
                self.columnHeights.removeAll()
            }
            self.lastContentHeight = self.contentHeight
            // 初始化区 y值
            for _ in 0..<self.columnCount {
                self.columnHeights.append(self.contentHeight)
            }
            // 多少个item
            for item in 0..<itemCount {
                let indexPat = IndexPath(item: item, section: idx)
                let attri = self.layoutAttributesForItem(at: indexPat)
                if let attri = attri {
                    self.attrsArray.append(attri)
                }
            }
            
            // 初始化footer
            let footerAttri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath)
            if let footer = footerAttri {
                self.attrsArray.append(footer)
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrsArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let column = self.flowDelegae?.columnNumber?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
            self.columnCount = column
        }
        if let lineSpacing = self.flowDelegae?.lineSpacing?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
            self.lineSpacing = lineSpacing
        }
        if let interitem = self.flowDelegae?.interitemSpacing?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
            self.interitemSpacing = interitem
        }
        
        let attri = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        if scrollDirection == .vertical {
            let weight = self.collectionView!.frame.size.width
            let itemSpacing = CGFloat(self.columnCount - 1) * self.interitemSpacing
            let allWeight = weight - self.sectionInsets.left - self.sectionInsets.right - itemSpacing
            let cellWeight = floor(allWeight / CGFloat(self.columnCount))
            let cellHeight: CGFloat = (self.flowDelegae?.heightForRowAtIndexPath(collectionView: self.collectionView!, layout: self, indexPath: indexPath, itemWidth: cellWeight))!
            
            var tmpMinColumn = 0
            var minColumnHeight = self.columnHeights[0]
            for i in 0..<self.columnCount {
                let columnH = self.columnHeights[i]
                if minColumnHeight > columnH {
                    minColumnHeight = columnH
                    tmpMinColumn = i
                }
            }
            let cellX = self.sectionInsets.left + CGFloat(tmpMinColumn) * (cellWeight + self.interitemSpacing)
            var cellY: CGFloat = 0
            cellY = minColumnHeight
            if cellY != self.lastContentHeight {
                cellY += self.lineSpacing
            }
            
            if self.contentHeight < minColumnHeight {
                self.contentHeight = minColumnHeight
            }
            
            attri.frame = CGRect(x: cellX, y: cellY, width: cellWeight, height: cellHeight)
            self.columnHeights[tmpMinColumn] = attri.frame.maxY
            // 取最大的
            for i in 0..<self.columnHeights.count {
                if self.contentHeight < self.columnHeights[i] {
                    self.contentHeight = self.columnHeights[i]
                }
            }

        }else {
            let weight = self.collectionView!.frame.size.height
            let itemSpacing = CGFloat(self.columnCount - 1) * self.interitemSpacing
            let allWeight = weight - self.sectionInsets.top - self.sectionInsets.bottom - itemSpacing
            let cellWeight = floor(allWeight / CGFloat(self.columnCount))
            let cellHeight: CGFloat = (self.flowDelegae?.heightForRowAtIndexPath(collectionView: self.collectionView!, layout: self, indexPath: indexPath, itemWidth: cellWeight))!
            
            var tmpMinColumn = 0
            var minColumnHeight = self.columnHeights[0]
            for i in 0..<self.columnCount {
                let columnH = self.columnHeights[i]
                if minColumnHeight > columnH {
                    minColumnHeight = columnH
                    tmpMinColumn = i
                }
            }
            let cellX = self.sectionInsets.left + CGFloat(tmpMinColumn) * (cellWeight + self.interitemSpacing)
            var cellY: CGFloat = 0
            cellY = minColumnHeight
            if cellY != self.lastContentHeight {
                cellY += self.lineSpacing
            }
            
            if self.contentHeight < minColumnHeight {
                self.contentHeight = minColumnHeight
            }
            
            attri.frame = CGRect(x: cellX, y: cellY, width: cellWeight, height: cellHeight)
            self.columnHeights[tmpMinColumn] = attri.frame.maxY
            // 取最大的
            for i in 0..<self.columnHeights.count {
                if self.contentHeight < self.columnHeights[i] {
                    self.contentHeight = self.columnHeights[i]
                }
            }

        }
                
        return attri
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        if elementKind == UICollectionView.elementKindSectionHeader {
            if let headerSize = self.flowDelegae?.referenceSizeForHeader?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
                self.headerSize = headerSize
            }
            
            self.contentHeight += self.spacingWithLastSection
            attri.frame = CGRect(x: 0, y: self.contentHeight, width: self.headerSize.width, height: self.headerSize.height)
            self.contentHeight += self.headerSize.height
            self.contentHeight += self.sectionInsets.top
            
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerSize = self.flowDelegae?.referenceSizeForFooter?(collectionView: self.collectionView!, layout: self, section: indexPath.section) {
                self.footerSize = footerSize
            }
            self.contentHeight += self.sectionInsets.bottom
            attri.frame = CGRect(x: 0, y: self.contentHeight, width: self.footerSize.width, height: self.footerSize.height)
            self.contentHeight += self.footerSize.height
            
        }
        return attri
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.collectionView!.frame.size.width, height: self.contentHeight)
    }
}


