//
//  TransitionViewController.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/17.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit
import AVFoundation

enum TransitionType {
    case Dissolve//溶解效果
    case Push
}

class TransitionViewController: UIViewController {

    var assets: [AVAsset] = []
    let composition = AVMutableComposition()
    var videoComposition: AVMutableVideoComposition!
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
     var overLayer: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        //1.加载视屏中的资源
        prepareResource()
        //2.构建视屏轨道
        buildCompositionVideoTracks()
        //3.构建音频轨道
        buildCompositionAudioTracks()
        //4.设置视屏效果
        buildVideoEffect()
        //5.播放
        playVideo()
        //6.添加图纸
        buildOverLayer()
        //7.导出
        export()
       
    }
    
    
    func prepareResource()  {
        
        guard let urls = Bundle.main.urls(forResourcesWithExtension: ".mp4", subdirectory: nil) else {
            return
        }
        
        for url  in urls {
            let asset = AVAsset(url: url)
            assets.append(asset)
        }
        
    }
    
    func buildCompositionVideoTracks()  {
       //使用invalid，系统会自动分配一个有效的trackId
        let trackId = kCMPersistentTrackID_Invalid
        //创建AB两条视频轨道，视频片段交叉插入到轨道中，通过对两条轨道的叠加编辑各种效果。如0-5秒内，A轨道内容alpha逐渐到0，B轨道内容alpha逐渐到1
        guard let trackA = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId) else {
            return
        }
        guard let trackB = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId) else {
            return
        }
        
        let videoTracks = [trackA,trackB]
        
        //视频片段插入时间轴时的起始点
        var cursorTime = CMTime.zero
        //转场动画时间
        let transitionDuration = CMTime(value: 2, timescale: 1)
        for (index,value) in assets.enumerated() {
            //交叉循环A，B轨道
            let trackIndex = index % 2
            let currentTrack = videoTracks[trackIndex]
            //获取视频资源中的视频轨道
            guard let assetTrack = value.tracks(withMediaType: .video).first else {
                continue
            }
            do {
                //插入提取的视频轨道到 空白(编辑)轨道的指定位置中
                try currentTrack.insertTimeRange(CMTimeRange(start: .zero, duration: value.duration), of: assetTrack, at: cursorTime)
                //光标移动到视频末尾处，以便插入下一段视频
                cursorTime = CMTimeAdd(cursorTime, value.duration)
                //光标回退转场动画时长的距离，这一段前后视频重叠部分组合成转场动画
                cursorTime = CMTimeSubtract(cursorTime, transitionDuration)
            } catch {
                
            }
        }
        
    }
    
    func buildCompositionAudioTracks()  {
        
        let trackId = kCMPersistentTrackID_Invalid
         guard let trackAudio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: trackId) else {
             return
         }
         var cursorTime = CMTime.zero
         for (_,value) in assets.enumerated() {
             //获取视频资源中的音频轨道
             guard let assetTrack = value.tracks(withMediaType: .audio).first else {
                 continue
             }
             do {
                 try trackAudio.insertTimeRange(CMTimeRange(start: .zero, duration: value.duration), of: assetTrack, at: cursorTime)
                 cursorTime = CMTimeAdd(cursorTime, value.duration)
             } catch {

             }
         }
        
    }
    
    func buildVideoEffect()  {
        //创建默认配置的videoComposition
        let videoComposition = AVMutableVideoComposition.init(propertiesOf: composition)
        self.videoComposition = videoComposition
        filterTransitionInstructions(of: videoComposition)
    }
    
    /// 过滤出转场动画指令
    func filterTransitionInstructions(of videoCompostion: AVMutableVideoComposition) -> Void {
        let instructions = videoCompostion.instructions as! [AVMutableVideoCompositionInstruction]
        
        
        for (index,instruct) in instructions.enumerated() {
            
            //非转场动画区域只有单轨道(另一个的空的)，只有两个轨道重叠的情况是我们要处理的转场区域
            guard instruct.layerInstructions.count > 1 else {
                continue
            }
            var transitionType: TransitionType
            //需要判断转场动画是从A轨道到B轨道，还是B-A
            var fromLayerInstruction: AVMutableVideoCompositionLayerInstruction
            var toLayerInstruction: AVMutableVideoCompositionLayerInstruction
            //获取前一段画面的轨道id
            let beforeTrackId = instructions[index - 1].layerInstructions[0].trackID;
            //跟前一段画面同一轨道的为转场起点，另一轨道为终点
            let tempTrackId = instruct.layerInstructions[0].trackID
            if beforeTrackId == tempTrackId {
                fromLayerInstruction = instruct.layerInstructions[0] as! AVMutableVideoCompositionLayerInstruction
                toLayerInstruction = instruct.layerInstructions[1] as! AVMutableVideoCompositionLayerInstruction
                transitionType = TransitionType.Dissolve
            }else{
                fromLayerInstruction = instruct.layerInstructions[1] as! AVMutableVideoCompositionLayerInstruction
                toLayerInstruction = instruct.layerInstructions[0] as! AVMutableVideoCompositionLayerInstruction
                transitionType = TransitionType.Push
            }
            
            setupTransition(for: instruct, fromLayer: fromLayerInstruction, toLayer: toLayerInstruction,type: transitionType)
        }
    }
    
    /// 设置转场动画
    func setupTransition(for instruction: AVMutableVideoCompositionInstruction, fromLayer: AVMutableVideoCompositionLayerInstruction, toLayer: AVMutableVideoCompositionLayerInstruction ,type: TransitionType) {
        let identityTransform = CGAffineTransform.identity
        let timeRange = instruction.timeRange
        let videoWidth = self.videoComposition.renderSize.width
        if type == TransitionType.Push{
            let fromEndTranform = CGAffineTransform(translationX: -videoWidth, y: 0)
            let toStartTranform = CGAffineTransform(translationX: videoWidth, y: 0)
            
            fromLayer.setTransformRamp(fromStart: identityTransform, toEnd: fromEndTranform, timeRange: timeRange)
            toLayer.setTransformRamp(fromStart: toStartTranform, toEnd: identityTransform, timeRange: timeRange)
        }else {
            fromLayer.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: timeRange)
        }
        
        //重新赋值
        instruction.layerInstructions = [fromLayer,toLayer]
    }
    
    func playVideo()  {
        
                let playerItem = AVPlayerItem(asset: composition)
                playerItem.videoComposition = videoComposition
                player = AVPlayer(playerItem: playerItem)
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height - 200)
                playerLayer.position = view.center
                view.layer.addSublayer(playerLayer)
                player.play()
        
    }
    
    func buildOverLayer() {
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        layer.opacity = 0;
        layer.backgroundColor = UIColor.yellow.cgColor
        
        let fadeInFadeOutAni = CAKeyframeAnimation(keyPath: "opacity")
        fadeInFadeOutAni.values = [0.0,1.0,1.0,0.0]
        fadeInFadeOutAni.keyTimes = [0.0,0.25,0.75,1]
        //动画时间与时间轴时间绑定
        fadeInFadeOutAni.beginTime = CMTimeGetSeconds(CMTime(seconds: 3, preferredTimescale: 1))
        fadeInFadeOutAni.duration = CMTimeGetSeconds(CMTime(seconds: 5, preferredTimescale: 1))
        fadeInFadeOutAni.isRemovedOnCompletion = false
        
        layer.add(fadeInFadeOutAni, forKey: nil)
        overLayer = layer
        
    }
    
    func export()  {
        
        let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset640x480)
        
        if overLayer != nil {
             let videoLayer = CALayer()
             videoLayer.frame = CGRect(x: 0, y: 0, width: 1280, height: 720)
             let animateLayer = CALayer()
             animateLayer.frame = CGRect(x: 0, y: 0, width: 1280, height: 720)
             //videoLayer必须在animateLayer层级中
             animateLayer.addSublayer(videoLayer)
             animateLayer.addSublayer(overLayer!)
             animateLayer.isGeometryFlipped = true
             
             let animateTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: animateLayer)
             videoComposition.animationTool = animateTool
         }
        
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
