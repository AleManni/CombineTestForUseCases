
import Foundation
import UIKit
import Combine

enum UseCaseState<Value> {
  case noValue
  case loading
  case loaded(_ value: Value)
}
