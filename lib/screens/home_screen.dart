import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/gate_status.dart';
import '../services/gate_service.dart';
import '../services/signalr_service.dart';
import '../services/auth_service.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GateService _gateService = GateService();
  final SignalRService _signalRService = SignalRService();
  final AuthService _authService = AuthService();
  
  GateStatus? _gateStatus;
  bool _isLoading = true;
  bool _isControlling = false;
  StreamSubscription? _signalRSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _signalRSubscription?.cancel();
    _signalRService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
      if (!_signalRService.isConnected) {
        _connectSignalR();
      }
    }
  }

  Future<void> _initialize() async {
    await _refreshStatus();
    await _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    try {
      await _signalRService.connect();
      _signalRSubscription = _signalRService.stateStream.listen((data) {
        if (mounted) {
          setState(() {
            _gateStatus = GateStatus(
              state: data['state'] as String,
              lastUpdated: DateTime.parse(data['lastUpdated'] as String),
              lastActionByUserName: data['userName'] as String?,
            );
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting SignalR: $e');
      }
    }
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await _gateService.getStatus();
      if (mounted) {
        setState(() {
          _gateStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar estado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _controlGate() async {
    if (_isControlling) return;

    setState(() => _isControlling = true);

    try {
      final status = await _gateService.controlGate('TOGGLE');
      if (mounted) {
        setState(() {
          _gateStatus = status;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status?.isOpen == true 
                  ? '🚪 Portão a abrir...' 
                  : '🚪 Portão a fechar...'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isControlling = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminar Sessão'),
        content: const Text('Tem a certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Color _getStatusColor() {
    if (_gateStatus == null) return Colors.grey;
    if (_gateStatus!.isOpen) return Colors.red;
    if (_gateStatus!.isClosed) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon() {
    if (_gateStatus == null) return Icons.help_outline;
    if (_gateStatus!.isOpen) return Icons.garage_outlined;
    if (_gateStatus!.isClosed) return Icons.garage;
    return Icons.help_outline;
  }

  String _getStatusText() {
    if (_gateStatus == null) return 'Carregando...';
    if (_gateStatus!.isOpen) return 'ABERTO';
    if (_gateStatus!.isClosed) return 'FECHADO';
    return 'DESCONHECIDO';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Controlo do Portão'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(),
                              size: 60,
                              color: _getStatusColor(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Status Text
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Last Updated
                          if (_gateStatus != null)
                            Text(
                              'Atualizado: ${_formatDateTime(_gateStatus!.lastUpdated)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          
                          // Last Action By
                          if (_gateStatus?.lastActionByUserName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Por: ${_gateStatus!.lastActionByUserName}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Control Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isControlling ? null : _controlGate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: _isControlling
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _gateStatus?.isOpen == true
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _gateStatus?.isOpen == true
                                        ? 'FECHAR PORTÃO'
                                        : 'ABRIR PORTÃO',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info Cards
                    if (_gateStatus != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Última Abertura',
                              _gateStatus!.lastOpenedAt != null
                                  ? _formatDateTime(_gateStatus!.lastOpenedAt!)
                                  : 'N/A',
                              Icons.lock_open,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              'Último Fecho',
                              _gateStatus!.lastClosedAt != null
                                  ? _formatDateTime(_gateStatus!.lastClosedAt!)
                                  : 'N/A',
                              Icons.lock,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
