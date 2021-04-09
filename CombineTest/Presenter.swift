import Foundation
import Combine
import SwiftUI

class Presenter: ObservableObject {
  
  private let useCaseOne: UseCaseOne
  private let useCaseTwo: UseCaseTwo
  @Published var compositeModel: ViewModelItem = ViewModelItem(name: "")
  private var cancellables = Set<AnyCancellable>()
  
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
 
  init(useCaseOne: UseCaseOne,
       useCaseTwo: UseCaseTwo) {
    self.useCaseOne = useCaseOne
    self.useCaseTwo = useCaseTwo
  }
  
  func start() {
    useCaseOne.start()
    useCaseTwo.start()
    
    startObservingComposite()
    startObservingState1()
    startObservingState2()
  }
  
  func startObservingComposite()  {
    Publishers
      .CombineLatest(useCaseOne.caseState.receive(on: DispatchQueue.main),
                     useCaseTwo.caseState.receive(on: DispatchQueue.main))
      .sink(receiveValue: { [weak self] state1, state2 in
        guard let self = self else { return }
        
        StatesHandler.handle(state1: state1,
                             state2: state2,
                             actions: self.actions)
      })
      .store(in: &cancellables)
  }
  
  // Everything below is here only for the sake of the demo allowing the ui to showcase the work of the state handler vs the two independent streams. Our typical Presenter class would finish here.
  
  @Published var modelOne: ViewModelItem = ViewModelItem(name: "")
  @Published var modelTwo: ViewModelItem = ViewModelItem(name: "")
  
  func startObservingState1() {
    useCaseOne.caseState
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] state1 in
      guard let self = self else { return }
      self.modelOne = ViewModelItem(name: "\(state1.printValue)")
    })
    .store(in: &cancellables)
  }
  
  func startObservingState2() {
    useCaseTwo.caseState
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] state2 in
      guard let self = self else { return }
      self.modelTwo = ViewModelItem(name: "\(state2.printValue)")
    })
    .store(in: &cancellables)
  }
}

// This extension is purely for the sake of demo
extension UseCaseState {
  var printValue: String {
    switch self {
    case .idle:
      return "Idle 💤"
    case .loading:
      return "Loading ⌛"
    case let .success(value):
      return String("🎉 \(value)")
    case .failure:
      return "Failure ❌"
    }
  }
}

