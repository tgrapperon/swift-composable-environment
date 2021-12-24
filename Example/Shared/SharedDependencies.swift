import ComposableEnvironment
import ComposableArchitecture

// mainQueue dependency:
private struct MainQueueKey: DependencyKey {
  static var defaultValue: AnySchedulerOf<DispatchQueue> {
    .main
  }
}

public extension Dependencies {
  var mainQueue: AnySchedulerOf<DispatchQueue> {
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

public extension Dependencies {
  var backgroundQueue: AnySchedulerOf<DispatchQueue> {
    get { self[BackgroundQueueKey.self] }
    set { self[BackgroundQueueKey.self] = newValue }
  }
}
