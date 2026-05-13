import Foundation

/// Maneja el guardado y validación de la cuenta local con UserDefaults.
class AccountStorage {

    static let shared = AccountStorage()
    private init() {}

    private let keyName     = "account_name"
    private let keyEmail    = "account_email"
    private let keyPassword = "account_password"

    // MARK: - Guardar cuenta

    func save(name: String, email: String, password: String) {
        UserDefaults.standard.set(name,     forKey: keyName)
        UserDefaults.standard.set(email,    forKey: keyEmail)
        UserDefaults.standard.set(password, forKey: keyPassword)
    }

    // MARK: - Verificar si existe cuenta guardada

    var hasAccount: Bool {
        UserDefaults.standard.string(forKey: keyEmail) != nil
    }

    // MARK: - Validar credenciales al hacer Login

    func validate(email: String, password: String) -> Bool {
        let savedEmail    = UserDefaults.standard.string(forKey: keyEmail)    ?? ""
        let savedPassword = UserDefaults.standard.string(forKey: keyPassword) ?? ""
        return email == savedEmail && password == savedPassword
    }

    // MARK: - Obtener nombre guardado (para usarlo después en el Home)

    var savedName: String {
        UserDefaults.standard.string(forKey: keyName) ?? ""
    }

    // MARK: - Cerrar sesión / borrar cuenta

    func logout() {
        UserDefaults.standard.removeObject(forKey: keyName)
        UserDefaults.standard.removeObject(forKey: keyEmail)
        UserDefaults.standard.removeObject(forKey: keyPassword)
    }
}
