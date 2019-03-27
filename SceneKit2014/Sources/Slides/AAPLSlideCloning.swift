/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Shows how objects can be shared or unshared depending on specific needs.

*/

import SceneKit

// slide #56
class AAPLSlideCloning: APPLSlide {
    var _redColor, _greenColor, _blueColor, _purpleColor: NSColor?
    var _diagramNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 4
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _redColor = NSColor(deviceRed:168.0 / 255.0, green:21.0 / 255.0, blue:0.0 / 255.0, alpha:1.0)
        _greenColor = NSColor(deviceRed:154.0 / 255.0, green:197.0 / 255.0, blue:58.0 / 255.0, alpha:1.0)
        _blueColor = NSColor(deviceRed:49.0 / 255.0, green:80.0 / 255.0, blue:201.0 / 255.0, alpha:1.0)
        _purpleColor = NSColor(deviceRed:190.0 / 255.0, green:56.0 / 255.0, blue:243.0 / 255.0, alpha:1.0)

        // Create the diagram but hide it
        _diagramNode = self.cloningDiagramNode()
        _diagramNode?.opacity = 0.0
        self.contentNode.addChildNode(_diagramNode!)
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        // Once the slide ordered in, reveal the diagram
        
        for node in (_diagramNode?.childNodes)! {
            node.rotation = SCNVector4Make(0, 1, 0,
                                           CGFloat.pi/2)    // initially viewed from the side
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        do {
            _diagramNode?.opacity = 1.0
            for node in (_diagramNode?.childNodes)! {
                node.rotation = SCNVector4Make(0, 1, 0,
                                               0)
            }
        }
        SCNTransaction.commit()
    }

    override func present(stepIndex: UInt,
                 with: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            // Set the slide's title and subtitle and add some text
            _ = self.textManager.set(title: "Performance")
            _ = self.textManager.set(subtitle: "Copying")
            
            _ = self.textManager.add(bullet: "Attributes are shared by default",
                                     at: 0)
            _ = self.textManager.add(bullet: "Unshare if needed",
                                     at: 0)
            _ = self.textManager.add(bullet: "Copying geometries is cheap",
                                     at: 0)
        case 1:
            do {
                // New "Node B" box
                let nodeB = SCNNode.asc_boxNode(title: "Node B",
                                                frame:NSMakeRect(-55, -36, 110, 50),
                                                color: _greenColor!,
                                                cornerRadius: 10,
                                                centered: true)
                nodeB.name = "nodeB"
                nodeB.position = SCNVector3Make(140, 0, 0)
                nodeB.opacity = 0

                let nodeA = self.contentNode.childNode(withName: "nodeA",
                                                       recursively: true)
                nodeA?.addChildNode(nodeB)
                // Arrow from "Root Node" to "Node B"
                var arrowNode = SCNNode()
                arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(140, 3),
                                                                                     tipSize: NSMakeSize(10, 14),
                                                                                     hollow: 4,
                                                                                     twoSides: false),
                                              extrusionDepth: 0)
                arrowNode.position = SCNVector3Make(-130, 60, 0)
                arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                    -CGFloat.pi * 0.12)
                arrowNode.geometry?.firstMaterial?.diffuse.contents = _greenColor
                nodeB.addChildNode(arrowNode)

                // Arrow from "Node B" to the shared geometry
                arrowNode = SCNNode()
                arrowNode.name = "arrow-shared-geometry"
                arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(140, 3),
                                                                                     tipSize: NSMakeSize(10, 14),
                                                                                     hollow: 4,
                                                                                     twoSides: true),
                                              extrusionDepth: 0)
                arrowNode.position = SCNVector3Make(0, -28, 0)
                arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                    CGFloat.pi * 1.12)
                arrowNode.geometry?.firstMaterial?.diffuse.contents = _purpleColor
                nodeB.addChildNode(arrowNode)

                // Reveal
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1
                do {
                    nodeB.opacity = 1.0

                    // Show the related code
                    _ = self.textManager.add(code: "// Copy a node \n" +
                                            "SCNNode *nodeB = [nodeA #copy#];")
                }
                SCNTransaction.commit()
            }
        case 2:
            do {
                let geometryNodeA = self.contentNode.childNode(withName: "geometry",
                                                               recursively: true)
                let oldArrowNode = self.contentNode.childNode(withName: "arrow-shared-geometry",
                                                              recursively: true)
                // New "Geometry" box
                let geometryNodeB = SCNNode.asc_boxNode(title: "Geometry",
                                                        frame:NSMakeRect(-55, -20, 110, 40),
                                                        color: _purpleColor!,
                                                        cornerRadius: 10,
                                                        centered: true)
                geometryNodeB.position = SCNVector3Make(140, 0, 0)
                geometryNodeB.opacity = 0
                geometryNodeA?.addChildNode(geometryNodeB)

                // Arrow from "Node B" to the new geometry
                var arrowNode = SCNNode()
                arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(55, 3),
                                                                                     tipSize: NSMakeSize(10, 14),
                                                                                     hollow: 4,
                                                                                     twoSides: false),
                                              extrusionDepth: 0)
                arrowNode.position = SCNVector3Make(0, 75, 0)
                arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                    (-CGFloat.pi * 0.5))
                arrowNode.geometry?.firstMaterial?.diffuse.contents = _purpleColor
                geometryNodeB.addChildNode(arrowNode)
                
                // Arrow from the new geometry to "Material"
                arrowNode = SCNNode()
                arrowNode.name = "arrow-shared-material"
                arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(140, 3),
                                                                                     tipSize: NSMakeSize(10, 14),
                                                                                     hollow: 4,
                                                                                     twoSides: true),
                                              extrusionDepth: 0)
                arrowNode.position = SCNVector3Make(-130, -80, 0)
                arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                    CGFloat.pi * 0.12)
                arrowNode.geometry?.firstMaterial?.diffuse.contents = _redColor
                geometryNodeB.addChildNode(arrowNode)

                // Reveal
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1
                do {
                    geometryNodeB.opacity = 1.0
                    oldArrowNode?.opacity = 0.0
                    
                    // Show the related code
                    self.textManager.addEmptyLine()
                    _ = self.textManager.add(code: "// Unshare geometry \n" +
                                                "nodeB.geometry = [nodeB.geometry #copy#];")
                }
                SCNTransaction.commit()
            }
        case 3:
            do {
                let materialANode = self.contentNode.childNode(withName: "material",
                                                               recursively: true)
                let oldArrowNode = self.contentNode.childNode(withName: "arrow-shared-material",
                                                              recursively: true)
                // New "Material" box
                let materialBNode = SCNNode.asc_boxNode(title: "NMaterial",
                                                        frame:NSMakeRect(-55, -36, 110, 40),
                                                        color: NSColor.orange,
                                                        cornerRadius: 10,
                                                        centered: true)
                materialBNode.position = SCNVector3Make(140, 0, 0)
                materialBNode.opacity = 0
                materialANode?.addChildNode(materialBNode)
                
                // Arrow from the unshared geometry to the new material
                let arrowNode = SCNNode()
                arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(55, 3),
                                                                                     tipSize: NSMakeSize(10, 14),
                                                                                     hollow: 4,
                                                                                     twoSides: false),
                                              extrusionDepth: 0)
                arrowNode.position = SCNVector3Make(0, 75, 0)
                arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                    -CGFloat.pi * 0.5)
                arrowNode.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
                materialBNode.addChildNode(arrowNode)
                // Reveal
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1
                do {
                    materialBNode.opacity = 1.0
                    oldArrowNode?.opacity = 0.0
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }

    func cloningDiagramNode() -> SCNNode {
        let diagramNode = SCNNode()
        diagramNode.position = SCNVector3Make(7, 9, 3)

        // "Scene" box
        let sceneNode = SCNNode.asc_boxNode(title: "Scene",
                                            frame: NSMakeRect(-53.5, -25, 107, 50),
                                            color: _blueColor!,
                                            cornerRadius: 10,
                                            centered: true)
        sceneNode.name = "scene"
        sceneNode.scale = SCNVector3Make(0.03, 0.03, 0.03)
        sceneNode.position = SCNVector3Make(0, 4.8, 0)
        diagramNode.addChildNode(sceneNode)



        // "Root node" box
        let rootNode = SCNNode.asc_boxNode(title: "Root Node",
                                           frame: NSMakeRect(-40, -36, 80, 72),
                                           color: _greenColor!,
                                           cornerRadius: 10.0,
                                           centered: true)
        rootNode.name = "rootNode"
        rootNode.scale = SCNVector3Make(0.03, 0.03, 0.03)
        rootNode.position = SCNVector3Make(0.05, 1.8, 0)
        diagramNode.addChildNode(rootNode)

        // "Node A" box
        let nodeA = SCNNode.asc_boxNode(title: "Node A",
                                        frame:NSMakeRect(-55, -36, 110, 50),
                                        color:_greenColor!,
                                        cornerRadius:10,
                                        centered: true)
        nodeA.name = "nodeA"
        nodeA.scale = SCNVector3Make(0.03, 0.03, 0.03)
        nodeA.position = SCNVector3Make(0, -1.4, 0)
        diagramNode.addChildNode(nodeA)

        // "Geometry" box
        let geometryNode = SCNNode.asc_boxNode(title:"Geometry",
                                               frame: NSMakeRect(-55, -20, 110, 40),
                                               color: _purpleColor!,
                                               cornerRadius: 10,
                                               centered: true)
        geometryNode.name = "geometry"
        geometryNode.scale = SCNVector3Make(0.03, 0.03, 0.03)
        geometryNode.position = SCNVector3Make(0, -4.7, 0)
        diagramNode.addChildNode(geometryNode)

        // "Material" box
        let materialNode = SCNNode.asc_boxNode(title:"Geometry",
                                               frame: NSMakeRect(-55, -20, 110, 40),
                                               color: _redColor!,
                                               cornerRadius: 10,
                                               centered: true)
        materialNode.name = "material"
        materialNode.position = SCNVector3Make(0, -7.5, 0)
        materialNode.scale = SCNVector3Make(0.03, 0.03, 0.03)
        diagramNode.addChildNode(materialNode)

        // Arrow from "Scene" to "Root Node"
        var arrowNode = SCNNode()
        arrowNode.name = "sceneArrow"
        arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(3, 0.2),
                                                                             tipSize: NSMakeSize(0.5, 0.7),
                                                                             hollow: 0.2,
                                                                             twoSides: false),
                                      extrusionDepth: 0)
        arrowNode.scale = SCNVector3Make(20, 20, 1)
        arrowNode.position = SCNVector3Make(-5, 0, 8)
        arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                            -CGFloat.pi/2)
        arrowNode.geometry?.firstMaterial?.diffuse.contents = _blueColor
        sceneNode.addChildNode(arrowNode)
        
        // Arrow from "Root Node" to "Node A"
        arrowNode = arrowNode.clone()
        arrowNode.name = "arrow"
        arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(2.6, 0.15),
                                                                             tipSize: NSMakeSize(0.5, 0.7),
                                                                             hollow: 0.2,
                                                                             twoSides: true),
                                      extrusionDepth: 0)
        arrowNode.position = SCNVector3Make(-6, -38, 8)
        arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                            -CGFloat.pi * 0.5)
        arrowNode.geometry?.firstMaterial?.diffuse.contents = _greenColor
        rootNode.addChildNode(arrowNode)

        // Arrow from "Node A" to "Geometry"
        arrowNode = SCNNode()
        arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(3, 0.2),
                                                                             tipSize: NSMakeSize(0.5, 0.7),
                                                                             hollow: 0.2,
                                                                             twoSides: false),
                                      extrusionDepth: 0)
        arrowNode.position = SCNVector3Make(-5, 74, 8)
        arrowNode.scale = SCNVector3Make(20, 20, 1)
        arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                            -CGFloat.pi/2)
        arrowNode.geometry?.firstMaterial?.diffuse.contents = _purpleColor
        geometryNode.addChildNode(arrowNode)

        // Arrow from "Geometry" to "Material"
        arrowNode = SCNNode()
        arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(2.7, 0.15),
                                                                             tipSize: NSMakeSize(0.5, 0.7),
                                                                             hollow: 0.2,
                                                                             twoSides: false),
                                      extrusionDepth: 0)
        arrowNode.position = SCNVector3Make(-6, 74, 8)
        arrowNode.scale = SCNVector3Make(20, 20, 1)
        arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                            -CGFloat.pi/2)
        arrowNode.geometry?.firstMaterial?.diffuse.contents = _redColor
        materialNode.addChildNode(arrowNode)

        return diagramNode
    }
}
