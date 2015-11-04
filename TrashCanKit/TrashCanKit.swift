import Foundation
import RequestKit

let bitbucketBaseURL = "https://bitbucket.org/api/2.0"
let bitbucketWebURL = "https://bitbucket.org"
let BitbucketErrorDomain = "com.nerdishbynature.bitbucket.error"

public struct TrashCanKit {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}

internal extension Router {
    internal var URLRequest: NSURLRequest? {
        return request()
    }
}
