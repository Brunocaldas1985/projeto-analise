import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'dart:typed_data';

class ColorDetectState extends StatelessWidget {
  dynamic bytes = 0; // Cria os um elemento que recebera os bytes da foto

  var Hexadecimal; // Cria a variavel que receberáo valor em hexadecimal

//Cria uma variável inicializada como uma nova instância da classe Image e cria uma nova imagem em memória com um tamanho de 0x0 pixels.
  img.Image photo = img.Image(0, 0);

// Atribui a imagem decodificada ou um objeto de imagem vazio com largura e altura de 0 se a decodificação falhou
  void setImageBytes(imageBytes) {
    print("setImageBytes");
    List<int> values = imageBytes.buffer.asUint8List();
    photo = img.decodeImage(values) ?? img.Image(0, 0);
  }

/*Uma função que recebe um número inteiro como parâmetro, representa uma cor no formato 
ARGB e retorna outra cor no mesmo formato, mas com a ordem dos canais vermelho e azul invertida.*/
  int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

//Trata uma imagem em bytes e retorna um valor em Color Hexadecimal
  Future<Color> _getColor() async {
    //
    /*Inicializa uma variavel da classe que representa uma lista de bytes não modificáveis
    ou seja, uma lista de valores de 8 bits*/
    Uint8List? data;

    if (data != null) {
      // use data
    } else {
      // handle null case
    }
    try {
      data = bytes.buffer.asUint8List();
    } catch (ex) {
      print(ex.toString());
    }

    //FractionalOffset(1.0, 0.0); //representa o canto superior direito do [Size].
    setImageBytes(data);

    // Cria duas variaveis dinamicas que recebe as coordenadas do pixel de onde a cor será tirada
    dynamic px = 10.0;
    dynamic py = 10.0;

    /*sa o metodo getPxelSafe para obter o valor de cor (ARGB) de um pixel
    na imagem, dado as coordenadas x e y do pixel e atribui a pixel23*/
    int pixel32 = photo.getPixelSafe(px.toInt(), py.toInt());

    //Atribui a variavel um valor invertido pela função abgrToArgb que recebe a variavel pixel32
    int hex = abgrToArgb(pixel32);

    //Atribui o valor Color Hexadecimal na rariavel global hexadecimal
    Hexadecimal = Color(hex);

    return Color(hex);
  }

  /*Cria uma função recebe uma foto em bytes, coloca em uma variavel global, 
  chama a função get_pixel_color, e retorna um valor Color Hexadecimal*/
  Color get_pixel_color(bytes_temp) {
    bytes = bytes_temp;
    _getColor();
    return Hexadecimal;
  }

  @override
  Widget build(BuildContext context) {
    return Text("ColorDetect");
  }
}
