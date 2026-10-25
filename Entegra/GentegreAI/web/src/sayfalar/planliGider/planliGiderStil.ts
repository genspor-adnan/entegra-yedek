/**
 * PLANLI GİDER STİLİ (mockup Ekranlar/ERP/planli_gider.html, planli_gider_karti.html). Bütün sınıflar
 * `pg-` önekli: tema.css'te `.d` düğmedir, mockup'ın `.d` / `.ozet .d` adları burada KULLANILMAZ.
 * Renkler tema değişkenlerinden (koyu tema da okunur kalsın).
 */
export const PLANLI_GIDER_STILI = `
.pg { display:flex; flex-direction:column; min-height:0; background:var(--yuz); border:1px solid var(--cizgi); border-radius:4px; }
.pg-sp { margin-left:auto; }
.pg-sepv { width:1px; height:20px; background:var(--cizgi); margin:0 4px; flex:none; }
.pg-rz { display:inline-block; border-radius:9px; padding:1px 8px; font-size:10.5px; border:1px solid var(--cizgi); background:var(--yuz2); color:#4d5d6e; white-space:nowrap; }
.pg-rz.ok { background:#e2f3e8; color:#2e7d46; border-color:#bfe3cb; }
.pg-rz.mavi { background:#eef4fc; color:#2f6db3; border-color:#cfe0f5; }
.pg-rz.sari { background:#fdf6e3; color:#8a6218; border-color:#f2ddbf; }
.pg-rz.kir { background:#fbe9e7; color:#b3261e; border-color:#f3c4bf; }
.pg-rz.mor { background:#f1ecfa; color:#6a3fb5; border-color:#ddd0f2; }
.pg-borc { color:#b3261e; } .pg-ok { color:#2e7d46; } .pg-soluk { color:var(--soluk); } .pg-sag { text-align:right; } .pg-orta { text-align:center; }
.pg-arac { display:flex; gap:6px; align-items:flex-end; padding:8px 12px; background:var(--yuz2); border-bottom:1px solid var(--cizgi); flex-wrap:wrap; }
.pg-arac .pg-alan { display:flex; flex-direction:column; gap:2px; }
.pg-arac .pg-alan > span { font-size:10.5px; color:var(--soluk); }
.pg-arac select, .pg-arac input { min-width:130px; }
.pg-gor { display:flex; gap:2px; padding:4px 8px 0; background:var(--sekmezem); border-bottom:1px solid var(--cizgi); }
.pg-gor span { padding:5px 12px; border:1px solid var(--cizgi); border-bottom:none; border-radius:4px 4px 0 0; background:#f6f8fb; color:var(--soluk); font-size:11.5px; cursor:pointer; }
.pg-gor span.on { background:var(--yuz); color:var(--yazi2); font-weight:bold; margin-bottom:-1px; }
.pg-ozet { display:grid; grid-template-columns:repeat(6,minmax(0,1fr)); border-bottom:1px solid var(--cizgi); background:#fbfcfe; }
.pg-ozet > div { padding:8px 12px; border-right:1px solid var(--cizgi2); min-width:0; }
.pg-ozet > div:last-child { border-right:none; }
.pg-ozet.tik > div { cursor:pointer; } .pg-ozet.tik > div:hover { background:#f4f8fd; }
.pg-ozet .pg-ob { font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.3px; }
.pg-ozet .pg-od { font-size:17px; font-weight:bold; color:var(--yazi2); margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.pg-ozet .pg-ox { font-size:10.5px; color:var(--soluk); }
.pg-bar { height:7px; border-radius:4px; background:#e7edf4; overflow:hidden; margin:5px 0 2px; }
.pg-bar i { display:block; height:100%; background:#5cb87a; }
.pg-govde { display:grid; grid-template-columns:minmax(0,1fr) 360px; min-height:0; }
.pg-govde.kart { grid-template-columns:minmax(0,1fr) 330px; min-height:560px; }
.pg-liste { min-width:0; border-right:1px solid var(--cizgi); overflow:auto; }
.pg-cipler { display:flex; gap:4px; padding:6px 12px; border-bottom:1px solid var(--cizgi2); align-items:center; flex-wrap:wrap; }
.pg-cip { border:1px solid var(--cizgi); border-radius:12px; padding:2px 10px; font-size:11px; background:var(--yuz); color:var(--soluk); cursor:pointer; user-select:none; }
.pg-cip.on { background:#4a5d73; color:#fff; border-color:#4a5d73; }
.pg-cip.mavi.on { background:linear-gradient(#4d8fd6,#2f6db3); border-color:#2f6db3; font-weight:bold; }
.pg-dg { width:100%; border-collapse:collapse; }
.pg-dg th { background:var(--yuz2); text-align:left; padding:5px 8px; border-bottom:1px solid var(--cizgi); font-size:11px; color:#4d5d6e; white-space:nowrap; position:sticky; top:0; z-index:1; }
.pg-dg td { padding:5px 8px; border-bottom:1px solid var(--cizgi2); vertical-align:top; font-size:12px; }
.pg-dg tbody tr { cursor:default; }
.pg-dg tbody tr:hover td { background:#f6f9fd; }
.pg-dg tr.sec td { background:var(--mor2); }
.pg-dg tr.pasif td { color:#9aa6b3; }
.pg-dg tr.grup td { background:#f7f9fc; font-weight:bold; color:#2c4a6b; }
.pg-dg td small { display:block; color:var(--soluk); font-size:10.5px; }
.pg-dg tfoot td { background:var(--yuz2); font-weight:bold; border-top:1px solid var(--cizgi); }
.pg-dg .pg-bos { text-align:center; color:var(--soluk); padding:18px; }
.pg-altsatir { display:flex; gap:8px; align-items:center; padding:8px 12px; border-top:1px solid var(--cizgi); background:var(--yuz2); color:var(--soluk); font-size:11px; }
.pg-yan { padding:10px 12px; background:#fbfcfe; overflow:auto; min-width:0; }
.pg-yan h5 { margin:10px 0 6px; font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.4px; display:flex; align-items:center; }
.pg-yan h5:first-child { margin-top:2px; }
.pg-yan h5 a { margin-left:auto; text-transform:none; letter-spacing:0; color:var(--vurgu); font-weight:normal; cursor:pointer; }
.pg-kutu { border:1px solid var(--cizgi); border-radius:4px; background:var(--yuz); padding:8px 10px; margin-bottom:8px; line-height:1.55; }
.pg-kutu .pg-sat { display:flex; justify-content:space-between; gap:10px; }
.pg-kutu .pg-sat > span { color:var(--soluk); flex:none; }
.pg-kutu .pg-sat > b { font-weight:normal; text-align:right; }
.pg-aylar { display:grid; grid-template-columns:repeat(12,minmax(0,1fr)); gap:3px; align-items:end; height:120px; padding:4px 2px 0; }
.pg-aylar > div { display:flex; flex-direction:column; align-items:center; justify-content:flex-end; gap:0; font-size:9.5px; color:var(--soluk); height:100%; }
.pg-aylar i { display:block; width:100%; }
.pg-aylar i.s { background:#8fb3de; } .pg-aylar i.t { background:#d9b25f; } .pg-aylar i.h { background:#b9c4d0; }
.pg-aylar i:first-child { border-radius:2px 2px 0 0; }
.pg-ic { padding:12px 14px; }
.pg-grp { border:1px solid var(--cizgi2); border-radius:5px; margin-bottom:12px; background:var(--yuz); }
.pg-grp > h4 { margin:0; padding:7px 10px; font-size:11.5px; color:#3a5573; background:linear-gradient(#f7f9fc,#eef3f8); border-bottom:1px solid var(--cizgi2); border-radius:5px 5px 0 0; display:flex; align-items:center; gap:8px; }
.pg-grp > h4 .pg-sp { display:flex; gap:4px; font-weight:normal; font-size:10.5px; }
.pg-grp .pg-gi { padding:10px; }
.pg-iki { display:grid; grid-template-columns:minmax(0,1fr) minmax(0,1fr); gap:12px; }
.pg-f { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:8px 12px; }
.pg-f.k2 { grid-template-columns:repeat(2,minmax(0,1fr)); }
.pg-fld { display:flex; flex-direction:column; gap:2px; min-width:0; }
.pg-fld > label, .pg-fld > .pg-et { font-size:10.5px; color:var(--soluk); }
.pg-fld .pg-req::after { content:" *"; color:#c0392b; }
.pg-fld.g2 { grid-column:span 2; } .pg-fld.g4 { grid-column:1 / -1; }
.pg-fld input, .pg-fld select, .pg-fld textarea { width:100%; min-width:0; }
.pg-fld textarea { min-height:52px; resize:vertical; }
.pg-fld .pg-ro { border:1px solid var(--cizgi); border-radius:3px; background:var(--yuz2); color:#4d5d6e; min-height:25px; padding:3px 7px; font-size:11.5px; display:flex; align-items:center; gap:6px; }
.pg-fld .pg-hata { color:var(--hata); font-size:10.5px; }
.pg-fld .lookup .etiket, .pg-fld .alan .etiket { display:none; }
.pg-fld .alan { display:flex; flex-direction:column; align-items:stretch; }
.pg-yanyana { display:flex; gap:4px; align-items:center; min-width:0; }
.pg-yanyana > :first-child { flex:1; min-width:0; }
.pg-bag { font-size:10.5px; color:var(--vurgu); cursor:pointer; white-space:nowrap; background:none; border:0; padding:0 2px; }
.pg-bag:hover { text-decoration:underline; }
.pg-radyo { display:flex; gap:6px; flex-wrap:wrap; }
.pg-radyo span { border:1px solid var(--cizgi); border-radius:3px; padding:3px 9px; background:var(--yuz); cursor:pointer; font-size:11.5px; user-select:none; }
.pg-radyo span.on { border-color:#2f6db3; background:#eef4fc; color:#2f6db3; font-weight:bold; }
.pg-radyo.kilit span { cursor:default; opacity:.8; }
.pg-ipucu { font-size:10.5px; color:var(--soluk); margin-top:6px; line-height:1.5; }
.pg-bilgi { border:1px solid #cfe0f5; background:#eef4fc; color:#24508a; border-radius:4px; padding:7px 10px; line-height:1.5; margin-top:8px; font-size:11.5px; }
.pg-uyari { border:1px solid #f3c4bf; background:#fdf1ef; border-radius:4px; padding:7px 9px; color:#8a2a22; font-size:11.5px; margin-bottom:6px; }
.pg-uyari.sari { border-color:#f2ddbf; background:#fdf8ec; color:#7a5512; }
.pg-uyari.mavi { border-color:#cfe0f5; background:#eef4fc; color:#24508a; }
.pg-pin { border:1px solid #f2ddbf; background:#fffbea; border-radius:4px; padding:7px 9px; font-size:11.5px; line-height:1.5; }
.pg-pin small { display:block; color:var(--soluk); font-size:10px; margin-top:3px; }
.pg-onizle { display:flex; gap:4px; flex-wrap:wrap; margin-top:6px; }
.pg-onizle span { border:1px solid var(--cizgi2); border-radius:3px; padding:2px 6px; font-size:10.5px; background:#fbfcfe; }
.pg-onizle span.k { background:#fdf6e3; border-color:#f2ddbf; }
.pg-bas { display:flex; gap:14px; align-items:center; padding:12px 14px; border-bottom:1px solid var(--cizgi2); }
.pg-avatar { width:52px; height:52px; border-radius:10px; background:linear-gradient(#6a8fc2,#3d6597); color:#fff; font-size:22px; display:flex; align-items:center; justify-content:center; flex:none; position:relative; }
.pg-avatar small { position:absolute; bottom:-6px; right:-6px; background:var(--yuz); border:1px solid var(--cizgi); border-radius:8px; font-size:9.5px; color:var(--soluk); padding:0 4px; white-space:nowrap; }
.pg-kim { min-width:0; }
.pg-kim .pg-ad { font-size:17px; font-weight:bold; color:var(--yazi2); }
.pg-kim .pg-alt { color:var(--soluk); font-size:11.5px; margin-top:3px; }
.pg-kim .pg-alt b { color:var(--yazi); font-weight:normal; }
.pg-kim .pg-rzlar { margin-top:6px; display:flex; gap:4px; flex-wrap:wrap; }
.pg-bas .pg-islem { margin-left:auto; display:flex; gap:6px; align-items:center; flex:none; }
.pg-hizli { display:flex; gap:4px; padding:6px 12px; background:var(--yuz2); border-bottom:1px solid var(--cizgi); flex-wrap:wrap; align-items:center; }
.pg-ana { min-width:0; border-right:1px solid var(--cizgi); }
.pg-tabs { display:flex; padding:0 8px; border-bottom:1px solid var(--cizgi); background:var(--yuz); overflow-x:auto; }
.pg-tab { padding:8px 12px; color:var(--soluk); font-size:12px; border-bottom:2px solid transparent; cursor:pointer; white-space:nowrap; display:flex; gap:5px; align-items:center; }
.pg-tab .n { background:#eef2f7; border-radius:8px; padding:0 6px; font-size:10px; }
.pg-tab.on { color:var(--yazi2); font-weight:bold; border-bottom-color:var(--vurgu); }
.pg-pane { padding:12px; }
.pg-serit { display:flex; gap:6px; align-items:center; margin-bottom:8px; flex-wrap:wrap; }
.pg-kisi { display:flex; gap:8px; align-items:center; padding:7px 0; border-bottom:1px dashed var(--cizgi2); }
.pg-kisi .pg-av { width:28px; height:28px; border-radius:50%; background:#e7eef6; color:#2f6db3; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:bold; flex:none; }
.pg-kisi b { display:block; font-size:11.5px; }
.pg-kisi small { color:var(--soluk); font-size:10.5px; }
.pg-kisi .pg-ik { margin-left:auto; }
.pg-zaman { border-left:2px solid #cfe0f5; margin-left:6px; padding-left:10px; }
.pg-zaman div { position:relative; padding:4px 0 7px; font-size:11.5px; }
.pg-zaman div::before { content:""; position:absolute; left:-15px; top:8px; width:8px; height:8px; border-radius:50%; background:#9cc4ee; border:2px solid #fbfcfe; }
.pg-zaman div.ok::before { background:#5cb87a; } .pg-zaman div.kir::before { background:#d0473d; }
.pg-zaman small { display:block; color:var(--soluk); font-size:10.5px; }
.pg-mini12 { display:grid; grid-template-columns:repeat(12,1fr); gap:2px; align-items:end; height:54px; margin-top:4px; }
.pg-mini12 i { display:block; background:#8fb3de; border-radius:2px 2px 0 0; }
.pg-mini12 i.y { background:#2f6db3; }
.pg-mini12l { display:grid; grid-template-columns:repeat(12,1fr); gap:2px; font-size:9px; color:var(--soluk); text-align:center; }
.pg-altbar { display:flex; gap:16px; padding:5px 12px; background:var(--yuz2); border-top:1px solid var(--cizgi); font-size:11px; color:var(--soluk); }
.pg-mini { padding:2px 8px !important; font-size:10.5px !important; height:auto !important; }
.pg-not-kaydet { font-size:10.5px; color:#8a6218; margin-left:6px; font-weight:normal; }
.pg-dg input.pg-hucre { width:100%; min-width:70px; font-size:11.5px; padding:1px 4px; }
@media (max-width: 1100px) {
  .pg-govde, .pg-govde.kart { grid-template-columns:minmax(0,1fr); }
  .pg-ozet { grid-template-columns:repeat(3,minmax(0,1fr)); }
  .pg-iki { grid-template-columns:minmax(0,1fr); }
}
`;
