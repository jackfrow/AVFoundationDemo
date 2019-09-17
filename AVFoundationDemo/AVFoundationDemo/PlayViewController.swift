//
//  PlayViewController.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/16.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {

    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        navigationItem.title = "视屏播放"
        
        
        guard let string = Bundle.main.path(forResource: "01_nebula", ofType: "mp4")else{
            return
        }
         let url = URL(fileURLWithPath: string)

        let asset = AVAsset(url: url)

        let playItem = AVPlayerItem(asset: asset)

         player = AVPlayer(playerItem: playItem)

        let layer = AVPlayerLayer(player: player)
        
        layer.frame = view.bounds
        
        view.layer.addSublayer(layer)
        
        player.play()
        
    }
    

  
}
