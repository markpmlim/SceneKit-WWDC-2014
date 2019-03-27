/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates how shadows are rendered.
*/

import SceneKit

// slide #48
class AAPLSlideShadows: APPLSlide {
    var _palmTree: SCNNode?
    var _character: SCNNode?
    var _lightHandle: SCNNode?
    var _projector: SCNNode?
    var _staticShadowNode: SCNNode?

    var _oldSpotPosition: SCNVector3?
    var _oldSpotParent: SCNNode?
    var _oldSpotZNear: CGFloat?
    var _oldSpotShadowColor: Any?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 6
    }
    
    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch(stepIndex) {
        case 0:
            break
        case 1:
            do {
                self.textManager.highlightBullet(at: 0)

                _staticShadowNode?.opacity = 1

                let node = self.textManager.add(code: "aMaterial.#multiply#.contents = aShadowMap;")
                node.position = SCNVector3Make(node.position.x, node.position.y-4, node.position.z)
                node.enumerateChildNodes({
                    (child: SCNNode,  stop: UnsafeMutablePointer<ObjCBool>) in
                    child.renderingOrder = 1
                    for m in (child.geometry?.materials)! {
                        m.readsFromDepthBuffer = false
                    }
                })
            }
        case 2:
            //move the tree
            _palmTree?.runAction(SCNAction.rotateBy(x: 0,
                                                    y: CGFloat.pi*4,
                                                    z: 0,
                                                    duration: 8))
        case 3:
            do {
                self.textManager.fadesIn = true
                self.textManager.fadeOutText(ofTextType: .code)
                
                let node = self.textManager.add(code: "aLight.#castsShadow# = YES;")
                node.enumerateChildNodes({
                    (child: SCNNode,  stop: UnsafeMutablePointer<ObjCBool>) in
                    child.renderingOrder = 1;
                    for m in (child.geometry?.materials)! {
                        m.readsFromDepthBuffer = false
                        m.writesToDepthBuffer = false
                    }
                })
                node.position = SCNVector3Make(node.position.x, node.position.y-11.5, node.position.z)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75

                let spot = presentationViewController.spotLight
                _oldSpotShadowColor = spot?.light?.shadowColor
                spot?.light?.shadowColor = NSColor.black
                spot?.light?.shadowRadius = 3

                var tp = self.textManager.textNode.position

                let superNode = presentationViewController.cameraNode?.parent?.parent

                let p0 = self.groundNode.convertPosition(SCNVector3Zero,
                                                         to: nil)
                let p1 = self.groundNode.convertPosition(SCNVector3Make(20, 0, 0),
                                                         to: nil)
                let tr = SCNVector3Make(p1.x-p0.x, p1.y-p0.y, p1.z-p0.z)


                var p = superNode?.position
                p?.x += tr.x
                p?.y += tr.y
                p?.z += tr.z
                tp.x += 20
                tp.y += 0
                tp.z += 0
                superNode?.position = p!
                self.textManager.textNode.position = tp
                SCNTransaction.commit()

                self.textManager.highlightBullet(at: 1)
            }
        case 4:
            do {
                //move the light
                let lightPivot = SCNNode()
                lightPivot.position = (_character?.position)!
                self.groundNode.addChildNode(lightPivot)

                let spot = presentationViewController.spotLight
                _oldSpotPosition = spot?.position
                _oldSpotParent = spot?.parent
                _oldSpotZNear = spot?.light?.zNear

                spot?.light?.zNear = 20
                spot?.position = lightPivot.convertPosition((spot?.position)!,
                                                            from: spot?.parent)
                lightPivot.addChildNode(spot!)

                //add an object to represent the light
                let lightModel = SCNNode()
                let lightHandle = SCNNode()
                let cone = SCNCone(topRadius: 0,
                                   bottomRadius: 0.5,
                                   height: 1)
                cone.radialSegmentCount = 10
                cone.heightSegmentCount = 5
                lightModel.geometry = cone
                lightModel.geometry?.firstMaterial?.emission.contents = NSColor.yellow
                let DIST: CGFloat = 0.3
                lightHandle.position = SCNVector3Make((spot?.position.x)! * DIST,
                                                      (spot?.position.y)! * DIST,
                                                      (spot?.position.z)! * DIST)
                lightModel.castsShadow = false
                lightModel.eulerAngles = SCNVector3Make(CGFloat.pi/2,   // rotate 90 about x-axis
                                                        0, 0)
                lightHandle.addChildNode(lightModel)
                lightHandle.constraints = [SCNLookAtConstraint(target: _character)]
                lightPivot.addChildNode(lightHandle)
                _lightHandle = lightHandle

                let animation = CABasicAnimation(keyPath: "eulerAngles.z")
                animation.fromValue = (CGFloat.pi/4*1.7)
                animation.toValue = (-CGFloat.pi/4*0.3)
                animation.duration = 4
                animation.autoreverses = true
                animation.repeatCount = MAXFLOAT
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.timeOffset = animation.duration/2
                lightPivot.addAnimation(animation,
                                        forKey: "lightAnim")
            }
        case 5:
            self.textManager.fadeOutText(ofTextType: .code)
            let text = self.textManager.add(code: "aLight.#shadowMode# =\n       #SCNShadowModeModulated#;\naLight.#gobo# = anImage;")
            text.position = SCNVector3Make(text.position.x, text.position.y-11.5, text.position.z)
            text.enumerateChildNodes({
                (child: SCNNode,  stop: UnsafeMutablePointer<ObjCBool>) in
                child.renderingOrder = 1
                for m in (child.geometry?.materials)! {
                    m.readsFromDepthBuffer = false
                    m.writesToDepthBuffer = false
                }
            })

            _lightHandle?.removeFromParentNode()

            self.restoreSpotPosition(presentationViewController)
            // problem with call below. SCNTransaction.commit will crash
            self.textManager.highlightBullet(at: 2)

            let spot = presentationViewController.spotLight
            spot?.light?.castsShadow = false
            let head = _character?.childNode(withName: "Bip001_Pelvis",
                                             recursively: true)
            let node = SCNNode()
            node.light = SCNLight()
            node.light?.type = .spot
            node.light?.spotOuterAngle = 30.0
            node.constraints = [SCNLookAtConstraint(target:head)]
            node.position = SCNVector3Make(0, 220, 0)
            node.light?.zNear = 10
            node.light?.zFar = 1000
            node.light?.gobo?.contents = NSImage(named: "blobShadow")
            node.light?.gobo?.intensity = 0.65
            node.light?.shadowMode = .modulated

            //exclude character from shadow
            node.light?.categoryBitMask = 0x1
            _character?.enumerateChildNodes({
                (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) in
                child.categoryBitMask = 0x2
            })

            _projector = node
            _character?.addChildNode(node)

        default:
            break
        }
    }


    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and add some text
        _ = self.textManager.set(title: "Shadows")
        
        _ = self.textManager.add(bullet:"Static",
                                 at: 0)
        _ = self.textManager.add(bullet:"Dynamic",
                                 at: 0)
        _ = self.textManager.add(bullet:"Projected",
                                 at: 0)

        let sceneryHolder = SCNNode()
        sceneryHolder.name = "scenery"
        sceneryHolder.position = SCNVector3Make(5, -19, 12)

        self.groundNode.addChildNode(sceneryHolder)

        //add scenery
        _ = sceneryHolder.asc_addChildNode(named: "scenery",
                                           fromSceneNamed: "Scenes.scnassets/banana/level",
                                           withScale: 130)

        _palmTree = self.groundNode.asc_addChildNode(named: "PalmTree",
                                                     fromSceneNamed: "Scenes.scnassets/palmTree/palm_tree",
                                                     withScale: 15)

        _palmTree?.position = SCNVector3Make(3, -1, 7)
        _palmTree?.eulerAngles = SCNVector3Make(0,
                                                (-CGFloat.pi/4*0.2),    // rotate about y-axis
                                                0)

        _palmTree?.enumerateChildNodes({
            (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) in
            child.castsShadow = false
        })

        //add a static shadow
        let shadowPlane = SCNNode(geometry: SCNPlane(width: 15,
                                                     height: 15))
        shadowPlane.eulerAngles = SCNVector3Make(-CGFloat.pi/2,         // π/2
                                                 (CGFloat.pi/4*0.5),    // π/8
                                                 0)
        shadowPlane.position = SCNVector3Make(0.5, 0.1, 2)
        shadowPlane.geometry?.firstMaterial?.diffuse.contents = "staticShadow.tiff"
        self.groundNode.addChildNode(shadowPlane)
        _staticShadowNode = shadowPlane
        _staticShadowNode?.opacity = 0

        let character = self.groundNode.asc_addChildNode(named: "explorer",
                                                         fromSceneNamed: "Scenes.scnassets/explorer/explorer_skinned",
                                                         withScale: 9)

        let animScene = SCNScene(named: "idle.dae",
                                 inDirectory: "Scenes.scnassets/explorer",
                                 options: nil)
        let animatedNode = animScene?.rootNode.childNode(withName: "Bip001_Pelvis",
                                                         recursively: true)
        character.addAnimation((animatedNode?.animation(forKey: (animatedNode?.animationKeys[0])!))!,
                               forKey: "idle")

        character.position = SCNVector3Make(20, 0, 7)
        character.eulerAngles = SCNVector3Make(0,
                                               CGFloat.pi/2,
                                               0)
        _character = character
    }

    func restoreSpotPosition(_ presentationViewController: AAPLPresentationViewController) {
        let spot = presentationViewController.spotLight
        spot!.light!.castsShadow = true
        _oldSpotParent?.addChildNode(spot!)
        spot!.position = _oldSpotPosition!
        spot!.light!.zNear = _oldSpotZNear!
        spot!.light!.shadowColor = _oldSpotShadowColor!
    }

    // handles pre-early exit from a slide presentation
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {

        if _projector != nil {
            _projector?.removeFromParentNode()
        }
        if (_oldSpotParent != nil) {
            self.restoreSpotPosition(presentationViewController)
        }

        if (_oldSpotShadowColor != nil) {
            let spot = presentationViewController.spotLight
            spot?.light?.shadowColor = _oldSpotShadowColor!
        }
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
    }
}
