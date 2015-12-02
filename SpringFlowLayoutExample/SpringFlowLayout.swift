//
//  SpringFlowLayout.swift
//  SpringFlowLayoutExample
//
//  Created by Shunki Tan on 2015/12/02.
//  Copyright © 2015年 eureka. All rights reserved.
//

import Foundation
import UIKit

class SpringFlowLayout: UICollectionViewFlowLayout {
    
    var scrollResistanceFactor: CGFloat = 1000
    var boundaryScrollResistanceFactor: CGFloat = 10
    var springDamping: CGFloat = 1
    
    private var animator: UIDynamicAnimator!
    private var visibleIndexPaths = Set<NSIndexPath>()
    private var addedBehaviors = [NSIndexPath: UIAttachmentBehavior]()
    
    override init() {
        
        super.init()
        self.animator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.animator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        guard let collectionView = self.collectionView else {
            
            return
        }
        
        // 初回レイアウトを避けるため
        if self.animator.behaviors.count != 0 {
            
            let contentOffset = collectionView.contentOffset.y
            let contentSize = collectionView.contentSize.height
            let collectionViewSize = collectionView.bounds.size.height
            
            if contentOffset < 0 {
                
                let distanceFromEdge = fabs(contentOffset)
                let offset = distanceFromEdge / self.boundaryScrollResistanceFactor
                
                for behavior in self.animator.behaviors {
                    
                    guard let behavior = behavior as? UIAttachmentBehavior, let item = behavior.items.first as? UICollectionViewLayoutAttributes else {
                        
                        continue
                    }
                    
                    item.center.y = self.itemSize.height / 2 + offset + (self.minimumInteritemSpacing + self.itemSize.height + offset) * CGFloat(item.indexPath.item) - distanceFromEdge
                    
                    self.animator.updateItemUsingCurrentState(item)
                }
                
                return
            } else if contentOffset + collectionViewSize > contentSize {
                
                let distanceFromEdge = fabs(contentOffset + collectionViewSize - contentSize)
                let offset = distanceFromEdge / self.boundaryScrollResistanceFactor
                let itemCount = collectionView.numberOfItemsInSection(0)
                
                for behavior in self.animator.behaviors {
                    
                    guard let behavior = behavior as? UIAttachmentBehavior, let item = behavior.items.first as? UICollectionViewLayoutAttributes else {
                        
                        continue
                    }
                    
                    item.center.y = contentSize - (self.itemSize.height / 2 + offset + (self.minimumInteritemSpacing + self.itemSize.height + offset) * CGFloat(itemCount - item.indexPath.item - 1) - distanceFromEdge)
                    
                    self.animator.updateItemUsingCurrentState(item)
                }
                return
            }
        }
        
        // 初回レイアウト、中間をスクロールしているとき
        let visibleRect = CGRectInset(CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size), 0, -100)
        
        guard let visibleItems = super.layoutAttributesForElementsInRect(visibleRect) else {
            
            return
        }
        
        let visibleIndexPaths = visibleItems.map { $0.indexPath }
        let noLongerVisibleIndexPaths = self.visibleIndexPaths.subtract(visibleIndexPaths)
        self.visibleIndexPaths = Set(visibleIndexPaths)
        
        for indexPath in noLongerVisibleIndexPaths {
            
            if let behavior = self.addedBehaviors[indexPath] {
                
                self.animator.removeBehavior(behavior)
                self.addedBehaviors.removeValueForKey(indexPath)
            }
        }
        
        for item in visibleItems {
            
            if let _ = self.addedBehaviors[item.indexPath] {
                
                continue
            }
            
            let behavior = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
            behavior.length = 0
            behavior.damping = self.springDamping
            behavior.frequency = 1.0
            
            self.animator.addBehavior(behavior)
            self.addedBehaviors[item.indexPath] = behavior
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return self.animator.itemsInRect(rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.animator.layoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        
        guard let collectionView = self.collectionView else {
            
            return false
        }
        
        let contentOffset = collectionView.contentOffset.y
        let contentSize = collectionView.contentSize.height
        let collectionViewSize = collectionView.bounds.size.height
        
        if 0 <= contentOffset && contentOffset + collectionViewSize <= contentSize {
            
            self.adjustItemCenterFolowingTouchLocation(newBounds: newBounds)
        }
        
        return false
    }
    
    private func adjustItemCenterFolowingTouchLocation(newBounds newBounds: CGRect) {
        
        guard let collectionView = self.collectionView else {
            
            return
        }
        
        let scrollDistance: CGFloat = newBounds.origin.y - collectionView.bounds.origin.y
        
        let touchLocation = collectionView.panGestureRecognizer.locationInView(collectionView)
        
        for behavior in self.animator.behaviors {
            
            if let behavior = behavior as? UIAttachmentBehavior, let item = behavior.items.first {
                
                let distanceFromTouch: CGFloat = fabs(touchLocation.y - item.center.y)
                let scrollResistance: CGFloat = distanceFromTouch / self.scrollResistanceFactor
                let offset: CGFloat = scrollDistance * scrollResistance
                
                item.center.y += offset
                
                self.animator.updateItemUsingCurrentState(item)
            }
        }
    }
}
