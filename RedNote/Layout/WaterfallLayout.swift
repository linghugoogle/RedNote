//
//  WaterfallLayout.swift
//  RedNote
//
//  Created by linghugoogle on 2025/10/21.
//

import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
    func waterfallLayout(_ layout: WaterfallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelegate?
    
    var numberOfColumns: Int = 2
    var minimumColumnSpacing: CGFloat = 8
    var minimumInteritemSpacing: CGFloat = 8
    var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var itemWidth: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        // Reset cache
        cache.removeAll()
        contentHeight = sectionInset.top
        
        // Calculate item width
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right - CGFloat(numberOfColumns - 1) * minimumColumnSpacing
        itemWidth = availableWidth / CGFloat(numberOfColumns)
        
        // Initialize column heights
        var columnHeights = Array(repeating: sectionInset.top, count: numberOfColumns)
        
        // Process all sections
        let numberOfSections = collectionView.numberOfSections
        for section in 0..<numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                
                // 选取当前高度最小的列，实现真正瀑布流
                let minColumnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
                let xOffset = sectionInset.left + CGFloat(minColumnIndex) * (itemWidth + minimumColumnSpacing)
                let yOffset = columnHeights[minColumnIndex]
                
                // Get item height from delegate
                let itemHeight = delegate?.waterfallLayout(self, heightForItemAt: indexPath) ?? 200
                
                // Calculate frame
                let frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                
                // Create layout attributes
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                
                // Update column height
                columnHeights[minColumnIndex] = frame.maxY + minimumInteritemSpacing
            }
        }
        
        // Update content height
        contentHeight = (columnHeights.max() ?? 0) + sectionInset.bottom
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }
}