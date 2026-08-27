import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './tema.css'
import App from './App.tsx'
import { temaBaslat } from './bilesenler/tema';

// Tema ILK BOYAMADAN once: sonra uygulanirsa ekran bir an aydinlik
//   yanip gece moduna geciyor.
temaBaslat();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
