import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GPUGridApp());
}

class GPUGridApp extends StatelessWidget {
  const GPUGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPUGrid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// โมเดลสำหรับเก็บข้อมูล GPU Job
class GpuJob {
  String id;
  String experimentName;
  String framework;
  String researcherEmail;
  int allocatedGpus;
  int maxComputeHours;

  GpuJob({
    required this.id,
    required this.experimentName,
    required this.framework,
    required this.researcherEmail,
    required this.allocatedGpus,
    required this.maxComputeHours,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<GpuJob> _jobs = [
    GpuJob(
      id: '1',
      experimentName: 'LLM-FineTune-V3',
      framework: 'PyTorch',
      researcherEmail: 'alex@ai-lab.com',
      allocatedGpus: 8,
      maxComputeHours: 48,
    ),
    GpuJob(
      id: '2',
      experimentName: 'Vision-Transformer-Train',
      framework: 'TensorFlow',
      researcherEmail: 'sarah@ml.org',
      allocatedGpus: 4,
      maxComputeHours: 12,
    ),
  ];

  void _addJob(GpuJob job) {
    setState(() {
      _jobs.add(job);
      _currentIndex = 1;
    });
  }

  void _updateJob(GpuJob updatedJob) {
    setState(() {
      final index = _jobs.indexWhere((j) => j.id == updatedJob.id);
      if (index != -1) {
        _jobs[index] = updatedJob;
      }
    });
  }

  void _deleteJob(String id) {
    setState(() {
      _jobs.removeWhere((j) => j.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      JobRequestFormTab(onSubmit: _addJob),
      GpuMonitorTab(
        jobs: _jobs,
        onUpdate: _updateJob,
        onDelete: _deleteJob,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.memory),
            SizedBox(width: 8),
            Text('GPUGrid Control Center'),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_task),
            label: 'ยื่นคำขอจอง',
          ),
          NavigationDestination(
            icon: Icon(Icons.developer_board),
            label: 'มอนิเตอร์คิวงาน',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// แท็บ 1: Form ยื่นคำขอจองโหนดประมวลผล
// ==========================================
class JobRequestFormTab extends StatefulWidget {
  final Function(GpuJob) onSubmit;

  const JobRequestFormTab({super.key, required this.onSubmit});

  @override
  State<JobRequestFormTab> createState() => _JobRequestFormTabState();
}

class _JobRequestFormTabState extends State<JobRequestFormTab> {
  final _formKey = GlobalKey<FormState>();

  final _experimentNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _gpusController = TextEditingController();
  final _hoursController = TextEditingController();

  String _selectedFramework = 'PyTorch';
  final List<String> _frameworks = ['PyTorch', 'TensorFlow', 'JAX'];

  @override
  void dispose() {
    _experimentNameController.dispose();
    _emailController.dispose();
    _gpusController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newJob = GpuJob(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        experimentName: _experimentNameController.text.trim(),
        framework: _selectedFramework,
        researcherEmail: _emailController.text.trim(),
        allocatedGpus: int.parse(_gpusController.text),
        maxComputeHours: int.parse(_hoursController.text),
      );

      widget.onSubmit(newJob);

      _experimentNameController.clear();
      _emailController.clear();
      _gpusController.clear();
      _hoursController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งคำขอจองโหนดประมวลผลสำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ยื่นคำขอจองโหนดประมวลผล GPU',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experimentNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อโปรเจกต์ / การทดลอง (Experiment Name)',
                hintText: 'เช่น LLM-FineTune-V3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ห้ามเว้นว่าง';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFramework,
              decoration: const InputDecoration(
                labelText: 'ประเภทโมเดล / Framework',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
              ),
              items: _frameworks.map((framework) {
                return DropdownMenuItem(
                  value: framework,
                  child: Text(framework),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFramework = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'อีเมลนักวิจัยหลัก (Principal Researcher)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ห้ามเว้นว่าง';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gpusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'จำนวนการ์ด GPU ที่ขอใช้ (Allocated GPUs)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grid_view),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ห้ามเว้นว่าง';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'กรุณาระบุจำนวนเต็มมากกว่า 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'เวลาจำกัดการรัน (Max Compute Hours)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ห้ามเว้นว่าง';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'กรุณาระบุจำนวนชั่วโมงให้ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send),
                label: const Text('ส่งคำขอจองทรัพยากร'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// แท็บ 2: Display จอมอนิเตอร์คิวงาน GPU
// ==========================================
class GpuMonitorTab extends StatelessWidget {
  final List<GpuJob> jobs;
  final Function(GpuJob) onUpdate;
  final Function(String) onDelete;

  const GpuMonitorTab({
    super.key,
    required this.jobs,
    required this.onUpdate,
    required this.onDelete,
  });

  void _showEditDialog(BuildContext context, GpuJob job) {
    final hoursController =
        TextEditingController(text: job.maxComputeHours.toString());
    final gpusController =
        TextEditingController(text: job.allocatedGpus.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('แก้ไขพารามิเตอร์: ${job.experimentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gpusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'จำนวน GPU (Allocated GPUs)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ขยายชั่วโมงประมวลผล (Max Hours)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedGpus = int.tryParse(gpusController.text);
              final updatedHours = int.tryParse(hoursController.text);

              if (updatedGpus != null && updatedHours != null) {
                job.allocatedGpus = updatedGpus;
                job.maxComputeHours = updatedHours;
                onUpdate(job);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, GpuJob job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการ Terminate Job'),
        content: Text(
          'คุณต้องการยกเลิกและ Terminate งาน "${job.experimentName}" ใช่หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              onDelete(job.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Terminate Job'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text('ไม่มีคิวงานที่กำลังประมวลผลอยู่'),
      );
    }

    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${job.allocatedGpus}G',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              job.experimentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Framework: ${job.framework}\n'
              'รันสูงสุด: ${job.maxComputeHours} ชม. | ผู้ขอ: ${job.researcherEmail}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, job),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmDialog(context, job),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}