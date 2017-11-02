//  HttpHelper.swift
//  Pods
//
//  Created by Jefferson Fernandes on 30/10/2017.

import Foundation
import Security

/**
 * HttpHelper
 * Classe principal de conexao http
 * - Dependencies:
 *      Exception
 *      StringUtils
 *      extension String
 *      DeviceUtils
 *      AppUtils
 *      LogUtils
 */
public class HttpHelper: NSObject, URLSessionDelegate {
    
    //MARK: - Constants
    
    static public let UTF8  = String.Encoding.utf8
    static public let ISO   = String.Encoding.isoLatin1
    
    //MARK: - Variables
    
    //Basic Properties
    
    private var url         : String!
    private var contentType : String!
    private var timeout     : TimeInterval!
    private var encoding    : String.Encoding!
    private var parameters  : [String: AnyObject]!
    private var json        : String!
    private var header      : [String: String]!
    private var addDefaultHttpParams    : Bool = false
    
    //Basic Authorization
    
    private var username    : String!
    private var password    : String!
    
    //Certificates
    
    private var certificateMode     : CertificateMode = .None
    private var certificate         : NSData?
    private var certificatePassword : String?
    private var trustAllSSL         : Bool = false
    private var hostDomain          : String?
    
    //Response
    
    private var responseData    : NSData!
    private var responseError   : NSError?
    
    //Semaphore
    
    ///Faz com que a requisição fique síncrona.
    private var semaphore       = DispatchSemaphore(value: 0);
    
    //MARK: - Inits
    
    /**
     * Inicializa parametros basicos de uma conexao inicializador utilizado quando nenhum parametro e passado
     * para se inicar uma conexao
     */
    override public init() {
        super.init()
        
        self.contentType = "application/x-www-form-urlencoded"
        self.timeout = 20
        self.encoding = HttpHelper.UTF8
        self.header = [:]
        self.parameters = [:]
        self.json = ""
    }
    
    /**
     * Inicializa parametros basicos de uma conexao inicializador utilizado quando existem parametros costumizados para se inicar uma conexao
     */
    convenience public init(contentType: String, timeout: TimeInterval = 60, encoding: String.Encoding = HttpHelper.UTF8) {
        self.init()
        
        self.contentType = contentType
        self.timeout = timeout
        self.encoding = encoding
    }
    
    //MARK: - Setters
    
    public func addHeader(key _key: String, andValue value: String) -> HttpHelper {
        header[_key] = value
        return self
    }
    
    public func setContentType(contentType: String) -> HttpHelper {
        self.contentType = contentType
        return self
    }
    
    public func setTimeout(timeout: TimeInterval) -> HttpHelper {
        self.timeout = timeout
        return self
    }
    
    public func setEncoding(encoding: String.Encoding) -> HttpHelper {
        self.encoding = encoding
        return self
    }
    
    public func setAddDefaultHttpParams(addDefaultHttpParams: Bool) -> HttpHelper {
        self.addDefaultHttpParams = addDefaultHttpParams
        return self
    }
    
    public func setBasicAuth(username _username: String, password _password: String) -> HttpHelper {
        self.username = _username
        self.password = _password
        return self
    }
    
    public func setCertificate(certificate: NSData?, withPassword password: String? = nil) -> HttpHelper {
        if (certificate != nil) {
            self.certificateMode = .PublicKey
        }
        
        self.certificate = certificate
        self.certificatePassword = password
        return self
    }
    
    public func setTrustAll(trustAllSSL: Bool) -> HttpHelper {
        self.trustAllSSL = trustAllSSL
        return self
    }
    
    public func setHostDomain(hostDomain: String) -> HttpHelper {
        self.hostDomain = hostDomain
        return self
    }
    
    //MARK: - Getters
    
    public func getData() -> NSData {
        return responseData
    }
    
    /**
     * Retorna uma string json da requisicao
     * - returns: String json
     */
    public func getJson() -> String {
        if (responseData == nil) {
            return ""
        }
        
        if let json = String(data: responseData as Data, encoding: String.Encoding.utf8) {
            return json
        }
        
        return ""
    }
    
    /**
     * Exibe no console o json retornado pela requisicao como pretty
     */
    func getJsonPretty() -> () {
        do {
            let data = try JSONSerialization.data(withJSONObject:self.getJson().toJsonDictionary() as! [String: AnyObject], options: .prettyPrinted)
            print(String(data: data, encoding: .utf8)!)
        } catch  {
           LogUtils.log(message: "Houve um erro no JsonPretty")
        }
    }
    
    //MARK: - Conversions
    
    /**
     Cria um valor de  autenticacao para requisicoes http
     
     - parameter username: login de usuario.
     - parameter password: senha de usuario.
     
     - returns: "Basic XxXxXxXXXXXxxXXXxxXXXxXX"
     */
    private func getBase64BasicAuth(username: String, password: String) throws -> String {
        let basicAuthCredentials = "\(username):\(password)"
        
        if let basicData = basicAuthCredentials.data(using: String.Encoding.utf8) {
            let base64EncodedCredential = basicData.base64EncodedString(options: .lineLength64Characters)
            let authValue = "Basic \(base64EncodedCredential)"
            return authValue
        }
        
        throw Exception.DomainException(message: "Erro ao formatar Basic Authentication.")//
    }
    
    /**
     Atraves de um Dictionary retona uma String
     
     - parameter dictionary: [String: AnyObject] parametro e valor de um http get.
     - parameter password: senha de usuario.
     
     - returns: "key=value$key=value..."
     */
    private func getStringFromDictionary(dictionary: [String: AnyObject]) -> String {
        var resource = ""
        
        for (key, value) in dictionary {
            resource = StringUtils.isEmpty(str:resource) ? "" : resource + "&"
            resource += key + "=" + "\(value)"
        }
        
        return resource
    }
    
    /**
     Atraves de uma string retorna um Dictionary
     
     - parameter body: "key=value$key=value..."
     
     - returns: [String: AnyObject]
     */
    private func getDictionaryFromString(body: String) throws -> [String: AnyObject] {
        return try body.toJsonDictionary() as! [String: AnyObject]
    }
    
    //MARK: - Requests
    
    /**
     Realiza uma requisicao do tipo GET
     
     - parameter url : url da requisicao GET
     - parameter withParameters parameters: parametros da requisicao GET
     
     - returns: throws
     */
    public func get(url: String, withParameters parameters: [String: String] = [:]) throws {
        updateUrl(url: url, withParameters: parameters)
        try sendHttpRequest(requestMethod: "get")
    }
    
    /**
     Realiza uma requisicao do tipo DELETE
     
     - parameter url : url da requisicao DELETE
     - parameter withParameters parameters: parametros da requisicao DELETE
     
     - returns: throws
     */
    public func delete(url: String, withParameters parameters: [String: String] = [:]) throws {
        updateUrl(url: url, withParameters: parameters)
        try sendHttpRequest(requestMethod: "delete")
    }
    
    /**
     Realiza uma requisicao do tipo POST
     
     - parameter url : url da requisicao POST
     - parameter withParameters parameters: parametros da requisicao POST (json or row)
     
     - returns: throws
     */
    public func post(url: String, withBody body: String) throws {
        updateUrl(url: url)
        self.json = body
        try sendHttpRequest(requestMethod: "post")
    }
    
    /**
     Realiza uma requisicao do tipo POST
     
     - parameter url : url da requisicao POST
     - parameter withParameters parameters: parametros da requisicao POST (form data)
     
     - returns: throws
     */
    public func post(url: String, withParameters parameters: [String: AnyObject]) throws {
        updateUrl(url: url)
        self.parameters = parameters
        try sendHttpRequest(requestMethod: "post")
    }
    
    /**
     Realiza uma requisicao do tipo UPDATE
     
     - parameter url : url da requisicao UPDATE
     - parameter withParameters parameters: parametros da requisicao UPDATE (json or row)
     
     - returns: throws
     */
    public func update(url: String, withBody body: String) throws {
        updateUrl(url: url)
        
        self.json = body
        
        try sendHttpRequest(requestMethod: "update")
    }
    
    /**
     Realiza uma requisicao do tipo UPDATE
     
     - parameter url : url da requisicao UPDATE
     - parameter withParameters parameters: parametros da requisicao UPDATE (form data)
     
     - returns: throws
     */
    public func update(url: String, withParameters parameters: [String: AnyObject]) throws {
        updateUrl(url: url)
        
        self.parameters = parameters
        
        try sendHttpRequest(requestMethod: "update")
    }
    
    /**
     Quem de fato realiza a request http
     
     - parameter requestMethod : tipo de request a ser excutado pela funcao
     
     - returns: throws
     */
    private func sendHttpRequest(requestMethod: String) throws {
        
        guard let nsurl = NSURL(string: url) else {
            LogUtils.log(message: "A URL inválida.")
            throw Exception.DomainException(message: "A URL inválida.")
        }
        
        let request = NSMutableURLRequest(url: nsurl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        request.httpMethod = requestMethod
        
        if let username = username, username.isNotEmpty {
            if let password = password, password.isNotEmpty {
                let encodedBasicAuth = try getBase64BasicAuth(username: username, password: password)
                request.setValue(encodedBasicAuth, forHTTPHeaderField: "Authorization")
            }
        }
        
        if (header.count > 0) {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if (requestMethod.equalsIgnoreCase(string: "post") || requestMethod.equalsIgnoreCase(string: "update")) {
            if (self.parameters.isEmpty && StringUtils.isEmpty(str: json)) {
                LogUtils.log(message: "Requisição http (\(requestMethod.lowercased()) sem parâmetros).")
                throw Exception.DomainException(message: "Requisição http (\(requestMethod.lowercased()) sem parâmetros).")
            }
            
            if (request.value(forHTTPHeaderField: "Content-Type") == nil) {
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            
            let hasJsonString = StringUtils.isNotEmpty(str: json)
            
            if (contentType == "application/x-www-form-urlencoded") {
                if (hasJsonString) {
                    LogUtils.log(message: "Use dicionário para content-type application/x-www-form-urlencoded")
                    throw Exception.DomainException(message: "Use dicionário para content-type application/x-www-form-urlencoded")
                }
                
                let formString = getStringFromDictionary(dictionary: parameters)
                let length = "\(formString.length)"
                
                request.setValue(length, forHTTPHeaderField: "Content-Length")
                request.httpBody = formString.data(using: String.Encoding.utf8)
            } else {
                do {
                    if (hasJsonString) {
                        let data = json.data(using: String.Encoding.utf8)!
                        request.httpBody = data
                    } else {
                        let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                        request.httpBody = data
                    }
                } catch {
                    LogUtils.log(message: "Erro ao formatar os dados de envio.")
                    throw Exception.DomainException(message: "Erro ao formatar os dados de envio.")
                }
            }
        }
        
        semaphore = DispatchSemaphore(value: 0)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                self.responseError = error as NSError
                LogUtils.log(message: "Http Error: \(error.localizedDescription)")
            }
            
            if let data = data {
                self.responseData = data as NSData
            }
            self.semaphore.signal()
        } )
        
        dataTask.resume()
        semaphore.wait(timeout: .distantFuture)
        session.finishTasksAndInvalidate()
        
        if let error = responseError {
            if (error.code == -1022) {
                LogUtils.log(message: "Security Transport Exception")
                throw Exception.AppSecurityTransportException
            }
            throw Exception.IOException
        }
        
        if (responseData == nil) {
            throw Exception.IOException
        }
    }
    
    //MARK: - Url Parameters
    
    /**
     Atualiza os parametros de uma url
     
     - parameter url: url do request
     - parameter withParameters parameters: [String: String]
     
     - returns: url?key:value&key:value
     */
    private func updateUrl(url: String, withParameters parameters: [String: String] = [:]) {
        self.url = url
        
        let queryString = getUrlParams(parameters: parameters, withDefaultHttpParams: addDefaultHttpParams)
        if (StringUtils.isNotEmpty(str: queryString)) {
            self.url = self.url + "?" + queryString
        }
    }

    /**
     Recupera parametros do dispositivo e do SO
     Incorpora a URL os parametros recuperados
     
     - returns: [String: String]
     */
    private func getDefaultHttpParameters() -> [String: String] {
        var params : [String: String] = [:]
        
        let so = "iOS"
        let soVersion = "\(DeviceUtils.getVersion())"
        let width = "\(DeviceUtils.getScreenWidth() * DeviceUtils.getScreenScale())"
        let height = "\(DeviceUtils.getScreenHeight() * DeviceUtils.getScreenScale())"
        let deviceName = DeviceUtils.getName()
        let appVersion = AppUtils.getVersion()
        
        params["device.so"] = so
        params["device.so_version"] = soVersion
        params["device.width"] = width
        params["device.height"] = height
        params["device.imei"] = DeviceUtils.getUUID()
        params["device.name"] = deviceName
        params["app.version"] = appVersion
        params["app_version"] = appVersion
        params["app.version_code"] = ""
        params["so.version"] = soVersion
        
        return params
    }
    
    private func getUrlParams(parameters: [String: String], withDefaultHttpParams addDefaultHttpParams: Bool) -> String {
        
        var parameters = parameters
        let defaultMap : [String: String] = addDefaultHttpParams ? getDefaultHttpParameters() : [:]
        
        if (!parameters.isEmpty) {
            for (key, value) in defaultMap {
                parameters[key] = value
            }
        } else {
            parameters = defaultMap
        }
        
        let urlParams = getStringFromDictionary(dictionary: parameters as [String : AnyObject])
        
        return urlParams
    }
    
    //MARK: - Certificate Handlers
    
    public func shoultTrustProctectionSpace(protectionSpace: URLProtectionSpace, withCertificate certificate: NSData) -> Bool {
        // TODO
        return false
    }
    
    public func loadCertificate(certificate: NSData, withPassword password: String) -> AnyObject {
        // TODO
        return String() as AnyObject
    }
    
    //MARK: - URL Session Delegate
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else {
            return
        }
        
        responseError = error as NSError
        LogUtils.log(message: error.localizedDescription)
        semaphore.signal()
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if let hostDomain = hostDomain, hostDomain.isNotEmpty {
            if !hostDomain.equalsIgnoreCase(string: challenge.protectionSpace.host) {
                completionHandler(.rejectProtectionSpace, nil)
            }
        }
        
        if trustAllSSL {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            }
        } else if certificateMode == .PublicKey {
            if let certificate = certificate {
                if shoultTrustProctectionSpace(protectionSpace: challenge.protectionSpace, withCertificate: certificate) {
                    if let certificatePassword = certificatePassword {
                        let credential = loadCertificate(certificate: certificate, withPassword: certificatePassword)
                        completionHandler(.useCredential, credential as? URLCredential)
                        
                    } else {
                        if let serverTrust = challenge.protectionSpace.serverTrust {
                            let credential = URLCredential(trust: serverTrust)
                            completionHandler(.useCredential, credential)
                        }
                    }
                } else {
                    completionHandler(.performDefaultHandling, nil)
                }
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
