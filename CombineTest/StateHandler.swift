//// This associates states and actions and can be expanded to handle 2, 3, 4 use cases, pairing up with CombineLatest, CombineLatest2, CombineLatest3 operators in the Presenter.
//enum StatesHandler {
//  
//  struct Actions<T, S> {
//    let onLoading: () -> Void
//    let onSuccess: (T, S) -> Void
//    let onError: (Error) -> Void
//  }
//  
//  struct Actions3<T, S, U> {
//    let onLoading: () -> Void
//    let onSuccess: (T, S, U) -> Void
//    let onError: (Error) -> Void 
//  }
//  
//  static func handle<T, S>(
//    state1: UseCaseState<T>,
//    state2: UseCaseState<S>,
//    actions: Actions<T, S>) {
//    
//    
//    
//    switch (state1, state2) {
//    
////    case let (.failure(error), _), let (_, .failure(error)):
////      actions.onError(error)
//    
//    case (_, .loading), (.loading, _):
//      actions.onLoading()
//      
//    case let (.loaded(value1), .loaded(value2)):
//      actions.onSuccess(value1, value2)
//      
//    default:
//      break
//    }
//  }
//}

