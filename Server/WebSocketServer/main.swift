//
//  main.swift
//  WebSocketServer
//
//  Created by Kristaps Grinbergs on 13/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

import NIO
import NIOHTTP1
import NIOWebSocket
import WebSocketKit

let upgradePipelineHandler: (Channel, HTTPRequestHead) -> EventLoopFuture<Void> = { channel, req in
  WebSocket.server(on: channel) { ws in
    ws.send("You have connected to WebSocket")
    
    ws.onText { ws, string in
      print("received")
      ws.send(string.trimmingCharacters(in: .whitespacesAndNewlines).reversed())
    }
    
    ws.onBinary { ws, buffer in
      print(buffer)
    }
    
    ws.onClose.whenSuccess { value in
      print("onClose")
    }
  }
}

var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
let port = Int.random(in: 8000..<9000)

let promise = eventLoopGroup.next().makePromise(of: String.self)

let server = try ServerBootstrap(group: eventLoopGroup).childChannelInitializer { channel in
  let webSocket = NIOWebSocketServerUpgrader(
    shouldUpgrade: { channel, req in
      return channel.eventLoop.makeSucceededFuture([:])
  },
    upgradePipelineHandler: upgradePipelineHandler
  )
  
  return channel.pipeline.configureHTTPServerPipeline(
    withServerUpgrade: (
      upgraders: [webSocket],
      completionHandler: { ctx in
        // complete
    })
  )
}.bind(host: "localhost", port: port).wait()

_ = try promise.futureResult.wait()
try server.close(mode: .all).wait()
