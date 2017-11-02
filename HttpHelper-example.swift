
// Cria instancia, alimenta parametros de autenticacao caso nescessario e seta url
let httpHelper = HttpHelper(contentType: "application/json")
httpHelper.setBasicAuth(username: "", password: "")
let url:String = "http://load-balancer-api-report-761270865.sa-east-1.elb.amazonaws.com/v5/verificarcnpj"


// Paramtros
var param:String = "{\"cnpj\":\"40.670.000/0000-00\"}"

// Funcao que realiza um POST
func RealizarRequest(autor:String){
    
    do {
        try httpHelper.post(url: url, withBody: param)
        httpHelper.getJsonPretty()
    } catch   {
        print("ERRO")
    }
}

// Laco de persistencia
for i in 0 ... 1000 {
    RealizarRequest(autor:"Kamila_\(i)")
}
