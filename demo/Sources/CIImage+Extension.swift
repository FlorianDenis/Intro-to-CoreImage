//
//  CIImage+Extension.swift
//  IntroductionToCoreImage
//
//  Created by Florian on 07/01/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins

extension CIImage {
    public func applyingFilter<T: CIFilter>(_ filter: T, _ configurationBlock: ((T) -> Void)? = nil) -> CIImage {
        filter.setValue(self, forKey: kCIInputImageKey)
        configurationBlock?(filter)
        return filter.outputImage ?? self
    }
}
