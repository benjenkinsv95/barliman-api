//
//  AppDelegate.swift
//  Barliman
//
//  Created by William Byrd on 5/14/16.
//  Copyright © 2016 William E. Byrd.
//  Released under MIT License (see LICENSE file)

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var semanticsWindowController: SemanticsWindowController?
    var editorWindowController: EditorWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create window controllers with XIB files of the same name
        let semanticsWindowController = SemanticsWindowController()
        let editorWindowController = EditorWindowController()

        semanticsWindowController.editorWindowController = editorWindowController
        editorWindowController.semanticsWindowController = semanticsWindowController
        
        // Put the windows of the controllers on screen
        semanticsWindowController.showWindow(self)
        editorWindowController.showWindow(self)
        
        // Set the property to point to the window controllers
        self.semanticsWindowController = semanticsWindowController
        self.editorWindowController = editorWindowController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        editorWindowController!.cleanup()
        semanticsWindowController!.cleanup()
    }
    
}
