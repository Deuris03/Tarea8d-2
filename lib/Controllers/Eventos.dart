// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_import, avoid_print, body_might_complete_normally_nullable, file_names
/*
Nombre: Deuris Andres Estevez Bueno
Matricula: 2022-0233
*/

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'AudioPlayer.dart';
import 'DatabaseHelper.dart';
import 'registro.dart';

class Partido extends StatelessWidget {
  const Partido({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro de Eventos',
      home: EventListPage(),
    );
  }
}

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final dbHelper = DatabaseHelper();
  late List<Registro> resgistros = [];
  late AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadRegistros();
  }

  Future<void> _loadRegistros() async {
    final loadRegistros = await dbHelper.retrieveRegistros();
    setState(() {
      resgistros = loadRegistros;
    });
  }

  // Método para reproducir audio desde una URL
  Future<void> _playAudio(String audioUrl) async {
    try {
      await audioPlayer.setSourceUrl(audioUrl);
      print('Reproducción de audio iniciada correctamente');
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
  }

  Future<void> _addRegistro(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController(); // Controller para la URL de la imagen
    final audioFileController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Nuevo Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: audioFileController,
                  decoration:
                      const InputDecoration(labelText: 'Archivo de audio'),
                ),
                TextField(
                  controller: urlController,
                  decoration:
                      const InputDecoration(labelText: 'URL de la imagen'),
                ),
                // Widget para seleccionar la fecha
                TextButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      selectedDate = pickedDate;
                    }
                  },
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;
                final imageUrl = urlController.text; 
                final date = selectedDate.toString(); 
                final audioFile = audioFileController.text;
                final newEvent = Registro(
                  id: 0,
                  title: title,
                  description: description,
                  date: date,
                  audioPath: audioFile,
                  photoPath: imageUrl, 
                );

                await dbHelper.insertRegistro(newEvent);
                await _loadRegistros();

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editEvent(Registro registro, BuildContext context) async {
    final titleController = TextEditingController(text: registro.title);
    final descriptionController = TextEditingController(text: registro.description);
    final urlController = TextEditingController(text: registro.photoPath);
    final audioFileController = TextEditingController(text: registro.audioPath);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Imagen'),
              ),
              TextField(
                controller: audioFileController,
                decoration: const InputDecoration(labelText: 'Audio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;
                final imagen = urlController.text;
                final audio = audioFileController.text;
                
                final date = DateTime.now().toString();
                final updatedRegistro = Registro(
                  id: registro.id,
                  title: title,
                  description: description,
                  date: date,
                  audioPath: audio,
                  photoPath: imagen, // Mantener la URL existente
                );
                await dbHelper.updateRegistro(updatedRegistro);
                await _loadRegistros();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRegistro(Registro registro) async {
    await dbHelper.deleteRegistro(registro.id);
    await _loadRegistros();
  }

  Future<void> _deleteAllRegistros() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Borrar Todos los Eventos'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar todos los eventos?'),
          actions: [
            TextButton(
              onPressed: () async {
                await dbHelper.deleteAllRegistros();
                await _loadRegistros();
                Navigator.pop(dialogContext);
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos de Partidos Politicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _deleteAllRegistros(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: resgistros.map((resgistro) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistroDetailsPage(registro: resgistro),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          resgistro.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            resgistro.photoPath,
                            width: 400,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 40,
                              margin: const EdgeInsets.only(
                                  right: 40), // Espacio entre botones
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 3, 245,
                                    124), // Color de fondo para el botón de reproducción de audio
                                borderRadius:
                                    BorderRadius.circular(8), // Radio de borde
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  _playAudio(
                                      resgistro.audioPath); // Reproducir audio al hacer clic
                                },
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 40,
                              margin: const EdgeInsets.only(
                                  right: 40), // Espacio entre botones
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue, // Color de fondo para el botón de edición
                                borderRadius:
                                    BorderRadius.circular(8), // Radio de borde
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editEvent(resgistro, context);
                                },
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors
                                    .red, // Color de fondo para el botón de eliminación
                                borderRadius:
                                    BorderRadius.circular(8), // Radio de borde
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar Evento'),
                                      content: const Text(
                                          '¿Estás seguro de que deseas eliminar este evento?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _deleteRegistro(resgistro);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRegistro(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RegistroDetailsPage extends StatelessWidget {
  final Registro registro;
  const RegistroDetailsPage({super.key, required this.registro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(registro.title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 3, 27, 248),
        ),
        child: Column(
          children: [
            if (registro.photoPath.isNotEmpty)
              Image.network(
                registro.photoPath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo para el primer ListTile
                borderRadius: BorderRadius.circular(10), // Radio de borde
              ),
              child: ListTile(
                title: Text(
                  'Título: ${registro.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo para el segundo ListTile
                borderRadius: BorderRadius.circular(10), // Radio de borde
              ),
              child: ListTile(
                title: Text('Descripción: ${registro.description}'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo para el tercer ListTile
                borderRadius: BorderRadius.circular(10), // Radio de borde
              ),
              child: ListTile(
                title: Text('Fecha: ${registro.date}'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo para el tercer ListTile
                borderRadius: BorderRadius.circular(10), // Radio de borde
              ),
              child: ListTile(
                title: PlayerWidget(player: AudioPlayer()..setSourceUrl(registro.audioPath)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
