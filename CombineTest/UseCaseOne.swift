import Combine
import Foundation

protocol UseCaseOne {
  var caseState: AnyPublisher<UseCaseState<DomainModelOne>, Never> { get }
  func start()
}

class UseCaseOneImpl: UseCaseOne {
  
  private var timer1: Timer?
  private var timer2: Timer?
  private let internalState = CurrentValueSubject<UseCaseState<DomainModelOne>, Never>(.idle)
  
  var caseState: AnyPublisher<UseCaseState<DomainModelOne>, Never>{
    internalState.eraseToAnyPublisher()
  }
  
  func start() {
    internalState.value = .loading
    timer1 = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
      DispatchQueue.global(qos: .background).async {
      self?.generateRandomString()
      }
    }
    timer1 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
      DispatchQueue.global(qos: .unspecified).async {
      self?.generateRandomError()
      }
    }
  }
   
  @objc private func generateRandomString() {
    let letter = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"].randomElement()!
    internalState.send(.success(DomainModelOne(name: letter)))
  }
  
  @objc private func generateRandomError() {
    let index  = [0, 1].randomElement()!
    let error = UseCaseError.allCases[index]
    internalState.send( .failure(error))
  }
}
