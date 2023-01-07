//
//  UIView+Snapshot.swift
//  IntroductionToCoreImage
//
//  Created by Florian Denis on 04/01/2023.
//

import UIKit

extension UIView {
    public func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
    }
}

