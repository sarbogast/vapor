import libc
import Foundation

extension NSDateFormatter {
    private static func makeRFC1123() -> NSDateFormatter {
        // https://github.com/Fykec/NSDate-RFC1123/blob/master/NSDate%2BRFC1123.swift
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return dateFormatter
    }
}

extension NSDate {
    private func rfc1123() -> String {
        // Using this to cache the date. Formatters take time to load
        struct Formatter {
            static let rfc1123 = NSDateFormatter.makeRFC1123()
        }
        return Formatter.rfc1123.string(from: self)
    }
}

extension Response {
    /**
        Convenience Initializer Error

        Will return 500

        - parameter error: a description of the server error
     */
    public init(error: String) {
        self.init(status: .internalServerError, headers: [:], body: error.data)
    }

    /**
        Convenience Initializer - Html

        - parameter status: http status of response
        - parameter html: the html string to be rendered as a response
     */
    public init(status: Status, html body: String) {
        let html = "<html><meta charset=\"UTF-8\"><body>\(body)</body></html>"
        let headers: Headers = [
            "Content-Type": "text/html"
        ]
        self.init(status: status, headers: headers, body: html.data)
    }

    /**
        Convenience Initializer - Data

        - parameter status: http status
        - parameter data: response bytes
     */
    public init(status: Status, data: Data) {
        self.init(status: status, headers: [:], body: data)
    }

    /**
        Convenience Initializer - Text

        - parameter status: http status
        - parameter text: basic text response
     */
    public init(status: Status, text: String) {
        let headers: Headers = [
            "Content-Type": "text/plain"
        ]
        self.init(status: status, headers: headers, body: text.data)
    }

    /**
        Convenience Initializer

        - parameter status: the http status
        - parameter json: any value that will be attempted to be serialized as json.  Use 'Json' for more complex objects
     */
    public init(status: Status, json: Json) {
        let headers: Headers = [
            "Content-Type": "application/json"
        ]
        self.init(status: status, headers: headers, body: json.data)
    }

    /**
        Creates an empty response with the
        supplied status code.
    */
    public init(status: Status) {
        self.init(status: status, text: "")
    }

    public init(redirect location: String) {
        let headers: Headers = [
            "Location": Headers.Values(location)
        ]
        self.init(status: .movedPermanently, headers: headers, body: [])
    }

    public init(async closure: Stream throws -> Void) {
        self.init(status: .ok, headers: [:], body: closure)
    }

    public static var date: String {
        return NSDate().rfc1123()
    }

    public var cookies: [String: String] {

        get {
            var cookies: [String: String] = [:]

            for value in headers["Set-Cookie"] {
                for cookie in value.split(byString: ";") {
                    var parts = cookie.split(byString: "=")
                    if parts.count >= 2 {
                        cookies[parts[0]] = parts[1]
                    }
                }
            }

            return cookies
        }
        set(newCookies) {
            var cookies: [String] = []

            for (key, value) in newCookies {
                cookies.append("\(key)=\(value)")

            }

            headers["Set-Cookie"] = Headers.Value(cookies.joined(separator: ";"))
        }
    }
}
