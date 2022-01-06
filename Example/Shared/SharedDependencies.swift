import ComposableArchitecture
import ComposableEnvironment

// mainQueue dependency:
private struct MainQueueKey: DependencyKey {
  static var defaultValue: AnySchedulerOf<DispatchQueue> {
    .main
  }
}

extension Dependencies {
  public var mainQueue: AnySchedulerOf<DispatchQueue> {
    get { self[MainQueueKey.self] }
    set { self[MainQueueKey.self] = newValue }
  }
}

// backgroundQueue dependency:
private struct BackgroundQueueKey: DependencyKey {
  static var defaultValue: AnySchedulerOf<DispatchQueue> {
    DispatchQueue.global().eraseToAnyScheduler()
  }
}

extension Dependencies {
  public var backgroundQueue: AnySchedulerOf<DispatchQueue> {
    get { self[BackgroundQueueKey.self] }
    set { self[BackgroundQueueKey.self] = newValue }
  }
}
