/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

This slide is about animation events.

*/

import SceneKit
enum AAPLCharacterAnimation: Int {
    case attack = 0
    case walk
    case die
}

// slide #28
class AAPLSlideAnimationEvents: APPLSlide {
    var _heroSkeletonNode: SCNNode?
    var _animations = [CAAnimation](repeating: CAAnimation(),
                                    count: 3)

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 8
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Load the character and add it to the scene
        let heroNode = self.groundNode.asc_addChildNode(named: "heroGroup",
                                                        fromSceneNamed: "Scenes.scnassets/hero/hero.dae",
                                                        withScale: 0.0)
        let SCALE: CGFloat = 0.015
        heroNode.scale = SCNVector3Make(SCALE, SCALE, SCALE);
        heroNode.position = SCNVector3Make(3.0, 0.0, 15.0);

        self.groundNode.addChildNode(heroNode)
        // Convert sceneTime-based animations into systemTime-based animations.
        // Animations loaded from DAE files will play according to the `currentTime` property of the scene renderer if this one is playing
        // (see the SCNSceneRenderer protocol). Here we don't play a specific DAE so we want the animations to animate as soon as we add
        // them to the scene (i.e have them to play according the time of the system when the animation was added).

        _heroSkeletonNode = heroNode.childNode(withName:"skeleton",
                                               recursively: true)
        for animationKey in (_heroSkeletonNode?.animationKeys)! {
            let animation = _heroSkeletonNode?.animation(forKey: animationKey)
            animation?.usesSceneTimeBase = false
            animation?.repeatCount = .greatestFiniteMagnitude

            _heroSkeletonNode?.addAnimation(animation!,
                                            forKey: animationKey)
        }

        // Load other animations so that we will use them later
        self.setAnimation(AAPLCharacterAnimation.attack,
                          withAnimationNamed:"attackID",
                          fromSceneNamed: "Scenes.scnassets/hero/attack")    // boss?boss_attack
        self.setAnimation(AAPLCharacterAnimation.die,
                          withAnimationNamed: "DeathID",
                          fromSceneNamed: "Scenes.scnassets/hero/death")
        self.setAnimation(AAPLCharacterAnimation.walk,
                          withAnimationNamed: "WalkID",
                          fromSceneNamed: "Scenes.scnassets/hero/walk")
    }

    override func present(stepIndex: UInt,
                 with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            do {
                _ = self.textManager.set(title: "Animation Extensions")
                _ = self.textManager.add(bullet: "SCNAnimationEvent",
                                         at: 0)
                _ = self.textManager.add(bullet: "Smooth transitions",
                                         at: 0)

                let node =  self.textManager.add(code: "#SCNAnimationEvent# *anEvent = \n" +
                 "  [SCNAnimationEvent #animationEventWithKeyTime:#0.6 #block:#aBlock]; \n" +
                 "anAnimation.#animationEvents# = @[anEvent, anotherEvent];")
                
                node.position = SCNVector3Make(node.position.x, node.position.y+0.75, node.position.z)
                
                // Warm up NSSound by playing an empty sound.
                // Otherwise the first sound may take some time to start playing and will be desynchronised.
                NSSound(named: "bossaggro")?.play()
            }
        case 1:
            do {
                // Trigger the attack animation
                _heroSkeletonNode?.addAnimation(_animations[AAPLCharacterAnimation.attack.rawValue],
                                                forKey: "attack")
            }
        case 2:
            do {
                self.textManager.fadeOutText(ofTextType: .code)
                let node = self.textManager.add(code: "\n\n\n\n\n\n" +
                                                "anAnimation.#fadeInDuration# = 0.0;\n" +
                                                "anAnimation.#fadeOutDuration# = 0.0;")
                node.position = SCNVector3Make(node.position.x, node.position.y+0.55, node.position.z)
            }
        case 3:
            fallthrough
        case 4:
            do {
                _animations[AAPLCharacterAnimation.attack.rawValue].fadeInDuration = 0
                _animations[AAPLCharacterAnimation.attack.rawValue].fadeOutDuration = 0
                // Trigger the attack animation
                _heroSkeletonNode?.addAnimation(_animations[AAPLCharacterAnimation.attack.rawValue],
                                                forKey: "attack")
            }
        case 5:
            do {
                self.textManager.fadeOutText(ofTextType: .code)
                let node = self.textManager.add(code: "\n\n\n\n\n\n" +
                                "anAnimation.fadeInDuration = #0.3#;\n" +
                                "anAnimation.fadeOutDuration = #0.3#;")
                node.position = SCNVector3Make(node.position.x, node.position.y+0.55, node.position.z)
            }
        case 6:
            fallthrough
        case 7:
            do {
                _animations[AAPLCharacterAnimation.attack.rawValue].fadeInDuration = 0.3
                _animations[AAPLCharacterAnimation.attack.rawValue].fadeOutDuration = 0.3
                // Trigger the attack animation
                _heroSkeletonNode?.addAnimation(_animations[AAPLCharacterAnimation.attack.rawValue],
                                                forKey: "attack")
            }
        default:
            break
        }
    }

    func setAnimation(_ index: AAPLCharacterAnimation,
                      withAnimationNamed animationName: String,
                      fromSceneNamed sceneName: String) {

        // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
        let url = Bundle.main.url(forResource: sceneName,
                                  withExtension: "dae")
        let sceneSource = SCNSceneSource(url: url!,
                                         options: [ .animationImportPolicy : SCNSceneSource.AnimationImportPolicy.play])
        let animation = sceneSource?.entryWithIdentifier(animationName,
                                                         withClass:CAAnimation.self)

        _animations[index.rawValue] = animation!

        // Blend animations for smoother transitions
        animation?.fadeInDuration = 0.3
        animation?.fadeOutDuration = 0.3

        if (index == .die) {
            // We want the "death" animation to remain at its final state at the end of the animation
            animation?.isRemovedOnCompletion = false
            animation?.fillMode = kCAFillModeBoth

            // Create animation events and set them to the animation
            let swipeSoundEventBlock: SCNAnimationEventBlock = {
                //(animation: CAAnimation, animatedObject: Any, playingBackward: Bool) -> Void in
                animation, animatedObject, playingBackward in
                NSSound(named: "swipe")!.play()
            }
            let deathSoundEventBlock: SCNAnimationEventBlock = {
                animation, animatedObject, playingBackward in
                //(animation: CAAnimation, animatedObject: Any, playingBackward: Bool) -> Void in
                NSSound(named: "death")!.play()
            }

            animation?.animationEvents = [SCNAnimationEvent(keyTime: 0.0,
                                                            block: swipeSoundEventBlock),
                                          SCNAnimationEvent(keyTime: 0.3,
                                                            block: deathSoundEventBlock)]
        }

        if (index == .attack) {
            // Create an animation event and set it to the animation
            let swordSoundEventBlock: SCNAnimationEventBlock = {
                animation, animatedObject, playingBackward in
                NSSound(named: "attack4")!.play()
            }
            animation?.animationEvents = [SCNAnimationEvent(keyTime: 0.4,
                                                            block: swordSoundEventBlock)]
        }

        if (index == .walk) {
            // Repeat the walk animation 3 times
            animation?.repeatCount = 3

            // Create an animation event and set it to the animation
            let stepSoundEventBlock: SCNAnimationEventBlock = {
                animation, animatedObject, playingBackward in
                NSSound(named: "walk")!.play()
            }
            animation?.animationEvents = [SCNAnimationEvent(keyTime: 0.2,
                                                            block: stepSoundEventBlock),
                                          SCNAnimationEvent(keyTime: 0.7,
                                                            block: stepSoundEventBlock)]
        }
    }
}
