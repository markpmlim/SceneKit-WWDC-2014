/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how to the physics of scenekit works.
*/


import SceneKit

//#define USE_GAME_ICON 0
// slide #30
class AAPLSlidePhysics: APPLSlide {
    var _timer: DispatchSourceTimer?
    var _dices: [SCNNode]
    var _balls: [SCNNode]
    var _shapes: [SCNNode]
    var _meshes: [SCNNode]
    var _hinges: [SCNNode]
    var _kinematicItems: [SCNNode]

    var _step: UInt = 0

    required init() {
        _dices  = [SCNNode]()
        _balls  = [SCNNode]()
        _shapes  = [SCNNode]()
        _meshes  = [SCNNode]()
        _hinges  = [SCNNode]()
        _kinematicItems  = [SCNNode]()
        super.init()
    }

    override var numberOfSteps: UInt {
        return 20
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        _step = stepIndex
        switch (stepIndex) {
        case 0:
            break
        case 1:
            do {
                
                self.textManager.flipOutText(ofTextType: .bullet)
                _ = self.textManager.set(subtitle: "SCNPhysicsBody")
                
                _ = self.textManager.flipInText(ofTextType: .subtitle)
                
                _ = self.textManager.add(bullet: "Dynamic bodies",
                                         at: 0)

                // Add some code
                _ = self.textManager.add(code:
                        "// Make a node dynamic\n" +
                        "aNode.#physicsBody# = [SCNPhysicsBody #dynamicBody#];")

                self.textManager.flipInText(ofTextType: .bullet)
                self.textManager.flipInText(ofTextType: .code)
            }
        case 2:
            do {
//      #if USE_GAME_ICON
/*
                let node = SCNNode.node(withPixelatedImage: NSImage(named: "game.png")!,
                                        pixelSize: 0.25)
                let worldPos = self.groundNode.convertPosition(SCNVector3Make(0, 0, 7),
                                                               to: nil)
                node.position = worldPos


                presentationViewController.presentationView.scene?.rootNode.addChildNode(node)

                var f: CGFloat = 1.0
                //add to scene
                node.enumerateChildNodes( {
                    (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) in
                    child.transform = child.worldTransform
                    presentationViewController.presentationView.scene?.rootNode.addChildNode(child)
                    _dices.append(child)

                    let animation = CABasicAnimation(keyPath: "transform")
                    animation.fromValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeRotation(f*100.0, f*10, f*20, f*30),
                                                                                     CATransform3DMakeTranslation(0, 0, -50)))
                    animation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                    animation.isAdditive = true
                    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                    animation.duration = 1.0
                    animation.fillMode = kCAFillModeBoth
                    animation.beginTime = CACurrentMediaTime() + Double(f)
                    child.addAnimation(animation,
                                       forKey: nil)

                    f -= 0.01
                })
                node.removeFromParentNode()
*/
                //add a cube
                let worldPos = self.groundNode.convertPosition(SCNVector3Make(0, 12, 2),
                                                               to: nil)
                let dice = self.block(atPosition: worldPos,
                                      size:SCNVector3Make(1.5, 1.5, 1.5))
                dice.physicsBody = nil  //wait!
                dice.rotation = SCNVector4Make(0, 0, 1, (CGFloat.pi/4*0.5))
                dice.scale = SCNVector3Make(0.001, 0.001, 0.001)

                presentationViewController.presentationView.scene?.rootNode.addChildNode(dice)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                dice.scale = SCNVector3Make(2, 2, 2)
                SCNTransaction.commit()
                _dices.append(dice)

            }
        case 3:
            do {
                var f = 7.0
                for node in _dices {
                    node.physicsBody = SCNPhysicsBody.dynamic()
/*
//              #if USE_GAME_ICON
                    node.physicsBody?.applyForce(SCNVector3Make(0, CGFloat(f), CGFloat(-f*0.5)),
                                                 at: SCNVector3Zero,
                                                 asImpulse: true)
//              #endif
*/
                    f -= 0.03
                }
            }
        case 4:
            self.presentDices(presentationViewController)
        case 5:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.flipOutText(ofTextType: .code)

            _ = self.textManager.add(bullet: "Manipulate with forces",
                                     at: 0)

            self.textManager.flipInText(ofTextType: .subtitle)

            // Add some code
            _ = self.textManager.add(code:
                    "// Apply an impulse\n" +
                    "[aNode.physicsBody #applyForce:#aVector3 #atPosition:#aVector3 #impulse:#YES];")
            
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .code)

        case 6:
            do {
                // remove dices
                var center = SCNVector3Make(0,-5,20)
                center = self.groundNode.convertPosition(center,
                                                         to: nil)

                self.explosion(at: center,
                               receivers:_dices)

                let popTime = DispatchTime.now().rawValue + (1 * NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {

                    self.textManager.flipOutText(ofTextType: .code)
                    self.textManager.flipOutText(ofTextType: .bullet)

                    _ = self.textManager.add(bullet: "Static bodies",
                                         at: 0)
                    _ = self.textManager.add(code:
                            "// Make a node static\n" +
                            "aNode.#physicsBody# = [SCNPhysicsBody #staticBody#];")
                    self.textManager.flipInText(ofTextType: .bullet)
                    self.textManager.flipInText(ofTextType: .code)
                }

            }
        case 7:
            self.presentWalls(presentationViewController)
        case 8:
            self.presentBalls(presentationViewController)
        case 9:
            do {
                //remove walls
                var walls = [SCNNode]()
                self.groundNode.enumerateChildNodes( {
                    (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if child.name == "container-wall" {
                        child.runAction(SCNAction.sequence([SCNAction.move(by: SCNVector3Make(0, -2, 0),
                                                                           duration:0.5),
                                                            SCNAction.removeFromParentNode()]))
                        walls.append(child)
                    }
                })
            }
        case 10:
            do {
                    // remove balls
                    var center = SCNVector3Make(0, -5, 5)
                    center = self.groundNode.convertPosition(center,
                                                             to: nil)
                    self.explosion(at: center,
                                   receivers: _balls)
                    let popTime = DispatchTime.now().rawValue + UInt64(NSEC_PER_SEC/2)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
                        self.textManager.flipOutText(ofTextType: .code)
                        self.textManager.flipOutText(ofTextType: .bullet)

                        _ = self.textManager.add(bullet: "Kinematic bodies",
                                                 at: 0)
                        _ = self.textManager.add(code:
                                "// Make a node kinematic\n" +
                                "aNode.#physicsBody# = [SCNPhysicsBody #kinematicBody#];")
                        self.textManager.flipInText(ofTextType: .bullet)
                        self.textManager.flipInText(ofTextType: .code)
                    }
                }
        case 11:
            do {
                    let MIDDLE_Z: CGFloat = 0
                    let boxNode = SCNNode()
                    boxNode.geometry = SCNBox(width: 10,
                                              height: 0.2,
                                              length: 10,
                                              chamferRadius:0)
                    boxNode.position = SCNVector3Make(0, 5, MIDDLE_Z)
                    boxNode.geometry?.firstMaterial?.emission.contents = NSColor.darkGray
                    boxNode.physicsBody = SCNPhysicsBody.kinematic()
                    boxNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                                 y: 0,
                                                                                 z: (CGFloat.pi * 2.0),
                                                                                 duration: 2.0)))
                    self.groundNode.addChildNode(boxNode)
                    _kinematicItems.append(boxNode)

                    var invisibleWall = SCNNode()
                    invisibleWall.geometry = SCNBox(width:4, height:40, length:10, chamferRadius:0)
                    invisibleWall.position = SCNVector3Make(-7, 0, MIDDLE_Z)
                    invisibleWall.geometry?.firstMaterial?.transparency = 0
                    invisibleWall.physicsBody = SCNPhysicsBody.static()
                    self.groundNode.addChildNode(invisibleWall)
                    _kinematicItems.append(invisibleWall)

                    invisibleWall = invisibleWall.copy() as! SCNNode
                    invisibleWall.position = SCNVector3Make(7, 0, MIDDLE_Z)
                    self.groundNode.addChildNode(invisibleWall)
                    _kinematicItems.append(invisibleWall)

                    invisibleWall = invisibleWall.copy() as! SCNNode
                    invisibleWall.geometry = SCNBox(width:10, height:40, length:4, chamferRadius:0)
                    invisibleWall.geometry?.firstMaterial?.transparency = 0
                    invisibleWall.position = SCNVector3Make(0, 0, MIDDLE_Z-7)
                    invisibleWall.physicsBody = SCNPhysicsBody.static()
                    self.groundNode.addChildNode(invisibleWall)
                    _kinematicItems.append(invisibleWall)

                    invisibleWall = invisibleWall.copy() as! SCNNode
                    invisibleWall.position = SCNVector3Make(0, 0, MIDDLE_Z+7)
                    self.groundNode.addChildNode(invisibleWall)
                    _kinematicItems.append(invisibleWall)


                    for _ in 0..<100 {
                        let ball = SCNNode()
                        let worldPos = boxNode.convertPosition(SCNVector3Make(randFloat(-4, 4),
                                                                              randFloat(10, 30),
                                                                              randFloat(-1, 4)),
                                                               to: nil)
                        ball.position = worldPos
                        ball.geometry = SCNSphere(radius: 0.5)
                        ball.geometry?.firstMaterial?.diffuse.contents = NSColor.cyan
                        ball.physicsBody = SCNPhysicsBody.dynamic()
                        presentationViewController.presentationView.scene?.rootNode.addChildNode(ball)

                        _kinematicItems.append(ball)
                    }
                }
        case 12:
            do {
                    self.textManager.flipOutText(ofTextType: .code)
                    self.textManager.flipOutText(ofTextType: .bullet)
                    self.textManager.flipOutText(ofTextType: .subtitle)
                    _ = self.textManager.set(subtitle: "SCNPhysicsShape")
                    _ = self.textManager.add(code:
                            "// Configure the physics shape\n" +
                            "aNode.physicsBody.#physicsShape# = \n\t[#SCNPhysicsShape# shapeWithGeometry:aGeometry options:options];")
                    self.textManager.flipInText(ofTextType: .bullet)
                    self.textManager.flipInText(ofTextType: .code)

                    _kinematicItems[0].runAction(SCNAction.sequence([SCNAction.fadeOut(duration: 0.5),
                                                                     SCNAction.removeFromParentNode()]))
                    for i in 1..<5 {
                        _kinematicItems[i].removeFromParentNode()
                    }

                    let count = _kinematicItems.count
                    for i in 5..<count {
                        let node = _kinematicItems[i]

                        node.runAction(SCNAction.sequence([SCNAction.wait(duration: 5),
                                                           SCNAction.run({
                                                                (owner: SCNNode) -> Void in
                                                                owner.transform = owner.presentation.transform
                                                                owner.physicsBody = nil
                                                            }),
                                                           SCNAction.scale(by: 0.001,
                                                                           duration: 0.5),
                                                           SCNAction.removeFromParentNode()]))
                    }
                    _kinematicItems.removeAll(keepingCapacity: true)
                }
        case 13:
            // add meshes
            self.presentMeshes(presentationViewController)
        case 14:
            do {
                    // remove meshes
                    var center = SCNVector3Make(0,-5,20)
                    center = self.groundNode.convertPosition(center,
                                                             to: nil)
                    self.explosion(at:center,
                                   receivers: _meshes)
            }
        case 15:
            // add shapes
            self.presentPrimitives(presentationViewController)
        case 16:
            do {
                    // remove shapes
                    var center = SCNVector3Make(0,-5,20)
                    center = self.groundNode.convertPosition(center,
                                                             to: nil)
                    self.explosion(at:center,
                                   receivers: _shapes)
                    let popTime = DispatchTime.now().rawValue + (NSEC_PER_SEC / 2)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
                        self.textManager.flipOutText(ofTextType: .code)
                        self.textManager.flipOutText(ofTextType: .bullet)
                        self.textManager.flipOutText(ofTextType: .subtitle)
                        _ = self.textManager.set(subtitle: "SCNPhysicsBehavior")
                        _ = self.textManager.add(code:
                                "// setup a physics behavior\n" +
                                "#SCNPhysicsHingeJoint# *joint = [SCNPhysicsHingeJoint\n" +
                                "   jointWithBodyA:#nodeA.physicsBody# axisA:[...] anchorA:[...]\n" +
                                "            bodyB:#nodeB.physicsBody# axisB:[...] anchorB:[...]];\n\n" +
                                "[scene.#physicsWorld# addBehavior:joint];")
                        self.textManager.flipInText(ofTextType: .bullet)
                        self.textManager.flipInText(ofTextType: .subtitle)
                        self.textManager.flipInText(ofTextType: .code)
                    }
                }
        case 17:
            //add meshes
            self.presentHinge(presentationViewController)
        case 18:
            //remove constraints
            presentationViewController.presentationView.scene?.physicsWorld.removeAllBehaviors()

            for node in _hinges {
                node.runAction(SCNAction.sequence([SCNAction.wait(duration: 3.0),
                                                   SCNAction.fadeOut(duration: 0.5),
                                                   SCNAction.removeFromParentNode()]))
            }
        case 19:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.flipOutText(ofTextType: .subtitle)
            self.textManager.flipOutText(ofTextType: .code)
            _ = self.textManager.set(subtitle: "More")

            self.textManager.flipInText(ofTextType: .subtitle)

            _ = self.textManager.add(bullet: "SCNPhysicsField",
                                     at: 0)
            _ = self.textManager.add(bullet: "SCNPhysicsVehicle",
                                     at: 0)
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .code)
        default:
            break
        }
    }

    // this will be called before setup
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        presentationViewController.presentationView.scene?.physicsWorld.speed = 0

        for node in _dices {
            node.removeFromParentNode()
        }

        for node in _balls {
            node.removeFromParentNode()
        }

        for node in _shapes {
            node.removeFromParentNode()
        }
        for node in _meshes {
            node.removeFromParentNode()
        }
        for node in _hinges {
            node.removeFromParentNode()
        }
        
        presentationViewController.presentationView.scene?.physicsWorld.removeAllBehaviors()
    }
    
    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        presentationViewController.presentationView.scene?.physicsWorld.speed = 2
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {

        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Physics")
        
        _ = self.textManager.add(bullet: "Nodes are automatically animated by SceneKit",
                                 at: 0)
        _ = self.textManager.add(bullet:"Same approach as SpriteKit",
                                 at: 1)

        }


    func randFloat(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        return min + (max - min) * CGFloat(arc4random()) /  CGFloat(RAND_MAX)
    }

    func presentDices(_  presentationViewController: AAPLPresentationViewController) {
        let count = 200
        let spread = 2.0

        // drop rigid bodies cubes
        let intervalTime = Int(Double(NSEC_PER_SEC) * 5.0 / Double(count))
        let startTime = DispatchTime.now() + .nanoseconds(Int(1 * NSEC_PER_SEC))
        let queue = DispatchQueue.main
        _timer = DispatchSource.makeTimerSource(queue: queue)
        _timer?.scheduleRepeating(deadline: startTime,
                                  interval: .nanoseconds(intervalTime))

        var remainingCount = count
        _timer?.setEventHandler(handler: {
            [weak self] in
            if ((self?._step)! > 4) {
                self?._timer?.cancel()
                return
            }

            SCNTransaction.begin()
            let worldPos = self?.groundNode.convertPosition(SCNVector3Make(0, 30, 0),
                                                            to: nil)

            let dice = self?.block(atPosition: worldPos!,
                                   size: SCNVector3Make(1.5, 1.5, 1.5))

            //add to scene
            presentationViewController.presentationView.scene?.rootNode.addChildNode(dice!)
            
            dice?.physicsBody?.velocity = SCNVector3Make((self?.randFloat(-CGFloat(spread), CGFloat(spread)))!,
                                                         -10,
                                                         (self?.randFloat(-CGFloat(spread), CGFloat(spread)))!)
            dice?.physicsBody?.angularVelocity = SCNVector4Make((self?.randFloat(-1, 1))!,
                                                                (self?.randFloat(-1, 1))!,
                                                                (self?.randFloat(-1, 1))!,
                                                                (self?.randFloat(-3, 3))!)
            SCNTransaction.commit()
            self?._dices.append(dice!)

            // ensure we stop firing
            remainingCount -= 1
            if (remainingCount < 0) {
                self?._timer?.cancel()
            }
        })
        _timer?.resume()
    }

    func presentWalls(_  presentationViewController: AAPLPresentationViewController) {
        //add spheres and container
        let height: CGFloat = 2;
        let width: CGFloat = 1.0;

        let count = 3
        let margin: CGFloat = 2;

        let totalWidth = CGFloat(count) * (margin + width)

        let blockMesh = self.blockMesh(withSize: SCNVector3Make(width, height, width))

        for i in 0..<count {
            //create a static block
            var wall = SCNNode()
            wall.position = SCNVector3Make(CGFloat(i-(count/2)) * (width + margin), -height/2, totalWidth/2)
            wall.geometry = blockMesh
            wall.name =  "container-wall"
            wall.physicsBody = SCNPhysicsBody.static()

            self.groundNode.addChildNode(wall)
            wall.runAction(SCNAction.move(by: SCNVector3Make(0, height, 0),
                                          duration: 0.5))

            //one more
            wall = wall.copy() as! SCNNode
            wall.position = SCNVector3Make(CGFloat(i-(count/2)) * (width + margin), -height/2, -totalWidth/2)
            self.groundNode.addChildNode(wall)

            // one more
            wall = wall.copy() as! SCNNode
            wall.position = SCNVector3Make(totalWidth/2, -height/2, CGFloat(i-(count/2)) * (width + margin))
            self.groundNode.addChildNode(wall)

            //one more
            wall = wall.copy() as! SCNNode
            wall.position = SCNVector3Make(-totalWidth/2, -height/2, CGFloat(i-(count/2)) * (width + margin))
            self.groundNode.addChildNode(wall)
        }
    }

    func presentBalls(_  presentationViewController: AAPLPresentationViewController) {
        let count = 150

        for _ in 0..<count {
            let worldPos = self.groundNode.convertPosition(SCNVector3Make(randFloat(-5, 5), randFloat(25, 30), randFloat(-5, 5)),
                                                           to: nil)

            let ball = self.poolBall(withPosition: worldPos)

            presentationViewController.presentationView.scene?.rootNode.addChildNode(ball)
            _balls.append(ball)
        }
    }

    func presentPrimitives(_  presentationViewController: AAPLPresentationViewController) {
        let count = 100
        let spread: CGFloat = 0

        // create a cube with a sphere shape
        for _ in 0..<count {
            let model = SCNNode()
            model.position = self.groundNode.convertPosition(SCNVector3Make(randFloat(-1, 1),
                                                                            randFloat(30, 50),
                                                                            randFloat(-1, 1)),
                                                             to: nil)
            model.eulerAngles = SCNVector3Make(randFloat(0, (CGFloat.pi * 2.0)),
                                               randFloat(0, (CGFloat.pi * 2.0)),
                                               randFloat(0, (CGFloat.pi * 2.0)))

            let size = SCNVector3Make(randFloat(1.0, 1.5),
                                      randFloat(1.0, 1.5),
                                      randFloat(1.0, 1.5))
            let geometryIndex = arc4random() % 8
            switch (geometryIndex) {
            case 0: // Box
                model.geometry = SCNBox(width: size.x,
                                        height: size.y,
                                        length: size.z,
                                        chamferRadius: 0)
            case 1: // Pyramid
                model.geometry = SCNPyramid(width: size.x,
                                            height: size.y,
                                            length: size.z)
            case 2: // Sphere
                model.geometry = SCNSphere(radius: size.x)
            case 3: // Cylinder
                model.geometry = SCNCylinder(radius: size.x,
                                             height: size.y)
            case 4: // Cone
                //model.geometry = SCNCone(topRadius:0, bottomRadius:size.x, height:size.y)
                break
            case 5: // Tube
                model.geometry = SCNTube(innerRadius: size.x,
                                         outerRadius: (size.x+size.z),
                                         height: size.y)
            case 6: // Capsule
                model.geometry = SCNCapsule(capRadius: size.x,
                                            height: (size.y + 2 * size.x))
            case 7: // Torus
                model.geometry = SCNTorus(ringRadius: size.x,
                                          pipeRadius: min(size.x, size.y) / 2)
            default:
                break
            }

            //model.geometry.firstMaterial.diffuse.contents = [NSColor colorWithCalibratedHue:randFloat(0, 1) saturation:1.0 brightness:1.0 alpha:1.0];
            model.geometry?.firstMaterial?.multiply.contents = "texture.png"
            
            model.physicsBody = SCNPhysicsBody.dynamic()
            model.physicsBody?.velocity = SCNVector3Make(randFloat(-spread, spread),
                                                         -10,
                                                         randFloat(-spread, spread))
            model.physicsBody?.angularVelocity = SCNVector4Make(randFloat(-1, 1),
                randFloat(-1, 1),
                randFloat(-1, 1),
                randFloat(-3, 3))

            _shapes.append(model)

            presentationViewController.presentationView.scene?.rootNode.addChildNode(model)
        }
    }

    func presentMeshes(_  presentationViewController: AAPLPresentationViewController) {
        // add meshes
        let container = SCNNode()
        let black = container.asc_addChildNode(named: "teapot",
                                               fromSceneNamed: "Scenes.scnassets/lod/midResTeapot.dae",
                                               withScale: 5)
        //SCNNode *white = [container asc_addChildNodeNamed:@"white" fromSceneNamed:@"pawn.dae" withScale:2];

        //    black.physicsBody = [SCNPhysicsBody dynamicBody];
        //    white.physicsBody = [SCNPhysicsBody dynamicBody];

        //    SCNVector3 min, max;
        //    [black getBoundingBoxMin:&min max:&max];
        //    black.pivot = SCNMatrix4MakeTranslation((min.x+max.x) * 0.5, (min.y+max.y) * 0.5, (min.z+max.z) * 0.5);
        //    white.pivot = black.pivot;

        let count = 100
        for _ in 0..<count {
            let worldPos = self.groundNode.convertPosition(SCNVector3Make(randFloat(-1, 1),
                                                                          randFloat(30, 50),
                                                                          randFloat(-1, 1)),
                                                           to: nil)

            //SCNNode *object = (i&1) ? [black copy] : [white copy];
            let object = black.copy() as! SCNNode
            object.position = worldPos
            object.physicsBody = SCNPhysicsBody.dynamic() //FIX ME!
            object.physicsBody?.friction = 0.5

            presentationViewController.presentationView.scene?.rootNode.addChildNode(object)
            _meshes.append(object)
        }
    }

    func presentHinge(_  presentationViewController: AAPLPresentationViewController) {
        let count = 10

        let material = SCNMaterial()
        material.diffuse.contents = NSColor.white
        material.specular.contents = NSColor.white
        material.locksAmbientWithDiffuse = true

        let cubeWidth: CGFloat = 10.0/CGFloat(count)
        let cubeHeight: CGFloat = 0.2
        let cubeLength: CGFloat = 5.0
        let offset: CGFloat = 0
        let height: CGFloat = 5 + CGFloat(count) * cubeWidth

        var oldModel: SCNNode?
        for i in 0..<count {
            let model = SCNNode()

            let worldtr = self.groundNode.convertTransform(SCNMatrix4MakeTranslation(-offset + cubeWidth * CGFloat(i), height, 5),
                                                       to: nil)

            model.transform = worldtr;
            
            model.geometry = SCNBox(width: cubeWidth,
                                    height: cubeHeight,
                                    length: cubeLength,
                                    chamferRadius: 0)
            model.geometry?.firstMaterial = material

            let body = SCNPhysicsBody.dynamic()
            body.restitution = 0.6
            model.physicsBody = body

            presentationViewController.presentationView.scene?.rootNode.addChildNode(model)
            var joint: SCNPhysicsHingeJoint
            if i == 0 {
                joint = SCNPhysicsHingeJoint(body: model.physicsBody!,
                                             axis: SCNVector3Make(0, 0, 1),
                                             anchor: SCNVector3Make(-cubeWidth*0.5, 0, 0))
            }
            else {
                joint = SCNPhysicsHingeJoint(bodyA: model.physicsBody!,
                                                 axisA: SCNVector3Make(0, 0, 1),
                                                 anchorA: SCNVector3Make(-cubeWidth*0.5, 0, 0),
                                                 bodyB: (oldModel?.physicsBody!)!,
                                                 axisB: SCNVector3Make(0, 0, 1),
                                                 anchorB: SCNVector3Make(cubeWidth*0.5, 0, 0))
            }
            presentationViewController.presentationView.scene?.physicsWorld.addBehavior(joint)

            _hinges.append(model)
            oldModel = model
        }
    }

    func explosion(at center: SCNVector3,
                   receivers nodes: [SCNNode]) {

        let c = SCNVector3ToGLKVector3(center)

        for node in nodes {
            let p = SCNVector3ToGLKVector3(node.presentation.position)
            var dir = GLKVector3Subtract(p, c)

            let force: Float = 25.0
            let distance = GLKVector3Length(dir)

            dir = GLKVector3MultiplyScalar(dir, force / max(0.01, distance))

            node.physicsBody?.applyForce(SCNVector3FromGLKVector3(dir),
                                         at:SCNVector3Make(randFloat(-0.2, 0.2),
                                                           randFloat(-0.2, 0.2),
                                                           randFloat(-0.2, 0.2)),
                                         asImpulse: true)

            node.runAction(SCNAction.sequence([SCNAction.wait(duration: 2),
                                               SCNAction.fadeOut(duration: 0.5),
                                               SCNAction.removeFromParentNode()]))
        }
    }

    func poolBall(withPosition position: SCNVector3) -> SCNNode {
        let model = SCNNode()
        model.position = position;
        model.geometry = SCNSphere(radius: 0.7)
        model.geometry?.firstMaterial?.diffuse.contents =  "Scenes.scnassets/pool/pool_8.png"
        model.physicsBody = SCNPhysicsBody.dynamic()
        return model
    }

    func blockMesh(withSize size: SCNVector3) -> SCNGeometry
    {
        let diceMesh = SCNBox(width: size.x, height:size.y, length:size.z, chamferRadius:0.05 * size.x)
        
        diceMesh.firstMaterial?.diffuse.contents = "texture.png"
        diceMesh.firstMaterial?.diffuse.mipFilter = .nearest
        diceMesh.firstMaterial?.diffuse.wrapS = .repeat
        diceMesh.firstMaterial?.diffuse.wrapT = .repeat

        return diceMesh
    }

    var diceMesh: SCNGeometry? = nil

    func block(atPosition position:SCNVector3,
               size: SCNVector3) -> SCNNode {

        if diceMesh == nil {
            diceMesh = self.blockMesh(withSize: size)
        }

        let model = SCNNode()
        model.position = position
        model.geometry = diceMesh
        model.physicsBody =  SCNPhysicsBody.dynamic()

        return model

    }
}
