import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpeedtestWebViewTab extends StatefulWidget {
  const SpeedtestWebViewTab({super.key});

  @override
  State<SpeedtestWebViewTab> createState() => _SpeedtestWebViewTabState();
}

class _SpeedtestWebViewTabState extends State<SpeedtestWebViewTab> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Mise à jour de la barre de progression si nécessaire
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Injecter du CSS pour améliorer l'affichage mobile et les popups
            _controller.runJavaScript('''
              var style = document.createElement('style');
              style.innerHTML = `
                body { 
                  margin: 0; 
                  padding: 8px; 
                  overflow-x: hidden; 
                  -webkit-overflow-scrolling: touch;
                }
                .container { 
                  max-width: 100%; 
                  overflow-x: hidden; 
                }
                .speedtest-container { 
                  max-width: 100%; 
                  overflow-x: hidden; 
                }
                /* Correction des popups et modales */
                .modal, .popup, .dialog, .overlay {
                  max-width: 90vw !important;
                  max-height: 80vh !important;
                  left: 50% !important;
                  top: 50% !important;
                  transform: translate(-50%, -50%) !important;
                  position: fixed !important;
                  z-index: 9999 !important;
                }
                .modal-content, .popup-content, .dialog-content {
                  max-width: 100% !important;
                  max-height: 100% !important;
                  overflow: auto !important;
                  padding: 10px !important;
                }
                /* Correction spécifique pour Speedtest */
                .speedtest-modal, .speedtest-popup {
                  max-width: 90vw !important;
                  max-height: 70vh !important;
                  font-size: 14px !important;
                }
                .speedtest-modal button, .speedtest-popup button {
                  font-size: 14px !important;
                  padding: 8px 16px !important;
                  margin: 4px !important;
                }
                * { 
                  box-sizing: border-box; 
                }
              `;
              document.head.appendChild(style);
            ''');
            
            // Réappliquer le CSS après un délai pour s'assurer qu'il s'applique aux éléments dynamiques
            Future.delayed(const Duration(seconds: 2), () {
              _controller.runJavaScript('''
                var existingStyle = document.getElementById('mobile-css-fix');
                if (existingStyle) {
                  existingStyle.remove();
                }
                var style = document.createElement('style');
                style.id = 'mobile-css-fix';
                style.innerHTML = `
                  .modal, .popup, .dialog, .overlay, [class*="modal"], [class*="popup"], [class*="dialog"] {
                    max-width: 90vw !important;
                    max-height: 80vh !important;
                    left: 50% !important;
                    top: 50% !important;
                    transform: translate(-50%, -50%) !important;
                    position: fixed !important;
                    z-index: 9999 !important;
                  }
                `;
                document.head.appendChild(style);
              ''');
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Gestion des erreurs
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.speedtest.net/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de chargement
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            // WebView avec contraintes appropriées et gestion d'overflow
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 16,
                      child: WebViewWidget(controller: _controller),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
