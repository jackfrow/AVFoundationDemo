//
//  AddSubTitleViewController.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/16.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit
import AVFoundation

class AddSubTitleViewController: UIViewController {

    let composition = AVMutableComposition()
    var videoComposition: AVMutableVideoComposition!
       var player:AVPlayer!
       var playerLayer:AVPlayerLayer!
       var videoAsset: AVAsset?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        navigationItem.title = "添加水印"
        //1.加载资源
        prepareResource()
        //2.设置视屏轨道
        buildVideoComposition()
        //3.添加效果
        applyEffect()
        //4.播放视屏
        playVideo()
        //5.导出视屏
        export()
    }
    
    
    func buildVideoComposition() {
        
        guard let videoAsset = videoAsset else {
                
                let alert = UIAlertController(title: "Error", message: "Please Load a Video Asset First", preferredStyle: .alert)
                          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                          present(alert, animated: true, completion: nil)
                return
            }
        
        //使用invalid，系统会自动分配一个有效的trackId
            let trackId = kCMPersistentTrackID_Invalid
            
            guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId) else {
                return
            }
        
        do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
            } catch  {
                print("faild to insert videoTrack")
                return
            }
    
        
    }
    
    func applyEffect()  {
        
        
        guard let videoAsset =  videoAsset else {
            return
        }
        
         videoComposition = AVMutableVideoComposition(propertiesOf: videoAsset)
        let mainInstruction  = AVMutableVideoCompositionInstruction()
          mainInstruction.timeRange =  CMTimeRange(start: .zero, duration: videoAsset.duration)
        
        guard let assetTrack = videoAsset.tracks(withMediaType: .video).first  else {
            return
        }
        
//      AVVideoCompositionLayerInstruction
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        mainInstruction.layerInstructions = [videoLayerInstruction]
        
//      videoComposition
        videoComposition.instructions = [mainInstruction]
        videoComposition.renderSize = assetTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        //apply effect
        applyVideoEffetctsToComposition(composition: videoComposition, size: assetTrack.naturalSize)
    }
    
    
    //RenderEffect
     func applyVideoEffetctsToComposition(composition: AVMutableVideoComposition,size: CGSize)  {
        
        // 1 - Set up the text layer
            let subtitle1Text = CATextLayer()
            subtitle1Text.font = "Helvetica-Bold" as CFTypeRef
            subtitle1Text.fontSize = 36
            subtitle1Text.frame = CGRect(x: 0, y: 0, width: size.width, height: 100)
            subtitle1Text.string = "jackfrow"
            subtitle1Text.alignmentMode = .center
            subtitle1Text.foregroundColor = UIColor.white.cgColor
        
            //2 - The usual overlay
            let overlayLayer = CALayer()
            overlayLayer.addSublayer(subtitle1Text)
            overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            overlayLayer.masksToBounds = true
            
            let parentLayer = CALayer()
            let videoLayer = CALayer()
            
            parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(overlayLayer)
            
            // 3 - apply magic
            composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
     }
    
    func prepareResource()  {
        
        guard let path = Bundle.main.path(forResource: "01_nebula", ofType: "mp4")else{
            return
        }
        let url = URL(fileURLWithPath: path)
        
        videoAsset = AVAsset(url: url)
    }
    

      func playVideo() {
        //添加了效果的无法直接播放
        
//            playerItem.videoComposition = videoComposition
//            player = AVPlayer(playerItem: playerItem)
//            playerLayer = AVPlayerLayer(player: player)
//            playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height - 200)
//            playerLayer.position = view.center
//            view.layer.addSublayer(playerLayer)
//            player.play()
            
        }
  
    
    func export()  {
        
    let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset640x480)
        export?.videoComposition = videoComposition
        
        export?.outputURL = VideoHelper.createTemplateFileURL()
        export?.outputFileType = .mp4
        
        export?.exportAsynchronously {

             let status = export?.status
            if status == AVAssetExportSession.Status.completed {
                
                VideoHelper.saveToAlbum(atURL: export!.outputURL!)
            }

        }

        
    }

}
