/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains what levels of detail are and shows an example of how to use them.
*/

import SceneKit

// slide #58
class AAPLSlideLOD: APPLSlide {

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 7
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title
        _ = self.textManager.set(title: "Levels of Detail")

        // Create a node that will hold the teapots
        let intermediateNode = SCNNode()
        //intermediateNode.rotation = SCNVector4Make(1, 0, 0, -CGFloat.pi/2)
        self.groundNode.addChildNode(intermediateNode)

        // Load two resolutions
        _ = self.addTeapot(withResolutionIndex: 0,
                           positionX: -5,
                           parent: intermediateNode)        // high res
        _ = self.addTeapot(withResolutionIndex: 4,
                           positionX: +5,
                           parent: intermediateNode)        // low res

        // Load the other resolutions but hide them
        for i in 1..<4 {
            let teapotNode = self.addTeapot(withResolutionIndex: i,
                                            positionX: 5,
                                            parent: intermediateNode)
            teapotNode.opacity = 0.0
        }
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            // Hide everything (in case the user went backward)
            for i in 1..<4 {
                let teapot = self.groundNode.childNode(withName: String(format:"Teapot%ld", i),
                                                       recursively: true)
                teapot?.opacity = 0.0
            }
        case 1:
            do {
                // Move the camera and adjust the clipping plane
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 3
                do {
                    presentationViewController.cameraNode?.position = SCNVector3Make(0, 0, 200)
                    presentationViewController.cameraNode?.camera?.zFar = 500.0
                    presentationViewController.presentationView.scene?.fogEndDistance = 600
                    presentationViewController.presentationView.scene?.fogStartDistance = 450.0
                }
                SCNTransaction.commit()
            }
        case 2:
            do {
                // Revert to original position
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1
                do {
                    presentationViewController.cameraNode?.position = SCNVector3Make(0, 0, 0)
                    presentationViewController.cameraNode?.camera?.zFar = 100.0
                }
                SCNTransaction.commit()
            }
        case 3:
            do {
                let numberNodes = [
                    self.addNode(withNumber: "64k", positionX: -17),
                    self.addNode(withNumber: "6k", positionX: -9),
                    self.addNode(withNumber: "3k", positionX: -1),
                    self.addNode(withNumber: "1k", positionX: 6.5),
                    self.addNode(withNumber: "256", positionX: 14)
                ]

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1
                do {
                    // Move the camera and the text
                    presentationViewController.cameraHandle?.position = SCNVector3Make((presentationViewController.cameraHandle?.position.x)!,
                                                                                       (presentationViewController.cameraHandle?.position.y)! + 6,
                                                                                       (presentationViewController.cameraHandle?.position.z)!);
                    self.textManager.textNode.position = SCNVector3Make(self.textManager.textNode.position.x,
                                                                        self.textManager.textNode.position.y + 6,
                                                                        self.textManager.textNode.position.z);

                    // Show the remaining resolutions
                    for i in 0..<5 {
                        let numberNode = numberNodes[i]
                        numberNode.position = SCNVector3Make(numberNode.position.x, 7, -5)

                        let teapot = self.groundNode.childNode(withName: String(format: "Teapot%ld", i),
                                                               recursively: true)
                        teapot?.opacity = 1.0
                        teapot?.rotation = SCNVector4Make(0, 1, 0,
                                                          CGFloat.pi/4)
                        teapot?.position = SCNVector3Make(CGFloat((i - 2) * 8),
                                                          (teapot?.position.y)!,
                                                          -5)
                    }
                    SCNTransaction.commit()
                }
            }
        case 4:
            do {
                presentationViewController.setShowsNewInSceneKitBadge(showsBadge: true)

                // Remove the numbers
                self.removeNumberNodes()

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    // Add some text and code
                    _ = self.textManager.set(subtitle: "SCNLevelOfDetail")

                    _ = self.textManager.add(code:
                        "#SCNLevelOfDetail# *lod1 = [SCNLevelOfDetail #levelOfDetailWithGeometry:#aGeometry \n" +
                        "                                                  #worldSpaceDistance:#aDistance]; \n" +
                        "geometry.#levelsOfDetail# = @[ lod1, lod2, ..., lodn ];")

                    // Animation the merge
                    for i in 0..<5 {
                        let teapot = self.groundNode.childNode(withName: String(format: "Teapot%ld", i),
                                                               recursively: true)

                        teapot?.opacity = i == 0 ? 1.0 : 0.0;
                        teapot?.rotation = SCNVector4Make(0, 1, 0,
                                                          0)
                        teapot?.position = SCNVector3Make(0, (teapot?.position.y)!, -5)
                    }

                    // Move the camera and the text
                    presentationViewController.cameraHandle?.position = SCNVector3Make((presentationViewController.cameraHandle?.position.x)!,
                                                                                      (presentationViewController.cameraHandle?.position.y)! - 3,
                                                                                      (presentationViewController.cameraHandle?.position.z)!);
                    self.textManager.textNode.position = SCNVector3Make(self.textManager.textNode.position.x,
                                                                        self.textManager.textNode.position.y - 3,
                                                                        self.textManager.textNode.position.z);
                }
                SCNTransaction.commit()
            }
        case 5:
            do {
                //presentationViewController.showsNewInSceneKitBadge = true
                presentationViewController.setShowsNewInSceneKitBadge(showsBadge: true)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 3.0
                do {
                    // Change the lighting to remove the front light and rise the main light
                    presentationViewController.updateLighting(withIntensities: [1.0, 0.3, 0.0, 0.0, 0.0, 0.0])
                    presentationViewController.riseMainLight(true)

                    // Remove some text
                    self.textManager.fadeOutText(ofTextType: .title)
                    self.textManager.fadeOutText(ofTextType: .subtitle)
                    self.textManager.fadeOutText(ofTextType: .code)
                }
                SCNTransaction.commit()

                // Retrieve the main teapot
                let teapot = self.groundNode.childNode(withName: "Teapot0",
                                                       recursively: true)

                // The distances to use for each LOD
                let distances: [CGFloat] = [30, 50, 90, 150]

                // An array of SCNLevelOfDetail instances that we will build
                var levelsOfDetail = [SCNLevelOfDetail]()
                for i in 1..<5 {
                    let teapotNode = self.groundNode.childNode(withName: String(format: "Teapot%ld", i),
                                                               recursively: true)
                    let teapot = teapotNode?.geometry

                    // Unshare the material because we will highlight the different levels of detail with different colors in the next step
                    teapot?.firstMaterial = teapot?.firstMaterial?.copy() as? SCNMaterial

                    // Build the SCNLevelOfDetail instance
                    let levelOfDetail = SCNLevelOfDetail(geometry: teapot,
                                                         worldSpaceDistance: distances[i - 1])
                    levelsOfDetail.append(levelOfDetail)
                }

                teapot?.geometry?.levelsOfDetail = levelsOfDetail

                // Duplicate and move the teapots
                let startTime = CACurrentMediaTime()
                var delay: CFTimeInterval = 0.2

                let rowCount = 9;
                let columnCount = 12;

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    // Change the far clipping plane to be able to see far away
                    presentationViewController.cameraNode?.camera?.zFar = 1000.0

                    for j in 0..<columnCount {
                        for i in 0..<rowCount {
                            // Clone
                            let clone = teapot?.clone()
                            teapot?.parent?.addChildNode(clone!)

                            // Animate
                            var animation = CABasicAnimation(keyPath: "position")
                            animation.isAdditive = true
                            animation.duration = 1.0
                            animation.toValue = NSValue(scnVector3: SCNVector3Make(CGFloat(i - rowCount / 2) * 12.0,
                                                                                   0,
                                                                                   -(5 + CGFloat((columnCount - j)) * 15.0)))
                            animation.fromValue = NSValue(scnVector3: SCNVector3Make(0, 0, 0))
                            animation.beginTime = startTime + delay // desynchronize

                            // Freeze at the end of the animation
                            animation.isRemovedOnCompletion = false
                            animation.fillMode = kCAFillModeForwards

                            clone?.addAnimation(animation, forKey: nil)

                            // Animate the hidden property to automatically show the node when the position animation starts
                            animation = CABasicAnimation(keyPath: "hidden")
                            animation.duration = delay + 0.01
                            animation.fillMode = kCAFillModeBoth
                            animation.fromValue = 1.0
                            animation.toValue = 0.0
                            clone?.addAnimation(animation, forKey:nil)

                            delay += 0.05
                        }
                    }
                }
                SCNTransaction.commit()

                // Animate the camera while we duplicate the nodes
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0 + Double(rowCount * columnCount) * 0.05
                do {
                    let position = presentationViewController.cameraHandle?.position
                    presentationViewController.cameraHandle?.position = SCNVector3Make((position?.x)!, (position?.y)! + 5, (position?.z)!)
                    presentationViewController.cameraPitch?.rotation = SCNVector4Make(1, 0, 0,
                                                                                      (presentationViewController.cameraPitch?.rotation.w)! - (CGFloat.pi/4 * 0.1))
                }
                SCNTransaction.commit()
            }
        case 6:
            do {
                // Highlight the levels of detail with colors
                let teapotNode = self.groundNode.childNode(withName: "Teapot0",
                                                           recursively: true)
                let colors: [NSColor] = [NSColor.red, NSColor.orange, NSColor.yellow, NSColor.green]

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    for i in 0..<4 {
                        let levelOfDetail = teapotNode?.geometry?.levelsOfDetail?[i]
                        levelOfDetail?.geometry?.firstMaterial?.multiply.contents = colors[i]
                    }
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }



    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
    }

    func addTeapot(withResolutionIndex index: Int,
                   positionX x: CGFloat,
                   parent: SCNNode) -> SCNNode {

        let teapotNode = parent.asc_addChildNode(named:String(format: "Teapot%d", index),
                                                 fromSceneNamed: "Scenes.scnassets/lod/lod.dae",
                                                 withScale: 11)
        teapotNode.geometry?.firstMaterial?.reflective.intensity = 0.8
        teapotNode.geometry?.firstMaterial?.fresnelExponent = 1.0

        let yOffset: CGFloat = index == 4 ? 0.0 : CGFloat(index * 20)
        teapotNode.position = SCNVector3Make(x, 0.1, 10 + yOffset)

        return teapotNode
    }

    func addNode(withNumber numberString: String, positionX x: CGFloat) -> SCNNode {
        let numberNode = SCNNode.asc_labelNode(withString: numberString,
                                               size: .large,
                                               isLit: true)
        numberNode.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
        numberNode.geometry?.firstMaterial?.ambient.contents = NSColor.orange
        numberNode.position = SCNVector3Make(x, 50, 0)
        numberNode.name = "number"

        let text = numberNode.geometry as! SCNText
        text.extrusionDepth = 5

        self.groundNode.addChildNode(numberNode)

        return numberNode
    }

    func removeNumberNodes() {
        // Move, fade and remove on completion
        for node in self.groundNode.childNodes {
            if node.name == "number" {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                SCNTransaction.completionBlock = {
                    node.removeFromParentNode()
                }
                do {
                    node.opacity = 0.0          // make it invisible first
                    node.position = SCNVector3Make(node.position.x, node.position.y, node.position.z - 20)
                }
                SCNTransaction.commit()
            }
        }
    }
}
