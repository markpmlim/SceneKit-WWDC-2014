/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates how instances of CALayer can be used with material properties.
*/

import SceneKit
import SpriteKit
import AVFoundation

// class #40
class AAPLSlideMaterialLayer: APPLSlide {
    var _videoNode: SKVideoNode?        // uninitialized
    var _playerLayer1: AVPlayerLayer?
    var _playerLayer2: AVPlayerLayer?
    var _material: SCNMaterial?
    var _object: SCNNode?
    let W: CGFloat = 8.0

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 5
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Materials")
        _ = self.textManager.set(subtitle: "Property contents")

        _ = self.textManager.add(bullet: "Color",
                                 at: 0)
        _ = self.textManager.add(bullet: "CGColorRef, NSColor, UIColor",
                                 at: 1)

        let code = self.textManager.add(code: "material.diffuse.contents = #[UIColor redColor]#;")
        
        code.position = SCNVector3Make(code.position.x+5, code.position.y - 9.5, code.position.z);

        let node = SCNNode()
        node.name =  "material-cube"
        node.geometry = SCNBox(width: W,
        height: W,
        length: W,
        chamferRadius: W*0.02)

        _material = node.geometry?.firstMaterial
        _material?.diffuse.contents = NSColor.red

        _object = node

        node.position = SCNVector3Make(8, 11, 0)
        self.contentNode.addChildNode(node)
        node.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat.pi*2.0,
                                                                around: SCNVector3Make(0.4, 1, 0),
                                                                duration:4)))

    }
    
    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            break
        case 1:
            do {
                self.textManager.flipOutText(ofTextType: .bullet)
                self.textManager.fadeOutText(ofTextType: .code)

                _ = self.textManager.add(bullet: "Image",
                                         at: 0)
                _ = self.textManager.add(bullet: "Name, path, URL",
                                         at: 1)
                _ = self.textManager.add(bullet: "NSImage, UIImage, NSData",
                                         at: 1)
                _ = self.textManager.add(bullet: "SKTexture",
                                         at: 1)

                self.textManager.flipInText(ofTextType: .bullet)
                
                
                let code = self.textManager.add(code: "material.diffuse.contents = #@\"slate.jpg\"#;")
                code.position = SCNVector3Make(code.position.x+6, code.position.y - 6.5, code.position.z);

                // the box's texture will be changed!
                _material?.diffuse.contents = "slate.jpg"
                _material?.normal.contents = "slate-bump.png"
                _material?.normal.intensity = 0
            }
        case 2:
            do {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                _material?.normal.intensity = 5.0;
                _material?.specular.contents = NSColor.gray
                SCNTransaction.commit()

                let code = self.textManager.add(code: "material.normal.contents = #[SKTexture textureByGeneratingNormalMap]#;")
                code.position = SCNVector3Make(code.position.x+2, code.position.y - 6.5, code.position.z)
                
            }
        case 3:
            do {
                self.textManager.fadeOutText(ofTextType: .code)
                self.textManager.flipOutText(ofTextType: .bullet)
                _ = self.textManager.add(bullet: "Live contents",
                                         at: 0)
                _ = self.textManager.add(bullet: "CALayer tree",
                                         at: 1)
                _ = self.textManager.add(bullet: "SKScene (new)",
                                         at: 1)
                _ = self.textManager.flipInText(ofTextType: .bullet)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                _material?.normal.intensity = 2.0
                SCNTransaction.commit()

                // Load movies and display movie layers
                func configurePlayer(_ movieURL: URL,
                                     hostingNodeName: String) -> AVPlayerLayer {
                    //(movieURL: URL, hostingNodeName: String) -> AVPlayerLayer in
                    let player = AVPlayer(url: movieURL)
                    player.actionAtItemEnd = .none                  // loop
                    
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(AAPLSlideMaterialLayer.playerItemDidReachEnd(_:)),
                                                           name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                           object: player.currentItem)

                    player.play()

                    // Set an arbitrary frame. This frame will be the size of our movie texture so if it is
                    // too small it will appear scaled up and blurry, and if it is too big it will be slow
                    let playerLayer = AVPlayerLayer()
                    playerLayer.player = player;
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    playerLayer.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0),
                                               size: CGSize(width: 600.0, height: 800.0))

                    // Use a parent layer with a background color set to black
                    // That way if the movie is stil loading and the frame is transparent, we won't see holes in the model
                    let backgroundLayer = CALayer()
                    backgroundLayer.backgroundColor = CGColor.black
                    backgroundLayer.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0),
                                                   size: CGSize(width: 600.0, height: 800.0))
                    backgroundLayer.addSublayer(playerLayer)

                    let frameNode = self.contentNode.childNode(withName: hostingNodeName,
                                                               recursively: true)
                    let material = frameNode?.geometry?.firstMaterial
                    material?.diffuse.contents = backgroundLayer

                    return playerLayer
                }

                _playerLayer1 = configurePlayer(Bundle.main.url(forResource: "movie1",
                                                                withExtension: "mov")!,
                                                hostingNodeName: "material-cube")
            }
        case 4:
            do {
                //_videoNode.pause

                self.textManager.flipOutText(ofTextType: .bullet)
                self.textManager.addEmptyLine()

                _ = self.textManager.add(bullet: "Cube map",
                                         at: 0)
                _ = self.textManager.add(bullet: "NSArray of 6 items",
                                         at: 1)

                self.textManager.flipInText(ofTextType: .bullet)

                let code = self.textManager.add(code: "material.reflective.contents = #@[@\"right.png\", @\"left.png\" ... @\"front.png\"]#;")
                code.position = SCNVector3Make(code.position.x, code.position.y - 9.5, code.position.z)


                let image = SCNNode.asc_planeNode(withImageNamed: "cubemap.png",
                                                  size: 12,
                                                  isLit: true)
                image.position = SCNVector3Make(-10, 9, 0)
                image.opacity = 0
                self.contentNode.addChildNode(image)


                _object?.geometry = SCNTorus(ringRadius: W*0.5,
                                             pipeRadius: W*0.2)
                _material = _object?.geometry?.firstMaterial
                _object?.rotation = SCNVector4Make(1, 0, 0,
                                                   CGFloat.pi/2)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                _material?.reflective.contents = ["right.tga", "left.tga", "top.tga", "bottom.tga", "back.tga", "front.tga"]
                _material?.diffuse.contents = NSColor.red
                image.opacity = 1.0
                SCNTransaction.commit()
            }
        default:
            break
        }
    }
    
    func playerItemDidReachEnd(_ notification: NSNotification) {
            let playerItem = notification.object as! AVPlayerItem
            playerItem.seek(to: kCMTimeZero)
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: _playerLayer1?.player?.currentItem)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: _playerLayer2?.player?.currentItem)
        _playerLayer1?.player?.pause()
        _playerLayer2?.player?.pause()

        _playerLayer1?.player = nil
        _playerLayer2?.player = nil

        // Stop playing scene animations, restore the original point of view and restore the default spot light mode
        presentationViewController.presentationView.isPlaying = false
        presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode
        presentationViewController.narrowSpotlight(false)
    }
}
