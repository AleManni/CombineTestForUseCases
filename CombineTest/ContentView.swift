import Combine
import SwiftUI

struct ContentViewImpl: View {
  
  @ObservedObject var presenter: Presenter
  
  init(presenter: Presenter) {
    self.presenter = presenter
    presenter.start2()
  }
  
  var body: some View {
    VStack {
      HStack {
        Text("COMPOSITE showcases the view model resulting from two separate publishers, each operating on a different background thread and providing a UseCaseState holding a different domain model. The publishers outputs are then combined in the Presenter, sync'ed on main, and their output (UseCaseStates) fed to a statehandler.")
      }.padding()
      VStack(alignment: .leading, spacing: 14) {
      Text("Composite = \(presenter.compositeModel.name)")
      //Text("Stream 1️⃣ = \(presenter.modelOne.name)")
     // Text("Stream 2️⃣  = \(presenter.modelTwo.name)")
    }
    .padding()
  }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentViewImpl(presenter: Presenter(useCaseOne: UseCaseOneImpl(), useCaseTwo: UseCaseTwoImpl()))
  }
}
