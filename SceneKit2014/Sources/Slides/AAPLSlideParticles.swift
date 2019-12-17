/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how to render particle systems.
*/

import SceneKit

// slide #46 - will break if run on Metal-aware macOS emulating OpenGL
class AAPLSlideParticles: APPLSlide {
    enum ParticleSteps: UInt {
        case step0
        case fire
        case fireScreen
        //    StepFireSubtract
        case local
        case gravity
        case collider
        case fields
        case fieldsVortex
        case subSystems
        case confetti
        case emitterCube
        case emitterSphere
        case emitterTorus
        case count
    }

    var hole: SCNNode?
    var hole2: SCNNode?
    var floorNode: SCNNode?
    var boxNode: SCNNode?
    var particleHolder: SCNNode?
    var fieldOwner: SCNNode?
    var vortexFieldOwner: SCNNode?
    var snow: SCNParticleSystem?
    var bokeh: SCNParticleSystem?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return ParticleSteps.count.rawValue
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and add some text
        _ = self.textManager.set(title: "Particles")
        _ = self.textManager.set(subtitle: "SCNParticleSystem")
        _ = self.textManager.add(bullet: "Achieve a large number of effects",
                                 at: 0)
        _ = self.textManager.add(bullet: "3D particle editor built into Xcode",
                                 at: 0)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        let HOLE_Z = 10

        switch(stepIndex) {
        case ParticleSteps.fire.rawValue:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.addEmptyLine()
            _ = self.textManager.add(bullet: "Particle image",
                                     at: 0)
            _ = self.textManager.add(bullet: "Color over life duration",
                                     at: 0)
            _ = self.textManager.add(bullet: "Size over life duration",
                                     at: 0)
            _ = self.textManager.add(bullet: "Several blend modes",
                                     at: 0)
            self.textManager.flipInText(ofTextType: .bullet)

            let _hole = SCNNode()
            _hole.geometry = SCNTube(innerRadius:1.7, outerRadius:1.9, height:1.5)
            _hole.position = SCNVector3Make(0, 0, CGFloat(HOLE_Z))
            _hole.scale = SCNVector3Make(1, 0, 1)

            self.groundNode.addChildNode(_hole)
            SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                _hole.scale = SCNVector3Make(1,1,1)
            SCNTransaction.commit()

            let ps = SCNParticleSystem(named: "fire",
                                       inDirectory: nil)
            _hole.addParticleSystem(ps!)

            hole = _hole

        case ParticleSteps.fireScreen.rawValue:
            let ps = hole?.particleSystems?[0]
            ps?.blendMode = .screen

        case ParticleSteps.local.rawValue:
            self.textManager.flipOutText(ofTextType: .bullet)

            _ = self.textManager.add(bullet: "Local or global",
                                     at : 0)
            self.textManager.flipInText(ofTextType: .bullet)

            hole?.removeAllParticleSystems()
            hole2 = hole?.clone()
            hole2?.geometry = hole?.geometry?.copy() as? SCNGeometry
            hole2?.position = SCNVector3Make(0, -2, CGFloat(HOLE_Z-4))
            self.groundNode.addChildNode(hole2!)
            SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                hole2?.position = SCNVector3Make(0, 0, CGFloat(HOLE_Z-4))
            SCNTransaction.commit()

            let ps = SCNParticleSystem(named: "smoke",
                                       inDirectory: nil)
            ps?.particleColorVariation = SCNVector4Make(0, 0, 0.5, 0)
            hole?.addParticleSystem(ps!)

            let localPs = ps?.copy() as? SCNParticleSystem
            localPs?.particleImage = ps?.particleImage // FIXME: remove when <rdar://problem/16957114> ParticleSystems does not copy its image
            localPs?.isLocal = true
            hole2?.addParticleSystem(localPs!)
            do {
                let animation = CABasicAnimation(keyPath: "position")
                animation.fromValue = NSValue(scnVector3: SCNVector3Make(7, 0, CGFloat(HOLE_Z-4)))
                animation.toValue = NSValue(scnVector3: SCNVector3Make(-7, 0, CGFloat(HOLE_Z-4)))
                animation.beginTime = CACurrentMediaTime() + 0.75
                animation.duration = 8
                animation.autoreverses = true
                animation.repeatCount = MAXFLOAT
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.timeOffset = animation.duration/2
                hole?.addAnimation(animation,
                                  forKey: "animateHole")
                do {
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.fromValue = NSValue(scnVector3: SCNVector3Make(-7, 0, CGFloat(HOLE_Z-4)))
                    animation.toValue = NSValue(scnVector3: SCNVector3Make(7, 0, CGFloat(HOLE_Z-4)))
                    animation.beginTime = CACurrentMediaTime() + 0.75
                    animation.duration = 8
                    animation.autoreverses = true
                    animation.repeatCount = MAXFLOAT
                    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    animation.timeOffset = animation.duration/2
                    hole2?.addAnimation(animation,
                                        forKey: "animateHole")
                }
            }

        case ParticleSteps.gravity.rawValue:
            do {
                self.textManager.flipOutText(ofTextType: .bullet)

                _ = self.textManager.add(bullet: "Affected by gravity",
                                         at : 0)
                self.textManager.flipInText(ofTextType: .bullet)

                hole2?.removeAllParticleSystems()
                hole2?.runAction(SCNAction.sequence([SCNAction.scale(to: 0,
                                                                     duration: 0.5),
                                                     SCNAction.removeFromParentNode()]))
                hole?.removeAllParticleSystems()
                hole?.removeAnimation(forKey: "animateHole",
                                      fadeOutDuration: 0.5)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5

                let tube = hole?.geometry as! SCNTube
                tube.innerRadius = 0.3
                tube.outerRadius = 0.4
                tube.height = 1.0

                SCNTransaction.commit()



                let ps = SCNParticleSystem(named: "sparks",
                                           inDirectory: nil)
                hole?.removeAllParticleSystems()
                hole?.addParticleSystem(ps!)
                // returning nil?
                let floorNodes = presentationViewController.presentationView.scene?.rootNode.childNodes(passingTest: {
                    (child, stop) -> Bool in
                    if (child.geometry?.isKind(of: SCNFloor.self)) != nil {
                        return true
                    }
                    else {
                        return false
                    }
                })
                floorNode = floorNodes?[0]
                ps?.colliderNodes = [floorNode!]
            }

        case ParticleSteps.collider.rawValue:
            do {

                self.textManager.flipOutText(ofTextType: .bullet)

                _ = self.textManager.add(bullet: "Affected by colliders",
                                         at : 0)
                self.textManager.flipInText(ofTextType: .bullet)

                let _boxNode = SCNNode()
                _boxNode.geometry = SCNBox(width: 5,
                                           height: 0.2,
                                           length: 5,
                                           chamferRadius: 0)
                _boxNode.position = SCNVector3Make(0, 7, CGFloat(HOLE_Z));
                _boxNode.geometry?.firstMaterial?.emission.contents = NSColor.darkGray

                self.groundNode.addChildNode(_boxNode)

                let ps = hole?.particleSystems?[0]
                ps?.colliderNodes = [floorNode!, _boxNode]

                let animation = CABasicAnimation(keyPath: "eulerAngles")

                animation.fromValue = NSValue(scnVector3: SCNVector3Make(0, 0, (CGFloat.pi/4*1.7)))
                animation.toValue = NSValue(scnVector3: SCNVector3Make(0, 0, (-CGFloat.pi/4*1.7)))
                animation.beginTime = CACurrentMediaTime() + 0.5
                animation.duration = 2
                animation.autoreverses = true
                animation.repeatCount = MAXFLOAT
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.timeOffset = animation.duration/2
                _boxNode.addAnimation(animation,
                                      forKey: "animateHole")

                boxNode = _boxNode
            }
 
        case ParticleSteps.fields.rawValue:
            do  {
                hole?.removeAllParticleSystems()

                hole?.runAction(SCNAction.sequence([SCNAction.scale(to: 0,
                                                                     duration:0.75),
                                                     SCNAction.removeFromParentNode()]))

                boxNode?.runAction(SCNAction.sequence([SCNAction.moveBy(x: 0,
                                                                        y: 15,
                                                                        z: 0,
                                                                        duration: 1.0),
                                                    SCNAction.removeFromParentNode()]))

                let  _particleHolder = SCNNode()
                _particleHolder.position = SCNVector3Make(0, 20, CGFloat(HOLE_Z));
                self.groundNode.addChildNode(_particleHolder)

                particleHolder = _particleHolder


                self.textManager.flipOutText(ofTextType: .bullet)

                _ = self.textManager.add(bullet: "Affected by physics fields",
                                         at: 0)
                self.textManager.flipInText(ofTextType: .bullet)

                let ps = SCNParticleSystem(named: "snow",
                                           inDirectory: nil)
                ps?.isAffectedByPhysicsFields = true
                particleHolder?.addParticleSystem(ps!)
                snow = ps

                //physics field
                let field = SCNPhysicsField.turbulenceField(smoothness:50,
                                                            animationSpeed: 1)
                field.halfExtent = SCNVector3Make(20, 20, 20)
                field.strength = 4.0

                let _fieldOwner = SCNNode()
                _fieldOwner.position = SCNVector3Make(0, 5, CGFloat(HOLE_Z))

                self.groundNode.addChildNode(_fieldOwner)
                _fieldOwner.physicsField = field
                fieldOwner = _fieldOwner

                ps?.colliderNodes = [floorNode!]
            }
 
        case ParticleSteps.fieldsVortex.rawValue:
            do {
                vortexFieldOwner = SCNNode()
                vortexFieldOwner?.position = SCNVector3Make(0, 5, CGFloat(HOLE_Z))

                self.groundNode.addChildNode(vortexFieldOwner!)

                //tornado
                let _worldOrigin = SCNVector3Make((fieldOwner?.worldTransform.m41)!,
                                                  (fieldOwner?.worldTransform.m42)!,
                                                  (fieldOwner?.worldTransform.m43)!)
                let _worldAxis = SCNVector3(x: 0, y: 1, z: 0)

                let VS = 20.0
                let VW = 10.0

                let vortex = SCNPhysicsField.customField(evaluationBlock: {
                    (position, velocity, mass, charge, time) -> SCNVector3 in
                    var l = SCNVector3Zero
                    l.x = _worldOrigin.x - position.x
                    l.z = _worldOrigin.z - position.z
                    let t = _worldAxis.cross(l)
                    let d2 = (l.x*l.x + l.z*l.z);
                    let vs =  CGFloat(VS) / sqrt(d2)
                    let fy = 1.0 - (min(1.0, (position.y / 15.0)))
                    return SCNVector3Make(t.x * vs + l.x * CGFloat(VW) * fy, 0, t.z * vs + l.z * CGFloat(VW) * fy)
                })
                vortex.halfExtent = SCNVector3Make(100, 100, 100);
                vortexFieldOwner?.physicsField = vortex
            }
 
        case ParticleSteps.subSystems.rawValue:
            fieldOwner?.removeFromParentNode()
            particleHolder?.removeAllParticleSystems()
            snow?.dampingFactor = -1

            self.textManager.flipOutText(ofTextType: .bullet)
            _ = self.textManager.add(bullet: "Sub-particle system on collision",
                                 at: 0)
            self.textManager.flipInText(ofTextType: .bullet)

            let ps = SCNParticleSystem(named: "rain",
                                       inDirectory: nil)
            let pss = SCNParticleSystem(named: "plok",
                                       inDirectory: nil)
            pss?.idleDuration = 0
            pss?.loops = false

            ps?.systemSpawnedOnCollision = pss

            particleHolder?.addParticleSystem(ps!)
            ps?.colliderNodes = [floorNode!]

        case ParticleSteps.confetti.rawValue:
            // working but program will crash since memory is modified
            do {
                particleHolder?.removeAllParticleSystems()

                self.textManager.flipOutText(ofTextType: .bullet)
                _ = self.textManager.add(bullet: "Custom blocks",
                                         at: 0)
                self.textManager.flipInText(ofTextType: .bullet)

                do {
                    let ps = SCNParticleSystem()
                    ps.emitterShape = SCNBox(width: 20,
                                             height:0,
                                             length:5,
                                             chamferRadius: 0)
                    ps.birthRate = 100
                    ps.particleLifeSpan = 5;
                    ps.particleLifeSpanVariation = 0
                    ps.spreadingAngle = 20
                    ps.particleSize = 0.25
                    ps.particleVelocity = 5
                    ps.particleVelocityVariation = 2
                    ps.birthDirection = .constant
                    ps.emittingDirection = SCNVector3Make(0, -1, 0)
                    ps.birthLocation = .volume
                    ps.particleImage = "confetti.png"
                    ps.isLightingEnabled = true
                    ps.orientationMode = .free
                    ps.sortingMode = .distance
                    ps.particleAngleVariation = 180
                    ps.particleAngularVelocity = 200
                    ps.particleAngularVelocityVariation = 400;
                    ps.particleColor = NSColor.green
                    ps.particleColorVariation = SCNVector4Make(0.2, 0.1, 0.1, 0)
                    ps.particleBounce = 0
                    ps.particleFriction = 0.6
                    ps.colliderNodes = [floorNode!]
                    ps.blendMode = .alpha

                    let floatAnimation = CAKeyframeAnimation(keyPath: nil)
                    floatAnimation.values = [1, 1, 0]
                    floatAnimation.keyTimes = [0, 0.9, 1]
                    floatAnimation.duration = 1.0
                    floatAnimation.isAdditive = false

                    ps.propertyControllers = [.opacity : SCNParticlePropertyController(animation: floatAnimation)]
                    ps.handle(.birth,
                              forProperties: [SCNParticleSystem.ParticleProperty.color],
                              handler: {
                        (data, dataStride, indices, count) -> Void in
                        // data[i] is a UnsafeMutableRawPointer; use assumingMemoryBound:to or bindMemory:to:capacity
                        // dataStride[i] is an Int
                        // indices[i] is a UInt32
                        for i in 0..<count {
                            let rawPtr = data[0] + dataStride[0] * i
                            let colorPtr = rawPtr.bindMemory(to: Float.self, capacity: dataStride[0])
                            let colorBuffer = UnsafeMutableBufferPointer(start: colorPtr, count: dataStride[0])
                            if (arc4random() & UInt32(0x1)) == 1 {
                                colorBuffer[0] = colorBuffer[1] // Switch the green and red color components.
                                colorBuffer[1] = 0
                            }
                        }

                    })
                    ps.handle(.collision,
                              forProperties: [.angle, .rotationAxis, .angularVelocity, .velocity, .contactNormal],
                              handler: {
                        //(UnsafeMutablePointer<UnsafeMutableRawPointer>, UnsafeMutablePointer<Int>, UnsafeMutablePointer<UInt32>?, Int) -> Swift.Void
                        (data, dataStride, indices, count) -> Void in
                        for i in 0..<count {
                            // i is the index of the i-th particle.
                            let rawPtr0 = data[0] + dataStride[0] * Int(indices![i])
                            let rawPtr1 = data[1] + dataStride[1] * Int(indices![i])
                            // fix orientation
                            let anglePtr = rawPtr0.bindMemory(to: Float.self, capacity: dataStride[0])
                            let angleBuffer = UnsafeMutableBufferPointer(start: anglePtr, count: dataStride[0])
                            let rotationAxisPtr = rawPtr1.bindMemory(to: Float.self, capacity: dataStride[1])
                            let rotationAxisBuffer = UnsafeMutableBufferPointer(start: rotationAxisPtr, count: dataStride[1])

                            let rawPtr4 = data[4] + dataStride[4] * Int(indices![i])
                            let contactNormalPtr = rawPtr4.bindMemory(to: Float.self, capacity: dataStride[4])
                            let contactNormalBuffer = UnsafeMutableBufferPointer(start: contactNormalPtr, count: dataStride[4])

                            let collisionNormal = SCNVector3(x: CGFloat(contactNormalBuffer[0]),
                                                             y: CGFloat(contactNormalBuffer[1]),
                                                             z: CGFloat(contactNormalBuffer[2]))
                            let cp = collisionNormal.cross(SCNVector3Make(0, 0, 1))
                            let cpLen = cp.length
                            angleBuffer[0] = asin(Float(cpLen))

                            rotationAxisBuffer[0] = Float(cp.x) / Float(cpLen)
                            rotationAxisBuffer[1] = Float(cp.y) / Float(cpLen)
                            rotationAxisBuffer[2] = Float(cp.z) / Float(cpLen)
                            // kill the angular rotation
                            let rawPtr2 = data[2] + dataStride[2] * Int(indices![i])
                            let angVelPtr = rawPtr2.bindMemory(to: Float.self, capacity: dataStride[2])
                            let angularVelocityBuffer = UnsafeMutableBufferPointer(start: angVelPtr, count: dataStride[2])

                            angularVelocityBuffer[0] = 0

                            if (contactNormalBuffer[1] > 0.4) {
                                let rawPtr = data[3] + dataStride[3] * Int(indices![i])
                                let velocityPointer = rawPtr.bindMemory(to: Float.self, capacity: dataStride[3])
                                let velocityBuffer = UnsafeMutableBufferPointer(start: velocityPointer, count: dataStride[3])
                                velocityBuffer[0] = 0
                                velocityBuffer[1] = 0
                                velocityBuffer[2] = 0
                            }
                        }
                    })

                    particleHolder?.addParticleSystem(ps)
                    particleHolder?.position = SCNVector3Make(0, 15, CGFloat(HOLE_Z))
                }
            }

        case ParticleSteps.emitterCube.rawValue:
            particleHolder?.removeAllParticleSystems()
            self.textManager.flipOutText(ofTextType: .bullet)
            _ = self.textManager.add(bullet: "Emitter shape",
                                     at: 0)
            self.textManager.flipInText(ofTextType: .bullet)

            particleHolder?.removeFromParentNode()

            let ps = SCNParticleSystem(named: "emitters",
                                       inDirectory: nil)
            ps?.isLocal = true
            particleHolder?.addParticleSystem(ps!)

            let node = SCNNode()
            node.position = SCNVector3Make(3, 6, CGFloat(HOLE_Z))
            node.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat.pi * 2,
                                                                    around: SCNVector3Make(0.3, 1, 0),
                                                                    duration: 8)))
            self.groundNode.addChildNode(node)
            bokeh = ps

            node.addParticleSystem(ps!)

        case ParticleSteps.emitterSphere.rawValue:
            bokeh?.emitterShape = SCNSphere(radius: 5)
 
        case ParticleSteps.emitterTorus.rawValue:
            bokeh?.emitterShape = SCNTorus(ringRadius: 5,
                                           pipeRadius: 1)
        default:
            break
        }
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        presentationViewController.presentationView.scene?.removeAllParticleSystems()
    }
}
