import UIKit
import WebKit
import PlaygroundSupport
import Hype

/*:
 The actual https://matthewramsden.com website.
 */

let dom = html {
    body {
        pre("""
        MMA Workout
        Available for iPhone and Apple Watch.

        MMA Bible
        Available for iPhone and Apple Watch.

        Matthew Ramsden
        Matthew designs and develops iOS apps.
        Github
        """)
    }
}

let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 700/1.5, height: 1000/1.5))
webView.loadHTMLString(render(dom), baseURL: nil)
PlaygroundPage.current.liveView = webView
