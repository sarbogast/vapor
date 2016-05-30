extension Route {
    /**
        An intermediary object used to group routes by middleware and leading paths
    */
    public struct Link {
        /// The parent to forward requests -- intended to ultimately be Application
        public let parent: RouteBuilder

        /// The leading path to prefix ahead of additional routing
        public let leadingPath: String

        /// The middleware to prefix to all requested routing
        public let scopedMiddleware: [Middleware]
    }
}

extension Route.Link: RouteBuilder {
    public func add(
        middleware: [Middleware],
        method: Request.Method,
        path: String,
        handler: Route.Handler
    ) {
        parent.add(
            middleware: self.scopedMiddleware + middleware,
            method: method,
            path: leadingPath.finish("/") + path,
            handler: handler
        )
    }
}

/**
    An organizational protocol that allows building of routes in separate files.
    
    Add to your application using the add function:
 
         app.add(UserRouteGroup.self)
 
    Or to nest further:
 
         app.add("special-user", UserRouteGroup.self)
 
    Example:
 
         class UserGroup: RouteGroup {
             static func build(builder: RouteBuilder) {
                 builder.grouped("users") { group in
                     group.put(Int.self) { request in
                         return "update user"
                     }
                 }

                 builder.get("utilities", "users", Int.self) { request in
                     return "Test"
                 }
            }
        }
*/
public protocol RouteGroup {
    /**
        When route group is added, this will be called to load routes

        - parameter builder: the route builder to use
    */
    static func build(builder: RouteBuilder)
}


extension RouteBuilder {
    /**
        Add a route group
    */
    public func add(_ group: RouteGroup.Type) {
        group.build(builder: self)
    }

    /**
        Add a route group that is further constrained to leading path
    */
    public func add(_ path: String, _ group: RouteGroup.Type) {
        grouped(path, group.build)
    }
}
