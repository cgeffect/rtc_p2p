//
//  SocketIO.swift
//  rtc_macos
//
//  Created by Jason on 2025/3/12.
//

import Foundation
import SocketIO

//enum Role:String {
//    case None = "None"
//    case Caller = "Caller"
//    case Receiver = "Receiver"
//}
// MARK: - Delegate
@objc public protocol SignalClientDelegate: AnyObject {
    @objc func didReceiveOffer(_ offer: [String: Any])
    @objc func didReceiveAnswer(_ answer: [String: Any])
    @objc func didReceiveCandidate(_ candidate: [String: Any])
    @objc func didMessage(_ msg: [String: Any])
}

@objc public class SocketClient: NSObject {
    private var socket: SocketIOClient!
    private var selfId:String = ""
    private var manager:SocketManager!
    private let roomId: String
    private var othersId:[String] = []
//    private var role: Role = .None
    
    @objc public weak var delegate: SignalClientDelegate?

    @objc public init(roomId: String) {
        self.roomId = roomId
        super.init()
        selfId = UUID().uuidString
        setupSocket()
    }
    
    @objc public func setupSocket() {
        // 初始化 Socket.IO 客户端, 监听http://localhost:3000, 记住这个是对方的地址
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!,
                                    config: [.log(true), .compress])
        
        // 获取监听的socket, 下面的监听和发送消息都是对方的
        socket = manager.defaultSocket

        // 监听连接事件
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
//            self.joinRoom()
        }

        socket.on(clientEvent: .error) { data, ack in
            print("socket error")
        }
        // 监听断开连接事件
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }

        // 监听 onJoinRoom, 拿到房间里所有的客户端
        socket.on("onJoinRoom") { [weak self] data, ack in
            guard let offer = data[0] as? [String: Any] else { return }
            self?.othersId.append("")
//            "connections"
//            "data"
//            "you"
        }
        
//        // 监听 Offer, 被叫
//        socket.on("onOffer") { [weak self] data, ack in
//            guard let offer = data[0] as? [String: Any] else { return }
//            self?.delegate?.didReceiveOffer(offer)
//        }
//
//        // 监听 Answer
//        socket.on("onAnswer") { [weak self] data, ack in
//            guard let answer = data[0] as? [String: Any] else { return }
//            self?.delegate?.didReceiveAnswer(answer)
//        }
//
//        // 监听 ICE 候选
//        socket.on("onCandidate") { [weak self] data, ack in
//            guard let candidate = data[0] as? [String: Any] else { return }
//            self?.delegate?.didReceiveCandidate(candidate)
//        }
        
        
        socket.on("onMessage") { [weak self] data, ack in
            guard let candidate = data[0] as? [String: Any] else { return }
            print("onMessage: \(data)")
//            self?.delegate?.didMessage(data)
            // 这里 解析协议, 判断收到的消息的类型, 是offer 还是answer
//            self?.delegate?.didReceiveOffer(candidate)
//            
//            self?.delegate?.didReceiveAnswer(candidate)
//            
//            self?.delegate?.didReceiveCandidate(candidate)
            
            self?.delegate?.didMessage(candidate)
        }
        
        // 连接到服务器
        socket.connect(timeoutAfter: 0) {
            print("connect success!!!");
        }
    }
    
    @objc public func joinRoom(map:[String: Any]) {
//        let jsonObject: [String: String] = [
//            "roomId": roomId,
//            "clientId": selfId
//        ]
        // 发送自己的信息到server
        socket.emit("joinRoom", map)
        print("Joined room: \(map)")
    }

    @objc public func leaveRoom(map:[String: Any]) {
//        let jsonObject: [String: String] = [
//            "roomId": roomId,
//            "clientId": selfId
//        ]
        socket.emit("leaveRoom", map)
        print("Left room: \(map)")
    }

    @objc public func sendMessage(_ msg: [String: Any]) {
        // 根据type区分
        sendOffer(msg)
        sendAnswer(msg)
    }
    
    @objc public func setSocketDelegate(_ delegate: SignalClientDelegate) {
        self.delegate = delegate
    }
}

extension SocketClient {
    @objc public func sendOffer(_ offer: [String: Any]) {
//        let jsonObject: [String: Any] = [
//            "from": selfId,
//            "to": othersId,
//            "roomId": roomId,
//            "targets": othersId,
//            "payload": offer,
//            "type": "offer"
//        ]
        socket.emit("onMessage", offer)
    }

    @objc public func sendAnswer(_ answer: [String: Any]) {
//        let jsonObject: [String: Any] = [
//            "from": selfId,
//            "to": othersId,
//            "roomId": roomId,
//            "targets": othersId,
//            "payload": answer,
//            "type": "answer"
//        ]
        socket.emit("onMessage", answer)
    }

    @objc public func sendCandidate(_ candidate: [String: Any]) {
//        let jsonObject: [String: Any] = [
//            "from": selfId,
//            "to": othersId,
//            "roomId": roomId,
//            "targets": othersId,
//            "type": "candidate",
//            "payload": candidate
//        ]
        socket.emit("onMessage", candidate)
    }
}
extension SocketClient {
//    @objc public func setRole(_ role_:String) {
//        if (role_ == Role.Caller.rawValue) {
//            role = Role.Caller
//        } else if (role_ == Role.Receiver.rawValue) {
//            role = Role.Receiver
//        }
//    }
//    
//    @objc public func getRole() -> String {
//        return role.rawValue
//    }
    
    func convertJsonToString(jsonObject: [String: Any]) -> String {
        // 将 Dictionary 转换为 JSON 数据
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
            // 将 JSON 数据转换为字符串
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON String: \(jsonString)")
                return jsonString;
            }
        } else {
            print("Failed to serialize JSON")
        }
        return ""
    }
}
