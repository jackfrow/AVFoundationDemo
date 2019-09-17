//
//  AddAnimationViewController.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/17.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit
import AVFoundation

class AddAnimationViewController: AddSubTitleViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    override func applyVideoEffetctsToComposition(composition: AVMutableVideoComposition, size: CGSize) {
        
        //1.overlay
              let animationImage = UIImage(named: "star.png")
              let overlayLayer1 = CALayer()
              overlayLayer1.contents = animationImage?.cgImage
              overlayLayer1.frame = CGRect(x: size.width/2 - 64, y: size.height/2 + 200, width:128, height: 128)
              overlayLayer1.masksToBounds = true
              
              let overlayLayer2 = CALayer()
              overlayLayer2.contents = animationImage?.cgImage
              overlayLayer2.frame = CGRect(x: size.width/2 - 64 , y: size.height/2 - 200, width: 128, height: 128)
              overlayLayer2.masksToBounds = true
        
        //2.3 - Twinkle
            let animationScale = CABasicAnimation(keyPath: "transform.scale")
                  animationScale.duration = 1.0
                  animationScale.repeatCount = 5
                  animationScale.autoreverses = true
                   //  // animate from half size to full size
            animationScale.fromValue = NSNumber(floatLiteral: 0.5)
            animationScale.toValue = NSNumber(floatLiteral: 1.0)
            animationScale.beginTime = AVCoreAnimationBeginTimeAtZero
              
            overlayLayer1.add(animationScale, forKey: "scale")
            overlayLayer2.add(animationScale, forKey: "scale")
            
            //3 - Composition
            let parentLayer = CALayer()
            let videoLayer = CALayer()
            parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(overlayLayer1)
            parentLayer.addSublayer(overlayLayer2)
            
            composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
    }
    

}
