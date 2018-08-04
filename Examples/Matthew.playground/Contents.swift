import UIKit
import WebKit
import PlaygroundSupport
import Hype

// ========================================
//
// -----------matthewramsden.com-----------
//
// ========================================

// ========================================
//
// ---------------Operators----------------
//
// ========================================

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}
infix operator |> : ForwardApplication
func |> <A, B> (lhs: A, rhs: (A) -> (B)) -> B { return rhs(lhs) }

precedencegroup BackwardApplication {
    associativity: right
    lowerThan: AdditionPrecedence
    higherThan: AssignmentPrecedence
}
infix operator <| : BackwardApplication
func <| <A, B> (lhs: (A) -> (B), rhs: A) -> B { return lhs(rhs) }

precedencegroup ForwardComposition {
    associativity: left
    higherThan: AdditionPrecedence
    lowerThan: MultiplicationPrecedence
}
infix operator >>> : ForwardComposition
func >>> <A, B, C>(_ lhs: @escaping (A) -> B, _ rhs: @escaping (B) -> C) -> (A) -> C {
    return { rhs(lhs($0)) }
}

// ========================================
//
// ----------------Models------------------
//
// ========================================

struct Link {
    let text: String
    let url: String
}

let links = [
    Link(text: "First Link", url: "https://blah1"),
    Link(text: "Second Link", url: "https://blah2")
]

let linkAD = { url in
    return attributeDecorator([
        .href(url: url)
        ])
}

let linkComponent2: Component<Link> = { link in
    a(link.text)
        |> attributeDecorator([.href(url: link.url)])
        |> attributeDecorator([.class(value: "link")])
}

// App

struct App {
    let link: Link
    let name: String
    let desc: String
}

let mmaWorkout = App(
    link: Link(text: "MMA Workout", url: "https://etsy.com"),
    name: "MMA Workout",
    desc: "Available for iPhone and Apple Watch/"
)

let mmaBible = App(
    link: Link(text: "MMA Bible", url: "https://instagr.am"),
    name: "MMA Bible",
    desc: "Available for iPhone and Apple Watch."
)

let apps = [mmaWorkout, mmaBible]

let appComponent: Component<App> = { app in
    div {
        h3(app.name) +
            p(app.desc) +
            linkComponent2(app.link)
    }
}

let appsComponent = listComponent <| appComponent

// Dev

struct Developer {
    let link: Link
    let name: String
    let desc: String
}

let matthew = Developer(link: Link(text: "github",
                                   url: "github.com/lllovesmatt"),
                        name: "Matthew Ramsden",
                        desc: "Matthew designs and develops iOS apps."
)

let devs = [matthew]

let devComponent: Component<Developer> = { dev in
    div {
        h4(dev.name) +
        p(dev.desc) +
        linkComponent2(dev.link)
    }
}

let devsComponent = listComponent <| devComponent

// TODO: get devComponent and appComponent together

// ========================================
//
// --------------Playground----------------
//
// ========================================

let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 700/1.5, height: 1000/1.5))
webView.loadHTMLString(render(appsComponent(apps)), baseURL: nil)
PlaygroundPage.current.liveView = webView
