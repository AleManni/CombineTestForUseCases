import SwiftUI

@main
struct CombineTestApp: App {
    var body: some Scene {
        WindowGroup {
          ContentViewImpl(presenter: Presenter(
                            useCaseOne: UseCaseOneImpl(),
                            useCaseTwo: UseCaseTwoImpl()))
        }
    }
}
