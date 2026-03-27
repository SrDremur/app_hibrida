import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
// Importa2tu nuevo servicio de reportes y el auth para la URL
import 'package:app_hibrida/rest_api.dart/auth_reports.dart';

class ConsultarReportes extends StatefulWidget {
  const ConsultarReportes({super.key});

  @override
  State<ConsultarReportes> createState() => _ConsultarReportesState();
}

class _ConsultarReportesState extends State<ConsultarReportes> {
  static const PdfColor darkGreen = PdfColor.fromInt(0xFF173831);
  static const PdfColor resumenBoxColor = PdfColor.fromInt(0xFF1B302F);

  // Variable para controlar el estado de carga
  bool _estaCargando = false;

  Future<void> _exportarReporte(BuildContext context, String tipo) async {
    setState(() => _estaCargando = true);

    try {
      // 1. OBTENER DATOS REALES DESDE EL BACKEND (Render)
      List<dynamic> datosBack = [];
      if (tipo == "Ventas") {
        datosBack = await ReportService.fetchVentas();
      } else {
        datosBack = await ReportService.fetchProductos();
      }

      if (datosBack.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ No se encontraron datos para este reporte"),
            ),
          );
        }
        setState(() => _estaCargando = false);
        return;
      }

      // Cálculos automáticos para el Resumen General
      double ingresoTotal = 0;
      for (var item in datosBack) {
        // Intentamos sumar el campo 'total' o 'precio' según el tipo
        var valorStr = tipo == "Ventas"
            ? item['total']
            : item['price'] ?? item['precio'];
        ingresoTotal += double.tryParse(valorStr?.toString() ?? '0') ?? 0;
      }

      String promedio = (ingresoTotal / datosBack.length).toStringAsFixed(2);

      // 2. CONFIGURACIÓN DEL PDF (Logo y Fuentes)
      pw.MemoryImage? logoImage;
      try {
        final ByteData logoData = await rootBundle.load(
          'assets/images/logo.png',
        );
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (e) {
        print("❌ Error cargando logo: $e");
      }

      final pdf = pw.Document();
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      // 3. CONSTRUCCIÓN DEL DOCUMENTO
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return [
              // ENCABEZADO
              pw.Container(
                color: darkGreen,
                padding: const pw.EdgeInsets.all(15),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      width: 70,
                      height: 70,
                      color: PdfColors.grey300,
                      padding: const pw.EdgeInsets.all(5),
                      child: logoImage != null
                          ? pw.Image(logoImage)
                          : pw.Center(child: pw.Text("LOGO")),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "REPORTE DE ${tipo.toUpperCase()}",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            font: fontBold,
                          ),
                        ),
                        pw.Text(
                          "Tiendita del Caballerito",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            font: fontRegular,
                          ),
                        ),
                        pw.Text(
                          "Generado: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            font: fontRegular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // RESUMEN DINÁMICO
              pw.Text(
                "Resumen General",
                style: pw.TextStyle(fontSize: 18, font: fontBold),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  _buildResumenBox(
                    datosBack.length.toString(),
                    "Registros",
                    fontRegular,
                    fontBold,
                  ),
                  _buildResumenBox(tipo, "Tipo", fontRegular, fontBold),
                  _buildResumenBox(
                    "\$${ingresoTotal.toStringAsFixed(2)}",
                    "Total",
                    fontRegular,
                    fontBold,
                  ),
                  _buildResumenBox(
                    "\$$promedio",
                    "Promedio",
                    fontRegular,
                    fontBold,
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // TABLA DE DATOS DEL BACKEND
              pw.Text(
                "Detalle de $tipo",
                style: pw.TextStyle(fontSize: 18, font: fontBold),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  font: fontBold,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: darkGreen),
                headers: tipo == "Ventas"
                    ? <String>['#', 'Fecha', 'Usuario', 'Total']
                    : <String>['#', 'Producto', 'Stock', 'Precio'],
                data: datosBack.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  var item = entry.value;

                  if (tipo == "Ventas") {
                    return [
                      idx.toString(),
                      item['fecha']?.toString() ?? 'N/A',
                      item['usuario']?.toString() ?? 'N/A',
                      "\$${item['total']?.toString() ?? '0.00'}",
                    ];
                  } else {
                    // CAMBIO CLAVE AQUÍ: 'product' en lugar de 'name'
                    return [
                      idx.toString(),
                      item['product']?.toString() ?? 'N/A',
                      item['stock']?.toString() ?? '0',
                      "\$${item['price']?.toString() ?? '0.00'}",
                    ];
                  }
                }).toList(),
              ),

              // TOTAL AL FINAL
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.all(5),
                color: darkGreen,
                child: pw.Text(
                  "VALOR TOTAL: \$${ingresoTotal.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    font: fontBold,
                    fontSize: 11,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // 4. GUARDAR ARCHIVO
      final Uint8List pdfBytes = await pdf.save();
      String? ruta = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Reporte',
        fileName: 'Reporte_${tipo.toLowerCase()}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (ruta != null) {
        final File archivo = File(ruta);
        await archivo.writeAsBytes(pdfBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("✅ Guardado en: $ruta")));
        }
      }
    } catch (e) {
      print("❌ Error general: $e");
    } finally {
      setState(() => _estaCargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Centro de Reportes"),
        backgroundColor: const Color(0xFF173831),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _btnReporte(
                  context,
                  "Reporte de Ventas",
                  Icons.receipt_long,
                  "Ventas",
                ),
                _btnReporte(
                  context,
                  "Reporte de Stock",
                  Icons.inventory_2,
                  "Stock",
                ),
              ],
            ),
          ),
          // Si está cargando, mostramos un overlay con el spinner
          if (_estaCargando)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF173831)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _btnReporte(
    BuildContext context,
    String titulo,
    IconData icon,
    String tipo,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF173831)),
        title: Text(titulo),
        trailing: const Icon(Icons.download, color: Colors.blue),
        onTap: _estaCargando ? null : () => _exportarReporte(context, tipo),
      ),
    );
  }

  pw.Widget _buildResumenBox(
    String valor,
    String etiqueta,
    pw.Font font,
    pw.Font bold,
  ) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 2),
        padding: const pw.EdgeInsets.all(10),
        color: resumenBoxColor,
        child: pw.Column(
          children: [
            pw.Text(
              valor,
              style: pw.TextStyle(
                color: PdfColors.white,
                font: bold,
                fontSize: 14,
              ),
            ),
            pw.Text(
              etiqueta,
              style: pw.TextStyle(
                color: PdfColors.white,
                font: font,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
