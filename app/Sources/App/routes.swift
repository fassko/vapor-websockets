import Vapor
import NIOWebSocket
import NIO
import NIOHTTP1
import WebSocketKit

import WebSocketKit

func routes(_ app: Application) throws {
  
  app.get("ws") { request -> String in
    let url = "wss://echo.websocket.org"
    let _ = WebSocket.connect(to: url, on: app.eventLoopGroup) { ws in
      ws.onText { ws, text in
        print(text)
      }
      
      ws.send("Hello")
    }
    
    return "Hello"
  }
  
  app.webSocket("") { request, ws in
    ws.send("You have been connected to WebSockets")
    
    ws.onText { ws, string in
      ws.send(string.trimmingCharacters(in: .whitespacesAndNewlines).reversed())
    }
    
    ws.onClose.whenComplete { result in
      switch result {
      case .success():
        print("Closed")
      case .failure(let error):
        print("Failed to close connection \(error)")
      }
    }
  }
}
