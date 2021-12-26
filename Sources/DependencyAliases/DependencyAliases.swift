import Foundation

public struct DependencyAliases {
  var aliases: [AnyHashable: AnyHashable] = [:]

  public init() {}

  public mutating func clear() {
    aliases.removeAll()
  }

  public mutating func alias<T>(dependency: T, to default: T) where T: Hashable {
    if let existingForDefault = aliases[`default`] as? T {
      aliases[dependency] = existingForDefault
    } else {
      aliases[dependency] = `default`
    }
  }

  public func standardAlias<T>(for dependency: T) -> T where T: Hashable {
    if aliases.isEmpty { return dependency }
    return path(for: dependency).last ?? dependency
  }

  func path<T>(for dependency: T) -> [T] where T: Hashable {
    var path = [dependency]
    if aliases.isEmpty { return path }
    var dependency = dependency
    while let alias = aliases[dependency] as? T {
      guard !path.contains(alias) else {
        breakpoint("""
        ---
        Warning: Cyclic dependency aliases for \(String(describing: T.self))

        A cycle was detected in the graph of dependency aliases. As a consequence, the depedency
        providing the default value is ambiguous.

        Please review your dependency aliases to make aliases for \(String(describing: T.self))
        form a directed graph.
        """)
        break
      }
      path.append(alias)
      dependency = alias
    }
    return path
  }

  public func aliasing<T>(with dependency: T) -> Set<T> where T: Hashable {
    if aliases.isEmpty { return [dependency] }
    let canonical = self.standardAlias(for: dependency)
    return Set(
      aliases
        .filter { $0.key is T }
        .map { path(for: $0.key as! T) }
        .filter { $0.contains(canonical) || $0.contains(dependency) }
        .flatMap { $0 }
    )
  }
}

/// Extracted from "swift-composable-architecture",
/// https://github.com/pointfreeco/swift-composable-architecture
/// Raises a debug breakpoint iff a debugger is attached.
@inline(__always) func breakpoint(_ message: @autoclosure () -> String = "") {
  #if DEBUG
    // https://github.com/bitstadium/HockeySDK-iOS/blob/c6e8d1e940299bec0c0585b1f7b86baf3b17fc82/Classes/BITHockeyHelper.m#L346-L370
    var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var info = kinfo_proc()
    var info_size = MemoryLayout<kinfo_proc>.size

    let isDebuggerAttached = name.withUnsafeMutableBytes {
      $0.bindMemory(to: Int32.self).baseAddress
        .map {
          sysctl($0, 4, &info, &info_size, nil, 0) != -1 && info.kp_proc.p_flag & P_TRACED != 0
        }
        ?? false
    }

    if isDebuggerAttached {
      fputs(
        """
        \(message())

        Caught debug breakpoint. Type "continue" ("c") to resume execution.

        """,
        stderr
      )
      raise(SIGTRAP)
    }
  #endif
}
