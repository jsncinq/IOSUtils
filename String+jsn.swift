//  String+jsn
//
//  Created by Jefferson Fernandes 06/11/2017
//  Pods

import Foundation

/**
 * String
 * Extension para String
 */
public extension String {
    
    //MARK: - Variables
    
    /**
     Retorna o tamanho da String
     
     - returns: int
     */
    public var length : Int {
        return self.characters.count
    }
    
    /**
     Verifica se s String NAO e vazia
     
     - returns: Bool
     */
    public var isNotEmpty : Bool {
        return !self.isEmpty
    }
    
    /**
     Transforma a String em um inteiro
     
     - returns: int
     */
    public var integerValue : Int {
        if self.isEmpty { return 0 }
        
        return (self as NSString).integerValue
    }
    
    /**
     Transforma a Strinf em um float
     
     - returns: Float
     */
    public var floatValue : Float {
        if self.isEmpty { return 0.0 }
        return (self as NSString).floatValue
    }
    
    /**
     Transforma a String em um double
     
     - returns: Double
     */
    public var doubleValue : Double {
        if self.isEmpty { return 0.0 }
        
        return (self as NSString).doubleValue
    }
    
    /**
     - returns: UnsafePointer<Int8>
     */
    public var UTF8String: UnsafePointer<Int8>? {
        if self.isEmpty { return nil }
        
        return (self as NSString).utf8String!
    }
    
    //MARK: - Characters
    
    /**
     Retorna o caracter em determinada posicao
     
     - parameter i: Int

     - returns: Character
     */
    public func charAt(i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    //MARK: - Contains
    
    /**
     Verifica se determianda string esta condida dentro de outra
     ignorando case sensitive
     
     - parameter find: String
     
     - returns: Bool
     */
    public func containsStringIgnoreCase(find: String) -> Bool {
        return self.uppercased().contains(find.uppercased())
    }
    
    /**
     Verifica se alguma String dentro do array esta contida na String
     
     - parameter array: [String]
     
     - returns: Bool
     */
    public func containsInArray(array: [String]) -> Bool {
        for element in array {
            if (self.containsStringIgnoreCase(find: element)) {
                return true
            }
        }
        return false
    }
    
    /**
     Verifica se a String comeca com a String passada
     
     - parameter string: String
     
     - returns: Bool
     */
    func beginsWith(string: String) -> Bool {
        guard let range = range(of: string, options:[ .anchored , .caseInsensitive]) else {
            return false
        }
        
        return range.lowerBound == startIndex
    }
    
    //MARK: - Equals
    
    /**
     Verifica se as String sao iguais ignorando case sensitive
     
     - parameter string: String
     
     - returns: Bool
     */
    public func equalsIgnoreCase(string: String) -> Bool {
        return self.uppercased() == string.uppercased()
    }
    
    //MARK: - Replace
    
    /**
     Substitui todas as ocorrencias de uma string por outra
     
     - parameter oldString: String
     - parameter withString: String
     
     - returns: String
     */
    public func replace(oldString: String, withString newString: String) -> String {
        return  self.replacingOccurrences(of: oldString, with: newString)
    }
    
    //MARK: - Substring
    
    /**
    Pega tudo que esta alem do index
     
     - parameter index: int
     
     - returns: String
     */
    public func substringFromIndex(index:Int) -> String {
        return String(self.suffix(from:self.index(self.startIndex, offsetBy: index)))
    }
    
    /**
     Pega tudo que esta apos o index
     
     - parameter index: int
     
     - returns: String
     */
    public func substringToIndex(index: Int) -> String {
        return String(self.prefix(upTo: self.index(self.startIndex, offsetBy: index)))
    }
    
    /**
     Realiza um sub string com index de inicio e fim
     
     - parameter startIndex : String
     - parameter toIndex : String
     
     - returns: String
     */
    public func substringFromIndex(startIndex: Int, toIndex endIndex: Int) -> String {
        let length = self.length
        
        if (endIndex >= length || (endIndex - startIndex) >= length || startIndex >= endIndex) { return "" }
    
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        
        return String(self[start...end])
    }
    
    //MARK: - Insert
    
    /**
     Inseri uma String apartir do index
     
     - parameter string: String
     - parameter atIndex: int

     - returns: String
     */
    public func insertString(string: String, atIndex index: Int) -> String {
        let prefix = self.characters.prefix(index)
        let suffix = self.characters.suffix(self.characters.count - index)
        
        return  String(prefix) + string + String(suffix)
    }
    
    //MARK: - Path Component
    
    /**
     Adiciona o componete de path a uma string "/"
     
     - parameter path: String
     
     - returns: String (String + / + String)
     */
    public func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    
    //MARK: - Trim
    
    /**
     Remove espacos a esquerda e a direita da String
     
     - returns: String
     */
    public func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    /**
     Remove espacos a esquerda e a direita da String e tambem espacos excessivos dentro da String
     
     - returns: String
     */
    public func removeExcessiveSpaces() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    //MARK: - Split
    
    /**
     Quebra a string em um array baseada em um caracter de referencia
     
     - parameter separator: String
     
     - returns: [String]
     */
    public func split(separator: String) -> [String] {
        return self.components(separatedBy:separator)
    }
    
    //MARK: - Number
    
    /**
     Verifica se a String e um Numero
     
     - returns: Bool
     */
    public func isNumber() -> Bool {
        if (self != "") {
            let characters = CharacterSet.decimalDigits.inverted
            return !self.isEmpty && rangeOfCharacter(from: characters) == nil
        }
        return false
    }
    
    //MARK: - Conversoes
    
    /**
     Transforma uma string json em um Distionary
     
     - returns: [NSObject : AnyObject]
     */
    public func toJsonDictionary() throws -> [NSObject : AnyObject] {
        guard let data = self.toNSData() else {
            throw NSError(domain: "StringDomain", code: 1, userInfo: [NSLocalizedDescriptionKey : "Erro ao transformar string em dicionario"])
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [NSObject : AnyObject] else {
            throw NSError(domain: "StringDomain", code: 1, userInfo: [NSLocalizedDescriptionKey : "Erro ao transformar string em dicionario"])
        }
        
        return jsonObject
    }
    
    /**
     - returns: NSData
     */
    public func toNSData() -> NSData? {
        let data = self.data(using: String.Encoding.utf8)
        return data as NSData?
    }
    
}

