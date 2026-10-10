/** Kurum icmaline özgü ekler - temel görünüm hasta icmaliyle ortak (icmalStil). */
export const stil = `
.hi-arac button:disabled { opacity:.5; cursor:default; }
.hi-arac button.hi-yesil { background:linear-gradient(#5cb87a,#3f9a5e); color:#fff; border-color:#3f9a5e; }
.ki-ayrac { width:1px; height:20px; background:var(--cizgi,#cdd6e0); margin:0 4px; }
.ki-lnk { color:#2f6db3; text-decoration:underline; cursor:pointer; }
.hi-serit .ki-lnk { font-size:11px; margin-left:4px; }
.ki-ok { border:1px solid var(--cizgi,#cdd6e0); background:var(--yuz,#fff); border-radius:3px; padding:0 6px; cursor:pointer; }
.ki-adim { display:flex; font-size:11px; }
.ki-adim span { padding:3px 10px; border:1px solid var(--cizgi,#cdd6e0); background:#f4f6f9; color:#8592a1; margin-left:-1px; }
.ki-adim span:first-child { border-radius:12px 0 0 12px; margin-left:0; }
.ki-adim span:last-child { border-radius:0 12px 12px 0; }
.ki-adim span.bitti { background:#e2f3e8; color:#2e7d46; border-color:#bfe3cb; }
.ki-adim span.simdi { background:#2f6db3; color:#fff; border-color:#2f6db3; font-weight:bold; }
.ki-cubuk { height:8px; border-radius:4px; background:#e7edf4; overflow:hidden; min-width:110px; }
.ki-cubuk i { display:block; height:100%; background:linear-gradient(90deg,#4d8fd6,#2f6db3); }
.hi-tablo tr.red td { color:#8a98a8; }
.ki-ikili { display:grid; grid-template-columns:minmax(0,1.3fr) minmax(0,1fr); gap:12px; }
@media (max-width:1200px) { .ki-ikili { grid-template-columns:1fr; } }
.ki-baslik { font-weight:bold; color:#2c4a6b; padding:8px 2px 4px; }
.ki-soluk { color:var(--soluk,#6b7a8b); }
.ki-not { padding:14px; color:var(--soluk,#6b7a8b); }
/* A4: kurum tablosu daha çok sütun taşır - genişlikler hasta tablosundan farklı. */
.a4-t.ki-a4t { font-size:9px; }
.a4-t.ki-a4t th:nth-child(1) { width:10%; } .a4-t.ki-a4t th:nth-child(2) { width:15%; }
.a4-t.ki-a4t th:nth-child(3), .a4-t.ki-a4t th:nth-child(4) { width:auto; }
.a4-t.ki-a4t th:nth-child(-n+4), .a4-t.ki-a4t td:nth-child(-n+4) { text-align:left; }
.a4-toplam tr.ki-kalan td { color:#14315a; }
`;
