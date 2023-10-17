/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2023, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa
import UniformTypeIdentifiers

@main
class ApplicationDelegate: NSObject, NSApplicationDelegate
{
    private var controllers: [ LottieWindowController ] = []

    func applicationDidFinishLaunching( _ notification: Notification )
    {
        if let plist    = Bundle.main.path( forResource: "Defaults", ofType: "plist" ),
           let data     = try? Data( contentsOf: URL( filePath: plist ) ),
           let defaults = try? PropertyListSerialization.propertyList( from: data, format: nil ) as? [ String: Any ]
        {
            UserDefaults.standard.register( defaults: defaults )
        }

        NotificationCenter.default.addObserver( forName: NSWindow.willCloseNotification, object: nil, queue: nil )
        {
            notification in self.controllers.removeAll { $0.window == notification.object as? NSWindow }
        }
        self.newDocument( nil )
    }

    @discardableResult
    private func createNewWindow() -> LottieWindowController
    {
        let controller = LottieWindowController()

        if let keyWindow = NSApp.keyWindow, keyWindow.windowController is LottieWindowController, let window = controller.window
        {
            window.setFrameOrigin( NSPoint( x: keyWindow.frame.origin.x + 20, y: keyWindow.frame.origin.y - 20 ) )
        }
        else
        {
            controller.window?.center()
        }

        controller.window?.makeKeyAndOrderFront( nil )
        self.controllers.append( controller )

        return controller
    }

    @IBAction
    public func newDocument( _ sender: Any? )
    {
        self.createNewWindow()
    }

    @IBAction
    public func openDocument( _ sender: Any? )
    {
        let panel                           = NSOpenPanel()
        panel.canChooseFiles                = true
        panel.canChooseDirectories          = true
        panel.allowsMultipleSelection       = true
        panel.canDownloadUbiquitousContents = true
        panel.allowedContentTypes           = [ .json ]

        guard panel.runModal() == .OK
        else
        {
            return
        }

        if let key = NSApp.keyWindow?.windowController as? LottieWindowController, key.hasFiles == false
        {
            key.open( urls: panel.urls )
        }
        else
        {
            self.createNewWindow().open( urls: panel.urls )
        }
    }

    @IBAction
    public func invertAppearance( _ sender: Any? )
    {
        if NSApp.effectiveAppearance.name == .aqua
        {
            NSApp.appearance = NSAppearance( named: .darkAqua )
        }
        else if NSApp.effectiveAppearance.name == .darkAqua
        {
            NSApp.appearance = NSAppearance( named: .aqua )
        }
        else if NSApp.effectiveAppearance.name == .accessibilityHighContrastAqua
        {
            NSApp.appearance = NSAppearance( named: .accessibilityHighContrastDarkAqua )
        }
        else if NSApp.effectiveAppearance.name == .accessibilityHighContrastDarkAqua
        {
            NSApp.appearance = NSAppearance( named: .accessibilityHighContrastAqua )
        }
        else if NSApp.effectiveAppearance.name == .vibrantLight
        {
            NSApp.appearance = NSAppearance( named: .vibrantDark )
        }
        else if NSApp.effectiveAppearance.name == .vibrantDark
        {
            NSApp.appearance = NSAppearance( named: .vibrantLight )
        }
        else if NSApp.effectiveAppearance.name == .accessibilityHighContrastVibrantLight
        {
            NSApp.appearance = NSAppearance( named: .accessibilityHighContrastVibrantDark )
        }
        else if NSApp.effectiveAppearance.name == .accessibilityHighContrastVibrantDark
        {
            NSApp.appearance = NSAppearance( named: .accessibilityHighContrastVibrantLight )
        }
    }
}
