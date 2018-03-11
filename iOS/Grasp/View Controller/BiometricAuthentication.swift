//
//  BiometricAuthentication.swift
//  ProjectCougarTime-iOS-Teacher
//
//  Created by Apollo Zhu on 11/7/17.
//  Copyright © 2017 Oakton High School. All rights reserved.
//

import LocalAuthentication

struct BiometricAuthentication {
    private init() { }
    static var isAvailable: Bool {
        var error: NSError? = nil
        return LAContext().canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error) && nil == error
    }
    static var isFaceID: Bool {
        if #available(iOS 11.0, *) {
            return .faceID == LAContext().biometryType
        }
        return false
    }
    static var isTouchID: Bool {
        return !isFaceID && isAvailable
    }
    
    private static var policy: LAPolicy {
        return isAvailable
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication
    }
    public enum State {
        case success
        case failure(error: Error?)
    }
    public typealias AuthenticationCompletionHandler = (_ state: State) -> Void
    private static var contextRef: LAContext!
    public static func authenticate(policy: LAPolicy = policy, reason: String? = nil,
                                    completionHandler: @escaping AuthenticationCompletionHandler) {
        let prefix = NSLocalizedStringPrefix()
        var realReason: String
        if let reason = reason {
            realReason = reason
        } else if isFaceID {
            realReason = NSLocalizedString(
                "\(prefix).FaceID.reason",
                value: "Use your face to login.",
                comment: "FaceID default login prompt")
        } else if isTouchID {
            realReason = NSLocalizedString(
                "\(prefix).TouchID.reason",
                value: "Use your finger print to login.",
                comment: "TouchID default login prompt")
        } else {
            realReason = NSLocalizedString(
                "\(prefix).password.reason",
                value: "Use the password of your device to login.",
                comment: "Password default login prompt")
        }
        contextRef = LAContext()
        contextRef.evaluatePolicy(policy, localizedReason: realReason) { succeeded, error in
            guard succeeded && nil == error else {
                return completionHandler(.failure(error: error))
            }
            completionHandler(.success)
        }
    }
}

extension BiometricAuthentication {
    static let userDefaultsKey = "BiometricAuthentication"
    static var isEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: userDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) }
    }
}
