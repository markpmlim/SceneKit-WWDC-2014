/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

AAPLSlideTextManager manages the layout of the different types of text presented in the slides.

*/

import SceneKit

enum AAPLTextType: Int {
    case none = 0
    case chapter
    case title
    case subtitle
    case bullet
    case body
    case code
    case footPrint
    case typeCount
}

let TEXT_SCALE: CGFloat = 0.02
let TEXT_CHAMFER: CGFloat = 1
let TEXT_DEPTH: CGFloat = 0.0
let TEXT_FLATNESS: CGFloat = 0.4
let TEXT_FOOTPRINT_SCALE: CGFloat = 0.006

class AAPLSlideTextManager: NSObject {
    var textNode: SCNNode
    var fadesIn: Bool

    // The containers for each type of text
    var subGroups = [SCNNode?](repeating: nil,
                               count: AAPLTextType.typeCount.rawValue)
    
    var previousType: AAPLTextType
    var currentBaseline: CGFloat
    var titleBaseline: CGFloat
    var subtitleBaseline: CGFloat
    var contentDefaultBaseline: CGFloat
    
    var baselinePerType = [Float](repeating: 0.0,
                                  count:AAPLTextType.typeCount.rawValue)

    override init() {
        textNode = SCNNode()
        currentBaseline = 16.0
        
        titleBaseline = 16.5
        subtitleBaseline = 16-2
        contentDefaultBaseline = 16-2.26-2.23-1

        previousType = .none
        fadesIn = false
        super.init()
    }

    func color(forTextType type: AAPLTextType,
               level: UInt) -> NSColor {

        var color = NSColor.white
        switch (type) {
        case .footPrint, .subtitle:
            color = NSColor(deviceRed: 142/255.0,
                            green: 142/255.0,
                            blue: 147/255.0,
                            alpha: 1)
        case .code:
            color = level == 0 ? NSColor.white : NSColor(deviceRed: 242/255.0,
                                                         green: 173/255.0,
                                                         blue: 24/255.0,
                                                         alpha: 1)
        case .body:
            if level == 2 {
                return NSColor(deviceRed:115/255.0,
                               green:170/255.0,
                               blue:230/255.0,
                               alpha:1)
            }
        default:
            color = NSColor.white
        }
        return color
    }

    func extrusionDepth(forTextType type: AAPLTextType ) -> CGFloat {
        return type == .chapter ? 10.0 : TEXT_DEPTH
    }

    func fontSize(forTextType type: AAPLTextType, level: UInt) -> CGFloat {
        switch (type) {
        case .title:
            return 88
        case .chapter:
            return 94
        case .code:
            return 36
        case .footPrint:
            return 34
        case .subtitle:
            return 64
        case .body:
            return level == 0 ? 50 : 40
        default:
            return 56
        }
    }

    func font(forTextType type: AAPLTextType,
              level: UInt) -> NSFont {

        let fontSize = self.fontSize(forTextType: type, level: level)
        var font: NSFont?
        switch (type) {
        case .code:
            font =  NSFont(name:"Menlo", size: fontSize)
        case .bullet, .footPrint:
            font =  NSFont(name:"Myriad Set", size: fontSize)
            if font == nil {
                font =  NSFont(name:"Avenir Medium", size: fontSize)
            }
        case .body:
            if (level != 0) {
                font =  NSFont(name:"Myriad Set", size: fontSize)
                if font == nil {
                    font =  NSFont(name:"Avenir Medium", size: fontSize)
                }
            }
            else {
                fallthrough
            }
        default:
            font =  NSFont(name:"Myriad Set", size: fontSize)
            if font == nil {
                font =  NSFont(name:"Avenir Medium", size: fontSize)
            }
        }
        return font!
    }

    func lineHeight(forTextType type: AAPLTextType,
                    level: UInt) -> CGFloat {
        switch (type) {
        case .title:
            return 2.26
        case .chapter:
            return 3
        case .code:
            return 1.22
        case .subtitle:
            return 1.8
        case .body:
            return level == 0 ? 1.2 : 1.0
        default:
            return 1.65
        }
    }

    func textContainer(forTextType type: AAPLTextType) -> SCNNode {
        if (type == .chapter) {
            return self.textNode.parent!
        }

        // problem?
        if (subGroups[type.rawValue] != nil) {
            return subGroups[type.rawValue]!
        }

        let container = SCNNode()
        self.textNode.addChildNode(container)

        subGroups[type.rawValue] = container
        baselinePerType[type.rawValue] = Float(currentBaseline);

        return container;
    }


    func addEmptyLine() {
        currentBaseline -= 1.2;
    }

    func node(withText string: String,
              withTextType type: AAPLTextType,
              level: UInt) -> SCNNode {

        let textNode = SCNNode()
        var str = string                    // we may modify the contents of string.
        // Bullet
        if type == .bullet {
            if level == 0 {
                //string = [NSString stringWithFormat:@"• %@", string];
                str = string
            }
            else {
                str = String(format:"• %@", string)
            }
        }

        // Text attributes
        let extrusion = self.extrusionDepth(forTextType: type)
        let text = SCNText(string: str,
                           extrusionDepth: extrusion)
        textNode.geometry = text
        text.flatness = TEXT_FLATNESS;
        text.chamferRadius = extrusion == 0 ? 0 : TEXT_CHAMFER
        text.font = self.font(forTextType: type,
                              level: level)

        // Layout
        let layoutManager = NSLayoutManager()
        let leading = layoutManager.defaultLineHeight(for: text.font)
        let descender = text.font.descender
        let newlineCount = (text.string as! String).components(separatedBy: CharacterSet.newlines).count
        textNode.pivot = SCNMatrix4MakeTranslation(0, -descender + CGFloat(newlineCount) * leading, 0)

        if type == .chapter {
            let (min, _) = textNode.boundingBox
            textNode.position = SCNVector3Make(-11, (-min.y + textNode.pivot.m42) * TEXT_SCALE, 7);
            textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
            textNode.rotation = SCNVector4Make(0, 1, 0,
                                               (CGFloat.pi/270.0))
        }
        else if type == .footPrint {
            textNode.position = SCNVector3Make(-5.68, -3.9, -10);
            textNode.scale = SCNVector3Make(TEXT_FOOTPRINT_SCALE, TEXT_FOOTPRINT_SCALE, TEXT_FOOTPRINT_SCALE);
        }
        else {
            textNode.position = SCNVector3Make(-16, currentBaseline, 0);
            textNode.scale = SCNVector3Make(TEXT_SCALE, TEXT_SCALE, TEXT_SCALE);
        }

        // Material
        if type == .chapter {
            let frontMaterial = SCNMaterial()
            let sideMaterial = SCNMaterial()

            frontMaterial.emission.contents = NSColor.lightGray
            frontMaterial.diffuse.contents = self.color(forTextType: type,
                                                        level:level)
            sideMaterial.diffuse.contents = NSColor.lightGray
            textNode.geometry?.materials = [frontMaterial, frontMaterial, sideMaterial, frontMaterial, frontMaterial]
        }
        else {
            // Full white emissive material (visible even when there is no light)
            textNode.geometry?.firstMaterial = SCNMaterial()
            textNode.geometry?.firstMaterial?.diffuse.contents = NSColor.black
            textNode.geometry?.firstMaterial?.emission.contents = self.color(forTextType: type,
                                                                             level: level)
        }

        if type == .footPrint {
            textNode.renderingOrder = 100   //render last
            textNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        }

        return textNode
    }

    func node(withCode string: String) -> SCNNode {

        // Node hierarchy:
        // codeNode
        // |__ regularCodeNode
        // |__ emphasis-0 (can be highlighted separately)
        // |__ emphasis-1 (can be highlighted separately)
        // |__ emphasis-2 (can be highlighted separately)
        // |__ ...
        let codeNode = SCNNode()

        var chunk = 0;
        var regularCode = String()
        var whitespacesCode = String()

        // Automatically highlight the parts of the code that are delimited by '#'
        let components = string.components(separatedBy: "#")

        for i in 0 ..< components.count {
            let component = components[i]

            var whitespaces = String()
            for char in component.characters {
                if char == "\n" {
                    whitespaces.append("\n")
                }
                else {
                    whitespaces.append(" ")
                }
            }
            if i%2 != 0 {
                let emphasisedCodeNode = self.node(withText: whitespacesCode.appending(component),
                                                   withTextType: .code,
                                                   level: 1)
                emphasisedCodeNode.name = String(format:"emphasis-%ld", chunk)
                chunk += 1
                codeNode.addChildNode(emphasisedCodeNode)

                regularCode.append(whitespaces)
            }
            else {
                regularCode.append(component)
            }
            whitespacesCode.append(whitespaces)
        }

        let regularCodeNode = self.node(withText: regularCode,
                                        withTextType: .code,
                                        level: 0)
        regularCodeNode.name = "regular"
        codeNode.addChildNode(regularCodeNode)
        return codeNode
    }

    func add(text string: String,
             with textType: AAPLTextType,
             level: UInt) -> SCNNode {

        let parentNode = self.textContainer(forTextType: textType)

        if textType != .footPrint {
            if previousType != textType {
                if textType == .title {
                    currentBaseline = titleBaseline
                }
                else if textType == .subtitle {
                    currentBaseline = subtitleBaseline
                }
                else {
                    if ((previousType.rawValue) <= AAPLTextType.subtitle.rawValue) {
                        currentBaseline = contentDefaultBaseline;
                    }
                    else {
                        currentBaseline -= 1.0
                    }
                }
            }
            currentBaseline -= self.lineHeight(forTextType: textType,
                                               level: level)
        }
        let textNode = (textType == .code) ? self.node(withCode: string) : self.node(withText: string,
                                                                                     withTextType: textType,
                                                                                     level: level)

        parentNode.addChildNode(textNode)

        if self.fadesIn {
            textNode.opacity = 0
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            do {
                textNode.opacity = 1
            }
            SCNTransaction.commit()
        }

        previousType = textType

        return textNode
    }

    // Public API
    func set(title: String) -> SCNNode {

        return self.add(text: title,
                        with: .title,
                        level: 0)
    }

    func set(subtitle: String)  -> SCNNode {

        return self.add(text: subtitle,
                        with: .subtitle,
                        level: 0)
    }

    func set(chapterTitle: String)  -> SCNNode {

        return self.add(text: chapterTitle,
                        with: .chapter,
                        level: 0)
    }

    func add(text: String,
             at level:UInt)  -> SCNNode {

        return self.add(text: text,
                        with: .body,
                        level: level)
    }

    func add(bullet: String,
             at level: UInt) -> SCNNode {

        return self.add(text: bullet,
                        with: .bullet,
                        level: level)
    }

    func add(code: String)  -> SCNNode {

        return self.add(text: code,
                        with: .code,
                        level: 0)
    }

    func add(footPrint: String)  -> SCNNode {
        return self.add(text: footPrint,
                            with: .footPrint,
                            level: 0)
    }

    // animations
    let PIVOT_X: CGFloat = 16
    let FLIP_ANGLE: CGFloat = .pi/2
    let FLIP_DURATION: CGFloat = 1.0

    // Animate (fade out) to remove the text of specified type
    func fadeOutText(ofTextType type: AAPLTextType) {
        previousType = .none
        let node = subGroups[type.rawValue]
        subGroups[type.rawValue] = nil
        if node != nil {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            do {
                node!.position = SCNVector3Make(-PIVOT_X, 0, 0);
                node!.pivot = SCNMatrix4MakeTranslation(-PIVOT_X, 0, 0);
            }
            SCNTransaction.commit()

            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(FLIP_DURATION)
            SCNTransaction.completionBlock = {
                node!.removeFromParentNode()
            }
            do {
                node!.rotation = SCNVector4Make(0, 1, 0,
                                                FLIP_ANGLE);
                node!.opacity = 0;
            }
            SCNTransaction.commit()

            // Reset the baseline to what it was before adding this text
            currentBaseline = max(currentBaseline, CGFloat(baselinePerType[type.rawValue]))
        }
    }

    // Animate (flip) to remove the text of specified type
    func flipOutText(ofTextType type: AAPLTextType) {

        previousType = .none

        let node = subGroups[type.rawValue]
        subGroups[type.rawValue] = nil
        if (node != nil) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            do {
                node?.position = SCNVector3Make(-PIVOT_X, 0, 0)
                node?.pivot = SCNMatrix4MakeTranslation(-PIVOT_X, 0, 0)
            }
            SCNTransaction.commit()

            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(FLIP_DURATION)
            SCNTransaction.completionBlock = {
                node?.removeFromParentNode()
            }

            do {
                node?.rotation = SCNVector4Make(0, 1, 0,
                                                FLIP_ANGLE)
                node?.opacity = 0
            }
            SCNTransaction.commit()

            // Reset the baseline to what it was before adding this text
            currentBaseline = max(currentBaseline, CGFloat(baselinePerType[type.rawValue]))
        }
    }

    // Animate to reveal the text of specified type
    func flipInText(ofTextType type: AAPLTextType) {

        if let node = subGroups[type.rawValue] {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            do {
                node.position = SCNVector3Make(-PIVOT_X, 0, 0)
                node.pivot = SCNMatrix4MakeTranslation(-PIVOT_X, 0, 0)
                node.rotation = SCNVector4Make(0, 1, 0, -FLIP_ANGLE)
                node.opacity = 0
            }
            SCNTransaction.commit()

            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(FLIP_DURATION)
            do {
                node.rotation = SCNVector4Make(0, 1, 0, 0)
                node.opacity = 1
            }
            SCNTransaction.commit()
        }
    }


    // Highlighting text

    func highlightBullet(at index: UInt) {

        // Highlight is done by changing the emission color
        if let node = subGroups[AAPLTextType.bullet.rawValue] {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.75
            do {
                // Reset all
                for child in node.childNodes {
                    child.geometry?.firstMaterial?.emission.contents = NSColor.white
                }

                // Unhighlight everything but index
                if (index != UInt.max) {
                    var i: UInt = 0
                    for child in node.childNodes {
                        if (i != index) {
                            child.geometry?.firstMaterial?.emission.contents = NSColor.darkGray
                        }
                        i += 1
                    }
                }
            }
            SCNTransaction.commit()
        }
    }


    func highlight(codeChunks : [NSNumber]) {
        let node = subGroups[AAPLTextType.code.rawValue]
        // Unhighlight everything
        node?.childNodes(passingTest: {
            (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            child.geometry?.firstMaterial?.emission.contents = self.color(forTextType: .code,
                                                                          level: 0)
            return false
        })

        // Highlight text inside range
        for i in codeChunks {
            let name = String(format: "emphasis-%ld", i.uintValue)
            let chunkNode = node?.childNode(withName: name,
                                            recursively: true)
            chunkNode?.geometry?.firstMaterial?.emission.contents = self.color(forTextType: .code,
                                                                               level: 1)
        }
    }
}
