import Combine
import Foundation

protocol UseCaseTwo {
  var caseState: AnyPublisher<UseCaseState<DomainModelTwo>, Never> { get }
  func start()
}

class UseCaseTwoImpl: UseCaseTwo {
  
  private var timer1: Timer?
  private let internalState = CurrentValueSubject<UseCaseState<DomainModelTwo>, Never>(.idle)
  
  var caseState: AnyPublisher<UseCaseState<DomainModelTwo>, Never>{
    internalState.eraseToAnyPublisher()
  }
  
  func start() {
    internalState.value = .loading
    timer1 = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
      DispatchQueue.global(qos: .userInitiated).async {
      self?.generateRandomInt()
      }
    }
  }
   
  @objc private func generateRandomInt() {
    let int = Array(1...10).randomElement()!
    internalState.send(.success(DomainModelTwo(number: int)))
  }
}

