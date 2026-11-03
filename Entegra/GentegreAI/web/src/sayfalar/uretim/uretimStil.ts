/**
 * ÜRETİM EKRANLARI STİLİ (1253): üretim fişi kartı (.uf), basit emir listesi (.ueb), emir kartı panelleri (.uep).
 * Rozet (.rz) renkleri mockup'tan TEK yerde (ROZET) - üç ekranda kopyası vardı.
 */
const ROZET = (kok: string) => `
${kok} .rz { display:inline-block; padding:0 7px; border-radius:9px; font-size:10.5px; font-weight:700; border:1px solid; white-space:nowrap }
${kok} .rz.gri { background:#eef1f5; color:#5b6b7c; border-color:#d4dde6 } ${kok} .rz.ok { background:#e9f6ee; color:var(--ok,#2e7d46); border-color:#c4e6d0 }
${kok} .rz.uy { background:#fdf1e2; color:var(--uyari,#a9791a); border-color:#f2ddbf } ${kok} .rz.hata { background:#fdecec; color:var(--hata,#b23b3b); border-color:#f2c9c9 }
`;

export const UF_STILI = ROZET('.uf') + `
.uf { display:flex; flex-direction:column; min-height:100%; background:var(--yuz,#fff); font-size:12px }
.uf .sp { flex:1 }
.uf .sl { color:var(--soluk,#6b7a8b) } .uf .kucuk { font-size:11px } .uf .eks { color:var(--hata,#b23b3b); font-weight:700 }
.uf .uyy { color:var(--uyari,#a9791a); font-weight:700 } .uf .gider { color:var(--hata,#b23b3b); font-weight:700 }
.uf .bag { border:0; background:none; color:var(--mavi,#2f6db3); cursor:pointer; padding:0; font:inherit; text-decoration:underline }
.uf-arac { display:flex; align-items:center; gap:6px; padding:7px 10px; border-bottom:1px solid var(--cizgi2,#e3e9f0); background:var(--yuz2,#f3f6fa); flex-wrap:wrap }
.uf-arac .ayrac { width:1px; height:22px; background:var(--cizgi,#cdd6e0) }
.uf-tur { font-size:15px; font-weight:700; letter-spacing:.3px; color:var(--mor,#6a3fb5) }
.uf-tur small { font-size:13px; color:var(--yazi2,#14315a); font-weight:700; letter-spacing:0 }
.uf .d.mor { background:linear-gradient(#8a63cc,#6a3fb5); color:#fff; border-color:#6a3fb5; font-weight:700 }
.uf-adim { display:flex; border-bottom:1px solid var(--cizgi2,#e3e9f0); background:#fbfcfe }
.uf-adim .a { flex:1; padding:6px 10px 6px 22px; position:relative; color:var(--soluk,#6b7a8b); font-weight:700; font-size:11.5px; border-right:1px solid var(--cizgi2,#e3e9f0) }
.uf-adim .a::before { content:""; position:absolute; left:8px; top:11px; width:8px; height:8px; border-radius:50%; background:#c9d3de }
.uf-adim .a.bitti { color:var(--ok,#2e7d46) } .uf-adim .a.bitti::before { background:var(--ok,#2e7d46) }
.uf-adim .a.simdi { color:var(--uyari,#a9791a); background:#fdf6e8 } .uf-adim .a.simdi::before { background:var(--uyari,#a9791a) }
.uf-adim .a.hata { color:var(--hata,#b23b3b) } .uf-adim .a.hata::before { background:var(--hata,#b23b3b) }
.uf-bas { padding:12px 14px; background:linear-gradient(#fff,#f4f7fb); border-bottom:1px solid var(--cizgi,#cdd6e0) }
.uf-mbb { display:grid; grid-template-columns:auto minmax(0,1fr) auto; gap:12px; align-items:center; padding:7px 12px; border:1px solid var(--cizgi2,#e3e9f0); border-radius:6px; background:#fff; margin-bottom:10px }
.uf-mbb .av { width:36px; height:36px; border-radius:8px; background:#efe8fa; color:var(--mor,#6a3fb5); font-size:18px; display:flex; align-items:center; justify-content:center; border:1px solid #ddd0f2 }
.uf-mbb .ad { font-size:13.5px; font-weight:700; color:var(--yazi2,#14315a); white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
.uf-mbb .ad .k { border:0; background:none; font-weight:400; color:var(--soluk,#6b7a8b); font-size:12px; margin-left:6px; cursor:pointer }
.uf-mbb .kim { color:var(--soluk,#6b7a8b); font-size:11.5px; margin-top:2px } .uf-mbb .kim b { color:var(--yazi,#1f2d3a); font-weight:600 }
.uf-mbb .sag { display:flex; gap:6px; align-items:stretch; flex-wrap:wrap; justify-content:flex-end }
.uf-mbb .kt { border:1px solid var(--cizgi2,#e3e9f0); border-radius:5px; padding:4px 9px; min-width:112px; background:var(--yuz2,#f3f6fa); display:flex; flex-direction:column; gap:2px }
.uf-mbb .kt .e { font-size:10px; color:var(--soluk,#6b7a8b); text-transform:uppercase; letter-spacing:.4px }
.uf-mbb .kt .v { font-size:12px; font-weight:700; display:flex; gap:5px; align-items:center; flex-wrap:wrap }
.uf-mbb .kt .a { font-size:10.5px; color:var(--soluk,#6b7a8b) }
.uf-mbb .kt.ok { background:#eef8f1; border-color:#c4e6d0 } .uf-mbb .kt.uy { background:#fdf6e8; border-color:#f0dfb8 }
.uf-mbb .kt.hata { background:#fdf0f0; border-color:#f2c9c9 } .uf-mbb .kt.mr { background:#f5f0fc; border-color:#ddd0f2 }
.uf-iz { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:8px 18px }
.uf-iz .al { display:grid; grid-template-columns:110px minmax(0,1fr); align-items:center; gap:8px; margin:0 }
.uf-iz .al .et { font-size:11px; color:var(--soluk,#6b7a8b); text-align:right } .uf-iz .al .et.z::after { content:" *"; color:var(--hata,#b23b3b) }
.uf-iz .al.c2 { grid-column:span 2 }
.uf-iz input, .uf-iz select, .uf-iz .inp { border:1px solid var(--cizgi,#cdd6e0); border-radius:2px; height:23px; padding:0 6px; background:#fff; font:inherit; min-width:0 }
.uf-iz input.ro, .uf-iz .inp.ro { background:#f6f8fb; color:var(--soluk,#6b7a8b) } .uf-iz .inp { display:flex; align-items:center; overflow:hidden; white-space:nowrap }
.uf-miktar { display:flex; gap:6px; align-items:center } .uf-miktar input { flex:1 } .uf input.sg { text-align:right }
.uf-sekmeler { display:flex; gap:2px; padding:0 10px; border-bottom:1px solid var(--cizgi,#cdd6e0); flex-wrap:wrap }
.uf-sekmeler .sk { border:0; background:none; padding:8px 14px; color:var(--soluk,#6b7a8b); white-space:nowrap; cursor:pointer; font:inherit; border-bottom:2px solid transparent }
.uf-sekmeler .sk.on { color:var(--yazi2,#14315a); font-weight:700; border-bottom-color:var(--mavi,#2f6db3) }
.uf-sekmeler .sk .say { display:inline-block; background:#e6edf5; color:#4d6178; border-radius:8px; padding:0 6px; font-size:10.5px; margin-left:4px }
.uf-panel { padding-bottom:12px }
.uf-karac { display:flex; gap:6px; align-items:center; padding:8px 10px; flex-wrap:wrap }
.uf-karac .ayrac { width:1px; height:22px; background:var(--cizgi,#cdd6e0) }
.uf .chk { display:inline-flex; gap:5px; align-items:center }
.uf-seg { display:inline-flex; border:1px solid var(--mavi,#2f6db3); border-radius:4px; overflow:hidden; margin-left:auto }
.uf-seg button { border:0; border-left:1px solid var(--mavi,#2f6db3); background:#fff; color:var(--mavi,#2f6db3); padding:3px 10px; font:inherit; font-weight:600; cursor:pointer }
.uf-seg button:first-child { border-left:0 } .uf-seg button.on { background:var(--mavi,#2f6db3); color:#fff }
.uf-uyari { margin:8px 10px 0; padding:6px 10px; border:1px solid #f2c9c9; background:#fdf0f0; color:var(--hata,#b23b3b); border-radius:4px; font-size:11.5px; display:flex; gap:8px; align-items:center; flex-wrap:wrap }
.uf .bilgi { margin:8px 10px 0; padding:6px 10px; border:1px solid #cfe0f4; background:#f3f8fe; color:#2c4a6b; border-radius:4px; font-size:11.5px }
.uf .not { color:var(--soluk,#6b7a8b); font-size:11px; margin:10px 10px 0; line-height:1.5 }
.uf .kbas { font-weight:700; color:var(--yazi2,#14315a); margin:10px 10px 6px }
.uf-dg { border-collapse:collapse; width:calc(100% - 20px); margin:8px 10px 10px; border:1px solid var(--cizgi2,#e3e9f0) }
.uf-dg th { background:linear-gradient(#f4f7fb,#e7eef6); border-bottom:1px solid var(--cizgi,#cdd6e0); border-right:1px solid var(--cizgi2,#e3e9f0); text-align:left; padding:5px 8px; font-size:11px; color:#3a5573; white-space:nowrap }
.uf-dg td { border-bottom:1px solid var(--cizgi2,#e3e9f0); border-right:1px solid #eef2f6; padding:3px 6px; font-size:11.5px; white-space:nowrap }
.uf-dg td input, .uf-dg td select { border:1px solid transparent; background:transparent; width:100%; min-width:60px; font:inherit; padding:1px 4px; border-radius:2px }
.uf-dg td input:hover, .uf-dg td select:hover, .uf-dg td input:focus { border-color:var(--cizgi,#cdd6e0); background:#fff }
.uf-dg td input.dar { width:80px; min-width:60px }
.uf-dg tr.grup td { background:#f7f9fc; font-weight:700; color:#2c4a6b; border-right:0 } .uf-dg tr.grup td .gs { font-weight:400; color:var(--soluk,#6b7a8b); margin-left:8px }
.uf-dg tr.grup.cikti td { background:#f5f0fc; color:var(--mor,#6a3fb5) } .uf-dg tr.grup.fire td { background:#fdf3f2; color:var(--hata,#b23b3b) }
.uf-dg tr.sel td { background:#f8f5fd } .uf-dg tr.eksik td { background:#fff6f5 } .uf-dg tr.anormal td { background:#fff4f3 }
.uf-dg tr.top td { background:#fbfcfe; font-weight:700; border-top:1px solid var(--cizgi,#cdd6e0) }
.uf-dg .sg { text-align:right } .uf-dg .or { text-align:center } .uf-dg td.bos { text-align:center; padding:10px }
.uf-dg .ana { color:#c69214 } .uf-dg.kucuk td, .uf-dg.kucuk th { font-size:11px }
.uf-dg .x { border:0; background:none; color:var(--hata,#b23b3b); cursor:pointer; font-size:11px }
.uf .lot { display:inline-flex; gap:4px; align-items:center; border:1px solid #cfe0f4; background:#f3f8fe; border-radius:3px; padding:0 6px; color:var(--mavi,#2f6db3); font-size:11px; cursor:pointer; max-width:220px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap }
.uf .lot.bos { border-color:#f2c9c9; background:#fdf0f0; color:var(--hata,#b23b3b) } .uf .lot:disabled { cursor:default }
.uf-basit-ek { display:grid; grid-template-columns:1fr 1fr; gap:8px 18px; padding:0 10px 12px }
.uf-basit-ek .al3 { display:grid; grid-template-columns:110px minmax(0,220px) minmax(0,1fr); align-items:center; gap:8px }
.uf-basit-ek .al3 .et { font-size:11px; color:var(--soluk,#6b7a8b); text-align:right }
.uf-basit-ek input { border:1px solid var(--cizgi,#cdd6e0); border-radius:2px; height:23px; padding:0 6px; font:inherit }
.uf-ozet { display:flex; gap:8px; justify-content:flex-end; padding:0 10px 12px; flex-wrap:wrap }
.uf-ozet .oz { border:1px solid var(--cizgi2,#e3e9f0); border-radius:5px; padding:5px 12px; background:var(--yuz2,#f3f6fa); min-width:130px }
.uf-ozet .oz .e { font-size:10px; color:var(--soluk,#6b7a8b); text-transform:uppercase; letter-spacing:.4px } .uf-ozet .oz .v { font-size:13px; font-weight:700; text-align:right }
.uf-ozet .oz.vurgu { background:#f5f0fc; border-color:#ddd0f2 } .uf-ozet .oz.vurgu .v { color:var(--mor,#6a3fb5); font-size:14px }
.uf-ozet .oz.uyy { background:#fdf6e8; border-color:#f0dfb8 } .uf-ozet .oz.uyy .v { color:var(--uyari,#a9791a) }
.uf-imza { margin:10px; border:1px solid #c4e6d0; background:#f6fbf7; border-radius:5px; padding:8px 10px }
.uf-agac { margin:10px; border:1px solid var(--cizgi2,#e3e9f0); border-radius:4px; padding:6px 10px; font-family:Consolas,"Courier New",monospace; font-size:11px; line-height:1.9; background:#fbfcfe }
.uf-agac .dug.cikti { color:var(--mor,#6a3fb5); font-weight:700 }
.uf-bilgi { max-width:520px; white-space:normal; word-break:break-all }
`;

export const UEB_STILI = ROZET('.ueb') + `
.ueb { background:var(--yuz,#fff); min-height:100%; font-size:12px }
.ueb .sl { color:var(--soluk,#6b7a8b) } .ueb .kucuk { font-size:11px } .ueb .eks { color:var(--hata,#b23b3b); font-weight:700 } .ueb .sp { flex:1 }
.ueb .bag { border:0; background:none; color:var(--yazi2,#14315a); cursor:pointer; padding:0; font:inherit; font-weight:700 } .ueb .bag:hover { text-decoration:underline }
.ueb-arac { display:flex; gap:6px; align-items:center; padding:7px 12px; border-bottom:1px solid var(--cizgi2,#e3e9f0); background:var(--yuz2,#f3f6fa); flex-wrap:wrap; margin-top:8px }
.ueb-arac .ayrac { width:1px; height:22px; background:var(--cizgi,#cdd6e0) } .ueb .chk { display:inline-flex; gap:5px; align-items:center }
.ueb .d.mor { background:linear-gradient(#8a63cc,#6a3fb5); color:#fff; border-color:#6a3fb5; font-weight:700 }
.ueb-dg { border-collapse:collapse; width:calc(100% - 24px); margin:10px 12px; border:1px solid var(--cizgi2,#e3e9f0) }
.ueb-dg th { background:linear-gradient(#f4f7fb,#e7eef6); border-bottom:1px solid var(--cizgi,#cdd6e0); border-right:1px solid var(--cizgi2,#e3e9f0); text-align:left; padding:5px 8px; font-size:11px; color:#3a5573; white-space:nowrap }
.ueb-dg td { border-bottom:1px solid var(--cizgi2,#e3e9f0); border-right:1px solid #eef2f6; padding:5px 8px; font-size:11.5px; white-space:nowrap }
.ueb-dg td.bos { text-align:center; padding:16px } .ueb-dg .sg { text-align:right } .ueb-dg tr.bitti td { color:var(--soluk,#6b7a8b) }
.ueb .bar { display:inline-block; width:110px; height:8px; border-radius:4px; background:#e6edf5; vertical-align:middle; margin-right:6px; overflow:hidden }
.ueb .bar i { display:block; height:100%; background:var(--ok,#2e7d46) }
@media print { .ueb-arac, .ueb .d { display:none } }
`;

export const UEP_STILI = ROZET('.uep-dg') + `
.uep-not { color:var(--soluk,#6b7a8b); font-size:11px; margin:0 0 8px; line-height:1.5 }
.uep-dg { border-collapse:collapse; width:100%; border:1px solid var(--cizgi2,#e3e9f0); font-size:11.5px }
.uep-dg th { background:linear-gradient(#f4f7fb,#e7eef6); border-bottom:1px solid var(--cizgi,#cdd6e0); border-right:1px solid var(--cizgi2,#e3e9f0); text-align:left; padding:5px 8px; font-size:11px; color:#3a5573 }
.uep-dg td { border-bottom:1px solid var(--cizgi2,#e3e9f0); border-right:1px solid #eef2f6; padding:4px 8px; white-space:nowrap }
.uep-dg .sg { text-align:right } .uep-dg .or { text-align:center } .uep-dg td.bos { text-align:center; padding:12px }
.uep-dg tr.uygunsuz td { background:#fff4f3 } .uep-dg tr.ters td { color:var(--soluk,#6b7a8b); text-decoration:line-through }
.uep-dg tr.top td { font-weight:700; background:#fbfcfe }
.uep-dg .sl { color:var(--soluk,#6b7a8b) } .uep-dg .bag { border:0; background:none; color:var(--mavi,#2f6db3); cursor:pointer; padding:0; font:inherit }
.uep-imza { margin-top:10px; border:1px solid #c4e6d0; background:#f6fbf7; border-radius:5px; padding:8px 10px; font-size:12px }
.uep-imza.hata { border-color:#f2c9c9; background:#fdf0f0; color:var(--hata,#b23b3b) }
`;
