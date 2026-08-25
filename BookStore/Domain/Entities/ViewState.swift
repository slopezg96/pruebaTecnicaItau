/// Estado explícito para pantallas que dependen de datos remotos o persistidos,
/// en vez de múltiples booleanos sueltos (isLoading, hasError, etc.).
enum ViewState<T> {
    case loading
    case loaded(T)
    case error(String)
    case empty
}

extension ViewState: Equatable where T: Equatable {}
