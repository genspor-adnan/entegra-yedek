/** Hasta icmali ekran + A4 baskı stili (HastaIcmal). */
export const stil = `
.hi-arac { display:flex; gap:6px; align-items:center; padding:6px 12px; }
.hi-arac button { border:1px solid var(--cizgi,#cdd6e0); border-radius:4px; padding:5px 11px; font-size:12px; background:var(--yuz,#fff); cursor:pointer; }
.hi-arac button.hi-ana { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; border-color:#2f6db3; }
.hi-arac .sp, .hi-serit .sp { flex:1; }
.hi-serit { display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:6px 12px; background:#f7fafc;
  border-top:1px solid var(--cizgi-ince,#e3e9f0); border-bottom:1px solid var(--cizgi-ince,#e3e9f0); }
.hi-serit .sel { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; background:var(--yuz,#fff); min-height:26px;
  display:flex; align-items:center; gap:6px; padding:0 8px; font-size:12px; }
.hi-serit input[type=date] { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.hi-ozet { display:grid; grid-template-columns:repeat(8,1fr); gap:1px; background:var(--cizgi-ince,#e3e9f0); border-bottom:1px solid var(--cizgi,#cdd6e0); }
@media (max-width:1100px) { .hi-ozet { grid-template-columns:repeat(4,1fr); } }
.hi-kutu { background:var(--yuz,#fff); padding:6px 10px; }
.hi-kutu .bas { font-size:10.5px; color:var(--soluk,#6b7a8b); text-transform:uppercase; letter-spacing:.3px; }
.hi-kutu .deg { font-size:16px; font-weight:bold; color:var(--baslik,#14315a); }
.hi-kutu .alt { font-size:10.5px; color:var(--soluk,#6b7a8b); }
.hi-kutu.mor .deg { color:#6a3fb5; } .hi-kutu.iyi .deg { color:#2e7d46; } .hi-kutu.uy .deg { color:#b7791f; } .hi-kutu.teh .deg { color:#b3261e; }
.hi-govde { padding:10px 12px; }
/* Önizleme sekmesi: A4 ortada, kağıt genişliğinde. Yazdır her sekmede çalışsın
   diye belge hep DOM'da; başka sekmedeyken yalnız EKRANDA gizli. */
.hi-onizleme { max-width:794px; margin:12px auto 0; }
@media screen { .hi-onizleme.gizli { display:none; } }
.hi-sol .katab { margin-bottom:0; }
.hi-tablo { width:100%; border-collapse:collapse; font-size:12px; background:var(--yuz,#fff); }
.hi-tablo th, .hi-tablo td { border-bottom:1px solid var(--cizgi-ince,#e3e9f0); padding:5px 8px; text-align:left; }
.hi-tablo th { background:#f3f6fa; font-weight:600; }
.hi-tablo .sag { text-align:right; font-family:Consolas,monospace; } .hi-tablo th.sag { font-family:inherit; }
.hi-tablo .kir { color:#b3261e; font-weight:bold; }
.hi-tablo tr.ac { cursor:pointer; } .hi-tablo tr.sec td { background:#eef4fc; }
.hi-tablo tr.iptal td { color:#9aa7b4; text-decoration:line-through; }
.hi-tablo tr.det td { background:#f9fbfd; font-size:11px; color:#3a4c5e; padding-left:26px; }
.hi-tablo tr.top td { font-weight:bold; background:#eef4fb; }
.hi-tablo .ok { display:inline-block; width:12px; color:#2f6db3; }
.hi-tablo td:first-child, .hi-tablo td:nth-child(2) { white-space:nowrap; }
.hi-tablo .bos { color:var(--soluk,#6b7a8b); text-align:center; padding:14px; }
.bo-rz { display:inline-block; border-radius:9px; padding:0 7px; font-size:10.5px; border:1px solid transparent; }
.bo-rz.ok { background:#e2f3e8; color:#2e7d46; } .bo-rz.sari { background:#fdf6e3; color:#8a6218; }
.bo-rz.kir { background:#fbe9e7; color:#b3261e; } .bo-rz.mavi { background:#eef4fc; color:#2f6db3; }
.bo-rz.pas { background:#eceff2; color:#6b7a8b; }
.hi-a4 { background:#fff; color:#111; border:1px solid #d9dee5; padding:14px; font-size:10.5px; box-shadow:0 2px 8px rgba(0,0,0,.06); }
.a4-bas { display:flex; gap:10px; align-items:flex-start; border-bottom:2px solid #1c4374; padding-bottom:6px; }
.a4-bas .logo { width:40px; height:40px; object-fit:contain; }
.a4-bas .kurum { font-weight:bold; font-size:12px; } .a4-bas .kurum-alt { color:#555; }
.a4-tarih { margin-left:auto; text-align:right; color:#555; white-space:nowrap; }
.hi-a4 h3 { text-align:center; margin:8px 0; font-size:13px; letter-spacing:.5px; }
.a4-hasta { display:grid; grid-template-columns:1fr 1fr; gap:2px 10px; border:1px solid #bbb; padding:5px 7px; margin-bottom:6px; }
.a4-t, .a4-toplam { width:100%; border-collapse:collapse; }
.a4-t { table-layout:fixed; font-size:9.5px; } .a4-t td, .a4-t th { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.a4-t th:nth-child(1) { width:15%; } .a4-t th:nth-child(2) { width:20%; }
.a4-t td:nth-child(n+3) { text-overflow:clip; }
.a4-t th, .a4-t td { border:1px solid #ccc; padding:2px 4px; text-align:right; } .a4-t th:nth-child(-n+2), .a4-t td:nth-child(-n+2) { text-align:left; }
.a4-toplam { width:60%; margin:6px 0 0 auto; } .a4-toplam td { padding:2px 4px; } .a4-toplam td:last-child { text-align:right; }
.a4-toplam tr.kalan td { font-weight:bold; color:#b3261e; border-top:1px solid #333; }
.a4-not { color:#555; margin:8px 0; }
.a4-imza { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-top:34px; text-align:center; }
.a4-imza div { border-top:1px solid #333; padding-top:3px; }
@media print {
  body * { visibility:hidden !important; }
  .hi-a4, .hi-a4 * { visibility:visible !important; }
  .hi-a4 { position:fixed; left:0; top:0; width:100%; border:none; box-shadow:none; font-size:11px; }
}
`;
