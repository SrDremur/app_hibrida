import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:app_hibrida/rest_api.dart/auth_reports.dart';

class ConsultarReportes extends StatefulWidget {
  const ConsultarReportes({super.key});

  @override
  State<ConsultarReportes> createState() => _ConsultarReportesState();
}

class _ConsultarReportesState extends State<ConsultarReportes> {
  static const PdfColor darkGreen = PdfColor.fromInt(0xFF173831);
  static const PdfColor resumenBoxColor = PdfColor.fromInt(0xFF1B302F);

  bool _estaCargando = false;

  // ✅ Formateador de fecha corregido
  String _formatearFecha(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _exportarReporte(BuildContext context, String tipo) async {
    setState(() => _estaCargando = true);

    try {
      // 1. CARGA DE DATOS Y VARIABLES (Definidas al inicio para evitar "Undefined name")
      List<dynamic> datosBack = [];
      List<dynamic> listaProductos = [];
      double ingresoTotal = 0;
      String promedio = '0.00';

      if (tipo == "Ventas") {
        final resultados = await Future.wait([
          ReportService.fetchVentas(),
          ReportService.fetchProductos(),
        ]);
        datosBack = resultados[0];
        listaProductos = resultados[1];
      } else {
        datosBack = await ReportService.fetchProductos();
        listaProductos = datosBack;
      }

      // 2. CÁLCULOS
      for (var item in datosBack) {
        dynamic valor = (tipo == "Ventas")
            ? item['total_price']
            : item['price'];
        ingresoTotal += double.tryParse(valor?.toString() ?? '0') ?? 0.0;
      }

      promedio = datosBack.isNotEmpty
          ? (ingresoTotal / datosBack.length).toStringAsFixed(2)
          : '0.00';

      // 3. RECURSOS DEL PDF
      pw.MemoryImage? logoImage;
      try {
        final ByteData logoData = await rootBundle.load(
          'assets/images/logo.png',
        );
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (e) {
        print("❌ Error logo: $e");
      }

      final pdf = pw.Document();
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      // 4. GENERACIÓN DEL DOCUMENTO (Tu diseño original)
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

              // RESUMEN GENERAL (Aquí ya no hay error de ingresoTotal)
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

              // TABLA DE DATOS
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
                    ? <String>['#', 'Fecha', 'Productos', 'Total']
                    : <String>['#', 'Producto', 'Stock', 'Precio'],
                data: datosBack.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  var item = entry.value;

                  if (tipo == "Ventas") {
                    List productosEnVenta = item['products'] as List? ?? [];
                    List<String> nombresList = [];

                    for (var pEnVenta in productosEnVenta) {
                      final idBuscado = pEnVenta['id_product'].toString();
                      var prodEncontrado = listaProductos.firstWhere(
                        (p) =>
                            p['id'].toString() == idBuscado ||
                            p['id_product']?.toString() == idBuscado,
                        orElse: () => null,
                      );

                      String nombre = prodEncontrado != null
                          ? (prodEncontrado['product']?.toString() ??
                                prodEncontrado['name']?.toString() ??
                                "Sin nombre")
                          : "ID: $idBuscado";

                      nombresList.add("$nombre (x${pEnVenta['quantity']})");
                    }

                    return [
                      idx.toString(),
                      _formatearFecha(item['sale_date']?.toString()),
                      nombresList.isEmpty
                          ? "Sin detalle"
                          : nombresList.join(", "),
                      "\$${double.tryParse(item['total_price']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                    ];
                  } else {
                    return [
                      idx.toString(),
                      item['product']?.toString() ?? 'N/A',
                      item['stock']?.toString() ?? '0',
                      "\$${double.tryParse(item['price']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
                    ];
                  }
                }).toList(),
              ),

              // TOTAL FINAL
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

      // 5. GUARDAR Y NOTIFICAR
      final Uint8List pdfBytes = await pdf.save();
      String? ruta = await FilePicker.saveFile(
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

  // ✅ Método de las cajas de resumen (Dentro de la clase)
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
}
