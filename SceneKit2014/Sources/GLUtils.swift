/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

This file contains some OpenGL utilities

*/
import SceneKit
import OpenGL

 struct AAPLAttribLocation {
    var index: GLuint = 0
    var name = String()
}

class GLUtils {

    // Compile a GLSL shader - used by APPLSlideDelegateRendering
    class func AAPLCompile(shader: inout GLuint, type: GLenum, file: String) -> Bool {
        var source: String?
        do {
            source = try String(contentsOfFile: file, encoding: .utf8)
        }
        catch _ {
            print("Failed to load shader:", file);
            return false
        }

        //var contents = (source! as NSString).cString(using: String.Encoding.ascii.rawValue)
        //var shaderStringLength = GLint((source! as NSString).length)
        let contents = source!.cString(using: String.Encoding.ascii)    // [CChar]?
        var shaderStringLength = GLint(source!.lengthOfBytes(using: String.Encoding.ascii))

        shader = glCreateShader(type)
        var ptr = UnsafePointer<GLchar>(contents)
        glShaderSource(shader, 1, &ptr, &shaderStringLength)
        glCompileShader(shader)

        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if (status == 0) {
            var length: GLsizei = 0
            var logs = [GLchar](repeating: 0x00, count:1000)
            glGetShaderInfoLog(shader, 1000, &length, &logs)
            print("gl Compile Status: %s", logs)
            glDeleteShader(shader);
            return false
        }

        return true
    }

    class func AAPLLink(program prog: GLuint) -> Bool {
        glLinkProgram(prog)

        var status: GLint = 0
        glGetProgramiv(prog, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            var length: GLsizei = 0
            var logs = [GLchar](repeating: 0x00, count:1000)
            glGetShaderInfoLog(prog, 1000, &length, &logs)
            print("gl Link Status: %s", logs)
            return false
        }
        return true
    }

    // Load, build and link a GLSL program
    // Only 3 types of shaders are supported: vertex, fragment & geometry.
    class func AAPLCreateProgram(withName shaderName: String,
                                 attribLocations: [AAPLAttribLocation]) -> GLuint {

        // Create and compile vertex shader.
        var vertShader: GLuint = 0
        if let vertShaderPathName = Bundle.main.path(forResource: shaderName,
                                                     ofType: "vsh") {
            if !AAPLCompile(shader: &vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertShaderPathName) {
                print("Failed to compile vertex shader");
                return 0
            }
        }

        var fragShader: GLuint = 0
        // Create and compile fragment shader.
        if let fragShaderPathName = Bundle.main.path(forResource: shaderName,
                                                     ofType: "fsh") {
            if !AAPLCompile(shader: &fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShaderPathName) {
                print("Failed to compile fragment shader");
                return 0
            }
        }

        var geomShader: GLuint = 0
        if let geomShaderPathName = Bundle.main.path(forResource: shaderName,
                                                     ofType: "gsh") {
            if !AAPLCompile(shader: &geomShader, type: GLenum(GL_GEOMETRY_SHADER), file: geomShaderPathName) {
                print("Failed to compile geometry shader");
                return 0
            }
        }

        var program = glCreateProgram()
        // Attach vertex shader to program.
        glAttachShader(program, vertShader)

        // Attach fragment shader to program.
        glAttachShader(program, fragShader)

        if geomShader != 0 {
            glAttachShader(program, geomShader)
        }

        // Bind attribute locations.
        // This needs to be done prior to linking.
        var i = 0
        while (true) {
            if (attribLocations[i].name.isEmpty) {
                break   // last attrib is a String with zero length.
            }

            glBindAttribLocation(program, attribLocations[i].index, attribLocations[i].name);
            i += 1
        }

        if geomShader != 0 {
            // configure the geometry shader
            glProgramParameteri(program, GLenum(GL_GEOMETRY_INPUT_TYPE), GL_TRIANGLES)
            glProgramParameteri(program, GLenum(GL_GEOMETRY_OUTPUT_TYPE), GL_TRIANGLE_STRIP)
            glProgramParameteri(program, GLenum(GL_GEOMETRY_VERTICES_OUT), 4)
        }
        // Link program.
        if !AAPLLink(program: program) {
            NSLog("Failed to link program: %d", program);
            
            if (vertShader != 0) {
                glDeleteShader(vertShader)
                vertShader = 0
            }

            if (fragShader != 0) {
                glDeleteShader(fragShader)
                fragShader = 0
            }

            if (geomShader != 0) {
                glDeleteShader(geomShader)
                geomShader = 0;
            }

            if (program != 0) {
                glDeleteProgram(program)
                program = 0
            }
            return 0
        }

        // Release vertex, fragment and geometry shaders.
        if (vertShader != 0) {
            glDetachShader(program, vertShader)
            glDeleteShader(vertShader)
        }

        if (fragShader != 0) {
            glDetachShader(program, fragShader)
            glDeleteShader(fragShader)
        }

        if (geomShader != 0) {
            glDetachShader(program, geomShader)
            glDeleteShader(geomShader)
        }
        return program
    }
}
