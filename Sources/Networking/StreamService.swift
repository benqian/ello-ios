//
//  StreamService.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

typealias StreamSuccessCompletion = (streamables: [Streamable]) -> ()
typealias StreamFailureCompletion = (error: NSError, statusCode:Int?) -> ()

typealias PostSuccessCompletion = (post: Post) -> ()
typealias PostFailureCompletion = (error: NSError, statusCode:Int?) -> ()


typealias CommentsSuccessCompletion = (streamables: [Streamable]) -> ()
typealias CommentsFailureCompletion = (error: NSError, statusCode:Int?) -> ()

class StreamService: NSObject {

    func loadStream(endpoint:ElloAPI, success: StreamSuccessCompletion, failure: StreamFailureCompletion?) {
        switch endpoint {
        case .UserStream: parseUserStream(endpoint, success: success, failure: failure)
        default: parseActivities(endpoint, success: success, failure: failure)
        }
    }

    func parseUserStream(endpoint: ElloAPI, success: StreamSuccessCompletion, failure: StreamFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.UsersType,
            success: { data in
                if let user = data as? User {
                    var streamables:[Streamable] = user.posts.map({ post -> Streamable in
                        return post as Post
                    })
                    success(streamables: streamables)
                }
            },
            failure: failure
        )
    }

    func parseActivities(endpoint: ElloAPI, success: StreamSuccessCompletion, failure: StreamFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.ActivitiesType,
            success: { (data) -> () in
                if let activities:[JSONAble] = data as? [JSONAble] {
                    var posts : [Streamable] = []
                    for jsonable in activities {
                        if let activity:Activity = jsonable as? Activity {
                            if let post = activity.subject as? Post {
                                posts.append(post)
                            }
                        }
                    }
                    success(streamables: posts)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
    
    func loadMoreCommentsForPost(postID:String, success: CommentsSuccessCompletion, failure: CommentsFailureCompletion?) {
        let endpoint: ElloAPI = .PostComments(postId: postID)
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.CommentsType,
            success: { data in
                if let comments:[Comment] = data as? [Comment] {
                    let streamables:[Streamable] = comments.map({return $0 as Streamable})
                    success(streamables: streamables)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
