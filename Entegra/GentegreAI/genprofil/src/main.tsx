import { createRoot } from 'react-dom/client';
import '@web/tema.css';
import './genprofil.css';
import { Kok } from './Kok';

createRoot(document.getElementById('kok')!).render(<Kok />);
