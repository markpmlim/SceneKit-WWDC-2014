/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates how morphing can be used.
*/

import SceneKit

// slide #34
class AAPLSlideMorphing: APPLSlide {
    var _mapNode: SCNNode?
    var _gaugeANode: SCNNode?
    var _gaugeAProgressNode: SCNNode?
    var _gaugeBNode: SCNNode?
    var _gaugeBProgressNode: SCNNode?

    required init() {
        _gaugeAProgressNode = SCNNode()
        _gaugeBProgressNode = SCNNode()
        super.init()
    }

    override var numberOfSteps: UInt {
        return 8
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Load the scene
        let intermediateNode = SCNNode()
        intermediateNode.position = SCNVector3Make(6, 9, 0)
        intermediateNode.scale = SCNVector3Make(1.4, 1, 1)
        self.groundNode.addChildNode(intermediateNode)

        _mapNode = intermediateNode.asc_addChildNode(named: "Map",
                                                     fromSceneNamed: "Scenes.scnassets/map/foldingMap.dae",
                                                     withScale:25)
        _mapNode?.position = SCNVector3Make(0, 0, 0)
        _mapNode?.opacity = 0.0

        // Use a shader modifier to support a secondary texture for some slides
        let geometryShaderFile = Bundle.main.path(forResource: "mapGeometry",
                                                  ofType:"shader")
        var geometryModifier: String?
        do {
            geometryModifier = try NSString(contentsOfFile: geometryShaderFile!,
                                            encoding: String.Encoding.utf8.rawValue) as String
        }
        catch let err as NSError {
            print("Can't load Geometry Shader Modifier file:", err)
            return
        }

        let fragmentShaderFile = Bundle.main.path(forResource: "mapFragment",
                                                  ofType:"shader")
        var fragmentModifier: String?
        do {
            fragmentModifier = try NSString(contentsOfFile: fragmentShaderFile!,
                                            encoding: String.Encoding.utf8.rawValue) as String
        }
        catch _ {
            print("Can't load Map Fragment Shader")
        }

        let lightingShaderFile = Bundle.main.path(forResource: "mapLighting",
                                                  ofType:"shader")
        var lightingModifier: String?
        do {
            lightingModifier = try NSString(contentsOfFile: lightingShaderFile!,
                                            encoding: String.Encoding.utf8.rawValue) as String
        }
        catch _ {
            print("Can't load Map Lighting Shader")
        }

        _mapNode?.geometry?.shaderModifiers = [.geometry : geometryModifier!,
                                               .fragment : fragmentModifier!,
                                               .lightingModel : lightingModifier!]
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {

        //animate by default
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        switch stepIndex {
        case 0:
            do {
                SCNTransaction.animationDuration = 0.0
            
                // Set the slide's title and subtitle and add some text
                _ = self.textManager.set(title: "Morphing")
                _ = self.textManager.add(bullet: "Linear morph between multiple targets",
                                         at: 0)
            
                // Initial state, no ambient occlusion
                // This also shows how uniforms from shader modifiers can be set using KVC
                _mapNode?.geometry?.setValue(NSNumber(value: Float(0.0)),
                                             forKey: "ambientOcclusionYFactor")
            }
        case 1:
            do {
                self.textManager.flipOutText(ofTextType: .bullet)

                // Reveal the map and show the gauges
                _mapNode?.opacity = 1.0

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    _gaugeANode = SCNNode.asc_gaugeNode(withTitle: "Target A",
                                                        progressNode: &_gaugeAProgressNode)
                    _gaugeANode?.position = SCNVector3Make(-10.5, 15, -5)
                    self.contentNode.addChildNode(_gaugeANode!)
                    
                    _gaugeBNode = SCNNode.asc_gaugeNode(withTitle: "Target B",
                                                        progressNode:&_gaugeBProgressNode)
                    _gaugeBNode?.position = SCNVector3Make(-10.5, 13, -5)
                    self.contentNode.addChildNode(_gaugeBNode!)
                }
                SCNTransaction.commit()
            }
        case 2:
            do {
                // Morph and update the gauges
                _gaugeAProgressNode?.scale = SCNVector3Make(1, 1, 1)
                _mapNode?.morpher?.setWeight(0.65,
                                             forTargetAt: 0)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.1
                do {
                    _gaugeAProgressNode?.opacity = 1.0
                }
                SCNTransaction.commit()

                let shadowPlane = _mapNode?.childNodes[0]
                shadowPlane?.scale = SCNVector3Make(0.35, 1, 1)

                _mapNode?.parent?.rotation = SCNVector4Make(1, 0, 0,
                                                            (-CGFloat.pi/4 * 0.75))
            }
        case 3:
            do {
                // Morph and update the gauges
                _gaugeAProgressNode?.scale = SCNVector3Make(1, 0.01, 1)
                _mapNode?.morpher?.setWeight(0,
                                             forTargetAt: 0)

                let shadowPlane = _mapNode?.childNodes[0]
                shadowPlane?.scale = SCNVector3Make(1, 1, 1)

                _mapNode?.parent?.rotation = SCNVector4Make(1, 0, 0,
                                                            0)

                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    do {
                        self._gaugeAProgressNode?.opacity = 0.0
                    }
                    SCNTransaction.commit()
                }
            }
        case 4:
            do {
                // Morph and update the gauges
                _gaugeBProgressNode?.scale = SCNVector3Make(1, 1, 1)
                _mapNode?.morpher?.setWeight(0.4,
                                             forTargetAt: 1)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.1
                do {
                    _gaugeBProgressNode?.opacity = 1.0
                }
                SCNTransaction.commit()
                
                let shadowPlane = _mapNode?.childNodes[0]
                shadowPlane?.scale = SCNVector3Make(1, 0.6, 1)
                
                _mapNode?.parent?.rotation = SCNVector4Make(0, 1, 0,
                                                            (-CGFloat.pi/4 * 0.5))
            }
        case 5:
            do {
                // Morph and update the gauges
                _gaugeBProgressNode?.scale = SCNVector3Make(1, 0.01, 1)
                _mapNode?.morpher?.setWeight(0,
                                             forTargetAt: 1)

                let shadowPlane = _mapNode?.childNodes[0]
                shadowPlane?.scale = SCNVector3Make(1, 1, 1)
                
                _mapNode?.parent?.rotation = SCNVector4Make(0, 1, 0,
                                                            0)

                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    do {
                        self._gaugeBProgressNode?.opacity = 0.0
                    }
                    SCNTransaction.commit()
                }
            }
        case 6:
            do {
                // Morph and update the gauges
                _gaugeAProgressNode?.scale = SCNVector3Make(1, 1, 1)
                _gaugeBProgressNode?.scale = SCNVector3Make(1, 1, 1)

                _mapNode?.morpher?.setWeight(0.65,
                                             forTargetAt: 0)
                _mapNode?.morpher?.setWeight(0.30,
                                             forTargetAt: 1)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.1
                do {
                    _gaugeAProgressNode?.opacity = 1.0
                    _gaugeBProgressNode?.opacity = 1.0
                }
                SCNTransaction.commit()

                let shadowPlane = _mapNode?.childNodes[0]
                shadowPlane?.scale = SCNVector3Make(0.4, 0.7, 1)
                shadowPlane?.opacity = 0.2

                _mapNode?.geometry?.setValue(NSNumber(value: Float(0.35)),
                                             forKey: "ambientOcclusionYFactor")

                _mapNode?.position = SCNVector3Make(0, 0, 5)
                _mapNode?.parent?.rotation = SCNVector4Make(0, 1, 0,                            // axis of rotation:y-axis
                                                            (-CGFloat.pi/4 * 0.5))              // angle of rotation
                _mapNode?.rotation = SCNVector4Make(1, 0, 0,                                    // axis of rotation:x-axis
                                                    (CGFloat.pi/2 + (-CGFloat.pi/4 * 0.75)))    // angle of rotation
            }
        case 7:
            do {
                SCNTransaction.animationDuration = 0.5

                // Hide gauges and update the text
                _gaugeANode?.opacity = 0.0
                _gaugeBNode?.opacity = 0.0

                _ = self.textManager.set(subtitle: "SCNMorpher")

                _ = self.textManager.add(bullet: "Topology must match", at: 0)
                _ = self.textManager.add(bullet: "Can be loaded from DAEs", at: 0)
                _ = self.textManager.add(bullet: "Can be created programmatically", at: 0)
            }
        default:
            break
        }
        SCNTransaction.commit()
    }
}
