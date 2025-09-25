// Import library Flutter untuk UI components
import 'package:flutter/material.dart';

class Task {
  // Property untuk menyimpan judul task
  String title;
  // Property untuk menyimpan status selesai/belum
  bool isCompleted;

  // Constructor = function untuk membuat Task baru
  Task({
    // title wajib diisi (required)
    required this.title,
    // isCompleted opsional, default false (belum selesai)
    this.isCompleted = false,
  });

  // Method untuk toggle status completed (true ↔ false)
  void toggle() {
    // Flip boolean: true jadi false, false jadi true
    isCompleted = !isCompleted;
  }

  // Override toString untuk debug print yang readable
  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

// Function utama yang dijalankan pertama kali
void main() {
  // Jalankan aplikasi Flutter, dimulai dari widget MyApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Constructor dengan key parameter untuk best practices
  const MyApp({super.key});

  // Override function build yang WAJIB ada di setiap widget
  @override
  Widget build(BuildContext context) {
    // Return MaterialApp sebagai root aplikasi
    return MaterialApp(
      // Nama aplikasi (muncul di task switcher)
      title: 'Todo App Pemula',
      // Tema warna aplikasi
      theme: ThemeData(
        // Warna utama aplikasi = biru
        primarySwatch: Colors.blue,
      ),
      // Halaman pertama yang ditampilkan saat app dibuka
      home: const TodoListScreen(),
    );
  }
}

// Deklarasi class TodoListScreen untuk halaman utama
class TodoListScreen extends StatefulWidget {
  // Constructor dengan key parameter untuk best practices
  const TodoListScreen({super.key});

  // Override function build untuk membangun UI halaman
  @override
    // Function yang return instance dari state class
    State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];
  // Controller untuk mengontrol TextField (ambil text, clear, dll)
  TextEditingController taskController = TextEditingController();

  void addTask() {
    // Ambil dan bersihkan input text
    String newTaskTitle = taskController.text.trim();

    // Validasi 1: Cek apakah input kosong
    if (newTaskTitle.isEmpty) {
      // Tampilkan SnackBar warning untuk input kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Content dengan icon dan text
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Task tidak boleh kosong!'),
            ],
          ),
          // Styling SnackBar
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Stop execution jika gagal validasi
      return;
    }

    // Validasi 2: Cek task duplikat (case insensitive)
    bool isDuplicate = tasks.any((task) =>
        task.title.toLowerCase() == newTaskTitle.toLowerCase());

    if (isDuplicate) {
      // SnackBar untuk task duplikat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              // Expanded agar text tidak overflow
              Expanded(child: Text('Task "$newTaskTitle" sudah ada!')),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi 3: Cek panjang task maksimal 100 karakter
    if (newTaskTitle.length > 100) {
      // SnackBar untuk task terlalu panjang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task terlalu panjang! Maksimal 100 karakter.')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Semua validasi passed - add task
    setState(() {
      Task newTask = Task(title: newTaskTitle);
      tasks.add(newTask);
    });

    // Clear input
    taskController.clear();

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Task "$newTaskTitle" berhasil ditambahkan!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Task ditambahkan: $newTaskTitle');
  }

  // Function async untuk menghapus task dengan konfirmasi dialog
  void removeTask(int index) async {
    // Simpan nama task yang akan dihapus untuk ditampilkan di dialog
    Task taskToDelete = tasks[index];

    // Tampilkan dialog konfirmasi dan tunggu response user
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      // Builder function untuk membuat content dialog
      builder: (BuildContext context) {
        // AlertDialog = popup konfirmasi
        return AlertDialog(
          // Title dialog dengan icon warning
          title: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Konfirmasi Hapus'),
              ],
            ),
          ),
          // Content dialog
          content: Column(
            // Column sekecil mungkin
            mainAxisSize: MainAxisSize.min,
            // Align kiri
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text pertanyaan
              const Text('Apakah kamu yakin ingin menghapus task ini?'),
              const SizedBox(height: 12),
              // Container untuk preview task yang akan dihapus
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                // Preview task dalam tanda kutip
                child: Text(
                  '"${taskToDelete.title}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Actions = tombol-tombol di bawah dialog
          actions: [
            // Tombol Batal
            TextButton(
              // Tutup dialog dan return false
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            // Tombol Hapus
            ElevatedButton(
              // Tutup dialog dan return true
              onPressed: () => Navigator.of(context).pop(true),
              // Styling button merah
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Cek apakah user pilih hapus (shouldDelete == true)
    if (shouldDelete == true) {
      setState(() {
        tasks.removeAt(index); // Hapus dari list
      });

      // Debug print
      debugPrint('Task dihapus: $taskToDelete');
      debugPrint('Sisa tasks: ${tasks.length}');
    } else {
      debugPrint('Delete dibatalkan');
    }
  }

  // Function untuk toggle status completed
  void toggleTask(int index) {
    setState(() {
      tasks[index].toggle(); // Pakai method toggle dari Task class
    });

    Task task = tasks[index];
    String status = task.isCompleted ? "selesai" : "belum selesai";
    debugPrint('Task $status: ${task.title}');
  }

  // Override method build untuk membuat UI
  @override
  Widget build(BuildContext context) {
    // Return UI yang sama seperti Tahap 2
    return Scaffold(
      // AppBar di bagian atas
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blue,
      ),
      // Body dengan padding di semua sisi
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Column untuk layout vertikal
        child: Column(
          children: [
            // Container untuk area input form
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              // Column di dalam container
              child: Column(
                children: [
                  // Input field untuk ketik task
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: 'Ketik task baru di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                  ),
                  // Jarak vertikal
                  const SizedBox(height: 12),
                  // Container untuk button
                  SizedBox(
                    width: double.infinity,
                    // Button untuk add task
                    child: ElevatedButton(
                      // Action saat button ditekan
                      onPressed: () {
                        addTask();
                      },
                      // Styling button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      // Isi button: Row dengan icon dan text
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text(
                            'Add Task',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Text counter untuk menampilkan jumlah tasks
            Text(
              'Total Tasks: ${tasks.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            // Jarak vertikal sebelum area list
            const SizedBox(height: 20),
            // Expanded mengambil sisa ruang yang tersedia di Column
            Expanded(
              // Container untuk styling area list
              child: Container(
                // Lebar penuh
                width: double.infinity,
                // Padding di dalam container
                padding: const EdgeInsets.all(16),
                // Dekorasi container: border dan border radius
                decoration: BoxDecoration(
                  // Border abu-abu di sekeliling
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  // Sudut melengkung
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Isi container: placeholder text di tengah
                child: tasks.isEmpty
                ?
                  Center(
                    child: Column(
                      // Center semua content di tengah
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon inbox kosong
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        // Jarak vertikal
                        const SizedBox(height: 16),
                        // Text utama
                        Text(
                          'Belum ada task',
                            style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        // Jarak kecil
                        const SizedBox(height: 8),
                        // Text penjelasan
                        Text(
                          'Tambahkan task pertamamu di atas!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  // Jumlah item yang akan dibuat
                  itemCount: tasks.length,
                  // Function yang dipanggil untuk membuat setiap item
                  itemBuilder: (context, index) {
                    Task task = tasks[index]; // Ambil Task object
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          // Background berubah berdasarkan status
                          color: task.isCompleted ? Colors.green[50] : Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: task.isCompleted
                              ? Border.all(color: Colors.green[200]!, width: 2) // Border hijau jika selesai
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 50),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Opacity(
                          opacity: task.isCompleted ? 0.7 : 1.0, // Completed task lebih transparan
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                // Warna berubah berdasarkan status
                                color: task.isCompleted ? Colors.green[100] : Colors.blue[100],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: task.isCompleted
                                    ? Icon(Icons.check, color: Colors.green[700]) // Icon check jika selesai
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              task.title, // Akses .title dari Task object
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                                // STRIKETHROUGH untuk completed task
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              task.isCompleted ? 'Selesai ✅' : 'Belum selesai',
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isCompleted ? Colors.green[600] : Colors.grey[600],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // CHECKBOX untuk toggle complete
                                IconButton(
                                  icon: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task.isCompleted ? Colors.green[600] : Colors.grey[400],
                                  ),
                                  onPressed: () => toggleTask(index),
                                  tooltip: task.isCompleted
                                      ? 'Mark as incomplete'
                                      : 'Mark as complete',
                                ),
                                // Delete button
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                                  onPressed: () => removeTask(index),
                                  tooltip: 'Hapus task',
                                ),
                              ],
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            // Tap pada item juga bisa toggle
                            onTap: () => toggleTask(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // Cleanup TextEditingController untuk prevent memory leaks
    taskController.dispose();
    // Call parent dispose
    super.dispose();
  }
}