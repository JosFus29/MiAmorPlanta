import Foundation
import FirebaseAuth

class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User? = nil
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoggedIn = user != nil
            }
        }
    }

    // MARK: - Registro
    func register(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = self.friendlyError(error)
                    completion(false)
                    return
                }

                // Guarda el nombre en Firebase Auth
                let changeRequest = result?.user.createProfileChangeRequest()
                changeRequest?.displayName = name
                changeRequest?.commitChanges { _ in }

                // Guarda localmente para usarlo en la app
                UserDefaults.standard.set(name, forKey: "account_name")
                UserDefaults.standard.set(email, forKey: "account_email")
                
                FirebaseService.shared.saveProfile(name: name, email: email)

                self.currentUser = result?.user
                self.isLoggedIn = true
                completion(true)
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = self.friendlyError(error)
                    completion(false)
                    return
                }

                UserDefaults.standard.set(result?.user.displayName ?? "", forKey: "account_name")
                UserDefaults.standard.set(email, forKey: "account_email")

                self.currentUser = result?.user
                self.isLoggedIn = true
                completion(true)
            }
        }
    }

    // MARK: - Logout
    func logout() {
        try? Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "account_name")
        UserDefaults.standard.removeObject(forKey: "account_email")
        isLoggedIn = false
        currentUser = nil
        PlantStorage.shared.clearOnLogout()
    }

    // MARK: - Errores en español
    private func friendlyError(_ error: Error) -> String {
        let code = AuthErrorCode(_nsError: error as NSError)
        switch code.code {
        case .emailAlreadyInUse:  return "Este correo ya está registrado."
        case .wrongPassword:      return "Contraseña incorrecta."
        case .userNotFound:       return "No existe una cuenta con ese correo."
        case .invalidEmail:       return "El correo no es válido."
        case .weakPassword:       return "La contraseña debe tener al menos 6 caracteres."
        case .networkError:       return "Sin conexión. Revisa tu internet."
        default:                  return "Error inesperado. Intenta de nuevo."
        }
    }
}
