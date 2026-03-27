import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

class ConsultarReportes extends StatelessWidget {
  const ConsultarReportes({super.key});

  static const PdfColor darkGreen = PdfColor.fromInt(0xFF173831);
  static const PdfColor resumenBoxColor = PdfColor.fromInt(0xFF1B302F);

  Future<void> _exportarReporte(BuildContext context, String tipo) async {
    pw.MemoryImage? logoImage;

    // 1. Cargar el logo (Ruta corregida fuera de lib)
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      print("✅ Logo cargado con éxito");
    } catch (e) {
      print("❌ ERROR cargando el logo: $e");
    }

    final pdf = pw.Document();

    // Cargar fuentes para evitar el error de Helvetica (Soporte Unicode para $)
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- ENCABEZADO DISEÑO ORIGINAL ---
            pw.Container(
              color: darkGreen,
              padding: const pw.EdgeInsets.all(15),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Cuadro gris para destacar el logo
                  pw.Container(
                    width: 70,
                    height: 70,
                    color: PdfColors.grey300,
                    padding: const pw.EdgeInsets.all(5),
                    child: logoImage != null
                        ? pw.Image(logoImage)
                        : pw.Center(
                            child: pw.Text(
                              "LOGO",
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
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

            // --- SECCIÓN: RESUMEN GENERAL ---
            pw.Text(
              "Resumen General",
              style: pw.TextStyle(fontSize: 18, font: fontBold),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                _buildResumenBox("10", "Total ventas", fontRegular, fontBold),
                _buildResumenBox(
                  "29",
                  "Productos vendidos",
                  fontRegular,
                  fontBold,
                ),
                _buildResumenBox(
                  "\$4,716.54",
                  "Ingreso total",
                  fontRegular,
                  fontBold,
                ),
                _buildResumenBox(
                  "\$471.65",
                  "Promedio/venta",
                  fontRegular,
                  fontBold,
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // --- SECCIÓN: DETALLE (TABLA) ---
            pw.Text(
              "Detalle de ${tipo}",
              style: pw.TextStyle(fontSize: 18, font: fontBold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                font: fontBold,
                fontSize: 12,
              ),
              cellStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: darkGreen),
              headers: tipo == "Ventas"
                  ? <String>['#', 'Fecha', 'Usuario', 'Productos', 'Total']
                  : <String>['#', 'Producto', 'Categoría', 'Stock', 'Precio'],
              data: tipo == "Ventas"
                  ? <List<String>>[
                      ['1', '2024-01-05', 'Carlos Méndez', '3', '\$450.00'],
                      ['2', '2024-01-07', 'Sofía Ramírez', '1', '\$120.50'],
                      ['3', '2024-01-10', 'Luis Torres', '5', '\$980.75'],
                    ]
                  : <List<String>>[
                      ['1', 'Aceite Vegetal', 'Abarrotes', '45', '\$35.00'],
                      ['2', 'Arroz 1kg', 'Granos', '120', '\$22.50'],
                    ],
            ),

            // Barra de Total al final de la tabla
            pw.Container(
              alignment: pw.Alignment.centerRight,
              padding: const pw.EdgeInsets.all(5),
              color: darkGreen,
              child: pw.Text(
                "TOTAL: \$4,716.54",
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

    // 3. Guardar el archivo
    final Uint8List pdfBytes = await pdf.save();
    String? rutaDestino = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar Reporte',
      fileName: 'Reporte_${tipo.toLowerCase()}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (rutaDestino != null) {
      final File archivoFinal = File(rutaDestino);
      await archivoFinal.writeAsBytes(pdfBytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Reporte guardado en: $rutaDestino")),
        );
      }
    }
  }

  // Widget auxiliar para las tarjetas de resumen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Centro de Reportes"),
        backgroundColor: const Color(0xFF173831),
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
        onTap: () => _exportarReporte(context, tipo),
      ),
    );
  }
}
