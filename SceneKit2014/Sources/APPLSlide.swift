/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

The AAPLSlide class represents a slide. A slide owns a node tree, some properties and a text manager.

*/


import SceneKit

// This is the super class of all slide classes.
class APPLSlide: NSObject {
    var contentNode: SCNNode
    var groundNode: SCNNode
    var textManager: AAPLSlideTextManager

    var isNewIn10_10: Bool

    var lightIntensities = [NSNumber](repeating: NSNumber(value: 0.0),
                                      count: 6)
    var mainLightPosition: SCNVector3
    // For KVC to work the variables must be initialized beforehand
    var floorWarmupMaterial: SCNMaterial    // used to retain a material to prevent it from being released before the slide is presented. This used for preloading and caching.
    var floorImageName: String
    var floorReflectivity: CGFloat
    var floorFalloff: CGFloat

    var transitionDuration: CGFloat
    var transitionOffsetX: CGFloat
    var transitionOffsetZ: CGFloat
    var transitionRotation: CGFloat

    var altitude: CGFloat
    var pitch: CGFloat

    override required init() {
        // Node hierarchy :
        // _contentNode
        // |__ _groundNode           : holds the rest of the scene
        // |__ _textManager.textNode : holds the text

        contentNode = SCNNode()

        groundNode = SCNNode()
        contentNode.addChildNode(groundNode)

        textManager = AAPLSlideTextManager()
        contentNode.addChildNode(textManager.textNode)

        // Default parameters - Scene Kit Presentation.plist has the actual parameters
        // to a specific sub-class of APPLSlide. The method slideAtIndex:loadIfNeeded
        // will extract the actual parameters from the Dictionary created from the plist.

        // Lighting the scene
        lightIntensities[0] = NSNumber(value: 0.0)
        lightIntensities[1] = NSNumber(value: 0.9)
        lightIntensities[2] = NSNumber(value:0.7)
        mainLightPosition = SCNVector3Make(0, 3, -13)

        // Customizing the floor
        floorWarmupMaterial =  SCNMaterial()
        floorImageName = String()
        floorReflectivity = 0.25
        floorFalloff = 3.0

        //Managing transitions
        transitionDuration = 1.0
        transitionOffsetX = 0.0
        transitionOffsetZ = 0.0
        transitionRotation = 0.0

        altitude = 5.0
        pitch = 0.0

        // Diplaying the 'New' badge
        isNewIn10_10 = false
        super.init()
    }

    // The sub-classes will implement one or more of the following methods.
    // Navigating within the slide

    var numberOfSteps: UInt {
        return 0
    }

    func present(stepIndex: UInt,
                 with presentationViewController: AAPLPresentationViewController) {
    }

    func setupSlide(with presentationViewController: AAPLPresentationViewController) {
    }

    // handles pre-early exit from a slide presentation
    func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
    }

    func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
    }
}
