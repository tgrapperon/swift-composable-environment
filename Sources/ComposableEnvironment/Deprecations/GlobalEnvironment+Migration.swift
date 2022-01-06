@available(
  *, deprecated,
  message:
    """
  If you are transitioning from `GlobalEnvironment`, you should make sure that is type is a \
  subclass of `ComposableEnvironment`.
  
  If your environment is a `struct`, replacing this by `class` should allow the project to build \
  and run again as a temporary workaround.

  If you are not transitioning from `GlobalEnvironment`, you should not have to use this type \
  at all. It is only provided to help transitioning projects from `GlobalEnvironment` to \
  `ComposableEnvironment`.
  """
)
open class GlobalEnvironment: ComposableEnvironment {
  public required init() {}
}

@available(
  *, deprecated,
  message:
    """
  If you are transitioning from `GlobalEnvironment`, you should make sure that is type is a \
  subclass of `ComposableEnvironment`.
  
  If your environment is a `struct`, replacing this by `class` should allow the project to build \
  and run again as a temporary workaround.

  If you are not transitioning from `GlobalEnvironment`, you should not have to use this type \
  at all. It is only provided to help transitioning projects from `GlobalEnvironment` to \
  `ComposableEnvironment`.
  """
)
open class GlobalDependenciesAccessing: ComposableEnvironment {
  public required init() {}
}
