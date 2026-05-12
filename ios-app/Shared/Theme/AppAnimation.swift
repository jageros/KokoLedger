import SwiftUI

enum AppAnimation {
    static let sheet = Animation.spring(response: 0.32, dampingFraction: 0.9)
    static let card = Animation.spring(response: 0.28, dampingFraction: 0.86)
    static let chart = Animation.easeInOut(duration: 0.25)
    static let drawer = Animation.spring(response: 0.36, dampingFraction: 0.88)
}
