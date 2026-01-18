import Foundation
import LocalAuthentication

class BiometricAuthManager {
    
    // MARK: - Singleton
    
    static let shared = BiometricAuthManager()
    private init() {}
    
    // MARK: - Properties
    
    private var context = LAContext()
    private var error: NSError?
    
    // MARK: - Biometric Type
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    /// 获取设备支持的生物识别类型
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            case .none:
                return .none
            default:
                return .none
            }
        } else {
            return .touchID
        }
    }
    
    /// 检查设备是否支持生物识别
    func isBiometricAvailable() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// 检查设备是否已注册生物识别
    func isBiometricEnrolled() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            switch error.code {
            case LAError.biometryNotEnrolled.rawValue:
                return false
            case LAError.biometryNotAvailable.rawValue:
                return false
            case LAError.biometryLockout.rawValue:
                return true // 已注册但被锁定
            default:
                return false
            }
        }
        
        return canEvaluate
    }
    
    /// 执行生物识别认证
    func authenticateUser(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        guard isBiometricAvailable() else {
            completion(false, error)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    /// 获取生物识别类型名称
    func getBiometricTypeName() -> String {
        switch biometricType {
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .none:
            return "None"
        }
    }
    
    /// 重置生物识别上下文
    func resetContext() {
        context.invalidate()
        // 创建新的上下文
        context = LAContext()
    }
}
