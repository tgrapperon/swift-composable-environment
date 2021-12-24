import Combine
import Foundation

public struct GlobalSchedulersClient {
  public init(
    _ scheduler: @escaping (DispatchQoS.QoSClass) -> NoOptionsSchedulerOf<DispatchQueue>
  ) {
    self.scheduler = scheduler
  }
  
  public var scheduler: (DispatchQoS.QoSClass) -> NoOptionsSchedulerOf<DispatchQueue>
  
  public func callAsFunction(
    qos: DispatchQoS.QoSClass = .default
  ) -> NoOptionsSchedulerOf<DispatchQueue> {
    return scheduler(qos)
  }
}

extension GlobalSchedulersClient {
  public static let live: GlobalSchedulersClient = .init { qos in
    return DispatchQueue.global(qos: qos).ignoreOptions()
  }
}
