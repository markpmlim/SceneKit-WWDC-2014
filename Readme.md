The original SceneKit Session WWDC 2014 demo was written by Apple and made available online.


This project is a Swift 3.0 port of the above demo and is developed with XCode 8.3.2 with a deployment target of macOS 10.10 (Yosemite).

The rendering of some slides might cause the demo to crash if this port is run on a computer with a macOS version which uses Metal as its default renderingAPI. 


Note: the renderingAPI is set to OpenGL by adding a key named "PrefersOpenGL"ù to the demo's info.plist.


The compiled program will run without problems on macOS 10.10.x (Yosemite).


Note: The Chapter 2 Slide (APPLSlideChapter2) in the Objective-C version of the demo is not displayed. So the Swift version does not have a APPLSlideChapter2.swift file.


Comments: So far, only 2 slides will crash viz. slide #33 step 4, slide #46 step 1 if macOS 10.12.x or later is the boot OS.  