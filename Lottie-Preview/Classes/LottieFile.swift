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

@objc
class LottieFile: NSObject
{
    @objc public var url:  URL
    @objc public var name: String
    @objc public var icon: NSImage?
    @objc public var size: UInt64

    public init?( url: URL )
    {
        let path        = url.path( percentEncoded: false )
        var isDirectory = ObjCBool( false )

        guard FileManager.default.fileExists( atPath: path, isDirectory: &isDirectory ), isDirectory.boolValue == false
        else
        {
            return nil
        }

        guard let attributes = try? FileManager.default.attributesOfItem( atPath: path )
        else
        {
            return nil
        }

        self.url  = url
        self.name = url.lastPathComponent
        self.icon = NSWorkspace.shared.icon( forFile: path )
        self.size = attributes[ .size ] as? UInt64 ?? 0
    }
}
