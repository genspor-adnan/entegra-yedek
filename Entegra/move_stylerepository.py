import re

def move_stylerepository():
    with open('c:/Entegra/Entegra/Utablo.dfm', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    extracted = []
    
    extracting = False
    object_depth = 0
    current_indent = -1
    
    obj_start_pattern = re.compile(r'^(\s*)object\s+([a-zA-Z0-9_]+):')
    
    for line in lines:
        match = obj_start_pattern.match(line)
        
        if match and not extracting:
            indent_str = match.group(1)
            name = match.group(2)
            indent_len = len(indent_str)
            
            if name == "cxStyleRepository1":
                extracting = True
                current_indent = indent_len
                extracted.append(line)
                continue
        
        if extracting:
            extracted.append(line)
            
            end_match = re.match(r'^(\s*)end', line)
            if end_match:
                end_indent = len(end_match.group(1))
                if end_indent == current_indent:
                    extracting = False
                    current_indent = -1
        else:
            new_lines.append(line)

    with open('c:/Entegra/Entegra/Utablo.dfm', 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
        
    print(f"Extracted {len(extracted)} lines for cxStyleRepository1")

    # Add to UStil.dfm
    if extracted:
        with open('c:/Entegra/Entegra/UStil.dfm', 'r', encoding='utf-8', errors='ignore') as f:
            stil_lines = f.readlines()
            
        # Insert before last 'end'
        last_end_index = -1
        for idx in range(len(stil_lines)-1, -1, -1):
            if stil_lines[idx].strip() == 'end':
                last_end_index = idx
                break
        
        if last_end_index != -1:
            stil_lines.insert(last_end_index, "".join(extracted))
            
        with open('c:/Entegra/Entegra/UStil.dfm', 'w', encoding='utf-8') as f:
            f.writelines(stil_lines)
            
    # Update Utablo.pas
    with open('c:/Entegra/Entegra/Utablo.pas', 'r', encoding='utf-8', errors='ignore') as f:
        pas_lines = f.readlines()
        
    new_pas_lines = []
    decl_pattern = re.compile(r'^\s+(cxStyleRepository1)\s*:\s*[a-zA-Z0-9_]+;')
    
    for line in pas_lines:
        match = decl_pattern.match(line)
        if match:
            continue
        new_pas_lines.append(line)
        
    with open('c:/Entegra/Entegra/Utablo.pas', 'w', encoding='utf-8') as f:
        f.writelines(new_pas_lines)
        
    # Update UStil.pas
    with open('c:/Entegra/Entegra/UStil.pas', 'r', encoding='utf-8', errors='ignore') as f:
        stil_pas = f.readlines()
        
    # Check if already exists
    has_repo1 = any("cxStyleRepository1" in line for line in stil_pas)
    
    if not has_repo1:
        for idx, line in enumerate(stil_pas):
            if "private" in line.lower():
                stil_pas.insert(idx, "    cxStyleRepository1: TcxStyleRepository;\n")
                break
                
        with open('c:/Entegra/Entegra/UStil.pas', 'w', encoding='utf-8') as f:
            f.writelines(stil_pas)

move_stylerepository()
