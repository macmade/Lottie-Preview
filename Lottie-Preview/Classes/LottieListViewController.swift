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
import Lottie

class LottieListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    @IBOutlet private var arrayController: NSArrayController?
    @IBOutlet private var tableView:       NSTableView?
    @IBOutlet private var dropView:        DropView?
    @IBOutlet private var container:       NSView?
    @IBOutlet private var searchField:     NSSearchField?

    private var selectionObserver: NSKeyValueObservation?
    private var controller:        LottieViewController?

    override var nibName: NSNib.Name?
    {
        "LottieListViewController"
    }

    public var hasFiles: Bool
    {
        ( ( self.arrayController?.content as? [ Any ] )?.isEmpty ?? true ) == false
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.arrayController?.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ) ]

        self.dropView?.onDrag = { [ weak self ] in self?.validateDrag( urls: $0 ) ?? false }
        self.dropView?.onDrop = { [ weak self ] in self?.performDrop(  urls: $0 ) ?? false }

        self.selectionObserver = self.arrayController?.observe( \.selectedObjects )
        {
            [ weak self ] _, _ in guard let file = self?.arrayController?.selectedObjects.first as? LottieFile
            else
            {
                return
            }

            self?.show( file: file )
        }
    }

    @IBAction
    public func performFindPanelAction( _ sender: Any )
    {
        self.view.window?.makeFirstResponder( self.searchField )
    }

    public func open( urls: [ URL ] )
    {
        self.files( from: urls ).forEach
        {
            self.arrayController?.addObject( $0 )
        }
    }

    private func show( file: LottieFile )
    {
        self.container?.subviews.forEach { $0.removeFromSuperview() }

        let controller  = LottieViewController( file: file )
        self.controller = controller

        self.container?.addFillingSubview( controller.view )
    }

    private func validateDrag( urls: [ URL ] ) -> Bool
    {
        urls.contains
        {
            var isDirectory = ObjCBool( false )

            if FileManager.default.fileExists( atPath: $0.path( percentEncoded: false ), isDirectory: &isDirectory ), isDirectory.boolValue
            {
                return true
            }

            return $0.pathExtension == "json"
        }
    }

    private func performDrop( urls: [ URL ] ) -> Bool
    {
        let files = self.files( from: urls )

        files.forEach
        {
            self.arrayController?.addObject( $0 )
        }

        return files.isEmpty == false
    }

    private func files( from urls: [ URL ] ) -> [ LottieFile ]
    {
        urls.reduce( into: [ URL ]() )
        {
            var isDirectory = ObjCBool( false )

            if FileManager.default.fileExists( atPath: $1.path( percentEncoded: false ), isDirectory: &isDirectory ), isDirectory.boolValue
            {
                $0.append( contentsOf: self.files( in: $1 ) )
            }
            else if $1.pathExtension == "json"
            {
                $0.append( $1 )
            }
        }
        .compactMap
        {
            LottieFile( url: $0 )
        }
    }

    private func files( in directory: URL ) -> [ URL ]
    {
        let files = try? FileManager.default.contentsOfDirectory( atPath: directory.path( percentEncoded: false ) ).reduce( into: [ URL ]() )
        {
            let url         = directory.appendingPathComponent( $1 )
            var isDirectory = ObjCBool( false )

            if FileManager.default.fileExists( atPath: url.path( percentEncoded: false ), isDirectory: &isDirectory ), isDirectory.boolValue
            {
                $0.append( contentsOf: self.files( in: url ) )
            }
            else if url.pathExtension == "json"
            {
                $0.append( url )
            }
        }

        return files ?? []
    }
}
