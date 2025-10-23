
import Foundation

// Networking/RequestExecutor.swift
struct RequestExecutor {
    let session = AuthSession()

    func send(_ original: URLRequest, requiresAuth: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var req = original

        if requiresAuth {
            guard let at = await session.currentAccessToken(), !at.isEmpty else {
                throw URLError(.userAuthenticationRequired)
            }
            req.setValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if (200...299).contains(http.statusCode) || !requiresAuth {
            return (data, http)
        }

        if requiresAuth && (http.statusCode == 401 || http.statusCode == 403) {
            do {
                try await session.refreshIfPossible()
                var retry = original
                if let newAT = await session.currentAccessToken() {
                    retry.setValue("Bearer \(newAT)", forHTTPHeaderField: "Authorization")
                }
                let (d2, r2) = try await URLSession.shared.data(for: retry)
                guard let http2 = r2 as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if (200...299).contains(http2.statusCode) {
                    return (d2, http2)
                } else {
                    throw URLError(.userAuthenticationRequired)
                }
            } catch {
                await session.clear() // refresh falló → limpiar sesión
                throw URLError(.userAuthenticationRequired)
            }
        }

        throw URLError(.badServerResponse)
    }
}
