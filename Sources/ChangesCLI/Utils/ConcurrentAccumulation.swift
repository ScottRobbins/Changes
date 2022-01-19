import Foundation

struct ConcurrentAccumulation {
  struct AccumulationContainer<ResultType> {
    let addSingleItem: (ResultType) -> Void
    let addMultipleItems: ([ResultType]) -> Void

    func add(_ items: [ResultType]) {
      addMultipleItems(items)
    }

    func add(_ item: ResultType) {
      addSingleItem(item)
    }
  }

  static func reduce<ReducingType, ResultType>(
    _ items: [ReducingType],
    closure: @escaping (_ item: ReducingType, _ container: AccumulationContainer<ResultType>) throws
      -> Void
  ) throws -> [ResultType] {
    var accumulation = [ResultType]()
    var error: Error?
    let queue = DispatchQueue(
      label: "com.swiftbuildtools.changes.thread-safe-array.\(UUID().uuidString)",
      qos: .userInitiated,
      attributes: .concurrent
    )
    let group = DispatchGroup()
    let accumulationContainer = AccumulationContainer<ResultType>(
      addSingleItem: { item in
        queue.sync(flags: .barrier) {
          accumulation.append(item)
        }
      },
      addMultipleItems: { items in
        queue.sync(flags: .barrier) {
          accumulation.append(contentsOf: items)
        }
      }
    )

    for item in items {
      DispatchQueue.global(qos: .userInitiated).async(group: group) {
        do {
          try closure(item, accumulationContainer)
        } catch let e {
          queue.sync {
            error = e
          }
        }
      }
    }

    group.wait()

    if let error = error {
      throw error
    }

    return accumulation
  }
}
