import Dependencies

extension LogInUseCase: DependencyKey {
    static var liveValue: Self {
        LogInUseCase { credentials in
//            @Dependency(\.authRepository) var authRepository
//            @Dependency(\.sessionRepository) var sessionRepository
//
//            LogInUseCase { email, ticketReference in
//                try await authenticationRepository.authenticate(
//                    AttendeeCredentials(
//                        email: email,
//                        ticketReference: ticketReference
//                    )
//                )
//
//                try await sessionRepository.bootstrap()
//            }

            print("Called log in use case with email: \(credentials.emailAddress) and ticket reference: \(credentials.ticketCredential)")

            @Dependency(\.authRepo) var authRepo
            let token = try await authRepo.authenticate(credentials)

            print("Token: \(token)")

            // TODO: Should return `Void` eventually
            return token
        }
    }
}

extension DependencyValues {
    var logIn: LogInUseCase {
        get { self[LogInUseCase.self] }
        set { self[LogInUseCase.self] = newValue }
    }
}

//extension LoginUseCase: DependencyKey {
//    static var liveValue: LogInUseCase {
//        @Dependency(\.authRepository) var authRepository
//        @Dependency(\.sessionRepository) var sessionRepository
//
//        LogInUseCase { email, ticketReference in
//            try await authenticationRepository.authenticate(
//                AttendeeCredentials(
//                    email: email,
//                    ticketReference: ticketReference
//                )
//            )
//
//            try await sessionRepository.bootstrap()
//        }
//    }
//}
