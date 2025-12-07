import SwiftUI
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published private(set) var isDisconnected: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isDisconnected = (path.status != .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
