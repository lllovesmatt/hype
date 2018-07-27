import UIKit
import WebKit
import PlaygroundSupport
import Hype

/*:
 The actual https://matthewramsden.com website.
 */

//=================
//-----------------
//---Operators-----
//-----------------
//=================

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

/*:
 ## Models
 */

struct Post {
    let title: String
    let content: String
}

let posts = [
    Post(title: "Hello world", content: "My first post."),
    Post(title: "Server Side Swift", content: "Swift is pretty neat!")
]

struct Link {
    let text: String
    let url: String
}

let links = [
    Link(text: "First Link", url: "https://blah1"),
    Link(text: "Second Link", url: "https://blah2")
]

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

let appComponent: Component<App> = { app in
    div {
        h3(app.name) +
            p(app.desc) +
            linkComponent2(app.link)
    }
}

let appsComponent = listComponent <| appComponent

render(
    linkAD("http://") <| a("test")
)

render(
    appsComponent(apps)
)


//let dom = html {
//    body {
//        pre("""
//        MMA Workout
//        Available for iPhone and Apple Watch.
//
//        MMA Bible
//        Available for iPhone and Apple Watch.
//
//        Matthew Ramsden
//        Matthew designs and develops iOS apps.
//        Github
//        """)
//    }
//}

let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 700/1.5, height: 1000/1.5))
//webView.loadHTMLString(render(dom), baseURL: nil)
webView.loadHTMLString(render(appsComponent(apps)), baseURL: nil)
PlaygroundPage.current.liveView = webView
