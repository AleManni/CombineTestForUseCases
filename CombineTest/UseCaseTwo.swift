import Combine
import Foundation

protocol UseCaseTwo {
  var caseState: AnyPublisher<UseCaseState<DomainModelTwo>, Error> { get }
  func start()
}

class UseCaseTwoImpl: UseCaseTwo {
  
  private var timer1: Timer?
  private let internalState = CurrentValueSubject<UseCaseState<DomainModelTwo>, Error>(.noValue)
  
  var caseState: AnyPublisher<UseCaseState<DomainModelTwo>, Error>{
    internalState.eraseToAnyPublisher()
  }
  
  func start() {
    internalState.value = .loading
    timer1 = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
      DispatchQueue.global(qos: .userInitiated).async {
      self?.generateRandomInt()
      }
    }
  }
   
  @objc private func generateRandomInt() {
    let int = Array(1...10).randomElement()!
    internalState.send(.loaded(DomainModelTwo(number: int)))
  }
}

