import ComposableEnvironment
import ComposableArchitecture

// MARK: - EventHandlingScheduler

// We keep this naming for the case if you want to use some background scheduler
// for your store events for some reason
private enum EventHandlingSchedulerKey: DependencyKey {
  public static var defaultValue: NoOptionsSchedulerOf<DispatchQueue> {
    UIScheduler.shared.eraseToAnyScheduler()
  }
}

extension ComposableDependencies {
  public var eventHandlingScheduler: NoOptionsSchedulerOf<DispatchQueue> {
    get { self[EventHandlingSchedulerKey.self] }
    set { self[EventHandlingSchedulerKey.self] = newValue }
  }
}

// MARK: - GlobalSchedulers

private enum GlobalSchedulersKey: DependencyKey {
  public static var defaultValue: GlobalSchedulersClient { .live }
}

extension ComposableDependencies {
  public var globalSchedulers: GlobalSchedulersClient {
    get { self[GlobalSchedulersKey.self] }
    set { self[GlobalSchedulersKey.self] = newValue }
  }
}

public final class StoreSchedulers: ComposableEnvironment {
  @Dependency(\.eventHandlingScheduler)
  public var main
  
  @Dependency(\.globalSchedulers)
  public var background
}
