/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Presents how dae files are supported on OS X.

*/

import SceneKit

// slide #17
class AAPLSlideDaeOnOSX: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Slide's title and subtitle
        _ = self.textManager.set(title: "Working with DAE Files")
        _ = self.textManager.set(subtitle: "DAE files on OS X")

        // DAE icon
        let daeIconNode = SCNNode.asc_planeNode(withImageNamed: "dae file icon",
                                                size: 5,
                                                isLit: false)
        daeIconNode.position = SCNVector3Make(0, 2.3, 0)
        self.groundNode.addChildNode(daeIconNode)

        // Preview icon and text
        let previewIconNode = SCNNode.asc_planeNode(withImageNamed: "Preview.tiff",
                                                    size:3,
                                                    isLit: false)
        previewIconNode.position = SCNVector3Make(-5, 1.3, 11)
        self.groundNode.addChildNode(previewIconNode)
        
        let previewTextNode = SCNNode.asc_labelNode(withString: "Preview",
                                                    size: .small,
                                                    isLit: false)
        previewTextNode.position = SCNVector3Make(-5.5, 0, 13)
        self.groundNode.addChildNode(previewTextNode)

        // Quicklook icon and text
        let qlIconNode = SCNNode.asc_planeNode(withImageNamed: "Finder.tiff",
                                               size:3,
                                               isLit: false)
        qlIconNode.position = SCNVector3Make(0, 1.3, 11)
        self.groundNode.addChildNode(qlIconNode)

        let qlTextNode = SCNNode.asc_labelNode(withString: "QuickLook",
                                               size: .small,
                                               isLit: false)
        qlTextNode.position = SCNVector3Make(-1.11, 0, 13)
        self.groundNode.addChildNode(qlTextNode)

        // Xcode icon and text
        let xcodeIconNode = SCNNode.asc_planeNode(withImageNamed: "Xcode.tiff",
                                                  size:3,
                                                  isLit: false)
        xcodeIconNode.position = SCNVector3Make(5, 1.3, 11)
        self.groundNode.addChildNode(xcodeIconNode)

        let xcodeTextNode = SCNNode.asc_labelNode(withString: "Xcode",
                                                  size: .small,
                                                  isLit: false)
        xcodeTextNode.position = SCNVector3Make(3.8, 0, 13)
        self.groundNode.addChildNode(xcodeTextNode)
    }
}
