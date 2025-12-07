import SwiftUI

struct LoadingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasCheckedAuthorization = false
    @State  var url: URLModel? = nil
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var conversionDataReceived: Bool = false
    @State var isNotif = false
    let lastDeniedKey = "lastNotificationDeniedDate"
    let configExpiresKey = "config_expires"
    let configUrlKey = "config_url"
    let configNoMoreRequestsKey = "config_no_more_requests"
    @State var isMain = false
    @State  var isRequestingConfig = false
    @StateObject  var networkMonitor = NetworkMonitor.shared
    @State var isInet = false
    @State private var hasHandledConversion = false
    
    var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact && horizontalSizeClass == .regular
    }
    @State var urlFromNotification: String? = nil
    
    var body: some View {
        VStack {
            if isPortrait {
                ZStack {
                    Image("loading")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 50) {
                        Spacer()
                        
                        VStack(spacing: 30) {
                            Spacer()
                            
                            ProgressView()
                                .scaleEffect(3.0)
                                .padding(.top, 120)
                                .tint(.white)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 20)
                }
            } else {
                ZStack {
                    Image("BGforNotificationsLandscape")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(3.0)
                            .tint(.white)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onReceive(networkMonitor.$isDisconnected) { disconnected in
            if disconnected {
                isInet = true
            } else {
            }
        }
        .fullScreenCover(item: $url) { item in
            Egg(urlString: item.urlString)
                .onReceive(NotificationCenter.default.publisher(for: .openUrlFromNotification)) { notification in
                    if let userInfo = notification.userInfo,
                       let url = userInfo["url"] as? String {
                        urlFromNotification = url
                    }
                }
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { urlFromNotification != nil },
                    set: { newValue in if !newValue { urlFromNotification = nil } }
                )) {
                    if let urlToOpen = urlFromNotification {
                        Egg(urlString: urlToOpen)
                            .ignoresSafeArea()
                    } else {
                    }
                }
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openUrlFromNotification)) { notification in
            if let userInfo = notification.userInfo,
               let url = userInfo["url"] as? String {
                urlFromNotification = url
            }
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { urlFromNotification != nil },
            set: { newValue in if !newValue { urlFromNotification = nil } }
        )) {
            if let urlToOpen = urlFromNotification {
                Egg(urlString: urlToOpen)
                    .ignoresSafeArea()
            } else {
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .datraRecieved)) { notification in
            DispatchQueue.main.async {
                guard !isInet else { return }
                if !hasHandledConversion {
                    let isOrganic = UserDefaults.standard.bool(forKey: "is_organic_conversion")
                    if isOrganic {
                        isMain = true
                    } else {
                        checknotif()
                    }
                    hasHandledConversion = true
                } else {
                    print("Conversion event ignored due to recent handling")
                }
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .notificationPermissionResult)) { notification in
            req()
        }
        .fullScreenCover(isPresented: $isNotif) {
            NotificationView()
        }
        .fullScreenCover(isPresented: $isMain) {
            ContentView()
        }
        .fullScreenCover(isPresented: $isInet) {
            NoInternet()
        }
    }
}

#Preview {
    LoadingView()
}
