/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

This slide displays a word cloud introducing the new features added to Scene Kit.

*/

import SceneKit

// slide #2
class AAPLSlideAllNew: APPLSlide {
    var materials: [SCNMaterial]?
    var font: NSFont?

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Create the font and the materials that will be shared among the features in the word cloud
        font = NSFont(name:"Myriad Set BoldItalic", size:50)
        if font == nil {
            font =  NSFont(name:"Avenir Heavy Oblique", size: 50)
        }

        let frontAndBackMaterial = SCNMaterial()
        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = NSColor.darkGray
        
        materials = [frontAndBackMaterial, sideMaterial, frontAndBackMaterial]

        self.place(feature: "Techniques", at: NSMakePoint(10,-8), timeOffset: 0)
        self.place(feature: "SpriteKit materials", at: NSMakePoint(-16,-7), timeOffset: 0.05)
        self.place(feature: "Inverse kinematics", at: NSMakePoint(-12,-6), timeOffset: 0.1)
        self.place(feature: "Actions", at: NSMakePoint(-10,6), timeOffset: 0.15)
        self.place(feature: "SKTexture", at: NSMakePoint(4,9), timeOffset: 0.2)
        self.place(feature: "JavaScript", at: NSMakePoint(-4,8), timeOffset: 0.25)
        self.place(feature: "Alembic", at: NSMakePoint(-3,-8), timeOffset: 0.3)
        self.place(feature: "OpenSubdiv", at: NSMakePoint(-1,6), timeOffset: 0.35)
        self.place(feature: "Assets catalog", at: NSMakePoint(1,5), timeOffset: 0.85)
        self.place(feature: "SIMD bridge", at: NSMakePoint(3,-6), timeOffset: 0.45)
        self.place(feature: "Physics", at: NSMakePoint(-0.5,0), timeOffset: 0.47)
        self.place(feature: "Vehicle", at: NSMakePoint(5,3), timeOffset: 0.50)
        self.place(feature: "Fog", at: NSMakePoint(7,2), timeOffset: 0.95)
        self.place(feature: "SpriteKit overlays", at: NSMakePoint(-10,1), timeOffset: 0.60)
        self.place(feature: "Particles", at: NSMakePoint(-13,-1), timeOffset: 0.65)
        self.place(feature: "Forward shadows", at: NSMakePoint(8,-1), timeOffset: 0.7)
        self.place(feature: "Snapshot", at: NSMakePoint(6,-2), timeOffset: 0.75)
        self.place(feature: "Physics fields", at: NSMakePoint(-6,-3), timeOffset: 0.8)
        self.place(feature: "Archiving", at: NSMakePoint(-11,3), timeOffset: 0.9)
        self.place(feature: "Performance tools", at: NSMakePoint(-2,-5), timeOffset: 1)
    }

    func place(feature string: String,
               at point: NSPoint,
               timeOffset offset: CGFloat) {

        // Create and configure a node with a text geometry, and add it to the scene
        let text = SCNText(string: string, extrusionDepth:5)
        text.font = font
        text.flatness = 0.4
        text.materials = materials!

        let textNode = SCNNode()
        textNode.geometry = text
        textNode.position = SCNVector3Make(point.x, point.y + self.altitude, 0)
        textNode.scale = SCNVector3Make(0.02, 0.02, 0.02)

        self.contentNode.addChildNode(textNode)

        // Animation the node's position and opacity
        let positionAnimation = CABasicAnimation(keyPath: "position.z")
        positionAnimation.fromValue = -10
        positionAnimation.toValue = 14
        positionAnimation.duration = 7.0
        positionAnimation.timeOffset = Double(-offset) * positionAnimation.duration
        positionAnimation.repeatCount = .greatestFiniteMagnitude
        textNode.addAnimation(positionAnimation, forKey:nil)

        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.keyTimes = [0.0, 0.2, 0.9, 1.0]
        opacityAnimation.values = [0.0, 1.0, 1.0, 0.0]
        opacityAnimation.duration = positionAnimation.duration;
        opacityAnimation.timeOffset = positionAnimation.timeOffset;
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        textNode.addAnimation(opacityAnimation, forKey:nil)
    }
}
