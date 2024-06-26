import Foundation
import RequestKit

public typealias Response<S> = Result<S, Swift.Error>

public func WTF(_ msg: String, code: Int = 0) -> Error {
    NSError(code: code, message: msg)
}

internal extension NSError {
    convenience init(code: Int, message: String) {
        let userInfo: [String: String] = [NSLocalizedDescriptionKey:message]
        self.init(domain: "FTW", code: code, userInfo: userInfo)
    }
}

extension NSError {
    static func notImplemented(_ msg: String) -> Error {
        WTF("not implemented: " + msg)
    }
}

struct UserJSON : Encodable, Decodable {
    let uuid: String?
    let username: String?
    let display_name: String?
}

@objc open class User: NSObject {
    public let id: String
    open var login: String?
    open var name: String?

    init(_ json: UserJSON) {
        if let id = json.uuid {
            self.id = id
            login = json.username
            name = json.display_name
        } else {
            id = "-1"
        }
    }
    
    public init(_ json: [String: AnyObject]) {
        if let id = json["uuid"] as? String {
            self.id = id
            login = json["username"] as? String
            name = json["display_name"] as? String
        } else {
            id = "-1"
        }
    }
}

struct EmailJSON : Encodable, Decodable {
    let email: String?
    let is_primary: Bool?
    let is_confirmed: Bool?
    let type: String?
}

@objc open class Email: NSObject {
    public let isPrimary: Bool
    public let isConfirmed: Bool
    open var type: String?
    open var email: String?

    init(_ json: EmailJSON) {
        if let _ = json.email {
            isPrimary = json.is_primary ?? false
            isConfirmed = json.is_confirmed ?? false
            type = json.type
            email = json.email
        } else {
            isPrimary = false
            isConfirmed = false
        }
        super.init()
    }
    
    public init(json: [String: AnyObject]) {
        if let _ = json["email"] as? String {
            isPrimary = json["is_primary"] as? Bool ?? false
            isConfirmed = json["is_confirmed"] as? Bool ?? false
            type = json["type"] as? String
            email = json["email"] as? String
        } else {
            isPrimary = false
            isConfirmed = false
        }
        super.init()
    }
}

public extension TrashCanKit {
    func me(_ session: RequestKitURLSession = URLSession.shared, completion: @escaping (_ response: Response<User>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.readAuthenticatedUser(configuration)
        return router.load(expectedResultType: UserJSON.self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let parsedUser = User(json)
                    completion(Response.success(parsedUser))
                }
            }
        }
    }

    func emails(_ session: RequestKitURLSession = URLSession.shared, completion: @escaping (_ response: Response<[Email]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.readEmails(configuration)
        return router.load(expectedResultType: EmailJSON.self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                completion(Response.failure(NSError.notImplemented("email")))
            }
        }
//        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
//            if let error = error {
//                completion(Response.failure(error))
//            } else {
//                if let json = json, let values = json["values"] as? [[String: AnyObject]] {
//                    let emails = values.map({ Email(json: $0) })
//                    completion(Response.success(emails))
//                }
//            }
//        }
    }
}

// MARK: Router

public enum UserRouter: Router {
    case readAuthenticatedUser(Configuration)
    case readEmails(Configuration)

    public var configuration: Configuration {
        switch self {
        case .readAuthenticatedUser(let config): return config
        case .readEmails(let config): return config
        }
    }

    public var method: HTTPMethod {
        return .GET
    }

    public var encoding: HTTPEncoding {
        return .url
    }

    public var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case .readEmails:
            return "user/emails"
        }
    }

    public var params: [String: Any] {
        return [:]
    }
}
