/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains the structure of the scene graph with a diagram.
*/


import SceneKit

// slide #5
class AAPLSlideSceneGraph: APPLSlide {
    private static var diagramNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 4
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Scene Graph")
        _ = self.textManager.set(subtitle: "Scene")
        _ = self.textManager.add(bullet: "SCNScene", at: 0)
        _ = self.textManager.add(bullet: "Starting point", at: 0)

        // Setup the diagram
        let diagramNode2 = AAPLSlideSceneGraph.sharedScenegraphDiagramNode()
        self.groundNode.addChildNode(diagramNode2)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        let diagramNode = AAPLSlideSceneGraph.sharedScenegraphDiagramNode()
        AAPLSlideSceneGraph.scenegraphDiagramGoTo(step: stepIndex)

        switch (stepIndex) {
        case 0:
            diagramNode.opacity = 0.0
            diagramNode.position = SCNVector3Make(0.0, 5.0, 3.0)
            diagramNode.rotation = SCNVector4Make(1, 0, 0,
                                                  -CGFloat.pi/2)
        case 1:
            do {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    self.textManager.flipOutText(ofTextType: .bullet)
                    self.textManager.flipOutText(ofTextType: .subtitle)
                    
                    // Change the slide's subtitle and add some text
                    _ = self.textManager.set(subtitle: "Node")
                    _ = self.textManager.add(bullet: "SCNNode",
                                             at: 0)
                    _ = self.textManager.add(bullet: "A location in 3D space",
                                             at: 0)
                    _ = self.textManager.add(bullet: "Position, rotation, scale",
                                             at: 1)

                    self.textManager.flipInText(ofTextType: .subtitle)
                    self.textManager.flipInText(ofTextType: .bullet)
                }
                SCNTransaction.commit()
            }
        case 2:
            _ = self.textManager.add(bullet: "Hierarchy of nodes",
                                     at: 0)
            _ = self.textManager.add(bullet: "Relative to the parent node",
                                     at: 1)
        case 3:
            do {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    self.textManager.flipOutText(ofTextType: .bullet)
                    self.textManager.flipOutText(ofTextType: .subtitle)
                    
                    // Change the slide's subtitle and add some text
                    _ = self.textManager.set(subtitle: "Node attributes")
                    _ = self.textManager.add(bullet: "Geometry",
                                             at: 0)
                    _ = self.textManager.add(bullet: "Camera",
                                             at: 0)
                    _ = self.textManager.add(bullet: "Light",
                                             at: 0)
                    _ = self.textManager.add(bullet: "Can be shared",
                                             at: 0)
                    self.textManager.flipInText(ofTextType: .subtitle)
                    self.textManager.flipInText(ofTextType: .bullet)
                }
                SCNTransaction.commit()
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    // move the diagram up otherwise it would intersect the floor
                    diagramNode.position = SCNVector3Make(0.0, diagramNode.position.y + 1.0, 3.0);
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {

        let diagramNode = AAPLSlideSceneGraph.sharedScenegraphDiagramNode()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            diagramNode.opacity = 1.0;
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.0
            diagramNode.rotation = SCNVector4Make(1, 0, 0, 0);
            SCNTransaction.commit()
            AAPLSlideSceneGraph.showNodes(named: ["scene"])
        }
        SCNTransaction.commit()
    }

    class func sharedScenegraphDiagramNode() ->SCNNode  {
        if AAPLSlideSceneGraph.diagramNode == nil {
            AAPLSlideSceneGraph.diagramNode = SCNNode()
            AAPLSlideSceneGraph.diagramNode?.opacity = 0.0

            // "Scene"
            let blue = NSColor(deviceRed: 44.0/255,
                               green: 137.0/255,
                               blue: 214/255.0,
                               alpha: 1)
            var box = SCNNode.asc_boxNode(title: "Scene",
                                          frame: NSMakeRect(-53.5, -25, 107, 50),
                                          color: blue,
                                          cornerRadius: 2,
                                          centered: true)
            box.name = "scene";
            box.scale = SCNVector3Make(0.03, 0.03, 0.03)
            box.position = SCNVector3Make(5.4, 4.8, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            // Arrow from "Scene" to "Root Node"
            var arrowNode = SCNNode()
            arrowNode.name = "sceneArrow";
            arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(3,0.2),
                                                                                 tipSize: NSMakeSize(0.5, 0.7),
                                                                                 hollow: 0.2,
                                                                                 twoSides: false),
                                          extrusionDepth: 0)
            arrowNode.scale = SCNVector3Make(20, 20, 1);
            arrowNode.position = SCNVector3Make(-5, 0, 8);
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -CGFloat.pi/2)
            arrowNode.geometry?.firstMaterial?.diffuse.contents = blue;
            box.addChildNode(arrowNode)

            // "Root Node"
            let green = NSColor(deviceRed: 58.0/255,
                                green: 166.0/255,
                                blue: 76.0/255,
                                alpha: 1)
            box = SCNNode.asc_boxNode(title: "Root Node",
                                      frame: NSMakeRect(-40, -36, 80, 72),
                                      color: green,
                                      cornerRadius:2,
                                      centered: true)
            box.name = "rootNode";
            box.scale = SCNVector3Make(0.03, 0.03, 0.03)
            box.position = SCNVector3Make(5.405, 1.8, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            // Arrows from "Root Node" to child nodes
            arrowNode = arrowNode.clone()
            arrowNode.name = "nodeArrow1";

            arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(5.8,0.15),
                                                                                 tipSize: NSMakeSize(0.5, 0.7),
                                                                                 hollow: 0.2,
                                                                                 twoSides: true),
                                          extrusionDepth:0)
            arrowNode.position = SCNVector3Make(0, -30, 8)
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -(CGFloat.pi * 0.85))
            arrowNode.geometry?.firstMaterial?.diffuse.contents = green
            box.addChildNode(arrowNode)

            arrowNode = arrowNode.clone()
            arrowNode.name = "nodeArrow2";
            arrowNode.position = SCNVector3Make(0, -43, 8)
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -(CGFloat.pi * (1-0.85)))
            box.addChildNode(arrowNode)

            arrowNode = arrowNode.clone()
            arrowNode.name = "nodeArrow3";
            arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(2.6,0.15),
                                                                                 tipSize: NSMakeSize(0.5, 0.7),
                                                                                 hollow: 0.2,
                                                                                 twoSides: true),
                                          extrusionDepth:0)
            arrowNode.position = SCNVector3Make(-4, -38, 8)
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -(CGFloat.pi * 0.5))
            arrowNode.geometry?.firstMaterial?.diffuse.contents = green
            box.addChildNode(arrowNode)

            // Multiple "Child Node"
            box = SCNNode.asc_boxNode(title: "Child Node",
                                      frame: NSMakeRect(-40, -36, 80, 72),
                                      color: green,
                                      cornerRadius: 2,
                                      centered: true)
            box.name = "child1"
            box.scale = SCNVector3Make(0.03, 0.03, 0.03)
            box.position = SCNVector3Make(2.405, -2, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            box = box.clone()
            box.name = "child2"
            box.position = SCNVector3Make(5.405, -2, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            box = box.clone()
            box.name = "child3";
            box.position = SCNVector3Make(8.405, -2, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            // "Light"
            let purple = NSColor(deviceRed: 255.0/255,
                                 green: 45.0/255,
                                 blue: 85.0/255,
                                 alpha: 1)
            box = SCNNode.asc_boxNode(title: "Light",
                                      frame: NSMakeRect(-40, -20, 80, 40),
                                      color: purple,
                                      cornerRadius: 2,
                                      centered: true)
            box.name = "light";
            box.scale = SCNVector3Make(0.03, 0.03, 0.03)
            box.position = SCNVector3Make(2.405, -4.8, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            // Arrow to "Light"
            arrowNode = SCNNode()
            arrowNode.name = "lightArrow"
            arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(2.0,0.15),
                                                                                 tipSize: NSMakeSize(0.5, 0.7),
                                                                                 hollow: 0.2,
                                                                                 twoSides: false),
                                          extrusionDepth: 0)
            arrowNode.position = SCNVector3Make(-5, 60, 8)
            arrowNode.scale = SCNVector3Make(20, 20, 1)
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -CGFloat.pi/2)
            arrowNode.geometry?.firstMaterial?.diffuse.contents = purple
            box.addChildNode(arrowNode)

            // "Camera"
            box = SCNNode.asc_boxNode(title: "Camera",
                                      frame: NSMakeRect(-45, -20, 90, 40),
                                      color: purple,
                                      cornerRadius: 2,
                                      centered: true)
            box.name = "camera"
            box.scale = SCNVector3Make(0.03, 0.03, 0.03)
            box.position = SCNVector3Make(5.25, -4.8, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            // Arrow to "Camera"
            arrowNode = arrowNode.clone()
            arrowNode.name = "cameraArrow"
            arrowNode.position = SCNVector3Make(0, 60, 8)
            box.addChildNode(arrowNode)

            // "Geometry"
            box = SCNNode.asc_boxNode(title: "Geometry",
                                      frame: NSMakeRect(-55, -20, 110, 40),
                                      color: purple,
                                      cornerRadius: 2,
                                      centered: true)
            box.name = "geometry"
            box.scale = SCNVector3Make(0.03, 0.03, 0.03)
            box.position = SCNVector3Make(8.6, -4.8, 0)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(box)

            // Arrows to "Geometry"
            arrowNode = arrowNode.clone()
            arrowNode.name = "geometryArrow";
            arrowNode.position = SCNVector3Make(-10, 60, 8)
            box.addChildNode(arrowNode)

            arrowNode = arrowNode.clone()
            arrowNode.name = "geometryArrow2"
            arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(5.0,0.15),
                                                                                 tipSize:NSMakeSize(0.5, 0.7),
                                                                                 hollow:0.2,
                                                                                 twoSides: false),
                                          extrusionDepth: 0)
            arrowNode.geometry?.firstMaterial?.diffuse.contents = purple
            arrowNode.position = SCNVector3Make(-105, 53, 8)
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -CGFloat.pi / 8)
            box.addChildNode(arrowNode)

            // Multiple "Material"
            let redColor = NSColor(deviceRed: 255.0/255,
                                   green: 149.0/255,
                                   blue: 0.0/255,
                                   alpha: 1)

            let materialsBox = SCNNode.asc_boxNode(title: "",       // nil,
                                                   frame: NSMakeRect(-151, -25, 302, 50),
                                                   color: NSColor.gray,
                                                   cornerRadius: 2,
                                                   centered: true)
            materialsBox.scale = SCNVector3Make(0.03, 0.03, 0.03)
            materialsBox.name = "materials"
            materialsBox.position = SCNVector3Make(8.7, -7.1, -0.2)
            AAPLSlideSceneGraph.diagramNode?.addChildNode(materialsBox)

            box = SCNNode.asc_boxNode(title: "Material",
                                      frame: NSMakeRect(-45, -20, 90, 40),
                                      color: redColor,
                                      cornerRadius: 0,
                                      centered: true)
            box.position = SCNVector3Make(-100, 0, 0.2);
            materialsBox.addChildNode(box)

            box = box.clone()
            box.position = SCNVector3Make(100, 0, 0.2)
            materialsBox.addChildNode(box)

            box = box.clone()
            box.position = SCNVector3Make(0, 0, 0.2)
            materialsBox.addChildNode(box)

            // Arrow from "Geometry" to the materials
            arrowNode = SCNNode()
            arrowNode.geometry = SCNShape(path: NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(2.0,0.15),
                                                                                 tipSize: NSMakeSize(0.5, 0.7),
                                                                                 hollow: 0.2,
                                                                                 twoSides: false),
                                          extrusionDepth: 0)
            arrowNode.position = SCNVector3Make(-6, 65, 8)
            arrowNode.scale = SCNVector3Make(20, 20, 1)
            arrowNode.rotation = SCNVector4Make(0, 0, 1,
                                                -CGFloat.pi/2)
            arrowNode.geometry?.firstMaterial?.diffuse.contents = redColor
            box.addChildNode(arrowNode)

            materialsBox.parent?.replaceChildNode(materialsBox,
                                                  with: materialsBox.flattenedClone())
        }
        return AAPLSlideSceneGraph.diagramNode!
    }

    class func highlightNodes(named names: [String],
                              inNodeTree node: SCNNode) {

        for child in node.childNodes {
            // is the child node's name in the Swift array?
            let isMember = names.contains {
                $0 == child.name
            }
            if isMember {
                child.opacity = 1.0
                // recursive call
                self.highlightNodes(named: names,
                                    inNodeTree: child)
            }
            else {
                if (child.opacity == 1.0) {
                    child.opacity = 0.3;
                }
            }
        }
    }

    class func showNodes(named names:[String]) {
        let diagramNode2 = AAPLSlideSceneGraph.sharedScenegraphDiagramNode()

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            for nodeName in names {
                let node = diagramNode2.childNode(withName: nodeName,
                                                  recursively: true)
                node?.opacity = 1.0
                if (node?.rotation.z == 0.0) {
                    node?.rotation = SCNVector4Make(0, 1, 0,
                                                    0)
                }
            }
        }
        SCNTransaction.commit()
    }

    class func scenegraphDiagramGoTo(step: UInt) {
        let diagramNode2 = AAPLSlideSceneGraph.sharedScenegraphDiagramNode()

        switch (step) {
        case 0:
            // Restore the initial state (hidden and rotated)
            diagramNode2.childNodes(passingTest: {
                (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                    child.opacity = 0.0
                    // don't touch nodes that already have a rotation set
                    if (child.rotation.z == 0) {
                        child.rotation = SCNVector4Make(0, 1, 0,
                                                        CGFloat.pi/2)
                    }
                    return false
                })
        case 1:
            self.showNodes(named: ["sceneArrow", "rootNode"])
        case 2:
            self.showNodes(named: ["child1", "child2", "child3", "nodeArrow1", "nodeArrow2", "nodeArrow3"])
        case 3:
            self.showNodes(named: ["light", "camera", "geometry", "lightArrow", "cameraArrow", "geometryArrow", "geometryArrow2"])
        case 4:
            self.showNodes(named: ["scene", "sceneArrow", "rootNode", "light", "camera", "cameraArrow", "child1", "child2", "child3", "nodeArrow1", "nodeArrow2", "nodeArrow3", "geometry", "lightArrow", "geometryArrow", "geometryArrow2"])
            self.highlightNodes(named: ["scene", "sceneArrow", "rootNode", "light", "camera", "cameraArrow", "child1", "child2", "child3", "nodeArrow1", "nodeArrow2", "nodeArrow3", "geometry", "lightArrow", "geometryArrow", "geometryArrow2"],
                                inNodeTree: diagramNode2)
        case 5:
            self.showNodes(named: ["scene", "sceneArrow", "rootNode", "light", "camera", "cameraArrow", "child1", "child2", "child3", "nodeArrow1", "nodeArrow2", "nodeArrow3", "geometry", "lightArrow", "geometryArrow", "geometryArrow2", "materials"])
            self.highlightNodes(named: ["scene", "sceneArrow", "rootNode", "child2", "child3", "nodeArrow2", "nodeArrow3", "geometry", "geometryArrow","geometryArrow2", "materials"],
                                inNodeTree: diagramNode2)
        case 6:
            self.highlightNodes(named: ["child3", "geometryArrow", "geometry"],
                                inNodeTree: diagramNode2)
        case 7:
            self.showNodes(named: ["scene", "sceneArrow", "rootNode", "light", "camera", "cameraArrow", "child1", "child2", "child3", "nodeArrow1", "nodeArrow2", "nodeArrow3", "geometry", "lightArrow", "geometryArrow", "geometryArrow2", "materials"])
        default:
            break
        }
    }
}
