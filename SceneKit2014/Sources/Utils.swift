/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

This file contains some utilities such as titled box, loading DAE files, loading images etc...

*/


import SceneKit
import GLKit
import Cocoa

var titleAttributes: [String: Any]? = nil
var centeredTitleAttributes: [String: Any]? = nil

enum AAPLLabelSize: UInt {
    case small = 1
    case normal = 2
    case large = 4
}

extension NSBitmapImageRep {

    convenience init?(fromNSImage image: NSImage) {
        let size = image.size
        
        if (size.width<=0 || size.height<=0) {
            return nil
        }
        
        image.lockFocus()
        self.init(focusedViewRect: NSMakeRect(0,0, size.width,size.height))
        image.unlockFocus()
        
    }
}


extension SCNNode {

    class func _markBuffer(_ mark: UnsafeMutablePointer<UInt8>,
                           _ pos: Int,
                           _ count: Int,
                           _ dx: Int)
    {
        var p = pos
        for _ in 0..<count {
            mark[p] = 1
            p += dx
        }
    }

    class func _sameColor(_ pos: Int, _ count: Int,
                          _ white: Bool,
                          _ dx: Int,
                          _ data: UnsafeMutablePointer<UInt8>) -> Bool {
        var tdx = 0
        for _ in 0..<count {
            if (data[(pos + tdx)*4 + 3] < 128) {
                return false
            }
            let c = data[(pos + tdx)*4]
            if (white && c < 128) {
                return false
            }
            if (!white && c > 128) {
                return false
            }
            tdx += dx
        }

        return true

    }

    class func _extend(_ x: Int, _ y: Int,
                       _ w: Int, _ h: Int,
                       _ data: UnsafeMutablePointer<UInt8>,
                       _ isWhite: Bool, _ mark: UnsafeMutablePointer<UInt8>) -> Int {
        var c = 1
        var shouldContinue = true

        repeat {
            if (x+c < w && y+c < h
                && _sameColor(x+c+y*w, c+1, isWhite, w, data)
                && _sameColor(x+(y+c)*w, c, isWhite, 1, data)) {
                //mark
                _markBuffer(mark, x+c+y*w, c+1, w);
                _markBuffer(mark, x+(y+c)*w, c, 1);
                //next
                c += 1
            }
            else {
                shouldContinue = false
            }


        } while (shouldContinue)

        return c
    }

    class func node(withPixelatedImage image: NSImage,
                    pixelSize size: CGFloat)  -> SCNNode {

        let bitmap = NSBitmapImageRep(fromNSImage: image)

        let w = bitmap?.pixelsWide
        let h = bitmap?.pixelsHigh
        let data = bitmap?.bitmapData

        let memBlock = calloc(1, w!*h!)         // w * h bytes
        let mark = memBlock?.bindMemory(to: UInt8.self, capacity: w!*h!)

        let white = SCNMaterial()
        let black = SCNMaterial()
        black.diffuse.contents = NSColor.orange
        //black.reflective.contents = "envmap.jpg"

        let group = SCNNode()
        var index = 0
        for y in 0..<h! {
            for x in 0..<w! {
                if mark?[index] != 0 {
                    index += 1
                    continue
                }
                if ((data?[index*4+3])! < 128) {
                    index += 1
                    continue
                }

                let isWhite = ((data?[index*4])! > 128)

                let count = _extend(x, y, w!, h!, data!, isWhite, mark!)
                let blockSize = size * CGFloat(count)
        
                let box = SCNBox(width: blockSize,
                                 height: blockSize,
                                 length: 5*size,
                                 chamferRadius: blockSize * 0.0)
                box.firstMaterial = isWhite ? white : black

                let node = SCNNode()
                node.position = SCNVector3Make(CGFloat(x-(w!/2))*size + CGFloat(count-1)*size*0.5,
                                               CGFloat(h!-y)*size - CGFloat(count-1)*size*0.5,
                                               0)
                node.geometry = box

                group.addChildNode(node)
                index += 1
            }
        }
        return group
    }

    func asc_addChildNode(named name: String?,
                          fromSceneNamed path: String,
                          withScale scale: CGFloat) -> SCNNode {

        // Load the scene from the specified file
        let scene = SCNScene(named: path,
                             inDirectory: nil,
                             options: nil)

        // Retrieve the root node
        var node = scene?.rootNode

        // Search for the node named "name"
        if name != nil {
            node = node?.childNode(withName: name!,
                                   recursively: true)
        }
        else {
            // Take the first child if no name is passed
            node = node?.childNodes[0]
        }

        if scale != 0 {
            // Rescale based on the current bounding box and the desired scale
            // Align the node to 0 on the Y axis
            // node must not be nil
            let (minimum, maximum) = (node?.boundingBox)!

            var mid = GLKVector3Add(SCNVector3ToGLKVector3(minimum), SCNVector3ToGLKVector3(maximum))
            mid = GLKVector3MultiplyScalar(mid, 0.5)
            // mid.y = min.y;
            mid = GLKVector3Make(mid.x, Float(minimum.y), mid.z) // Align on bottom


            let size = GLKVector3Subtract(SCNVector3ToGLKVector3(maximum), SCNVector3ToGLKVector3(minimum))
            let maxSize = max(max(size.x, size.y), size.z)

            let newScale = scale / CGFloat(maxSize)
            mid = GLKVector3MultiplyScalar(mid, Float(newScale))
            mid = GLKVector3Negate(mid)

            node?.scale = SCNVector3Make(newScale, newScale, newScale)
            node?.position = SCNVector3FromGLKVector3(mid)
        }

        // Add to the container passed in argument
        self.addChildNode(node!)

        return node!
    }
    
    class func asc_boxNode(title: String,
                           frame: NSRect,
                           color: NSColor,
                           cornerRadius: CGFloat,
                           centered: Bool) -> SCNNode {


        // create and extrude a bezier path to build the box
        let path = NSBezierPath(roundedRect: frame,
                                xRadius: cornerRadius,
                                yRadius: cornerRadius)
        path.flatness = 0.05

        let shape = SCNShape(path: path,
                             extrusionDepth: 20)
        shape.chamferRadius = 0.0

        let node = SCNNode()
        node.geometry = shape

        // create an image and fill with the color and text
        var textureSize = NSSize()
        textureSize.width = CGFloat(ceilf(Float(frame.size.width) * 1.5))
        textureSize.height = CGFloat(ceilf(Float(frame.size.height) * 1.5))

        let texture = NSImage(size: textureSize)

        texture.lockFocus()

        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0

        var drawFrame = NSMakeRect(0, 0, textureSize.width, textureSize.height)
        color.usingColorSpace(NSColorSpace.deviceRGB)?.getHue(&hue,
                                                              saturation: &saturation,
                                                              brightness: &brightness,
                                                              alpha: &alpha)

        let lightColor = NSColor(deviceHue: hue,
                                 saturation: saturation - 0.2,
                                 brightness: brightness + 0.3,
                                 alpha: alpha)

        lightColor.set()
        NSRectFill(drawFrame)

        var fillpath: NSBezierPath

        if cornerRadius == 0 && centered == false {
            //special case for the "labs" slide
            fillpath = NSBezierPath(roundedRect: NSOffsetRect(drawFrame, 0, -2),
                                    xRadius:cornerRadius,
                                    yRadius:cornerRadius)
        }
        else {
            fillpath = NSBezierPath(roundedRect:NSInsetRect(drawFrame, 3, 3),
                                    xRadius:cornerRadius,
                                    yRadius:cornerRadius)
        }

        color.set()
        fillpath.fill()


        // draw the title if any
        if !title.isEmpty {
            if (titleAttributes == nil) {
                let paraphStyle = NSMutableParagraphStyle()
                paraphStyle.lineBreakMode = .byWordWrapping
                paraphStyle.alignment = .left
                paraphStyle.minimumLineHeight = 38
                paraphStyle.maximumLineHeight = 38

                var font = NSFont(name: "Myriad Set", size: 34)
                if font == nil {
                    font = NSFont(name:"Avenir Medium", size: 34)
                }

                let shadow = NSShadow()
                shadow.shadowOffset = NSMakeSize(0, -2)
                shadow.shadowBlurRadius = 4
                shadow.shadowColor = NSColor(deviceWhite: 0.0,
                                             alpha:0.5)

                titleAttributes = [
                    NSFontAttributeName             : font!,
                    NSForegroundColorAttributeName  : NSColor.white,
                    NSShadowAttributeName           : shadow,
                    NSParagraphStyleAttributeName   : paraphStyle
                ]


                let centeredParaphStyle = paraphStyle.mutableCopy() as! NSMutableParagraphStyle
                centeredParaphStyle.alignment = .center
                // unwrapped the font?
                centeredTitleAttributes = [
                    NSFontAttributeName             : font!,
                    NSForegroundColorAttributeName  : NSColor.white,
                    NSShadowAttributeName           : shadow,
                    NSParagraphStyleAttributeName   : centeredParaphStyle
                ]
            }

            let attrString = NSAttributedString(string: title,
                                                attributes: centered ? centeredTitleAttributes : titleAttributes)

            var textSize = attrString.size()

            //check if we need two lines to draw the text
            var twoLines = (title as NSString).range(of: "\n").length > 0
            if (!twoLines) {
                twoLines = textSize.width > frame.size.width && (title as NSString).range(of: " ").length > 0
            }
            
            //if so, we need to adjust the size to center vertically
            if (twoLines) {
                textSize.height += 38;
            }

            if !centered {
                drawFrame = NSInsetRect(drawFrame, 15, 0);
            }
            
            //center vertically
            let dy = (drawFrame.size.height - textSize.height) * 0.5;
            drawFrame.size.height -= dy;
            attrString.draw(in: drawFrame)
        }

        texture.unlockFocus()

        //set the created image as the diffuse texture of our 3D box
        let front = SCNMaterial()
        front.diffuse.contents = texture
        front.locksAmbientWithDiffuse = true

        //use a lighter color for the chamfer and sides
        let sides = SCNMaterial()
        sides.diffuse.contents = lightColor
        node.geometry?.materials = [front, sides, sides, sides, sides]

        return node;
    }

    class func asc_planeNode(withImage image: NSImage,
                             size: CGFloat,
                             isLit: Bool) -> SCNNode {

        let node = SCNNode()

        let factor = size / (max(image.size.width, image.size.height))

        node.geometry = SCNPlane(width: image.size.width*factor,
                                 height: image.size.height*factor)
        node.geometry?.firstMaterial?.diffuse.contents = image;

        //if we don't want the image to be lit, set the lighting model to "constant"
        if (!isLit) {
            node.geometry?.firstMaterial?.lightingModel = .constant
        }

        return node
    }

    class func asc_planeNode(withImageNamed name: String,
                             size: CGFloat,
                             isLit: Bool) -> SCNNode {

        return self.asc_planeNode(withImage: NSImage(named: name)!,
                                  size: size,
                                  isLit: isLit)
    }
    
    class func asc_labelNode(withString string: String,
                             size: AAPLLabelSize,
                             isLit: Bool) -> SCNNode {
        let node = SCNNode()

        let text = SCNText(string: string, extrusionDepth:0)
        node.geometry = text
        node.scale = SCNVector3Make(0.01 * CGFloat(size.rawValue),
                                    0.01 * CGFloat(size.rawValue),
                                    0.01 * CGFloat(size.rawValue))
        text.flatness = 0.4

        // Use Myriad it's if available, otherwise Avenir
        if (size == .large) {
            
            if let font = NSFont(name: "Myriad Set Bold", size: 50) {
                text.font = font
            }
            else {
                text.font = NSFont(name: "Avenir bold", size:50)
            }
        }
        else {
            if let font = NSFont(name: "Myriad Set", size: 50) {
                text.font = font
            }
            else {
                text.font = NSFont(name: "Avenir Medium", size:50)
            }
        }
        if !isLit {
            text.firstMaterial?.lightingModel = .constant
        }

        return node
    }

    class func asc_gaugeNode(withTitle title: String,
                             progressNode: inout SCNNode?) -> SCNNode {
        let gaugeGroup = SCNNode()

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        do {
            let gauge = SCNNode()
            gauge.geometry = SCNCapsule(capRadius: 0.4, height: 8)
            gauge.geometry?.firstMaterial?.lightingModel = .constant
            gauge.rotation = SCNVector4Make(0, 0, 1,
                                            CGFloat.pi/2)
            gauge.geometry?.firstMaterial?.diffuse.contents = NSColor.white
            gauge.geometry?.firstMaterial?.cullMode = .front

            let gaugeValue = SCNNode()
            gaugeValue.geometry = SCNCapsule(capRadius: 0.3, height: 7.8)
            gaugeValue.pivot = SCNMatrix4MakeTranslation(0, 3.8, 0)
            gaugeValue.position = SCNVector3Make(0, 3.8, 0)
            gaugeValue.scale = SCNVector3Make(1, 0.01, 1)
            gaugeValue.opacity = 0.0;
            gaugeValue.geometry?.firstMaterial?.diffuse.contents = NSColor(deviceRed:0, green:1, blue:0, alpha:1)
            gaugeValue.geometry?.firstMaterial?.lightingModel = .constant
            gauge.addChildNode(gaugeValue)

            if progressNode != nil {
                progressNode = gaugeValue
            }

            let titleNode = SCNNode.asc_labelNode(withString: title,
                                                  size: .normal,
                                                  isLit:false)
            titleNode.position = SCNVector3Make(-8, -0.55, 0)

            gaugeGroup.addChildNode(titleNode)
            gaugeGroup.addChildNode(gauge)
        }
        SCNTransaction.commit()
        return gaugeGroup
    }
}

extension NSBezierPath {
    class func asc_arrowBezierPath(withBaseSize baseSize: NSSize,
                                   tipSize: NSSize,
                                   hollow: CGFloat,
                                   twoSides: Bool) -> NSBezierPath {
        let arrow = NSBezierPath()

        var h = [CGFloat](repeating: 0, count: 5)
        var w = [CGFloat](repeating: 0, count: 4)

        w[0] = 0
        w[1] = baseSize.width - tipSize.width - hollow
        w[2] = baseSize.width - tipSize.width
        w[3] = baseSize.width

        h[0] = 0
        h[1] = (tipSize.height - baseSize.height) * 0.5
        h[2] = (tipSize.height) * 0.5
        h[3] = (tipSize.height + baseSize.height) * 0.5
        h[4] = tipSize.height

        if (twoSides) {
            arrow.move(to: NSMakePoint(tipSize.width, h[1]))
            arrow.line(to: NSMakePoint(tipSize.width + hollow, h[0]))
            arrow.line(to: NSMakePoint(0, h[2]))
            arrow.line(to: NSMakePoint(tipSize.width + hollow, h[4]))
            arrow.line(to: NSMakePoint(tipSize.width, h[3]))

        }
        else {
            arrow.move(to: NSMakePoint(0, h[1]))
            arrow.line(to: NSMakePoint(0, h[3]))
        }

        arrow.line(to: NSMakePoint(w[2], h[3]))
        arrow.line(to: NSMakePoint(w[1], h[4]))
        arrow.line(to: NSMakePoint(w[3], h[2]))
        arrow.line(to: NSMakePoint(w[1], h[0]))
        arrow.line(to: NSMakePoint(w[2], h[1]))

        arrow.close()

        return arrow
    }
}

extension NSImage {

    // not tested
    class func asc_imageForApplication(named name: String) -> NSImage {
        var image: NSImage? = nil

        if let path = NSWorkspace.shared().fullPath(forApplication: name) {
            image = NSWorkspace.shared().icon(forFile: path)
            image = image?.asc_copy(withResolution: 512)
        }

        if (image == nil) {
            image = NSImage(named: NSImageNameCaution)
        }

        return image!
    }

    // not tested
    func asc_copy(withResolution size: CGFloat) -> NSImage? {
        let imageRep = self.bestRepresentation(for: NSMakeRect(0, 0, size, size),
                                               context: nil,
                                               hints: nil)
        if imageRep != nil {
            return NSImage(cgImage: imageRep!.cgImage(forProposedRect: nil,
                                                      context: nil,
                                                      hints: nil)!,
                           size: imageRep!.size)
        }
        return nil
    }
}

extension SCNAction {
    // not tested
    class func removeFromParentOnMainThread(node: SCNNode) -> SCNAction {
        return SCNAction.run({
            (owner: SCNNode) -> Void in
            owner.removeFromParentNode()
            }, queue: DispatchQueue.main)
    }
}


extension SCNVector3 {

    // usage: c = a.cross(b)
    func cross(_ toVector: SCNVector3) -> SCNVector3 {
        //  return a.yzx * b.zxy - a.zxy * b.yzx;
        return SCNVector3Make(y * toVector.z - z * toVector.y,
                              z * toVector.x - x * toVector.z,
                              x * toVector.y - y * toVector.x)
    }
    var length: CGFloat {
        return (CGFloat) (sqrt(x * x + y * y + z * z))
    }


    // usage: a.normalize where a is a var.
    mutating func normalize() {
        // check: we are not normalizing a zero vector
        if !SCNVector3EqualToVector3(self, SCNVector3Zero) {
            let invlen = 1.0 / self.length
            var out = SCNVector3Zero
            out.x = self.x * invlen
            out.y = self.y * invlen
            out.z = self.z * invlen
            self = out
        }
    }
}
