//
//  OnboardingViewController.swift
//  IntroductionToCoreImage
//
//  Created by Florian on 07/01/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import MetalKit
import UIKit

class OnboardingViewController: UIViewController {
    private enum K {
        static let animationDuration: TimeInterval = 1.5
    }
    @IBOutlet var backgroundView: UIImageView!
    @IBOutlet var foregroundView: UIView!
    
    private var startTime: TimeInterval?
    private var backgroundSourceSnapshot: CIImage?
    private var backgroundTargetSnapshot: CIImage?
    
    private var currentImage: Int = 0
    private let onboardingImageNames = [
        "onboarding-image-1",
        "onboarding-image-2",
        "onboarding-image-3",
        "onboarding-image-4",
    ]

    var processedImage: CIImage? {
        guard
            let startTime,
            let backgroundSourceSnapshot,
            let backgroundTargetSnapshot
        else {
            return nil
        }

        let dt = CACurrentMediaTime() - startTime
        let progress = min(dt / K.animationDuration, 1)
        
        return backgroundSourceSnapshot
            .applyingFilter(CIFilter.barsSwipeTransition()) {
                $0.targetImage = backgroundTargetSnapshot
                $0.angle =  9 * .pi / 5
                $0.width = 150
                $0.time = Float(progress)
            }
            .cropped(to: backgroundSourceSnapshot.extent)
    }
    
    @IBAction private func continuePressed() {
        currentImage = (currentImage + 1) % onboardingImageNames.count
        let targetImageName = onboardingImageNames[currentImage]
        
        backgroundSourceSnapshot = backgroundView.snapshot()
        backgroundView.image = UIImage(named: targetImageName)
        backgroundTargetSnapshot = backgroundView.snapshot()

        startTime = CACurrentMediaTime()
        mtkView.isHidden = false
        mtkView.isPaused = false
        mtkView.draw()

        Timer.scheduledTimer(withTimeInterval: K.animationDuration, repeats: false) { _ in
            self.mtkView.isHidden = true
            self.mtkView.isPaused = true
            self.backgroundSourceSnapshot = nil
            self.backgroundTargetSnapshot = nil
        }
    }

    // MARK: -

    @IBOutlet var mtkView: MTKView!

    private let context = CIContext()
    private let device = MTLCreateSystemDefaultDevice()!
    private lazy var commandQueue = device.makeCommandQueue()!

    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.device = device
        mtkView.delegate = self
        mtkView.framebufferOnly = false
    }
}

extension OnboardingViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard
            let processedImage,
            let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer()
        else {
            return
        }

        let destination = CIRenderDestination(mtlTexture: drawable.texture, commandBuffer: commandBuffer)
        destination.isFlipped = true
        _ = try? context.startTask(toRender: processedImage, to: destination)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
