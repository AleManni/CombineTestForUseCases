
import Foundation
import UIKit
import Combine

enum UseCaseState<Value> {
  case idle
  case loading
  case success(_ value: Value)
  case failure(_ error: Error)
}
