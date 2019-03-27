/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates the new API giving statistics about the scene.
*/

import SceneKit

// slide #54
class AAPLSlideStatistics: APPLSlide {
    var _fpsNode: SCNNode?
    var _panelNode: SCNNode?
    var _buttonNode: SCNNode?
    var _windowNode: SCNNode?

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
            do {
                // Set the slide's title and subtile and add some code
                _ = self.textManager.set(title: "Performance")
                _ = self.textManager.set(subtitle: "Statistics")
                
                _ = self.textManager.add(code: "// Show statistics \n" +
                                                "aSCNView.#showsStatistics# = YES;")
            }
        case 1:
            do {
                // Place a screenshot in the scene and animate it
                _windowNode = SCNNode.asc_planeNode(withImageNamed: "statistics",
                                                    size: 20,
                                                    isLit: true)
                self.contentNode.addChildNode(_windowNode!)

                _windowNode?.opacity = 0.0
                _windowNode?.position = SCNVector3Make(20, 5.4, 9)
                _windowNode?.rotation = SCNVector4Make(0, 1, 0,
                                                       -CGFloat.pi/4)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    _windowNode?.opacity = 1.0;
                    _windowNode?.position = SCNVector3Make(0, 5.4, 7)
                    _windowNode?.rotation = SCNVector4Make(0, 1, 0, 0)
                }
                SCNTransaction.commit()

                // The screenshot contains transparent areas so we need to make sure it is rendered
                // after the text (which also sets its rendering order)
                _windowNode?.renderingOrder = 2
            }
        case 2:
            do {
                _fpsNode = SCNNode.asc_planeNode(withImageNamed: "statistics-fps",
                                                 size: 7,
                                                 isLit: false)
                _windowNode?.addChildNode(_fpsNode!)

                _fpsNode?.scale = SCNVector3Make(0.75, 0.75, 0.75)
                _fpsNode?.opacity = 0.0
                _fpsNode?.position = SCNVector3Make(-6, -3, 0.5)
                _fpsNode?.renderingOrder = 4
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                do {
                    _fpsNode?.scale = SCNVector3Make(1.0, 1.0, 1.0)
                    _fpsNode?.opacity = 1.0
                }
                SCNTransaction.commit()
            }
        case 3:
            do {
                _buttonNode = SCNNode.asc_planeNode(withImageNamed: "statistics-button",
                                                    size:4,
                                                    isLit: false)
                _windowNode?.addChildNode(_buttonNode!)

                _buttonNode?.scale = SCNVector3Make(0.75, 0.75, 0.75)
                _buttonNode?.opacity = 0.0
                _buttonNode?.position = SCNVector3Make(-7.5, -2.75, 0.5)
                _buttonNode?.renderingOrder = 5

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                do {
                    _fpsNode?.opacity = 0.0;
                    _buttonNode?.scale = SCNVector3Make(1.0, 1.0, 1.0)
                    _buttonNode?.opacity = 1.0
                }
                SCNTransaction.commit()
            }
        case 4:
            do {
                _panelNode = SCNNode.asc_planeNode(withImageNamed: "control-panel",
                                                   size: 10,
                                                   isLit: false)
                _windowNode?.addChildNode(_panelNode!)

                _panelNode?.scale = SCNVector3Make(0.75, 0.75, 0.75);
                _panelNode?.opacity = 0.0;
                _panelNode?.position = SCNVector3Make(3.5, -0.5, 1.5);
                _panelNode?.renderingOrder = 6;

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                do {
                    _panelNode?.scale = SCNVector3Make(1.0, 1.0, 1.0);
                    _panelNode?.opacity = 1.0;
                }
                SCNTransaction.commit()
            }
        case 5:
            do {
                let detailsNode = SCNNode.asc_planeNode(withImageNamed: "statistics-detail",
                                                        size: 9,
                                                        isLit: false)
                _windowNode?.addChildNode(detailsNode)

                detailsNode.scale = SCNVector3Make(0.75, 0.75, 0.75)
                detailsNode.opacity = 0.0
                detailsNode.position = SCNVector3Make(5, -2.75, 1.5)
                detailsNode.renderingOrder = 7

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                do {
                    _panelNode?.opacity = 0.0
                    _buttonNode?.opacity = 0.0
                    
                    detailsNode.scale = SCNVector3Make(1.0, 1.0, 1.0)
                    detailsNode.opacity = 1.0
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }
}
