//
//  main.swift
//  WebSocketClient
//
//  Created by Kristaps Grinbergs on 13/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

import NIO
import NIOHTTP1
import NIOWebSocket
import WebSocketKit

var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
 
let port: Int = 8080
let promise = eventLoopGroup.next().makePromise(of: String.self)
WebSocket.connect(to: "ws://localhost:\(port)", on: eventLoopGroup) { ws in
  ws.send("hello")
  ws.onText { ws, string in
    print(string)
  }
}.cascadeFailure(to: promise)
 
_  = try promise.futureResult.wait()
