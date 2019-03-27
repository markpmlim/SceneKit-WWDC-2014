//
//  AppDelegate.swift
//  SceneKit2014
//
//  Created by mark lim pak mun on 21/12/2016.
//  Copyright © 2016 mark lim pak mun. All rights reserved.
//

import IOKit.pwr_mgt
import Cocoa
import IOKit

@NSApplicationMain
class AAPLAppDelegate: NSObject, NSApplicationDelegate, APPLPresentationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var goMenu: NSMenu!
    var presentationViewController: AAPLPresentationViewController?
    var assertionID: IOPMAssertionID = 0
    static var hidden = false

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        // Create a presentation from a .plist file (in Resources folder)
        presentationViewController = AAPLPresentationViewController(contentsOfFile: "Scene Kit Presentation")
        presentationViewController!.delegate = self
        // Populate the 'Go' menu for direct access to slides
        populateGoMenu()

        // Start the presentation
        self.window.contentView?.addSubview(presentationViewController!.presentationView)
        presentationViewController?.presentationView.frame = (self.window.contentView?.bounds)!
        presentationViewController?.presentationView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        presentationViewController?.applicationDidFinishLaunching()
    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // Application specific methods.
    @IBAction func nextSlide(_ sender: AnyObject) {
        presentationViewController?.goToNextSlideStep()
    }

    @IBAction func previousSlide(_ sender: AnyObject) {
        presentationViewController?.goToPreviousSlide()
    }

    @IBAction func goTo(_ sender: NSMenuItem) {
        let index = (sender.representedObject as! NSNumber).uintValue
        presentationViewController!.goToSlide(at: index)
    }

    @IBAction func exportSlidesToImages(_ sender: NSMenuItem) {
        presentationViewController?.exportSlidesToImages(sender)
    }

    @IBAction func exportSlidesToSCN(_ sender: NSMenuItem) {
        presentationViewController?.exportSlidesToSCN(sender)
    }

    @IBAction func autoPlay(_ sender: AnyObject) {
        presentationViewController?.autoPlay(sender)
    }

    @IBAction func toggleCursor(_ sender: AnyObject) {
        if AAPLAppDelegate.hidden {
            NSCursor.unhide()
            AAPLAppDelegate.hidden = false
        }
        else {
            NSCursor.hide()
            AAPLAppDelegate.hidden = true
        }
    }

    // Implementation of APPLPresentationDelegate method.
    func presentationViewController(_ presentationViewController: AAPLPresentationViewController,
                                    willPresentSlideAtIndex slideIndex: UInt,
                                    step: UInt) {

        // Update the window's title depending on the current slide
        if step == 0 {
            self.window.title = "SceneKit slide ".appendingFormat("%ld", slideIndex)
        }
        else {
            self.window.title = "SceneKit slide ".appendingFormat(" %ld step %ld", slideIndex, step)
        }
    }

    // 'Go' menu
    func populateGoMenu() {
        let numSlides = Int(presentationViewController!.numberOfSlides)
        for i in 0..<numSlides {
            let slideName = NSStringFromClass(presentationViewController!.classOfSlide(at: UInt(i))!)
            let prefixName = productModuleName + "AAPLSlide"
            let prefixRange = slideName.range(of: prefixName)
            let title = slideName.replacingCharacters(in: prefixRange!,
                                                      with: String(format:"%lu ", i))
            let item = NSMenuItem(title: title,
                                  action: #selector(AAPLAppDelegate.goTo(_:)),
                                  keyEquivalent: "")
            // associate this menu item with the index i
            item.representedObject = NSNumber(value: i)
            goMenu.addItem(item)
        }
    }

    func disableDisplaySleeping() {
        let reasonForActivity = String("Scene Kit Presentation")! as CFString
        IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                    IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                    reasonForActivity,
                                    &assertionID);
    }

    func enableDisplaySleeping() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID);
        }
    }
}

