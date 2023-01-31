//
//  UIView+Snapshot.swift
//  IntroductionToCoreImage
//
//  Created by Florian Denis on 04/01/2023.
//

import CoreImage
import UIKit

extension UIView {
    public func snapshot() -> CIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return CIImage(image: renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        })
    }
}

