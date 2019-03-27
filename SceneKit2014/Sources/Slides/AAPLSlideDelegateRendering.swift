/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Explains what scene delegate rendering is and shows an example.

*/

import SceneKit

// slide #43
enum AAPLAttrib: GLuint {
    case pos    // 0
    case uv     // 1
}

// A structure used to represent a vertex
// must use tuples; arrays does not seem to work.
struct AAPLVertexUV {
    var position: (GLfloat, GLfloat, GLfloat, GLfloat)  // position
    var uv0: (GLfloat, GLfloat, GLfloat)                // texture coordinates + vertex index (stored in the last component)
}

var retainPointer: AAPLSlideDelegateRendering?

class AAPLSlideDelegateRendering: APPLSlide, SCNSceneRendererDelegate {
    var quadVAO: GLuint = 0
    var quadVBO: GLuint = 0
    var program: GLuint = 0
    var timeLocation: GLint = 0
    var factorLocation: GLint = 0
    var resolutionLocation: GLint = 0

    // Other ivars
    var fadeFactor: GLfloat = 0
    var fadeFactorDelta: GLfloat = 0
    var startTime: CFAbsoluteTime = 0
    var viewport = CGSize()

    var active: Bool = false

    required init() {
        super.init()
        retainPointer = self
    }

    override var numberOfSteps: UInt {
        return 3
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Custom OpenGL/OpenGL ES")

        _ = self.textManager.add(bullet: "Custom code pre/post rendering",
                                 at: 0)
        _ = self.textManager.add(bullet: "Custom code per node",
                                 at: 0)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            break
        case 1:
            do  {
                active = true
                let delay = 1.0
                let popTime = DispatchTime.now().rawValue + (UInt64(delay) * NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {

                    if (!self.active) {
                            return
                    }

                    // Create a VBO to render a quad
                    self.createQuadGeometryIn(context: presentationViewController.presentationView.openGLContext!)

                    // Create the program and retrieve the uniform locations
                    var attrib = [AAPLAttribLocation](repeating: AAPLAttribLocation(),
                                                      count:3)
                    attrib[0] = AAPLAttribLocation(index: AAPLAttrib.pos.rawValue, name: "position")
                    attrib[1] = AAPLAttribLocation(index: AAPLAttrib.uv.rawValue, name: "texcoord0")
                    attrib[2] = AAPLAttribLocation(index: 0, name: String())

                    // The function below is re-written in Swift and returns a GLSL program id.
                    self.program = GLUtils.AAPLCreateProgram(withName: "SceneDelegate",
                                                             attribLocations: attrib)

                    self.timeLocation = glGetUniformLocation(self.program, "time")
                    self.factorLocation = glGetUniformLocation(self.program, "factor")
                    self.resolutionLocation = glGetUniformLocation(self.program, "resolution")

                    // Initialize time and cache the viewport
                    let frameSize = presentationViewController.presentationView.convertToBacking(presentationViewController.presentationView.frame.size)
                    self.viewport = NSSizeToCGSize(frameSize)
                    self.startTime = CFAbsoluteTimeGetCurrent()

                    self.fadeFactor = 0         // tunnel is not visible
                    self.fadeFactorDelta = 0.05 // fade in

                    // Set self as the scene renderer's delegate and make the view redraw for ever
                    presentationViewController.presentationView.delegate = self
                    presentationViewController.presentationView.isPlaying = true
                    presentationViewController.presentationView.loops = true
                }
                //retainPointer = self
            }
        case 2:
            fadeFactorDelta *= -1 // fade out
        default:
            break
        }
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        presentationViewController.presentationView.delegate = nil
        presentationViewController.presentationView.isPlaying = true
        active = false
        retainPointer = nil
    }

    // Create a VAO/VBO used to render a quad
    func createQuadGeometryIn(context: NSOpenGLContext)  {
        context.makeCurrentContext()

        glGenVertexArrays(1, &quadVAO)
        glBindVertexArray(quadVAO)

        glGenBuffers(1, &quadVBO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), quadVBO)

        // index is unused - 2 triangles are drawn for the quad.
        let vertices: [AAPLVertexUV] = [
            AAPLVertexUV(position: (-1.0, 1.0, 0.0, 1.0),   uv0: (0.0, 1.0, 0.0)),
            AAPLVertexUV(position: (1.0, 1.0, 0.0, 1.0),    uv0: (1.0, 1.0, 1.0)),
            AAPLVertexUV(position: (-1.0, -1.0, 0.0, 1.0),  uv0: (0.0, 0.0, 2.0)),
            AAPLVertexUV(position: (-1.0, -1.0, 0.0, 1.0),  uv0: (0.0, 0.0, 2.0)),
            AAPLVertexUV(position: (1.0, 1.0, 0.0, 1.0),    uv0: (1.0, 1.0, 1.0)),
            AAPLVertexUV(position: (1.0, -1.0, 0.0, 1.0),   uv0: (1.0, 0.0, 3.0))
        ]

        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     MemoryLayout<AAPLVertexUV>.stride * vertices.count,
                     vertices, GLenum(GL_STATIC_DRAW))

        let positionAttr = UnsafeRawPointer(bitPattern: 0)
        glVertexAttribPointer(AAPLAttrib.pos.rawValue,
                              4,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<AAPLVertexUV>.stride),
                              positionAttr)
        glEnableVertexAttribArray(AAPLAttrib.pos.rawValue)

        let uvAttr = UnsafeRawPointer(bitPattern: MemoryLayout<Float>.stride * 4)
        glVertexAttribPointer(AAPLAttrib.uv.rawValue,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_TRUE),
                              GLsizei(MemoryLayout<AAPLVertexUV>.stride),
                              uvAttr)
        glEnableVertexAttribArray(AAPLAttrib.uv.rawValue)

        glBindVertexArray(0)
    }

    // Implementation of a SCNSceneRendererDelegate method.
    // Invoked by SceneKit before rendering the scene. When this is invoked, SceneKit
    // has already installed the viewport and cleared the background.
    func renderer(_ renderer: SCNSceneRenderer,
                  willRenderScene scene: SCNScene,
                  atTime time: TimeInterval) {
        // Disable what SceneKit enables by default (and restore upon leaving)
        glDisable(GLenum(GL_CULL_FACE))
        glDisable(GLenum(GL_DEPTH_TEST))

        // Draw the procedural background
        glBindVertexArray(quadVAO)
        glUseProgram(program)
        glUniform1f(timeLocation, GLfloat(CFAbsoluteTimeGetCurrent() - startTime))
        glUniform1f(factorLocation, fadeFactor)
        // Should we get the viewport? the user may re-size the window.
        glUniform2f(resolutionLocation, GLfloat(viewport.width), GLfloat(viewport.height))
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        glBindVertexArray(0)

        // Restore SceneKit default states
        glEnable(GLenum(GL_DEPTH_TEST))

        // Update the fade factor
        fadeFactor = max(0, min(1, fadeFactor + fadeFactorDelta))
    }
}
