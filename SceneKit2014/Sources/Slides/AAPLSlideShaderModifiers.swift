/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates how shader modifiers work with several examples.
*/

import SceneKit

// slide #41
class AAPLSlideShaderModifiers: APPLSlide {
    var _planeNode: SCNNode?
    var _sphereNode: SCNNode?
    var _torusNode: SCNNode?
    var _xRayNode: SCNNode?
    var _virusNode: SCNNode?

    required init() {
        super.init()
        // should the light intensities be restored on exit from this slide?
        self.lightIntensities = [0.0, 0.3, 1.0]
    }

    override var numberOfSteps: UInt {
        return 2
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
  // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Shader Modifiers")

        _ = self.textManager.add(bullet: "Inject custom GLSL code at specific stages",
                                 at: 0)
        _ = self.textManager.add(bullet: "Combines with SceneKit’s shaders",
                                 at: 0)
        _ = self.textManager.add(bullet: "Refer to WWDC 2013 presentation",
                                 at: 0)

        self.textManager.addEmptyLine()
        _ = self.textManager.add(code: "aMaterial.#shaderModifiers# = @{ <Entry Point> : <GLSL Code> };")
    }

    // All shader modifiers will work if the renderAPI is OpenGL.
    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {

        SCNTransaction.begin()
        switch (stepIndex) {
        case 1:
            do {
                self.textManager.flipOutText(ofTextType: .code)
                self.textManager.flipOutText(ofTextType: .subtitle)
                self.textManager.flipOutText(ofTextType: .bullet)

                _ = self.textManager.set(subtitle: "Entry points")

                var textNode = SCNNode.asc_labelNode(withString: "Geometry",
                                                     size: .normal,
                                                     isLit: false)
                textNode.position = SCNVector3Make(-13.5, 9, 0)
                self.contentNode.addChildNode(textNode)
                textNode = SCNNode.asc_labelNode(withString: "Surface",
                                                 size: .normal,
                                                 isLit: false)
                textNode.position = SCNVector3Make(-5.3, 9, 0)
                self.contentNode.addChildNode(textNode)
                textNode = SCNNode.asc_labelNode(withString: "Lighting",
                                                 size: .normal,
                                                 isLit: false)
                textNode.position = SCNVector3Make(2, 9, 0)
                self.contentNode.addChildNode(textNode)
                textNode = SCNNode.asc_labelNode(withString: "Fragment",
                                                 size: .normal,
                                                 isLit: false)
                textNode.position = SCNVector3Make(9.5, 9, 0)
                self.contentNode.addChildNode(textNode)

                self.textManager.flipInText(ofTextType: .subtitle)

                //add spheres
                let sphere = SCNSphere(radius: 3)
                sphere.firstMaterial?.diffuse.contents = NSColor.red
                sphere.firstMaterial?.specular.contents = NSColor.white
                sphere.firstMaterial?.specular.intensity = 1.0

                sphere.firstMaterial?.shininess = 0.1
                sphere.firstMaterial?.reflective.contents = "envmap.jpg"
                sphere.firstMaterial?.fresnelExponent = 2

                //GEOMETRY: vertex processing stage
                var node = SCNNode()
                node.geometry = sphere.copy() as! SCNSphere
                node.position = SCNVector3Make(-12,3,0)
                node.geometry?.shaderModifiers = [ .geometry :  "// Waves Modifier\n" +
                                                                "uniform float Amplitude = 0.2;\n" +
                                                                "uniform float Frequency = 5.0;\n" +
                                                                "vec2 nrm = _geometry.position.xz;\n" +
                                                                "float len = length(nrm)+0.0001; // for robustness\n" +
                                                                "nrm /= len;\n" +
                                                                "float a = len + Amplitude*sin(Frequency * _geometry.position.y + u_time * 10.0);\n" +
                                                                "_geometry.position.xz = nrm * a;\n"]

                self.groundNode.addChildNode(node)

                // SURFACE: fragment processing stage
                node = SCNNode()
                node.geometry = sphere.copy() as! SCNSphere
                node.position = SCNVector3Make(-4, 3, 0)

                let surfaceShaderPath = Bundle.main.path(forResource: "sm_surf",
                                                         ofType: "shader")
                var surfaceModifier: String?
                do {
                    try surfaceModifier = NSString(contentsOfFile: surfaceShaderPath!,
                                                   encoding: String.Encoding.utf8.rawValue) as String
                }
                catch _ {

                }
                
                node.rotation = SCNVector4Make(1, 0, 0,
                                               -CGFloat.pi/4)
                node.geometry?.firstMaterial = node.geometry?.firstMaterial?.copy() as? SCNMaterial
                node.geometry?.firstMaterial?.lightingModel = .lambert
                node.geometry?.shaderModifiers = [ .surface : surfaceModifier! ]
                self.groundNode.addChildNode(node)

                // LIGHTING: provides a custom lighting equation
                node = SCNNode()
                node.geometry = sphere.copy() as! SCNSphere
                node.position = SCNVector3Make(4, 3, 0)

                let lightingShaderPath = Bundle.main.path(forResource: "sm_light",
                                                          ofType: "shader")
                var lightingModifier: String?
                do {
                    try lightingModifier = NSString(contentsOfFile: lightingShaderPath!,
                                                    encoding: String.Encoding.utf8.rawValue) as String
                }
                catch _ {
                }
                // note: litPerPixel is true (default)
                node.geometry?.shaderModifiers = [ .lightingModel : lightingModifier! ]

                self.groundNode.addChildNode(node)

                // FRAGMENT: change color of a fragment.
                node = SCNNode()
                node.geometry = sphere.copy() as! SCNSphere
                node.position = SCNVector3Make(12,3,0)

                node.geometry?.firstMaterial = node.geometry?.firstMaterial?.copy() as? SCNMaterial
                node.geometry?.firstMaterial?.diffuse.contents = NSColor.green

                let fragmentShaderPath = Bundle.main.path(forResource: "sm_frag",
                                                          ofType: "shader")
                var fragmentModifier: String?
                do {
                    try fragmentModifier = NSString(contentsOfFile: fragmentShaderPath!,
                                                    encoding: String.Encoding.utf8.rawValue) as String
                }
                catch _ {

                }
                node.geometry?.shaderModifiers = [ .fragment : fragmentModifier! ]
                
                self.groundNode.addChildNode(node)


                //redraw forever
                presentationViewController.presentationView.isPlaying = true
                presentationViewController.presentationView.loops = true
            }
        default:
            break
        }
        SCNTransaction.commit()
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        presentationViewController.presentationView.isPlaying = true
        presentationViewController.cameraNode?.position = SCNVector3Make(0, 0, 0)
    }
}
