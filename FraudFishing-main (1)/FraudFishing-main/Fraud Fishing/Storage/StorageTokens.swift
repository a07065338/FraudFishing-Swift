import Foundation
import Security

// MARK: - Errores personalizados del Keychain
enum KeychainError: Error, LocalizedError {
    case unexpectedStatus(OSStatus)
    case stringEncoding

    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status):
            return SecCopyErrorMessageString(status, nil) as String? ?? "Keychain error \(status)"
        case .stringEncoding:
            return "Encoding error"
        }
    }
}

// MARK: - Helper general para leer/escribir en Keychain
struct KeychainHelper {
    static func save(service: String, account: String, value: Data, accessible: CFString = kSecAttrAccessibleAfterFirstUnlock) throws {
        // Elimina si ya existe
        try delete(service: service, account: account)

        let query: [String: Any] = [
            kSecClass as String:              kSecClassGenericPassword,
            kSecAttrService as String:        service,
            kSecAttrAccount as String:        account,
            kSecValueData as String:          value,
            kSecAttrAccessible as String:     accessible
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    static func update(service: String, account: String, value: Data) throws {
        let query: [String: Any] = [
            kSecClass as String:          kSecClassGenericPassword,
            kSecAttrService as String:    service,
            kSecAttrAccount as String:    account
        ]
        let attrs: [String: Any] = [
            kSecValueData as String: value
        ]
        let status = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    static func get(service: String, account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrService as String:      service,
            kSecAttrAccount as String:      account,
            kSecReturnData as String:       true,
            kSecMatchLimit as String:       kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        return item as? Data
    }

    static func delete(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrService as String:  service,
            kSecAttrAccount as String:  account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

// MARK: - Wrapper para guardar tokens específicos
enum TokenKey: String {
    case access  = "access_token"
    case refresh = "refresh_token"
}

struct TokenStorage {
    private static let service = Bundle.main.bundleIdentifier ?? "com.example.app"

    @discardableResult
    static func set(_ key: TokenKey, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        do {
            // Si ya existe, actualiza
            try KeychainHelper.save(service: service, account: key.rawValue, value: data)
            return true
        } catch let KeychainError.unexpectedStatus(status) where status == errSecDuplicateItem {
            do {
                try KeychainHelper.update(service: service, account: key.rawValue, value: data)
                return true
            } catch {
                print("Keychain update error: \(error)")
                return false
            }
        } catch {
            print("Keychain save error: \(error)")
            return false
        }
    }

    static func get(_ key: TokenKey) -> String? {
        do {
            if let data = try KeychainHelper.get(service: service, account: key.rawValue) {
                return String(data: data, encoding: .utf8)
            }
            return nil
        } catch {
            print("Keychain get error: \(error)")
            return nil
        }
    }

    @discardableResult
    static func delete(_ key: TokenKey) -> Bool {
        do {
            try KeychainHelper.delete(service: service, account: key.rawValue)
            return true
        } catch {
            print("Keychain delete error: \(error)")
            return false
        }
    }

    static func clearSession() {
        _ = delete(.access)
        _ = delete(.refresh)
    }
}

