import os
import xml.etree.ElementTree as ET
import pandas as pd
from flask import Flask, request, render_template, send_file
from flask_cors import CORS
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# XML ad uzayları (namespace) tanımları
ns = {
    "cbc": "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2",
    "cac": "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
}

# Fatura klasörü
WATCH_FOLDER = "./faturalar"
OUTPUT_FILE = "fatura_kayitlari.xlsx"

app = Flask(__name__)
CORS(app)  # CORS hatalarını önlemek için

class InvoiceHandler(FileSystemEventHandler):
    def process_invoice(self, file_path):
        """ XML fatura dosyasını okuyup işleyen fonksiyon."""
        tree = ET.parse(file_path)
        root = tree.getroot()

        invoice_id = root.find("cbc:ID", ns).text if root.find("cbc:ID", ns) is not None else ""
        invoice_date = root.find("cbc:IssueDate", ns).text if root.find("cbc:IssueDate", ns) is not None else ""
        currency = root.find("cbc:DocumentCurrencyCode", ns).text if root.find("cbc:DocumentCurrencyCode", ns) is not None else ""

        invoice_lines = []
        invoice_line_elements = root.findall("cac:InvoiceLine", ns)
        
        for idx, line in enumerate(invoice_line_elements, start=1):
            product_code = line.find("cbc:ID", ns).text if line.find("cbc:ID", ns) is not None else ""
            product_name = line.find("cbc:Description", ns).text if line.find("cbc:Description", ns) is not None else ""
            kdv_orani = line.find("cac:TaxTotal/cac:TaxSubtotal/cbc:Percent", ns)
            kdv_orani = kdv_orani.text if kdv_orani is not None else ""
            
            invoice_lines.append([
                invoice_id, idx, product_code, product_name, kdv_orani
            ])
        
        df_invoice = pd.DataFrame(invoice_lines, columns=["Fatura No", "Satır No", "Ürün Kodu", "Ürün Adı", "KDV Oranı"])
        
        if os.path.exists(OUTPUT_FILE):
            df_existing = pd.read_excel(OUTPUT_FILE)
            df_combined = pd.concat([df_existing, df_invoice], ignore_index=True)
        else:
            df_combined = df_invoice
        
        df_combined.to_excel(OUTPUT_FILE, index=False)
        print(f"Fatura işlendi ve Excel'e kaydedildi: {file_path}")
    
    def on_created(self, event):
        if event.is_directory:
            return
        if event.src_path.endswith(".xml"):
            self.process_invoice(event.src_path)

@app.route('/')
def home():
    """Web arayüzü ana sayfası."""
    return "Fatura AI Ajanı Çalışıyor! Fatura yüklemek için /upload sayfasını kullanın."

@app.route('/upload', methods=['POST'])
def upload_file():
    """ Kullanıcıdan XML dosyası yükleyip işlemeyi sağlar."""
    if 'file' not in request.files:
        return "Dosya seçilmedi.", 400
    file = request.files['file']
    if file.filename == '':
        return "Dosya seçilmedi.", 400
    file_path = os.path.join(WATCH_FOLDER, file.filename)
    file.save(file_path)
    return "Fatura başarıyla yüklendi ve işleme alındı.", 200

@app.route('/download')
def download_file():
    """ İşlenen faturaların Excel dosyasını indirme."""
    if os.path.exists(OUTPUT_FILE):
        return send_file(OUTPUT_FILE, as_attachment=True)
    return "Henüz fatura işlenmedi.", 404

if __name__ == "__main__":
    os.makedirs(WATCH_FOLDER, exist_ok=True)  # Klasör yoksa oluştur
    event_handler = InvoiceHandler()
    observer = Observer()
    observer.schedule(event_handler, WATCH_FOLDER, recursive=False)
    observer.start()
    print(f"AI Fatura Ajanı çalışıyor. Klasör izleniyor: {WATCH_FOLDER}")
    
    try:
        app.run(debug=True, host='0.0.0.0', port=5000)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
