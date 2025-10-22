import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:av_wallet/l10n/app_localizations.dart';

class SpeedtestWebView extends StatefulWidget {
  const SpeedtestWebView({super.key});

  @override
  State<SpeedtestWebView> createState() => _SpeedtestWebViewState();
}

class _SpeedtestWebViewState extends State<SpeedtestWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  final bool _showWebChoice = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Injecter CSS pour une taille agrandie de 35% et corriger la roue de test
            _controller.runJavaScript('''
              var style = document.createElement('style');
              style.innerHTML = `
                body { 
                  margin: 0; 
                  padding: 6px; 
                  overflow-x: auto; 
                  overflow-y: auto;
                  -webkit-overflow-scrolling: touch;
                  transform: scale(0.4);
                  transform-origin: top left;
                  width: 250%;
                  height: 250%;
                  background: #f0f0f0;
                  min-height: 100vh;
                }
                .container { 
                  max-width: 100%; 
                  overflow-x: hidden; 
                  display: flex;
                  justify-content: center;
                  align-items: flex-start;
                  min-height: 100vh;
                }
                .speedtest-container { 
                  max-width: 100%; 
                  overflow-x: hidden; 
                  display: flex;
                  justify-content: center;
                  align-items: flex-start;
                }
                /* Masquer toutes les publicités et overlays */
                .ad, .advertisement, .ads, .ad-container, .ad-banner, .ad-wrapper,
                [class*="ad-"], [class*="advertisement"], [class*="ads-"],
                [id*="ad-"], [id*="advertisement"], [id*="ads-"],
                .google-ad, .adsense, .doubleclick, .pub, .publicite,
                iframe[src*="ads"], iframe[src*="doubleclick"], iframe[src*="googlesyndication"],
                /* Masquer les overlays de rate limit et autres */
                .overlay, .modal-overlay, .rate-limit-overlay, .error-overlay,
                [class*="overlay"], [class*="modal"], [class*="popup"], [class*="dialog"],
                .speedtest-overlay, .test-overlay, .loading-overlay,
                /* Masquer les éléments de titre qui peuvent avoir des overlays */
                .title-overlay, .header-overlay, .banner-overlay {
                  display: none !important;
                  visibility: hidden !important;
                  opacity: 0 !important;
                  height: 0 !important;
                  width: 0 !important;
                  margin: 0 !important;
                  padding: 0 !important;
                  position: absolute !important;
                  z-index: -1 !important;
                }
                /* Masquer les éléments de navigation et footer */
                .header, .footer, .nav, .navigation, .menu, .sidebar,
                [class*="header"], [class*="footer"], [class*="nav"], [class*="menu"],
                [id*="header"], [id*="footer"], [id*="nav"], [id*="menu"] {
                  display: none !important;
                }
                /* Garder seulement le test principal et forcer la visibilité */
                .speedtest-container, .test-container, .main-test,
                [class*="speedtest"], [class*="test-"], .result-container,
                .main-content, .content, .test-content {
                  display: block !important;
                  visibility: visible !important;
                  opacity: 1 !important;
                  z-index: 10 !important;
                  position: relative !important;
                }
                
                /* Forcer la visibilité des éléments de test */
                .speedtest-container *, .test-container *, .main-test * {
                  visibility: visible !important;
                  opacity: 1 !important;
                }
                
                /* Masquer spécifiquement les éléments de rate limit */
                [class*="rate"], [class*="limit"], [class*="blocked"],
                [class*="error"], [class*="warning"], [class*="restricted"] {
                  display: none !important;
                }
                /* Optimiser la taille des éléments du test pour la nouvelle échelle */
                .speedtest-container * {
                  font-size: 11px !important;
                  line-height: 1.3 !important;
                }
                .speedtest-container button {
                  font-size: 12px !important;
                  padding: 7px 14px !important;
                  margin: 3px !important;
                  min-height: 28px !important;
                  min-width: 70px !important;
                  border-radius: 5px !important;
                  cursor: pointer !important;
                }
                .speedtest-container input {
                  font-size: 11px !important;
                  padding: 5px 7px !important;
                  min-height: 22px !important;
                }
                /* Masquer les popups et modales */
                .modal, .popup, .dialog, .overlay,
                [class*="modal"], [class*="popup"], [class*="dialog"] {
                  display: none !important;
                }
                /* Améliorer la visibilité du bouton principal */
                .start-button, .go-button, [class*="start"], [class*="go"], 
                .speedtest-start-button, .test-button, button[class*="test"] {
                  background-color: #007bff !important;
                  color: white !important;
                  font-weight: bold !important;
                  font-size: 13px !important;
                  padding: 9px 18px !important;
                  border-radius: 7px !important;
                  border: none !important;
                  cursor: pointer !important;
                  min-height: 36px !important;
                  min-width: 90px !important;
                  box-shadow: 0 2px 6px rgba(0,123,255,0.3) !important;
                  transition: all 0.2s ease !important;
                }
                
                /* Corriger la roue de test - supprimer les overlays bleus */
                .speedtest-gauge, .gauge, .speedometer, [class*="gauge"], [class*="speedometer"],
                .gauge-container, .speedtest-container .gauge, .test-gauge {
                  width: 180px !important;
                  height: 180px !important;
                  margin: 20px auto !important;
                  display: block !important;
                  background: transparent !important;
                  border: none !important;
                  box-shadow: none !important;
                  position: relative !important;
                  z-index: 10 !important;
                }
                
                /* Supprimer les overlays bleus qui masquent la roue */
                .gauge-overlay, .speedtest-overlay, [class*="overlay"], 
                .gauge-container::before, .gauge-container::after,
                .speedtest-gauge::before, .speedtest-gauge::after {
                  display: none !important;
                  background: transparent !important;
                  opacity: 0 !important;
                }
                
                /* Forcer la visibilité des éléments SVG de la roue */
                .gauge svg, .speedtest-gauge svg, [class*="gauge"] svg {
                  display: block !important;
                  visibility: visible !important;
                  opacity: 1 !important;
                  z-index: 20 !important;
                }
                
                /* Corriger les cercles et arcs de la roue */
                .gauge circle, .gauge path, .gauge line,
                .speedtest-gauge circle, .speedtest-gauge path, .speedtest-gauge line {
                  fill: none !important;
                  stroke: #007bff !important;
                  stroke-width: 2 !important;
                  opacity: 1 !important;
                }
                
                /* Permettre le scroll et centrer le contenu */
                .speedtest-container, .main-content, [class*="main"] {
                  display: block !important;
                  text-align: center !important;
                  padding: 15px !important;
                  max-width: 100% !important;
                  overflow: visible !important;
                }
                /* Optimiser l'affichage des résultats */
                .result-container, .results, [class*="result"] {
                  font-size: 12px !important;
                  line-height: 1.4 !important;
                  padding: 10px !important;
                  margin: 10px !important;
                  background: rgba(255,255,255,0.9) !important;
                  border-radius: 7px !important;
                  text-align: center !important;
                }
                * { 
                  box-sizing: border-box; 
                }
              `;
              document.head.appendChild(style);
            ''');
            
            // Injecter JavaScript pour forcer le choix web et supprimer les overlays
            _controller.runJavaScript('''
              // Fonction pour supprimer les overlays problématiques
              function removeOverlays() {
                // Supprimer les overlays de rate limit et autres
                const overlaysToRemove = document.querySelectorAll(
                  '.overlay, .modal-overlay, .rate-limit-overlay, .error-overlay, ' +
                  '[class*="overlay"], [class*="modal"], [class*="popup"], [class*="dialog"], ' +
                  '.speedtest-overlay, .test-overlay, .loading-overlay, ' +
                  '.title-overlay, .header-overlay, .banner-overlay, ' +
                  '[class*="rate"], [class*="limit"], [class*="blocked"], ' +
                  '[class*="error"], [class*="warning"], [class*="restricted"]'
                );
                
                overlaysToRemove.forEach(el => {
                  el.style.display = 'none';
                  el.style.visibility = 'hidden';
                  el.style.opacity = '0';
                  el.style.zIndex = '-1';
                  el.style.position = 'absolute';
                });
                
                // Forcer la visibilité du contenu principal
                const mainContent = document.querySelectorAll(
                  '.speedtest-container, .test-container, .main-test, ' +
                  '[class*="speedtest"], [class*="test-"], .result-container, ' +
                  '.main-content, .content, .test-content'
                );
                
                mainContent.forEach(el => {
                  el.style.display = 'block';
                  el.style.visibility = 'visible';
                  el.style.opacity = '1';
                  el.style.zIndex = '10';
                  el.style.position = 'relative';
                });
              }
              
              // Exécuter immédiatement
              removeOverlays();
              
              // Exécuter périodiquement pour supprimer les nouveaux overlays
              setInterval(removeOverlays, 500);
              
              setTimeout(() => {
                // Chercher et cliquer sur le bouton "Continue to web version" s'il existe
                const webButton = document.querySelector('[data-testid="web-button"], .web-button, [href*="web"], button:contains("web"), a:contains("web")');
                if (webButton) {
                  webButton.click();
                }
                
                // Masquer les popups d'app
                const appPopups = document.querySelectorAll('[class*="app-popup"], [class*="download-app"], [class*="mobile-app"]');
                appPopups.forEach(popup => popup.style.display = 'none');
                
                // Masquer les bannières d'app
                const appBanners = document.querySelectorAll('[class*="app-banner"], [class*="download-banner"]');
                appBanners.forEach(banner => banner.style.display = 'none');
                
                // Supprimer les overlays une dernière fois
                removeOverlays();
              }, 1000);
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
        ),
      )
      // URL directe du test Speedtest.net
      ..loadRequest(Uri.parse('https://www.speedtest.net/'));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.all(6), // Marge légèrement augmentée
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withValues(alpha: 0.12), // Opacité légèrement augmentée
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          children: [
            // En-tête avec titre et contrôles - ajusté pour la nouvelle taille
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), // Padding légèrement augmenté
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06), // Opacité légèrement augmentée
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12), // Opacité légèrement augmentée
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.speed,
                    color: Colors.white,
                    size: 15, // Icône légèrement plus grande
                  ),
                  const SizedBox(width: 5), // Espacement légèrement augmenté
                  Expanded(
                    child: Text(
                      loc.bandwidth_test_title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12, // Police légèrement plus grande
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Bouton pour forcer la version web - ajusté
                  IconButton(
                    onPressed: () {
                      _controller.runJavaScript('''
                        // Forcer le choix web
                        const webButton = document.querySelector('[data-testid="web-button"], .web-button, [href*="web"], button:contains("web"), a:contains("web")');
                        if (webButton) {
                          webButton.click();
                        }
                        
                        // Masquer tous les éléments d'app
                        const elementsToHide = document.querySelectorAll('[class*="app"], [class*="download"], [class*="mobile-app"], [class*="ios"], [class*="android"]');
                        elementsToHide.forEach(el => {
                          if (el.textContent.toLowerCase().includes('app') || 
                              el.textContent.toLowerCase().includes('download') ||
                              el.textContent.toLowerCase().includes('mobile')) {
                            el.style.display = 'none';
                          }
                        });
                        
                        // Rediriger vers la version web si possible
                        if (window.location.href.includes('mobile') || window.location.href.includes('app')) {
                          window.location.href = 'https://www.speedtest.net/';
                        }
                      ''');
                    },
                    icon: Icon(
                      Icons.web,
                      color: Colors.white,
                      size: 15, // Icône légèrement plus grande
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 22, // Taille légèrement augmentée
                      minHeight: 22, // Taille légèrement augmentée
                    ),
                    tooltip: 'Web',
                  ),
                  const SizedBox(width: 3), // Espacement légèrement augmenté
                  // Bouton de rafraîchissement - ajusté avec nettoyage des overlays
                  IconButton(
                    onPressed: () {
                      // Nettoyer les overlays avant de recharger
                      _controller.runJavaScript('''
                        // Supprimer tous les overlays avant rechargement
                        const overlaysToRemove = document.querySelectorAll(
                          '.overlay, .modal-overlay, .rate-limit-overlay, .error-overlay, ' +
                          '[class*="overlay"], [class*="modal"], [class*="popup"], [class*="dialog"], ' +
                          '.speedtest-overlay, .test-overlay, .loading-overlay, ' +
                          '.title-overlay, .header-overlay, .banner-overlay, ' +
                          '[class*="rate"], [class*="limit"], [class*="blocked"], ' +
                          '[class*="error"], [class*="warning"], [class*="restricted"]'
                        );
                        overlaysToRemove.forEach(el => el.remove());
                      ''');
                      
                      // Recharger avec un délai pour éviter les rate limits
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _controller.reload();
                      });
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 15, // Icône légèrement plus grande
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 22, // Taille légèrement augmentée
                      minHeight: 22, // Taille légèrement augmentée
                    ),
                  ),
                ],
              ),
            ),
            // WebView
            Expanded(
              child: Stack(
                children: [
                  if (_error != null)
                    // Affichage d'erreur
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _controller.reload();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  else
                    // WebView
                    WebViewWidget(controller: _controller),
                  
                  // Indicateur de chargement
                  if (_isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chargement de Speedtest.net...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
