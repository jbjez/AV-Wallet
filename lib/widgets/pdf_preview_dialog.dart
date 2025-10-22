import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import 'dart:io';
import 'dart:async';

class PdfPreviewDialog extends StatefulWidget {
  final String pdfPath;
  final String calculationName;

  const PdfPreviewDialog({
    super.key,
    required this.pdfPath,
    required this.calculationName,
  });

  @override
  State<PdfPreviewDialog> createState() => _PdfPreviewDialogState();
}

class _PdfPreviewDialogState extends State<PdfPreviewDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;
  Timer? _loadingTimeout;
  bool _useWebView = false;

  @override
  void initState() {
    super.initState();
    print('🚀 PdfPreviewDialog initState - Chemin: ${widget.pdfPath}');
    
    // Utiliser WebView par défaut car PDFView ne fonctionne pas
    _useWebView = true;
    
    // Timeout après 10 secondes pour WebView
    _loadingTimeout = Timer(const Duration(seconds: 10), () {
      if (_isLoading) {
        print('⏰ TIMEOUT: Le PDF met trop de temps à se charger (10s)');
        setState(() {
          _errorMessage = 'Timeout: Le PDF met trop de temps à se charger (10s)';
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // En-tête avec titre et boutons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128), // Bleu nuit
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.calculationName,
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu PDF
            Expanded(
              child: _buildPdfContent(),
            ),
            
            // Barre de navigation en bas
            if (_totalPages > 0) _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel_button),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                      _useWebView = false;
                    });
                    // Redémarrer le timeout
                    _loadingTimeout?.cancel();
                    _loadingTimeout = Timer(const Duration(seconds: 15), () {
                      if (_isLoading) {
                        setState(() {
                          _errorMessage = 'Timeout: Le PDF met trop de temps à se charger (15s)';
                          _isLoading = false;
                        });
                      }
                    });
                  },
                  child: const Text('Réessayer PDFView'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                      _useWebView = true;
                    });
                    // Redémarrer le timeout
                    _loadingTimeout?.cancel();
                    _loadingTimeout = Timer(const Duration(seconds: 10), () {
                      if (_isLoading) {
                        setState(() {
                          _errorMessage = 'Timeout: Le PDF met trop de temps à se charger (10s)';
                          _isLoading = false;
                        });
                      }
                    });
                  },
                  child: const Text('Essayer WebView'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement du PDF...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Fichier: ${widget.pdfPath.split('/').last}',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Taille: ${_getFileSize()}',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Timeout: 10 secondes',
              style: TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        ),
      );
    }

    // Utiliser WebView comme fallback
    if (_useWebView) {
      print('🌐 Utilisation de WebView pour afficher le PDF');
      return _buildWebViewPdf();
    }

    print('📄 Création du PDFView avec le chemin: ${widget.pdfPath}');
    print('📄 Vérification du fichier avant PDFView:');
    print('   - Fichier existe: ${File(widget.pdfPath).existsSync()}');
    if (File(widget.pdfPath).existsSync()) {
      print('   - Taille: ${File(widget.pdfPath).lengthSync()} bytes');
      print('   - Permissions: ${File(widget.pdfPath).statSync().mode}');
    }
    
    return PDFView(
      filePath: widget.pdfPath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      // Optimisations pour les PDFs volumineux
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        print('✅ PDF rendu avec $pages pages');
        _loadingTimeout?.cancel(); // Annuler le timeout
        setState(() {
          _totalPages = pages!;
          _isLoading = false;
        });
      },
      onViewCreated: (PDFViewController controller) {
        print('✅ PDF controller créé');
        _pdfController = controller;
      },
      onPageChanged: (int? page, int? total) {
        print('📄 Page changée: ${page ?? 0} / ${total ?? 0}');
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
      onError: (error) {
        print('❌ Erreur PDF: $error');
        _loadingTimeout?.cancel(); // Annuler le timeout
        setState(() {
          _errorMessage = 'Erreur lors du chargement du PDF: $error';
          _isLoading = false;
        });
      },
      onPageError: (page, error) {
        print('❌ Erreur page $page: $error');
      },
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton page précédente
          IconButton(
            onPressed: _currentPage > 0 ? _previousPage : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage > 0 ? Colors.blue[700] : Colors.grey[300],
              foregroundColor: Colors.white,
            ),
          ),
          
          // Informations de page
          Text(
            '${_currentPage + 1} / $_totalPages',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Bouton page suivante
          IconButton(
            onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage < _totalPages - 1 ? Colors.blue[700] : Colors.grey[300],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileSize() {
    try {
      final file = File(widget.pdfPath);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) {
          return '$bytes B';
        } else if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
    } catch (e) {
      print('Erreur lors de la lecture de la taille du fichier: $e');
    }
    return 'Taille inconnue';
  }

  void _previousPage() {
    if (_pdfController != null && _currentPage > 0) {
      _pdfController!.setPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_pdfController != null && _currentPage < _totalPages - 1) {
      _pdfController!.setPage(_currentPage + 1);
    }
  }

  Widget _buildWebViewPdf() {
    print('🌐 Création du WebView pour PDF: ${widget.pdfPath}');
    
    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              print('✅ WebView PDF chargé');
              _loadingTimeout?.cancel();
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              print('❌ Erreur WebView: ${error.description}');
              _loadingTimeout?.cancel();
              setState(() {
                _errorMessage = 'Erreur WebView: ${error.description}';
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.file(widget.pdfPath)),
    );
  }
}

// Fonction utilitaire pour afficher le popup
void showPdfPreview(BuildContext context, String pdfPath, String calculationName) {
  print('Tentative d\'ouverture du PDF: $pdfPath');
  
  // Vérifier que le fichier existe
  final file = File(pdfPath);
  if (!file.existsSync()) {
    print('Fichier PDF introuvable: $pdfPath');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fichier PDF introuvable: ${file.path.split('/').last}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final fileSize = file.lengthSync();
  print('Fichier PDF trouvé, taille: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(1)} KB)');
  
  // Afficher un SnackBar informatif
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Ouverture du PDF: ${file.path.split('/').last} (${(fileSize / 1024).toStringAsFixed(1)} KB)'),
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 2),
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => PdfPreviewDialog(
      pdfPath: pdfPath,
      calculationName: calculationName,
    ),
  );
}
