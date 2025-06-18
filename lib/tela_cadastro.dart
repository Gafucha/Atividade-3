import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;



class TelaCadastro extends StatefulWidget {

  final Function? iniciarJogoOnClick;

  const TelaCadastro({super.key,  this.iniciarJogoOnClick});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();

}

class _TelaCadastroState extends State<TelaCadastro> {

  var txtNome = TextEditingController();
  var txtValor = TextEditingController();
  var txtNumero = TextEditingController();
  var txtParImpar = TextEditingController();

  Widget getTextField(label, controller) {
    DB.abrir().then((db){
    DB.listar(db, nome).then((resultado){
      if (resultado.isEmpty) {
        DB.inserir(db, JogadorDB(username: nome)).then((id){
          print('Jogador inserido: $id');
        });
      } else {
        nome = resultado.single['USERNAME'];
        print('Jogador banco de dados: $nome');
      }
    });
    });
    var txt = TextField(
        decoration:  InputDecoration(
          fillColor: const Color.fromARGB(255, 100, 100, 100),
          hintText: label,
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        controller: controller);

    return Container(
      margin: const EdgeInsets.all(12),
      child: txt);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text('Par ou Impar')),
          body: Column(children:[
            const SizedBox(height: 5.0),
            getTextField('Nome', txtNome),
            const SizedBox(height: 5.0),
            getTextField('Valor Aposta', txtValor),
            const SizedBox(height: 5.0),
            getTextField('Numero (0-5)', txtNumero),
            const SizedBox(height: 5.0),
            getTextField('2 - par / 1 - impar', txtParImpar),
          Flexible(child:           ListView.builder(
              itemBuilder: (context, id){
                return
                  Padding(padding: const EdgeInsets.all(2.0),
                      child:  ListTile(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                        key: Key(id.toString()),
                        tileColor: Colors.black12,
                        title: const Text('jogador 1'),
                        onTap: (){
                            //Gerando um novo jogador
                            var xuser = Jogador();
                            xuser.nome = txtNome;
                            xuser.aposta = txtValor;
                            xuser.chute = txtNumero;
                            //Código da aposta em si
                            //Variável pra gerar o número aleatório
                            var rand = Random();
                            var resaposta = rand.nextInt(6); //Gerando um número aleatório e armazenando em outra variável
                            getTextField(resaposta, txtParImpar); //Escrevendo na caixa de texto o resultado da aposta
                            //Verificando quem ganhou e arrumando os pontos de cada jogador baseado em sua aposta
                            if(xuser.chute == resaposta) {xuser.pontos += xuser.aposta;} else {xuser.pontos -= xuser.aposta;}
                        },
                        trailing: const Icon(Icons.ads_click),
                      )
                  );
              },
              itemCount: 4,
              shrinkWrap: true,
              padding: const EdgeInsets.all(5.0)
          )
          )

          ])
      ),
    );

  }

}

class Jogador {//Classe de Jogadores
  var nome = '';
  var aposta = 0;
  var pontos = 100;
  var chute = 0;

  @override
  String toString() {//Função para imprimir dados do jogador
    return "$nome - pontos: $pontos";
  }
}

class JogadorDB {//Jogador salvo na lista

    String username;
    
    JogadorDB({this.username = ''});
    
    Map<String, dynamic> toMap() {
    
      return {'username': username};
    
    }
}

class DB {
  //func pra iniciar o banco de dados
  static Future<Database> abrir() async {

  Database db =  await openDatabase("SimpleBlackJackDB", onCreate: (db, version){
        db.execute("CREATE TABLE TAB_JOGADOR (ID INTEGER PRIMARY KEY, USERNAME TEXT)");
      }, version: 1);

  return db;

  }
  //Func pra adicionar jogador
  static Future<int> inserir(Database db, JogadorDB jogador) async {

  var id = await db.insert('TAB_JOGADOR', jogador.toMap());
  return id;

  }
  //Func pra listar jogadores
  static Future<List<Map>> listar(Database db, String username) async {

  return db.query('TAB_JOGADOR', where: "USERNAME = ?", whereArgs: [username]);

  }
}

//Classe pra POST do cadastro
class Post() {
  final url = Uri.https('https://par-impar.glitch.me', 'novo');
  final Map<String, String> header = {'Content-Type' : 'application/json',
                                      'Accept' : 'application/json'};
  final body = '{"username":"${username.text}", \n "pontos":"${pontos.text}"}';
  // requisição http é assíncrona
  http.post(url, headers: header, body: body).then((resp) {
    print(resp)
});
}

//Classe pra POST para efetuar a aposta
class Post() {
  final url = Uri.https('https://par-impar.glitch.me', 'aposta');
  final Map<String, String> header = {'Content-Type' : 'application/json',
                                      'Accept' : 'application/json'};
  final body = '{"username":"${username.text}"} \n {"valor":"${valor.text}"} \n {"parimpar":"${parimpar.text}"} \n {"numero":"${numero.text}"}';
  // requisição http é assíncrona
  http.post(url, headers: header, body: body).then((resp) {
    print(resp)
});
}

//Classe pra GET dos jogadores já cadastrados
final url = Uri.https('https://par-impar.glitch.me', 'jogadores');
http.get(uri,
    headers: <String, String> {'Content-Type' : 'application/json', 'Accept' : 'application/json'})
    .then((resposta) => {
      if (resposta.statusCode == 200) {
        print(jsonDecode(resposta.body));
      }
});

//Classe pra efetivação do jogo par ou impar
final url = Uri.https('https://par-impar.glitch.me', 'jogar/username1/username2');
http.get(uri,
    headers: <String, String> {'Content-Type' : 'application/json', 'Accept' : 'application/json'})
    .then((resposta) => {
      if (resposta.statusCode == 200) {
        print(jsonDecode(resposta.body));
      }
});

//Classe de GET para pontos do usuário
final url = Uri.https('https://par-impar.glitch.me', 'username');
http.get(uri,
    headers: <String, String> {'Content-Type' : 'application/json', 'Accept' : 'application/json'})
    .then((resposta) => {
      if (resposta.statusCode == 200) {
        print(jsonDecode(resposta.body));
      }
});