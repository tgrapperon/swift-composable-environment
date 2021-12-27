@available(*, deprecated, message: """
  If you are transitioning from `ComposableEnvironment`, you should replace this class by a type \
  conforming to `GlobalEnvironment` or `GlobalDependenciesAccessing`. Please make sure that you \
  are not overriding dependencies mid-chain, as all dependencies are shared globally when using \
  `GlobalEnvironment`. If your project depends on mid-chain dependencies overrides, using \
  `GlobalEnvironment` will likely produce incoherent results. In this case, you should continue \
  using `ComposableEnvironment`.
  
  If you are not transitioning from `ComposableEnvironment`, you should not have to use this type \
  at all. It is only provided to help transitioning projects from `ComposableEnvironment` to \
  `GlobalEnvironment`.
  """)
open class ComposableEnvironment: GlobalEnvironment {
  public required init() {}
}
