//
//  ViewController.swift
//  SpringFlowLayoutExample
//
//  Created by Shunki Tan on 2015/12/02.
//  Copyright © 2015年 eureka. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var springFlowLayout: SpringFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1)
        self.collectionView.dataSource = self
        
        let flowLayout = SpringFlowLayout()
        flowLayout.scrollDirection = .Vertical
        self.springFlowLayout = flowLayout
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.springFlowLayout.itemSize = CGSize(width: self.collectionView.bounds.size.width, height: 44)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.contentView.backgroundColor = UIColor(red:0.14, green:0.18, blue:0.22, alpha:1)
        return cell
    }
    
}
