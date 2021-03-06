import UIKit
import WebKit
import PlaygroundSupport
import Hype

/*:
 # Statically Typed HTML in Swift
 
 ## Part 3: Components and composition
 
 This is where things get really interesting. How could we represent a component? We kind of did this already in the first playground with the `p` and `div` functions. If we generalize this we can come up with Component type:
 */

typealias Component<T> = (T) -> Node

/*:
 A Component<T> simply takes in some T and returns a node. For a `p` element it is `(String) -> Node` and for a div it is `(Node) -> Node`.
 
 We can use this idea to create a component that represents blog posts:
 */

struct Post {
    let title: String
    let content: String
}

let postComponent: Component<Post> = { post in
    h3(post.title) + p(post.content)
}

render(postComponent(Post(title: "Testing", content: "1 2 3")))

/*:
 And now a component that displays list of posts:
 */

let posts = [
    Post(title: "A", content: "Lorem ipsum."),
    Post(title: "B", content: "Server side Swift isn't so bad."),
    Post(title: "C", content: "Swift is pretty neat!")
]

let postsComponent: Component<[Post]> = { posts in
    Node.siblings(nodes: posts.map(postComponent))
}

render(postsComponent(posts))

/*:
 It works! However, we had to manually map things and then stick them in this `.siblings` node. We can make this more ergonomic by introducing a function that creates a generic "listComponent" for us. This function simply takes a list and a component and then creates a bunch of those components by using the items in the list:
 */

func listComponent<T>(_ component: @escaping Component<T>) -> Component<[T]> {
    return { list in
        Node.siblings(nodes: list.map(component))
    }
}

/*:
 Looks really similar to what we already wrote. Now we can write this:
 */

let postsComponent2 = listComponent(postComponent)

render(postsComponent2(posts))


/*:
 Much cleaner and more expressive IMO.
 
 Now imagine we want to not only render the list of posts using our `postComponent` but we'd also like to wrap it in some div that has some layout and styling. Here is one way we could do that.
 
 Ignore the styling mechanism for now.
 */

let fancyStyle = attributeDecorator(
    [Attribute.custom(key: "style", value: "background-color:#F37")]
)

let fancyPostsComponent: Component<[Post]> = { posts in
    div {
        (listComponent(postComponent))(posts)
    } |> fancyStyle
}

render(fancyPostsComponent(posts))

/*:
 Alternatively, could break this into a few components:
 */

let postsWrapper = { node in
    div { node } |> fancyStyle
}

let fancyPostsComponent2 = { posts in
    postsWrapper((listComponent(postComponent))(posts))
}

render(fancyPostsComponent(posts))

/*:
 I like the idea of breaking things apart into smaller components if I need to but what we have above isn't easy to read. We can introduce a Backward Application operator that clears things up.
 
        f <| g <| x == f(g(x))
 */

infix operator <| : BackwardApplication

let fancyPostsComponent3 = { posts in
    postsWrapper
        <| listComponent(postComponent)
        <| posts
}

/*:
 Let's get concise and use the Forward Composition operator to make this a one-liner. Think about the two Components we have: they are just functions.
 
                       ┌──────────────────────────┐
                       │   these types line up    │
                       └────────────┬─────────────┘
                                    │
                                    ▼
        postsComponent: [Posts] -> Node
        postsWrapper:      │       Node -> Node
                           │                │
                           └──┬─────────────┘
                              │
                              ▼
        composition: [Posts] -> Node
 
 The types line up! We have something that goes from `A -> B` and something that goes from `B -> C`. Math tells us that we can make something now that goes directly from `A -> C`. We can just pass the output of the first function into the input of the second function and then just pretend that whole thing we just described is a single function from `A -> C`
 
 No need to invent our own specialized functions, components, etc. There is a well-known existing operator for this: forward composition operator.
 */

infix operator >>> : ForwardComposition

let fancyPostsComponent4 = listComponent(postComponent) >>> postsWrapper
render(fancyPostsComponent4(posts))

/*:
 I think that is pretty neat. One line of code can express what was taking us many lines of code above. However, we are always making a tradeoff: Is this more readable? Is it easier to understand than the previous examples? Perhaps not if this is your first time seeing these operators. In the end, you need to use the right tool for the job and while forward composition is elegant, it might not make sense for your team or app.
 */
