import os, subprocess

src = r'C:\Users\HP\Entegra\Entegra\sp_Grnt_CariIslem.sql'
dst = r'C:\Users\HP\Entegra\Entegra\sp_Grnt_CariIslem_install.sql'

# cp1254'ten oku
with open(src, 'r', encoding='cp1254') as f:
    text = f.read()

# CREATE PROC -> CREATE OR ALTER PROC
text = text.replace('CREATE PROC ', 'CREATE OR ALTER PROC ', 1)

# UTF-8 BOM ile yaz (sqlcmd -f 65001 ile uyumlu)
with open(dst, 'w', encoding='utf-8-sig') as f:
    f.write(text)

print(f"Converted: {dst}")
print("Installing...")

result = subprocess.run([
    'sqlcmd', '-S', r'DESKTOP-HL3J3AS\SQLEXPRESS',
    '-U', 'sa', '-P', 'FETAGEN',
    '-d', 'BILIM', '-C',
    '-f', '65001',
    '-i', dst
], capture_output=True, text=True, encoding='cp1254', errors='replace')

print("STDOUT:")
print(result.stdout)
if result.stderr:
    print("STDERR:")
    print(result.stderr)
print(f"Exit: {result.returncode}")
