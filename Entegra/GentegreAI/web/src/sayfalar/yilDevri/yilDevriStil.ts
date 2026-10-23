/** Yıl Sonu Devri ekranı (mockup Ekranlar/Muhasebe/yil_sonu_devir.html) - `yd-` önekli (global .d / .ust ile çakışmasın). */
export const YD_STILI = `
.yd .rz { display:inline-block; border-radius:9px; padding:1px 8px; font-size:10.5px; border:1px solid var(--cizgi2); background:#f4f6f9; color:#4d5d6e; white-space:nowrap }
.yd .rz.ok { background:var(--okzem); color:var(--ok); border-color:var(--okkenar) }
.yd .rz.mavi { background:#eef4fc; color:#2f6db3; border-color:#cfe0f5 }
.yd .rz.sari { background:var(--uyarizem); color:var(--uyari); border-color:var(--uyarikenar) }
.yd .rz.kir { background:var(--hatazem); color:var(--hata); border-color:#f3c4bf }
.yd .borc { color:var(--hata) } .yd .alacak { color:var(--ok) } .yd .sonuk { color:var(--soluk) } .yd .sp { margin-left:auto }
.yd-bas { display:flex; gap:18px; align-items:center; padding:10px 14px; border:1px solid var(--cizgi2); border-radius:var(--r); background:var(--kartzem); margin-bottom:10px; flex-wrap:wrap }
.yd-gecis { display:flex; align-items:center; gap:10px }
.yd-yil { border:1px solid var(--cizgi2); border-radius:6px; padding:6px 12px; min-width:160px; background:#fbfcfe }
.yd-yil .y { font-size:20px; font-weight:bold; color:var(--lacivert, #14315a) }
.yd-yil .a { font-size:11px; color:var(--soluk) }
.yd-ok { font-size:22px; color:#2f6db3 }
.yd-alan { display:flex; flex-direction:column; gap:2px; font-size:11px; color:var(--soluk) }
.yd-alan select { min-width:110px }
.yd-bilgi { color:var(--soluk); font-size:11.5px; line-height:1.55 }
.yd-islem { margin-left:auto; display:flex; gap:6px }
.yd-govde { display:grid; grid-template-columns:240px minmax(0,1fr) 280px; border:1px solid var(--cizgi2); border-radius:var(--r); background:var(--kartzem); min-height:560px }
.yd-adimlar { border-right:1px solid var(--cizgi2); background:#f8fafc; padding:8px 0 }
.yd-adim { display:flex; gap:10px; padding:9px 14px; cursor:pointer; border-left:3px solid transparent; align-items:flex-start }
.yd-adim:hover { background:#eef4fc }
.yd-adim.on { background:#fff; border-left-color:#2f6db3 }
.yd-adim .no { width:24px; height:24px; border-radius:12px; flex:none; display:flex; align-items:center; justify-content:center; font-weight:bold; font-size:11.5px; border:1px solid var(--cizgi2); background:#fff; color:var(--soluk) }
.yd-adim.tamam .no { background:#3f9a5e; border-color:#3f9a5e; color:#fff }
.yd-adim.on .no { background:#2f6db3; border-color:#2f6db3; color:#fff }
.yd-adim .ad { font-weight:bold; color:var(--lacivert, #14315a) }
.yd-adim .alt { font-size:10.5px; color:var(--soluk); margin-top:2px; line-height:1.4 }
.yd-adimlar .ayr { border-top:1px solid var(--cizgi2); margin:8px 14px }
.yd-adimlar .kural { padding:4px 14px; font-size:10.5px; color:var(--soluk); line-height:1.5 }
.yd-icerik { padding:12px 14px; min-width:0 }
.yd-pbas { display:flex; align-items:center; gap:8px; margin-bottom:10px }
.yd-pbas h3 { margin:0; font-size:14px; color:var(--lacivert, #14315a) }
.yd-grp { border:1px solid var(--cizgi2); border-radius:4px; margin-bottom:12px; overflow:hidden }
.yd-grp h4 { margin:0; padding:6px 10px; background:var(--baslikzem, #f3f6fa); border-bottom:1px solid var(--cizgi2); font-size:12px; display:flex; align-items:center; gap:8px }
.yd-grp h4 .sp { font-weight:normal; display:flex; gap:10px; align-items:center }
.yd-dg { width:100%; border-collapse:collapse; font-size:12px }
.yd-dg th { background:var(--baslikzem, #f3f6fa); text-align:left; padding:5px 8px; border-bottom:1px solid var(--cizgi2); font-size:11px; white-space:nowrap }
.yd-dg td { padding:5px 8px; border-bottom:1px solid var(--cizgi2) }
.yd-dg .s { text-align:right; white-space:nowrap }
.yd-dg tfoot td { font-weight:bold; border-top:2px solid var(--cizgi2) }
.yd-dg tr.ara td { background:#f3f6fa; font-weight:bold }
.yd-dg tr.pasif td { opacity:.45 }
.yd-fis td:first-child { font-family:Consolas, "Courier New", monospace; font-size:11.5px }
.yd-ipucu { font-size:10.5px; color:var(--soluk); padding:6px 10px; line-height:1.5 }
.yd-kutular { display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); border:1px solid var(--cizgi2); border-radius:4px; margin-bottom:12px; background:#fbfcfe }
.yd-kutular > div { padding:8px 12px; border-right:1px solid var(--cizgi2) }
.yd-kutular > div:last-child { border-right:none }
.yd-kutular .b { font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.3px }
.yd-kutular .deg { font-size:17px; font-weight:bold; margin-top:2px }
.yd-kutular .x { font-size:10.5px; color:var(--soluk) }
.yd-bilgi-serit { border:1px solid #cfe0f5; background:#eef4fc; color:#24508a; border-radius:4px; padding:8px 10px; margin-bottom:10px; line-height:1.5 }
.yd-kir-serit { border:1px solid #f3c4bf; background:#fbe9e7; color:#8c1d17; border-radius:4px; padding:8px 10px; margin-bottom:10px; line-height:1.5 }
.yd-secim { display:flex; gap:10px; align-items:center; margin-bottom:10px }
.yd-chk { display:inline-flex; gap:6px; align-items:center; cursor:pointer }
.yd-link { color:#2f6db3; cursor:pointer; text-decoration:underline dotted }
.yd-yan { border-left:1px solid var(--cizgi2); background:#fbfcfe; padding:10px 12px }
.yd-yan h5 { margin:12px 0 6px; font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.4px }
.yd-yan h5:first-child { margin-top:2px }
.yd-yan .sat { display:flex; justify-content:space-between; padding:3px 0; border-bottom:1px dashed var(--cizgi2) }
.yd-yan .sat b { font-weight:normal }
.yd-gunluk { margin:0; padding:0 0 0 14px; list-style:none; border-left:2px solid var(--cizgi2) }
.yd-gunluk li { position:relative; padding:0 0 9px 6px; line-height:1.45; font-size:11.5px }
.yd-gunluk li::before { content:""; position:absolute; left:-20px; top:4px; width:9px; height:9px; border-radius:5px; background:#9fb1c4 }
.yd-gunluk li.ok::before { background:#3f9a5e } .yd-gunluk li.uy::before { background:#d6a23b }
.yd-gunluk small { color:var(--soluk) }
.yd-alt { display:flex; gap:6px; align-items:center; padding:8px 14px; border:1px solid var(--cizgi2); border-top:none; border-radius:0 0 var(--r) var(--r); background:var(--baslikzem, #f3f6fa) }
@media (max-width: 1100px) { .yd-govde { grid-template-columns:200px minmax(0,1fr) } .yd-yan { display:none } }
`;
