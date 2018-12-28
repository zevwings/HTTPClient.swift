//
//  HTTPTask.swift
//  HTTPClient
//
//  Created by 张伟 on 2018/12/12.
//  Copyright © 2018 zevwings. All rights reserved.
//

public protocol Task {
    
    /// 任务是否取消
    var isCancelled: Bool { get }
    
    /// 启动/恢复任务
    func resume()
    
    /// 暂停任务
    func suspend()
    
    /// 取消任务
    func cancel()
}

public final class HTTPTask: Task {
    
    public typealias CancelAction = () -> Void
    
    public private(set) var isCancelled: Bool = false
    
    private let request: AlamofireRequest
    
    private let cancelAction: CancelAction
    
    private var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    internal convenience init(_ request: AlamofireRequest) {
        self.init(request) {
            request.cancel()
        }
    }
    
    internal init(_ request: AlamofireRequest, action: @escaping CancelAction) {
        self.request = request
        self.cancelAction = action
    }
    
    public func resume() {
        request.resume()
    }
    
    public func suspend() {
        request.suspend()
    }
    
    public func cancel() {
        _ = lock.wait(timeout: DispatchTime.distantFuture)
        defer { lock.signal() }
        guard !isCancelled else {
            return
        }
        isCancelled = true
        cancelAction()
    }
}

extension HTTPTask: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return request.request?.description ?? "HTTPTask"
    }
    
    public var debugDescription: String {
        return request.request?.debugDescription ?? "HTTPTask"
    }
}
