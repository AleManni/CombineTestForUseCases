import Foundation
import Combine
import SwiftUI

class Presenter: ObservableObject {
  
  init(useCaseOne: UseCaseOne,
       useCaseTwo: UseCaseTwo) {
    self.useCaseOne = useCaseOne
    self.useCaseTwo = useCaseTwo
  }
  
  private let useCaseOne: UseCaseOne
  private let useCaseTwo: UseCaseTwo
  @Published var compositeModel: ViewModelItem = ViewModelItem(name: "")
  private var cancellables = Set<AnyCancellable>()
  
  private var state1: UseCaseState<DomainModelOne> = .noValue
  private var state2: UseCaseState<DomainModelTwo> = .noValue
  private var receivedError: Error?
  
  lazy var onCompletion: ((Subscribers.Completion<Error>) -> Void)? = { [weak self] completion in
      switch completion {
      case .finished:
       break
      case .failure(let error):
        self?.receivedError = error
        self?.makeViewModel()
      }
  }
  
  func start1() {
    useCaseOne.start()
    useCaseTwo.start()
    
    useCaseOne.caseState
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] error in
              self?.onCompletion?(error) },
            receiveValue: { [weak self] state in
              self?.state1 = state
              self?.makeViewModel()})
      .store(in: &cancellables)
    
    useCaseTwo.caseState
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] error in
              self?.onCompletion?(error) },
            receiveValue: { [weak self] state in
              self?.state2 = state
              self?.makeViewModel()})
      .store(in: &cancellables)
  }
  
  private func makeViewModel() {
    switch (state1, state2, receivedError) {
      case (_, _, let error) where error != nil:
        compositeModel = ViewModelItem(name: "Failure: \(error.debugDescription)")
    case (.loading, _, _), (_, .loading, _):
      compositeModel = ViewModelItem(name: "Loading ⌛")
    case let (.loaded(value1), .loaded(value2), _):
      compositeModel = ViewModelItem(name: String("🎉 \(value1) + \(value2)"))
    default:
      break
    }
  }
  
  // ALTERNATIVE PATTERN USING CombineLatest and StateHandler
  
  private lazy var actions = StatesHandler.Actions<DomainModelOne, DomainModelTwo>(
    onLoading: {
      self.compositeModel = ViewModelItem(name: "Loading ⌛")
    },
    onSuccess: { model1, model2 in
      self.compositeModel = ViewModelItem(name: "🎉 1️⃣ \(model1.name) 2️⃣ \(String(model2.number))")
    },
    onError: { _ in
      self.compositeModel = ViewModelItem(name: "Failure ❌")
    })
  
  lazy var onCompletion2: ((Subscribers.Completion<Error>) -> Void)? = { [weak self] completion in
      switch completion {
      case .finished:
       break
      case .failure(let error):
        guard let self = self else { return }
        StatesHandler.handle(state1: nil,
                             state2: nil,
                             error: error,
                             actions: self.actions)
      }
  }
  
  func start2()  {
    useCaseOne.start()
    useCaseTwo.start()
    
    Publishers
      .CombineLatest(useCaseOne.caseState.receive(on: DispatchQueue.main),
                     useCaseTwo.caseState.receive(on: DispatchQueue.main))
      .sink(receiveCompletion: { [weak self] error in
        self?.onCompletion2?(error)
      },
      receiveValue: { [weak self] state1, state2 in
        guard let self = self else { return }
        StatesHandler.handle(state1: state1,
                             state2: state2,
                             error: nil,
                             actions: self.actions)
      })
      .store(in: &cancellables)
  }
}
