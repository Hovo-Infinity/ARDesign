//
//  ViewController+UICollectionViewProtocols.swift
//  ARDesign
//
//  Created by Hovhannes Stepanyan on 4/8/18.
//  Copyright © 2018 David Varosyan. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "simpleCell", for: indexPath)
        let currentImage = datas[indexPath.item]
        let imageView = UIImageView(frame: cell.bounds)
        imageView.image = currentImage
        cell.addSubview(imageView)
        return cell
    }
}
