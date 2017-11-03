//  StringUtils.swift
//  Pods
//
//  Created by Jefferson Fernandes on 02/11/2017.

import UIKit

public enum PadType {
    case left
    case right
}

/**
 * StringUtils
 * Utilitarios para Strings
 * - Dependencies:
 *      Exception
 *      extension String
 */
public class StringUtils: NSObject {
    
    /**
     * O tamanho máximo para o qual a (s) constante (s) de preenchimento pode se expandir.
     */
    static private let PAD_LIMIT : Int = 8192
    
    //MARK: - Empty
    
    /**
     Verifica se a string e vazia
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isEmpty(str:String?) -> Bool {
        guard let str = str, !str.equalsIgnoreCase(string: "nil") else { return true }
        
        return str.isEmpty
    }
    
    /**
     Verifica se a string nao e vazia
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isNotEmpty(str:String?) -> Bool {
        return !isEmpty(str: str)
    }
    
    //MARK: - Split
    
    /**
     Equivalente a explode do php
     
     - parameter retorno: String
     - parameter separator: String
     
     - returns: [String]
     */
    static public func split(value: String?, withSeparator separator: String) -> [String] {
        guard let retorno = value else { return [] }

        return retorno.split(separator: separator)
    }
    
    //MARK: - Padding
    
    /**
     Preenchimento de caracteres a esquerda e a direita de uma string
     
     - exemplo:
         str = xxx
         toSize = 5
         withString = 0
         side = .left
         results = 00xxx
     
     - parameter str: String (string a ser preenchida)
     - parameter toSize: String (tamanho total da caixa incluido a string )
     - parameter withString: String (caracter a preencher)
     - parameter side: String (.left - .right ) - lado do preenchimento

     - returns: String
     */
    static func pad(str: String?, toSize size: Int, withString withPad: String , side padType: PadType) throws -> String {
        
        guard let str = str else { return "" }
        guard PAD_LIMIT > size else {throw Exception.RunTimeException(message: "PAD_LIMIT excedido") }
        guard size > str.characters.count else { throw Exception.RunTimeException(message: "Texto [\(str)] excedeu o tamanho: \(size)") }
        
        var padding = String(repeating: withPad, count: size - str.characters.count)
        
        switch padType {
        case .left:
            padding = padding + str
        case .right:
            padding = str + padding
        }
        
        return padding
    }

    //MARK: - Types
    
    /**
     Tranforma uma string em um int NSNumber
     
     - parameter s: String
     
     - returns: NSNumber?
     */
    static private func getIntegerFromString(s: String) -> NSNumber? {
        let formatter = NumberFormatter()
        
        return formatter.number(from: s)?.intValue as NSNumber?
    }
    
    /**
     Verifica se a String e um Int
     
     - parameter s: String
     
     - returns: Bool
     */
    static public func isInteger(s: String?) -> Bool {
        if isEmpty(str: s) { return false } 
        
        guard let s = s else { return false }
        
        if let _ = getIntegerFromString(s: s) { return true }
        
        return false
    }
    
    /**
     Tranforma uma string em um double NSNumber

     - parameter s: String
     
     - returns: NSNumber?
     */
    static private func getDoubleFromString(s: String) -> NSNumber? {
        let formatter = NumberFormatter()
        return formatter.number(from: s)?.doubleValue as NSNumber?
    }
    
    /**
     Verifica se a String e um double
     
     - parameter s: String
     
     - returns: Bool
     */
    static public func isDouble(s: String?) -> Bool {
        if isEmpty(str: s) { return false }
        
        guard let s = s else { return false }
        
        if let _ = getDoubleFromString(s: s) { return true }
        
        return false
    }
    
    //MARK: - Equals
    
    /**
     Compara duas string para ver se sao iguais
     
     - parameter s1: String
     - parameter withString: String

     - returns: Bool
     */
    static public func equals(s1: String?, withString s2: String?) -> Bool {
        guard let s1 = s1, isNotEmpty(str: s1) else { return false }
        
        guard let s2 = s2, isNotEmpty(str: s2) else { return false }
        
        return s1 == s2
    }
    
    /**
     Compara duas string ignorando letras maiusculas para ver se sao iguais
     
     - parameter s1: String
     - parameter withString: String
     
     - returns: Bool
     */
    static public func equalsIgnoreCase(s1: String?, withString s2: String?) -> Bool {
        guard let s1 = s1, isNotEmpty(str: s1) else { return false }
        
        guard let s2 = s2, isNotEmpty(str: s2) else { return false }
        
        return s1.equalsIgnoreCase(string: s2)
    }
    
    /**
     Compara se a string existe dentro de um array
     
     - parameter s1: String
     - parameter withArray: [String]?
     
     - returns: Bool
     */
    static public func equalsAny(s: String?, withArray strings: [String]?) -> Bool {
        guard let s = s, isNotEmpty(str: s) else { return false }
        
        guard let strings = strings, strings.count > 0 else { return false }
        
        for s2 in strings {
            let ok = equals(s1: s, withString: s2)
            
            if ok { return true }
        }
        
        return false
    }
    
    /**
     Compara se a string existe dentro de um array ignorando letras maiusculas
     
     - parameter s1: String
     - parameter withArray: [String]?
     
     - returns: Bool
     */
    static func equalsIgnoreCaseAny(s: String?, withArray strings: [String]?) -> Bool {
        guard let s = s, isNotEmpty(str: s) else { return false }
        
        guard let strings = strings, strings.count > 0 else { return false }
        
        for s2 in strings {
            let ok = equalsIgnoreCase(s1: s, withString: s2)
            if ok { return true }
        }
        
        return false
    }
    
    /**
     Compara se as string NAO sao iguais
     
     - parameter s1: String
     - parameter withString: [String]?
     
     - returns: Bool
     */
    static public func notEquals(s1: String?, withString s2: String) -> Bool {
        return !equals(s1: s1, withString: s2)
    }
    
    //MARK: - Types

    /**
     Confirma que a string contem apenas letras
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isLetters(str: String?) -> Bool {
        guard let str = str, isNotEmpty(str: str) else { return false }
        
        let letters = CharacterSet.letters
        
        return str.rangeOfCharacter(from: letters) != nil
    }
    
    /**
     Confirma que a string NÃO contem apenas letras
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isNotLetters(str: String?) -> Bool {
        return !isLetters(str: str)
    }
    
    /**
     Confirma que a string contem apenas numero
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isDigits(str: String?) -> Bool {
        guard let str = str, isNotEmpty(str: str) else { return false }
        
        let badCharacters = NSCharacterSet.decimalDigits.inverted
        
        return (str.rangeOfCharacter(from: badCharacters) == nil)
    }
    
    /**
     Confirma que a string NÃO contem apenas numero
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isNotDigits(str: String?) -> Bool {
        return !isDigits(str: str)
    }
   
    /**
     Confirma que a string é alphanumerica
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isAlphaNumeric(str: String?) -> Bool {
        guard let str = str, isNotEmpty(str: str) else {  return false }
        
        return str.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && str != ""
    }
    
    /**
     Confirma que a string NÃO é alphanumerica
     
     - parameter str: String
     
     - returns: Bool
     */
    static public func isNotAlphaNumeric(str: String?) -> Bool {
        return !isAlphaNumeric(str: str)
    }
    
    //MARK: - Cases
    
    /**
     Tranforma toda a String em maiuscula
     
     - parameter str: String
     
     - returns: string
     */
    static public func toUpperCase(str: String?) -> String {
        return str != nil ? str!.uppercased() : ""
    }
    
    /**
     Tranforma toda a String em minuscula
     
     - parameter str: String
     
     - returns: string
     */
    static public func toLowerCase(str: String?) -> String {
        return str != nil ? str!.lowercased() : ""
    }
    
    /**
     Tranforma a primeira letra da primeira palavra string em maiuscula
     
     - parameter str: String
     
     - returns: string
     */
    static public func capitalize(str: String?) -> String {
        guard let str = str, isNotEmpty(str: str) else {return "" }
        
        return String(str.charAt(i: 0)).uppercased() + str.substringFromIndex(index: 1)
    }
    
    /**
     Tranforma a primeira letra da primeira palavra string em maiuscula
     
     - parameter str: String
     
     - returns: string
     */
    static public func capitalizeAll(str: String?) -> String {
        return str != nil ? str!.capitalized : ""
    }
    
    //MARK: - Trim
    
    /**
     Remove espacos no inicio e no final da string
     
     - parameter str: String
     
     - returns: string
     */
    static public func trim(str: String?) -> String? {
        return str?.trim()
    }

    /**
     Remove espacos no inicio,final e espacos excessivos entre as string
     
     - parameter str: String
     
     - returns: string
     */
    static public func trimAll(str: String?) -> String? {
        return str?.removeExcessiveSpaces()
    }
    
    //MARK: - Contains
    
    /**
     Verifica se um determinado caracter existe dentro de uma string : caracter lenght 1
     
     - parameter str: String?
     - parameter fromArray: [Character]?
     
     - returns: int (posicao do caracter dentro da string)
     */
    static public func indexOfAny(str: String?, fromArray searchChars: [Character]?) -> Int {
        guard let str = str, isNotEmpty(str: str) else { return -1 }
        
        guard let searchChars = searchChars, searchChars.count > 0 && searchChars.count < 2 else { return -1 }

        for i in 0 ..< str.length {
            let ch = str.charAt(i:i)
            
            for j in 0 ..< searchChars.count {
                if (searchChars[j] == ch) { return i }
            }
        }
        
        return -1
    }
    
    /**
     Verifica se determinada string contemn dentro de outra string
     
     - parameter str: String?
     - parameter fromQuery: String?
     
     - returns: Bool
     */
    static public func contains(str: String?, fromQuery query: String?) -> Bool {
        guard let str = str, isNotEmpty(str: str) else {  return false }
        
        guard let query = query, isNotEmpty(str: query) else { return false }
        
        return str.contains(query)
    }
    
    /**
     Verifica se determinada string contemn dentro de outra string ignorando letras maiusculas
     
     - parameter str: String?
     - parameter fromQuery: String?
     
     - returns: Bool
     */
    static public func containsIgnoreCase(str: String?, fromQuery query: String?) -> Bool {
        return contains(str: str?.uppercased(), fromQuery: query?.uppercased())
    }
    
    /**
     Verifica se determinada Character contem dentro de uma string (Case Sensitive)
     
     - parameter str: String?
     - parameter fromCharacters: [Character]?
     
     - returns: Bool
     */
    static public func containsAny(str: String?, fromCharacters searchChars: [Character]?) -> Bool {
        guard let str = str, isNotEmpty(str: str) else { return false }
        
        guard let searchChars = searchChars, searchChars.count > 0 else { return false }
        
        for i in 0 ..< str.length {
            let ch = str.charAt(i: i)
            
            for j in 0 ..< searchChars.count {
                if (searchChars[j] == ch) { return true }
            }
        }
        
        return false
    }
    
    /**
     Verifica se qualquer um dos caracteres da string estao contidos na outra string (Case Sensitive)
     
     - parameter str: String?
     - parameter inString: String?
     
     - returns: Bool
     */
    static public func containsAny(str: String?, inString searchChars: String?) -> Bool {
        guard let searchChars = searchChars, isNotEmpty(str: searchChars) else {return false}
        
        return containsAny(str: str, fromCharacters: Array(searchChars.characters))
    }
    
    /**
     Verifica se qualquer um dos caracteres do array de string estao contidos na outra string
     
     - parameter str: String?
     - parameter inString: [String]?
     
     - returns: Bool
     */
    static public func containsAny(str: String?, inStrings searchChars: [String]?) -> Bool {
        guard let str = str, isNotEmpty(str: str) else { return false }
        
        guard let searchChars = searchChars, searchChars.count > 0 else { return false }
        
        for searchChar in searchChars {
            let ok = containsAny(str: str, fromCharacters: Array(searchChar.characters))
            if ok { return true }
        }
        
        return false
    }
    
    //MARK: - Replacing
    
    /**
     Subtitui todas as ocorrencias encontradas dentro de uma string por outro valor
     
     - parameter str: String?
     - parameter inQuery: String?
     - parameter withReplacement: String?
     
     - returns: String
     */
    static public func replace(str: String?, inQuery repl: String?, withReplacement with: String?) -> String {
        guard let text = str else { return "" }
        
        guard let repl = repl, isNotEmpty(str: repl) else { return text }
        
        guard let with = with else { return text }
        
        return text.replacingOccurrences(of: repl, with: with)
    }
    
    //MARK: - Bytes
    
    /**
     Descobre o tamanho de bytes de uma determinada String UTF8
     
     - parameter s: String?
     
     - returns: int
     */
    static public func getLengthUTF8StringInBytes(s: String?) throws -> Int {
        if let s = s {
            if let data = s.data(using: String.Encoding.utf8) {
                return data.count
            }
            
            throw Exception.RunTimeException(message: "Unsupported Encoding")
        }
        
        return 0
    }
}

