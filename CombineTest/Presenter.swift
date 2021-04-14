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
  
  // ALTERNATIVE PATTERN USING CombineLatest
  
  lazy var onCompletion2: ((Subscribers.Completion<Error>) -> Void)? = { [weak self] completion in
    switch completion {
    case .finished:
      break
    case .failure(let error):
      if let model = self?.makeViewModel(state1: nil, state2: nil, error: error) {
        self?.compositeModel = model
      }
    }
  }
  
  func start2()  {
    useCaseOne.start()
    useCaseTwo.start()
    
    useCaseOne.caseState
      .combineLatest(useCaseTwo.caseState)
      .receive(on: DispatchQueue.main)
      .map { [weak self] state1, state2 in
        self?.makeViewModel(state1: state1, state2: state2, error: nil)
      }
      .sink(receiveCompletion: { [weak self] error in
        self?.onCompletion2?(error)
      }, receiveValue: { [weak self] model in
        if let model = model {
          self?.compositeModel = model
        }
      })
      .store(in: &cancellables)
  }
  
  private func makeViewModel(state1: UseCaseState<DomainModelOne>?, state2: UseCaseState<DomainModelTwo>?, error: Error?) -> ViewModelItem?  {
    switch (state1, state2, error) {
    case (_, _, let error) where error != nil:
      return ViewModelItem(name: "Failure: \(error.debugDescription)")
    case (.loading, _, _), (_, .loading, _):
      return ViewModelItem(name: "Loading ⌛")
    case let (.loaded(value1), .loaded(value2), _):
      return ViewModelItem(name: String("🎉 \(value1) + \(value2)"))
    default:
      return nil
    }
  }
}
