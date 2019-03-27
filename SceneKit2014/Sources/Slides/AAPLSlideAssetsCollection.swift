/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Presents how dae files are supported on OS X.

*/

import SceneKit

// slide #20
class AAPLSlideAssetsCollection: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Slide's title and subtitle
        _ = self.textManager.set(title: "Assets Catalog")
        _ = self.textManager.set(subtitle: ".scnassets folders")

        _ = self.textManager.add(bullet: "Manage your assets", at: 0)
        _ = self.textManager.add(bullet: "Add DAE files and referenced textures", at: 0)
        _ = self.textManager.add(bullet: "Optimized at build time", at: 0)
        _ = self.textManager.add(bullet: "Compilation options", at: 0)
        _ = self.textManager.add(bullet: "Geometry interleaving", at: 0)
        _ = self.textManager.add(bullet: "PVRTC, Up axis", at: 0)

        let intermediateNode = SCNNode()
        intermediateNode.position = SCNVector3Make(0, 0, 7)
        self.groundNode.addChildNode(intermediateNode)

        // Load the "folder" model
        let folder = intermediateNode.asc_addChildNode(named:"folder",
                                                       fromSceneNamed: "Scenes.scnassets/assetCatalog/assetCatalog",
                                                       withScale: 8)
        folder.position = SCNVector3Make(5, 0, 2)
        folder.rotation = SCNVector4Make(0, 1, 0,               // axis of rotation
                                         -CGFloat.pi/4 * 0.9)   // angle of rotation
    }
}
