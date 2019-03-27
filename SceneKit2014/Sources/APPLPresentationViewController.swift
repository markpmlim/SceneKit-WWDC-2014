/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

AAPLPresentationViewController controls the presentation, including ordering the slides in and out, updating the position of the camera, the light intensites and more.

*/

import SceneKit

// The following string must match the module name of this demo.
let productModuleName = "SceneKit2014."

enum APPLLightName: Int {
    case main = 0
    case front = 1
    case spot = 2
    case left = 3
    case right = 4
    case ambient = 5
    case count = 6
}
    
@objc protocol APPLPresentationDelegate {
    // Called whenever a scene manager has transitioned to a new scene.
    func presentationViewController(_ presentationViewController: AAPLPresentationViewController,
                                    willPresentSlideAtIndex slideIndex: UInt,
                                    step: UInt)
}

let AAPL_INITIAL_SLIDE: UInt = 0

class AAPLPresentationViewController: NSViewController {
    static var demoRunning = false
    static var demoShouldStop = false

    var delegate: AAPLAppDelegate?
    var currentSlideIndex: UInt = 0
    var currentSlideStep: UInt?

    // The scene used for this presentation
    var scene: SCNScene?

    // Light nodes
    var lights: [SCNNode] = [SCNNode](repeating: SCNNode(),
                                      count: Int(UInt(APPLLightName.count.rawValue)))

    // Other useful nodes
    var cameraNode: SCNNode?
    var cameraPitch: SCNNode?
    var cameraHandle: SCNNode?
    // Nodes used to control the lighting
    var spotLight: SCNNode?
    var mainLight: SCNNode??
    var showsNewInSceneKitBadge: Bool?

    // Managing the floor
    var floor: SCNFloor?
    var floorImagePath = String()

    // Presentation settings and slides
    var settings: [String : AnyObject]?
    var slideCache = [Int : APPLSlide?]()        // dictionary with an integer as key

    // Managing the "New" badge
    var newBadgeNode: SCNNode?
    var newBadgeAnimation: CAAnimation?

    // We didn't set the renderingAPI.
    var presentationView: SCNView {
        //print("self view", self.view)
        return self.view as! SCNView
        //return super.view as! SCNView
    }

    convenience init?(contentsOfFile path: String) {
        self.init(nibName: nil, bundle: nil)
        // Load the presentation settings from the plist file
        let settingsPath = Bundle.main.path(forResource: path,
                                            ofType: "plist")
        //print(settingsPath)
        settings = NSDictionary(contentsOfFile: settingsPath!) as? [String : AnyObject]
    /*
        let array = settings?["Slides"] as! [[String : AnyObject]]
        for i in 0..<array.count {
            let item = array[i]
            let str = item["Class"] as! String
            if let dict = item["Parameters"] as? [String : AnyObject] {
                print("item\(i)", str, dict)
            }
            else {
                print("item\(i)", str)
            }
        }
    */
        scene = SCNScene()

        cameraHandle = SCNNode()
        cameraHandle!.name = "cameraHandle"
        scene!.rootNode.addChildNode(cameraHandle!)
        cameraPitch = SCNNode()
        cameraPitch!.name = "cameraPitch"
        cameraHandle!.addChildNode(cameraPitch!)

        cameraNode = SCNNode()
        cameraNode!.name = "cameraNode";
        cameraNode!.camera = SCNCamera()

        // Set the default field of view to 70 degrees (a relatively strong perspective)
        cameraNode!.camera!.xFov = 70.0;
        cameraNode!.camera!.yFov = 42.0;
        cameraPitch!.addChildNode(cameraNode!)

        // Setup the different lights
        initLighting()

        // Create and add a reflective floor to the scene
        let floorMaterial = SCNMaterial()
        floorMaterial.ambient.contents = NSColor.black
        floorMaterial.diffuse.contents = "floor.png"
        floorMaterial.locksAmbientWithDiffuse = true
        floorMaterial.normal.wrapS = .mirror
        floorMaterial.normal.wrapT = .mirror
        floorMaterial.specular.wrapS = .mirror
        floorMaterial.specular.wrapT = .mirror
        floorMaterial.diffuse.wrapS  = .mirror
        floorMaterial.diffuse.wrapT  = .mirror
        floorMaterial.normal.contents = "floorBump.jpg"
        floorMaterial.normal.mipFilter = .linear
        floorMaterial.diffuse.mipFilter = .linear
        // The structs CATransform3D and SCNMatrix4 are same.
        floorMaterial.diffuse.contentsTransform = CATransform3DScale(SCNMatrix4MakeRotation(CGFloat.pi/4,
                                                                                            0, 0, 1),       // z-axis
                                                                     1.0, 1.0, 1.0);                        // scale
        floorMaterial.normal.contentsTransform = SCNMatrix4MakeScale(20.0, 20.0, 1.0)
        floorMaterial.normal.intensity = 0.5

        floor = SCNFloor()
        floor?.reflectionFalloffEnd = 3.0
        floor?.firstMaterial = floorMaterial

        let floorNode = SCNNode()
        floorNode.geometry = floor
        scene?.rootNode.addChildNode(floorNode)

        floorNode.physicsBody = SCNPhysicsBody.static() //make floor dynamic for physics slides
        scene?.physicsWorld.speed = 0                   //pause physics to avoid continuous drawing

        // Use a shader modifier to support a secondary texture for some slides
        let shaderFile = Bundle.main.path(forResource: "floor",
                                          ofType:"shader")
        var shaderSource = String()
        do {
            shaderSource = try NSString(contentsOfFile: shaderFile!,
                                        encoding:String.Encoding.utf8.rawValue) as String
        }
        catch let err as NSError {
            print("Error reading 'floor' shader file:", err)
            exit(1)
        }
        floorMaterial.shaderModifiers = [SCNShaderModifierEntryPoint.surface : shaderSource]

        // Set the scene to the view
        self.view = AAPLView()

        // bg color
        self.presentationView.backgroundColor = NSColor.black

        // black fog
        scene?.fogColor = NSColor(calibratedWhite: 0,
                                   alpha: 1.0)
        scene?.fogEndDistance = 45.0;
        scene?.fogStartDistance = 40.0;

        // assign the scene to the view
        self.presentationView.scene = scene;

        // Turn on jittering for better anti-aliasing when the scene is still
        self.presentationView.isJitteringEnabled = true

        // Start the presentation
        goToSlide(at: AAPL_INITIAL_SLIDE)
    }
    
    func applicationDidFinishLaunching() {

    }

    // mark - Presentation outline
    var numberOfSlides: UInt {
        return UInt((settings?["Slides"]!.count)!)
    }

    // is there a method of getting the productModuleName instead of hardcoding?
    func classOfSlide(at slideIndex: UInt) -> APPLSlide.Type? {
        let array = settings?["Slides"] as! [[String:AnyObject]]
        let item = array[Int(slideIndex)]
        let className = item["Class"] as! String
        let fullClassName = productModuleName + className
        //print(fullClassName)
        let theClass = NSClassFromString(fullClassName) as? APPLSlide.Type
        //print(theClass)
        return theClass
    }

    // mark - Slide creation and warm up
    func slide(at slideIndex: UInt,
               loadIfNeeded: Bool) -> APPLSlide? {

        let array = settings?["Slides"] as! [[String:AnyObject]]
        if slideIndex < 0 || slideIndex >= UInt(array.count) {
            return nil
        }

        // Look into the cache first
        var slide = slideCache[Int(slideIndex)]
        if slide != nil {
            return slide!
        }

        if !loadIfNeeded {
            return nil
        }

        // Create the new slide
        let slideClass = classOfSlide(at :slideIndex)
        slide = slideClass!.init()
        // Update its parameters (read from Scene Kit Presentation.plist)
        let info = array[Int(slideIndex)]
        if let parameters = info["Parameters"] as? NSDictionary {
            parameters.enumerateKeysAndObjects({
                (key: Any, obj: Any, stop: UnsafeMutablePointer<ObjCBool>)  -> Void in
                slide??.setValue(obj, forKey: key as! String)
            })
        }

        slideCache[Int(slideIndex)] = slide!
        if slide == nil {
            return nil
        }

        // Setup the slide
        slide!?.setupSlide(with: self)

        return slide!
    }
    
    // Preload the next slide
    func prepareSlide(at slideIndex: UInt) {
        if slideIndex != currentSlideIndex+1 {
            return
        }

        // Retrieve the slide to preload

        if let slide = self.slide(at: slideIndex,
                                  loadIfNeeded: true) {
            // make sure that all pending transactions are flushed 
            // otherwise objects not added yet to the scene graph would not be preloaded
            SCNTransaction.flush()

            // Preload the node tree
            self.presentationView.prepare(slide.contentNode,
                                            shouldAbortBlock: nil)

            // Preload the floor image if any
            if slide.floorImageName.lengthOfBytes(using: .utf8) != 0 {
                // Create a container for this image to be able to preload it
                let material = SCNMaterial()
                material.diffuse.contents = slide.floorImageName
                material.diffuse.mipFilter = .linear    // we also want to preload mipmaps

                SCNTransaction.flush()  //make this material ready before warming up

                // Preload
                self.presentationView.prepare(material,
                                                shouldAbortBlock: nil)
                
                // Don't release the material now, otherwise we will loose what we just preloaded
                slide.floorWarmupMaterial = material
            }
        }
    }

    // mark - Navigating within a presentation

    func goToNextSlideStep() {
        let slide = self.slide(at: currentSlideIndex,
                               loadIfNeeded:false)
        if currentSlideStep! + 1 >= (slide?.numberOfSteps)! {
            self.goToSlide(at: currentSlideIndex + 1)
        }
        else {
            self.goToSlideStep(currentSlideStep! + 1)
        }
    }

    func goToPreviousSlide() {
        if currentSlideIndex >= 1 {
            self.goToSlide(at: currentSlideIndex - 1)
        }
    }

    func goToSlide(at slideIndex: UInt) {
        let oldIndex = currentSlideIndex

        // Load the slide at the specified index
        guard let slide = self.slide(at: slideIndex,
                                     loadIfNeeded:true)
        else {
            return
        }

        // Compute the playback direction (did the user select next or previous?)
        let direction = slideIndex >= currentSlideIndex ? 1 : -1

        // Update badge
        self.setShowsNewInSceneKitBadge(showsBadge: slide.isNewIn10_10)

        // If we are playing backward, we need to use the slide we come from to play the correct transition (backward)
        let transitionSlideIndex = direction == 1 ? slideIndex : currentSlideIndex
        let transitionSlide = self.slide(at: transitionSlideIndex,
                                         loadIfNeeded: true)

        // Make sure that the next operations are synchronized by using a transaction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0
        do {
            let rootNode = slide.contentNode
            let textContainer = slide.textManager.textNode

            var offset = SCNVector3Make((transitionSlide?.transitionOffsetX)!,
                                        0.0,
                                        (transitionSlide?.transitionOffsetZ)!)
            offset.x *= CGFloat(direction)
            offset.z *= CGFloat(direction)

            // Rotate offset based on current yaw
            let cosa = cos(Double(-cameraHandle!.rotation.w))
            let sina = sin(Double(-cameraHandle!.rotation.w))

            let tmpX = offset.x * CGFloat(cosa) - offset.z * CGFloat(sina)
            offset.z = offset.x * CGFloat(sina) + offset.z * CGFloat(cosa)
            offset.x = tmpX

            // If we don't move, fade in
            if (offset.x == 0 && offset.y == 0 && offset.z == 0 && transitionSlide?.transitionRotation == 0) {
                rootNode.opacity = 0;
            }

            // Don't animate the first slide
            let shouldAnimate = !(slideIndex == 0 && currentSlideIndex == 0)

            // Update current slide index
            currentSlideIndex = slideIndex;

            // Go to step 0
            self.goToSlideStep(0)

            // Add the slide to the scene graph
            self.presentationView.scene?.rootNode.addChildNode(rootNode)

            // Fade in, update paramters and notify on completion
            SCNTransaction.begin()
            SCNTransaction.animationDuration = Double(shouldAnimate ? slide.transitionDuration : CGFloat(0))
            SCNTransaction.completionBlock = {
                self.didOrderInSlide(at: slideIndex)
            }
            do {
                rootNode.opacity = 1;

                cameraHandle?.position = SCNVector3Make((cameraHandle?.position.x)! + offset.x,
                                                        slide.altitude,
                                                        (cameraHandle?.position.z)! + offset.z);
                cameraHandle?.rotation = SCNVector4Make(0, 1, 0,
                                                        (cameraHandle?.rotation.w)! + (transitionSlide?.transitionRotation)! * CGFloat(.pi / 180.0 * Double(direction)))
                cameraPitch?.rotation = SCNVector4Make(1, 0, 0,
                                                       slide.pitch * CGFloat(.pi / 180.0))

                self.updateLightingForSlide(at: slideIndex)

                floor?.reflectivity = slide.floorReflectivity;
                floor?.reflectionFalloffEnd = slide.floorFalloff;
            }
            SCNTransaction.commit()

            // Compute the position of the text (in world space, relative to the camera)
            let textWorldTransform = CATransform3DConcat(SCNMatrix4MakeTranslation(0, -3.3, -28),
                                                         (cameraNode?.worldTransform)!)

            // Place the rest of the slide
            rootNode.transform = textWorldTransform;
            rootNode.position = SCNVector3Make(rootNode.position.x, 0, rootNode.position.z) // clear altitude
            rootNode.rotation = SCNVector4Make(0, 1, 0,
                                               cameraHandle!.rotation.w)    // use same rotation as the camera to simplify the placement of the elements in slides

            // Place the text
            let textTransform = textContainer.parent?.convertTransform(textWorldTransform,
                                                                       from: nil)
            textContainer.transform = textTransform!

            // Place the ground node
            var localPosition = SCNVector3Make(0, 0, 0)
            var worldPosition = slide.groundNode.parent?.convertPosition(localPosition,
                                                                         to: nil)
            worldPosition?.y = 0; // make it touch the ground

            localPosition = (slide.groundNode.parent?.convertPosition(worldPosition!,
                                                         from: nil))!
            slide.groundNode.position = localPosition;

            // Update the floor image if needed
            self.update(floorImage: slide.floorImageName,
                        for: slide)
        }
        SCNTransaction.commit()

        // Preload the next slide after some delay
        let delayInSeconds: Double = 1.5
        let popTime = DispatchTime.now().rawValue + (UInt64(delayInSeconds) * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
            self.prepareSlide(at: slideIndex + 1)
        }

        // Order out previous slide if any
        if oldIndex != currentSlideIndex {
            self.willOrderOutSlide(at: oldIndex)
        }
    }

    func goToSlideStep(_ index: UInt) {
        currentSlideStep = index

        let slide = self.slide(at: currentSlideIndex,
                               loadIfNeeded: true)
        if slide == nil {
            return
        }

         if self.delegate != nil {
            if self.delegate!.responds(to: #selector(AAPLAppDelegate.presentationViewController(_:willPresentSlideAtIndex:step:))) {
                self.delegate!.presentationViewController(self,
                                                          willPresentSlideAtIndex: currentSlideIndex,
                                                          step: currentSlideStep!)
            }
        }
        slide?.present(stepIndex: currentSlideStep!,
                       with: self)
    }

    func didOrderInSlide(at slideIndex: UInt) {
        let slide = self.slide(at: slideIndex,
                               loadIfNeeded: false)
        slide?.didOrderIn(with: self)
    }

    func willOrderOutSlide(at slideIndex: UInt) {

        if let slide = self.slide(at: slideIndex,
                                  loadIfNeeded: false) {
            let node = slide.contentNode

            // Fade out and remove on completion
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.75
            SCNTransaction.completionBlock = {
                node.removeFromParentNode()
            }
            do {
                node.opacity = 0.0
            }
            SCNTransaction.commit()
            slide.willOrderOut(with: self)
            slideCache[Int(slideIndex)] = nil
        }
    }

    func setShowsNewInSceneKitBadge(showsBadge: Bool) {
        showsNewInSceneKitBadge = showsBadge

        if (newBadgeNode?.opacity == 1 && showsBadge) {
            return  // already visible
        }

        if (newBadgeNode?.opacity == 0 && !showsBadge) {
            return  // already invisible
        }

        // Load the model and the animation
        if newBadgeNode == nil {
            newBadgeNode = SCNNode()
            let badgeNode = newBadgeNode?.asc_addChildNode(named: "newBadge",
                                                           fromSceneNamed: "Scenes.scnassets/newBadge",
                                                           withScale: 1)
            newBadgeNode?.scale = SCNVector3Make(0.03, 0.03, 0.03)
            newBadgeNode?.opacity = 0
            newBadgeNode?.position = SCNVector3Make(50, 20, -10)

            let imageNode = newBadgeNode?.childNode(withName: "badgeImage",
                                                    recursively: true)
            imageNode?.geometry?.firstMaterial?.emission.intensity = 0.0

            // SCNAnimatable protocol methods
            newBadgeAnimation = badgeNode?.animation(forKey: (badgeNode?.animationKeys[0])!)
            badgeNode?.removeAllAnimations()

            // CAAnimation & CAMediaTiming protocol properties
            newBadgeAnimation?.speed = 1.5
            newBadgeAnimation?.fillMode = kCAFillModeBoth
            newBadgeAnimation?.usesSceneTimeBase = false
            newBadgeAnimation?.isRemovedOnCompletion = false
            newBadgeAnimation?.repeatCount = 0
        }

        // Play
        if (showsBadge) {
            //reset
            newBadgeNode?.opacity = 1.0;
            let ropeNode = newBadgeNode?.childNode(withName: "rope02",
                                                   recursively: true)
            ropeNode?.opacity = 1.0

            self.cameraPitch?.addChildNode(newBadgeNode!)
            newBadgeNode?.addAnimation(newBadgeAnimation!,
                                       forKey: "animation")

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2
            do {
                newBadgeNode?.position = SCNVector3Make(14, 8, -20)

                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 3
                    do {
                        let ropeNode = self.newBadgeNode?.childNode(withName: "rope02",
                                                                    recursively: true)
                        ropeNode?.opacity = 0.0
                    }
                    SCNTransaction.commit()
                }

                newBadgeNode?.opacity = 1.0
                let imageNode = newBadgeNode?.childNode(withName: "badgeImage",
                                                        recursively: true)
                imageNode?.geometry?.firstMaterial?.emission.intensity = 0.4
            }
            SCNTransaction.commit()
        }
        else {
            // Or hide
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.5
            do {
                SCNTransaction.completionBlock = {
                    self.newBadgeNode?.removeFromParentNode()
                }

                newBadgeNode?.position = SCNVector3Make(14, 50, -20)
                newBadgeNode?.opacity = 0.0
            }
            SCNTransaction.commit()
        }
    }

    // mark - Lighting the scene
    func initLighting() {
        // Omni light (main light of the scene)
        lights[APPLLightName.main.rawValue] = SCNNode()
        lights[APPLLightName.main.rawValue].name = "omni";
        lights[APPLLightName.main.rawValue].position = SCNVector3Make(0, 3, -13)
        lights[APPLLightName.main.rawValue].light = SCNLight()
        lights[APPLLightName.main.rawValue].light?.type = .omni
        lights[APPLLightName.main.rawValue].light?.attenuationStartDistance = 10.0
        lights[APPLLightName.main.rawValue].light?.attenuationEndDistance = 50.0
        lights[APPLLightName.main.rawValue].light?.color = NSColor.black
        //make all lights relative to the camera node
        cameraHandle!.addChildNode(lights[APPLLightName.main.rawValue])

        // Front light
        lights[APPLLightName.front.rawValue] = SCNNode()
        lights[APPLLightName.front.rawValue].name = "front light";
        lights[APPLLightName.front.rawValue].position = SCNVector3Make(0, 0, 0)
        lights[APPLLightName.front.rawValue].light = SCNLight()
        lights[APPLLightName.front.rawValue].light?.type = .directional
        lights[APPLLightName.front.rawValue].light?.color = NSColor.black
        cameraHandle!.addChildNode(lights[APPLLightName.front.rawValue])

        // Spot light
        lights[APPLLightName.spot.rawValue] = SCNNode()
        lights[APPLLightName.spot.rawValue].name = "spot light";
        lights[APPLLightName.spot.rawValue].transform = CATransform3DConcat(SCNMatrix4MakeRotation(-.pi/2 * 0.8,
                                                                                                    1, 0, 0),
                                                                             SCNMatrix4MakeRotation(-0.3,
                                                                                                    0, 0, 1));
        lights[APPLLightName.spot.rawValue].position = SCNVector3Make(15, 30, -7);
        lights[APPLLightName.spot.rawValue].light = SCNLight()
        lights[APPLLightName.spot.rawValue].light!.type = .spot;
        lights[APPLLightName.spot.rawValue].light!.shadowRadius = 3;
        lights[APPLLightName.spot.rawValue].light!.zNear = 20;
        lights[APPLLightName.spot.rawValue].light!.zFar = 100;
        lights[APPLLightName.spot.rawValue].light!.color = NSColor.black
        //lights[APPLLightName.spot.rawValue].light!.shadowColor = NSColor.black
        lights[APPLLightName.spot.rawValue].light!.castsShadow = true
        narrowSpotlight(false)
        cameraHandle!.addChildNode(lights[APPLLightName.spot.rawValue])

        // Left light
        lights[APPLLightName.left.rawValue] = SCNNode()
        lights[APPLLightName.left.rawValue].name = "left light";
        lights[APPLLightName.left.rawValue].position = SCNVector3Make(-20, 10, -20)
        lights[APPLLightName.left.rawValue].rotation = SCNVector4Make(0, 1, 0, .pi/2)
        lights[APPLLightName.left.rawValue].light?.attenuationStartDistance = 30.0
        lights[APPLLightName.left.rawValue].light?.attenuationEndDistance = 80.0
        lights[APPLLightName.left.rawValue].light = SCNLight()
        lights[APPLLightName.left.rawValue].light!.type = .omni
        lights[APPLLightName.left.rawValue].light!.color = NSColor.black
        cameraHandle!.addChildNode(lights[APPLLightName.left.rawValue])

        // Right light
        lights[APPLLightName.right.rawValue] = SCNNode()
        lights[APPLLightName.right.rawValue].name = "right light";
        lights[APPLLightName.right.rawValue].rotation = SCNVector4Make(0, 1, 0, -.pi/2)
        lights[APPLLightName.right.rawValue].position = SCNVector3Make(20, 10, -20)
        lights[APPLLightName.right.rawValue].light?.attenuationStartDistance = 30.0
        lights[APPLLightName.right.rawValue].light?.attenuationEndDistance = 80.0
        lights[APPLLightName.right.rawValue].light = SCNLight()
        lights[APPLLightName.right.rawValue].light!.type = .omni
        lights[APPLLightName.right.rawValue].light!.color = NSColor.black
        cameraHandle!.addChildNode(lights[APPLLightName.right.rawValue])

        // Ambient light
        lights[APPLLightName.ambient.rawValue] = SCNNode()
        lights[APPLLightName.ambient.rawValue].name = "ambient light"
        lights[APPLLightName.ambient.rawValue].light = SCNLight()
        lights[APPLLightName.ambient.rawValue].light!.type = .ambient;
        lights[APPLLightName.ambient.rawValue].light!.color = NSColor(calibratedWhite: 0.0,
                                                                       alpha:1.0)
        scene!.rootNode.addChildNode(lights[APPLLightName.ambient.rawValue])
        spotLight = lights[APPLLightName.spot.rawValue]
        mainLight = lights[APPLLightName.main.rawValue]

    }

    func updateLightingForSlide(at slideIndex:UInt) {
        let slide = self.slide(at: slideIndex,
                               loadIfNeeded:true)

        lights[APPLLightName.main.rawValue].position = (slide?.mainLightPosition)!

        self.updateLighting(withIntensities: slide!.lightIntensities)

    }

    func updateLighting(withIntensities intensities: [NSNumber]) {
        for i in 0..<APPLLightName.count.rawValue {

            let intensity = intensities.count > i ? intensities[i].floatValue : 0

            lights[i].light?.color = NSColor(deviceWhite: CGFloat(intensity),
                                             alpha: 1.0)
        }
    }

    func narrowSpotlight(_ narrow: Bool) {
        if (narrow) {
            lights[APPLLightName.spot.rawValue].light?.spotInnerAngle = 20
            lights[APPLLightName.spot.rawValue].light?.spotOuterAngle = 30
        }
        else {
            lights[APPLLightName.spot.rawValue].light?.spotInnerAngle = 10
            lights[APPLLightName.spot.rawValue].light?.spotOuterAngle = 50
        }
    }

    func riseMainLight(_ rise: Bool) {
        if rise {
            lights[APPLLightName.main.rawValue].light?.attenuationStartDistance = 90
            lights[APPLLightName.main.rawValue].light?.attenuationEndDistance = 250
            
            lights[APPLLightName.main.rawValue].position = SCNVector3Make(0, 10, -10)
        }
        else {
            lights[APPLLightName.main.rawValue].light?.attenuationStartDistance = 10
            lights[APPLLightName.main.rawValue].light?.attenuationEndDistance = 50
            lights[APPLLightName.main.rawValue].position = SCNVector3Make(0, 3, -13)
        }
    }

    // mark - Updating the floor
    // Updates the secondary image of the floor if needed
    func update(floorImage imagePath: String,
                for slide: APPLSlide) {
        
        // We don't want to animate if we replace the secondary image by a new one
        // Otherwise we want to translate the secondary image to the new location
        var disableAction = false
        
        if !(floorImagePath as NSString).isEqual(to: imagePath) &&
            imagePath != floorImagePath {
            floorImagePath = imagePath
            disableAction = true

            if imagePath.lengthOfBytes(using: .utf8) != 0 {
                // Set a new material property with this image to the "floorMap" custom property of the floor
                let property = SCNMaterialProperty(contents: imagePath)
                property.wrapS = .repeat
                property.wrapT = .repeat
                property.mipFilter = .linear

                floor?.firstMaterial?.setValue(property,
                                               forKey: "floorMap")  // cf: floor.shader
            }
        }

        if imagePath.lengthOfBytes(using: String.Encoding.utf8) != 0 {
            let slidePosition = slide.groundNode.convertPosition(SCNVector3Make(0, 0, 10),
                                                                 to: nil)

            if (disableAction) {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0
                do {
                    floor?.firstMaterial?.setValue(NSValue(scnVector3: slidePosition),
                                                   forKey: "floorImageNamePosition")    // cf: floor.shader
                }
                SCNTransaction.commit()
            }
            else {
                floor?.firstMaterial?.setValue(NSValue(scnVector3: slidePosition),
                                               forKey: "floorImageNamePosition")        // cf: floor.shader
            }
        }
    }

    // mark -  export slides
    func exportCurrentSlide() {
        var size = NSMakeSize(CGFloat(RESOLUTION_X), CGFloat(RESOLUTION_Y))

        let view = self.view as! SCNView
        let image = view.snapshot()
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return
        }
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        size.width /= 2
        size.height /= 2

        let composite = NSImage(size: size)
        composite.lockFocus()
        NSColor.black.set()

        let rect = NSMakeRect(0, 0, size.width, size.height)
        NSRectFill(rect)
        bitmap.draw(in: rect,
                    from: NSZeroRect,
                    operation: .sourceOver,
                    fraction: 1.0,
                    respectFlipped: true,
                    hints: nil)
        composite.unlockFocus()

        guard let tiffData = composite.tiffRepresentation
        else {
            return
        }
        let path = NSString(format: "~/Desktop/SceneKit-WWDC14/SceneKit_slide_%d_%d.tiff",
                            self.currentSlideIndex, self.currentSlideIndex)
        let pathURL = URL(fileURLWithPath: path.expandingTildeInPath)
        do {
            try tiffData.write(to: pathURL)
        }
        catch let err as NSError {
            print("Write File Error: \(err)")
        }
    }

    func exportCurrentSlideToSCN() {
        let scene = self.presentationView.scene

        let path = NSString(format: "~/Desktop/wwdc2014-archive/wdc14_slide_%d_%d.scn",
                            self.currentSlideIndex, self.currentSlideIndex)
        let pathURL = URL(fileURLWithPath: path.expandingTildeInPath)

        do {
            try FileManager.default.removeItem(at: pathURL)
        }
        catch let err as NSError {
            print("Delete File Error: \(err)")
        }

        NSKeyedArchiver.archiveRootObject(scene as Any,
                                          toFile: path.expandingTildeInPath)
    }

    // Export as SCN archive
    @IBAction func exportSlidesToSCN(_ sender: Any) {
        // Create the folder if it does not exists.
        let path = NSString(format: "~/Desktop/wwdc2014-archive")
        let pathURL = URL(fileURLWithPath: path.expandingTildeInPath)
       
        do {
            try FileManager.default.createDirectory(at: pathURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }
        catch let err as NSError {
            print("Cant' create archive folder error:\(err)")
            return
        }

        SCNTransaction.begin()
        SCNTransaction.disableActions = true

        exportCurrentSlideToSCN()
        SCNTransaction.commit()

        let q = DispatchQueue.global(qos: .background)
        q.async(execute: {
            var slideIndex: UInt = 0
            var stepIndex: UInt = 0

            while (true) {
                let mainQue = DispatchQueue.main
                mainQue.sync {
                    self.goToNextSlideStep()
                }
                if  self.currentSlideIndex == slideIndex &&
                    stepIndex == self.currentSlideStep {
                    return  //finish !
                }
                sleep(1)    //let the slide stabilize
                slideIndex = self.currentSlideIndex
                stepIndex = self.currentSlideStep!

                SCNTransaction.begin()
                SCNTransaction.disableActions = true
                self.exportCurrentSlideToSCN()
                SCNTransaction.commit()
            }
        })
    }

    // Export the slide in TIFF format.
    @IBAction func exportSlidesToImages(_ sender: Any) {
        // Create the folder if it does not exists.
        let path = NSString(format: "~/Desktop/SceneKit-WWDC14")
        let pathURL = URL(fileURLWithPath: path.expandingTildeInPath)

        do {
            try FileManager.default.createDirectory(at: pathURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }
        catch let err as NSError {
            print("Cant' create slide folder error:\(err)")
            return
        }
        SCNTransaction.begin()
        SCNTransaction.disableActions = true

        exportCurrentSlide()
        SCNTransaction.commit()

        // Save the rest of the slides
        let q = DispatchQueue.global(qos: .background)
        q.async(execute: {
            var slideIndex: UInt = 0
            var stepIndex: UInt = 0
 
            while (true) {
                let mainQue = DispatchQueue.main
                mainQue.sync {
                    self.goToNextSlideStep()
                }
                if  self.currentSlideIndex == slideIndex &&
                    stepIndex == self.currentSlideStep {
                    return  //finish !
                }
                sleep(1)    //let the slide stabilize
                slideIndex = self.currentSlideIndex
                stepIndex = self.currentSlideStep!

                SCNTransaction.begin()
                SCNTransaction.disableActions = true
                self.exportCurrentSlide()
                SCNTransaction.commit()
            }
        })
    }
    
    // Play the slides automatically
    @IBAction func autoPlay(_ sender: Any) {
        // Move to a background thread to do some long running work
        if (AAPLPresentationViewController.demoRunning == true) {
            AAPLPresentationViewController.demoShouldStop = true
            return
        }
        AAPLPresentationViewController.demoRunning = true
        AAPLPresentationViewController.demoShouldStop = false
        //let q = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let q = DispatchQueue.global(qos: .background)
        q.async(execute: {
            var lastSlide: UInt = 0
            var lastStep: UInt = 0

            sleep(4)

            while (AAPLPresentationViewController.demoShouldStop == false) {
                DispatchQueue.main.sync() {
                    self.goToNextSlideStep()
                }
                if  lastSlide == self.currentSlideIndex && lastStep == self.currentSlideStep {
                    self.goToSlide(at: 0)
                }

                lastSlide = self.currentSlideIndex
                lastStep = self.currentSlideStep!

                sleep(4)
            }
        })
    }
}

