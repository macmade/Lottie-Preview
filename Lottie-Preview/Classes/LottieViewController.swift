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

class LottieViewController: NSViewController
{
    @objc private dynamic var file:      LottieFile
    @objc private dynamic var animation: LottieAnimationView
    @objc private dynamic var playing  = false

    @objc private dynamic var loop = UserDefaults.standard.bool( forKey: "loop" )
    {
        didSet
        {
            self.animation.loopMode  = self.loop ? .loop : .playOnce

            UserDefaults.standard.setValue( self.loop, forKey: "loop" )
        }
    }

    @objc private dynamic var speed = 1.0
    {
        didSet
        {
            self.animation.animationSpeed = self.speed
        }
    }

    init( file: LottieFile )
    {
        self.file      = file
        self.animation = LottieAnimationView( filePath: file.url.path( percentEncoded: false ) )

        super.init( nibName: nil, bundle: nil )
    }

    required init?( coder: NSCoder )
    {
        nil
    }

    override var nibName: NSNib.Name?
    {
        "LottieViewController"
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.animation.setContentCompressionResistancePriority( .defaultLow, for: .horizontal )
        self.animation.setContentCompressionResistancePriority( .defaultLow, for: .vertical )
        self.view.addFillingSubview( self.animation )
    }

    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.play( nil )
    }

    @IBAction
    private func play( _ sender: Any? )
    {
        guard self.playing == false
        else
        {
            NSSound.beep()

            return
        }

        self.playing            = true
        self.animation.loopMode = self.loop ? .loop : .playOnce

        self.animation.play()
        {
            _ in self.playing = false
        }
    }

    @IBAction
    private func pause( _ sender: Any? )
    {
        guard self.playing
        else
        {
            NSSound.beep()

            return
        }

        self.playing = false

        self.animation.pause()
    }
}
