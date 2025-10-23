

import Foundation


// Networking/AuthSession.swift
actor AuthSession {
    private let http = HTTPClient()

    func currentAccessToken() -> String? { TokenStorage.get(.access) }
    func currentRefreshToken() -> String? { TokenStorage.get(.refresh) }

    func setAccessToken(_ access: String) {
        _ = TokenStorage.set(.access, value: access)
    }
    func setRefreshToken(_ refresh: String) {
        _ = TokenStorage.set(.refresh, value: refresh)
    }
    func clear() { TokenStorage.clearSession() }

    /// Intenta refrescar usando el refresh_token guardado.
    /// Si falla, lanza para que el llamador desloguee.
    func refreshIfPossible() async throws {
        guard let rt = currentRefreshToken(), !rt.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }
        // Backend sólo regresa access_token
        let newAccess = try await http.refreshAccessToken(refreshToken: rt)
        setAccessToken(newAccess)

    
    }
}
