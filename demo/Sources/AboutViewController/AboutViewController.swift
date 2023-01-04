//
//  ViewController.swift
//  IntroductionToCoreImage
//
//  Created by Florian Denis on 04/01/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import MetalKit
import UIKit

extension CIImage {
    func applyingFilter<T: CIFilter>(_ filter: T, _ configurationBlock: ((T) -> Void)? = nil) -> CIImage {
        filter.setValue(self, forKey: kCIInputImageKey)
        configurationBlock?(filter)
        return filter.outputImage ?? self
    }
}


class AboutViewController: UIViewController {
    private var snapshotImage: CIImage?
    private var gestureLocation: CGPoint?

    private var processedImage: CIImage? {
//        snapshotImage?
//            .applyingFilter(CIFilter.bumpDistortion()) {
//                $0.center = self.gestureLocation ?? .zero
//                $0.radius = 300
//                $0.scale = 0.3 + Float(1 + cos(CACurrentMediaTime())) / 3
//            }
        snapshotImage?
            .applyingFilter(CIFilter.twirlDistortion()) {
                $0.center = self.gestureLocation ?? .zero
                $0.radius = 300
                $0.angle = .pi / 2
            }
    }

    @IBAction private func panGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            snapshotImage = CIImage(image: view.snapshot())
            mtkView.isPaused = false
            mtkView.isHidden = false
        }

        let scale = view.window?.screen.scale ?? 1
        gestureLocation = gesture.location(in: view)
            .applying(CGAffineTransform(scaleX: 1, y: -1))
            .applying(CGAffineTransform(translationX: 0, y: view.bounds.height))
            .applying(CGAffineTransform(scaleX: scale, y: scale))


        if [.cancelled, .ended].contains(gesture.state) {
            snapshotImage = nil
            mtkView.isPaused = true
            mtkView.isHidden = true
            gestureLocation = nil
            return
        }
    }

    // MARK: -

    @IBOutlet var mtkView: MTKView!

    private lazy var device = MTLCreateSystemDefaultDevice()!
    private lazy var commandQueue = device.makeCommandQueue()!

    private lazy var context = CIContext(
        mtlCommandQueue: commandQueue,
        options:  [
            .cacheIntermediates: false,
        ]
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.device = device
        mtkView.delegate = self
        mtkView.framebufferOnly = false
    }
}

extension AboutViewController: MTKViewDelegate {
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
