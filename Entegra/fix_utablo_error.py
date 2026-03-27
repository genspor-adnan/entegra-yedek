import re

def fix_utablo():
    # 1. Read Utablo.dfm
    with open('c:/Entegra/Entegra/Utablo.dfm', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    extracted_item = []
    
    components_to_remove = [
        "cxEditRepository1ImageComboBoxItem1",
        "cxEditRepository1CheckBoxItem2",
        "cxEditRepository1ImageComboBoxItem2"
    ]
    
    extracting_target = "cxEditRepository1ImageComboBoxItem1"
    extracting = False
    removing = False
    current_indent = -1
    
    # Regex to identify object start: "  object Name: Type"
    obj_start_pattern = re.compile(r'^(\s*)object\s+([a-zA-Z0-9_]+):')
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check for object start
        match = obj_start_pattern.match(line)
        if match and not removing:
            indent_str = match.group(1)
            name = match.group(2)
            indent_len = len(indent_str)
            
            if name in components_to_remove:
                removing = True
                current_indent = indent_len
                if name == extracting_target:
                    extracting = True
                    extracted_item.append(line)
                i += 1
                continue
        
        if removing:
            # Check if we reached the 'end' of this object
            # The 'end' should be at the same indentation level
            # But we need to be careful about nested objects.
            # Simple approach: count 'object' and 'end' tokens?
            # Or just check indentation? DFM usually has 'end' at same indent.
            
            if extracting:
                extracted_item.append(line)
            
            # Check for end
            # Regex for end: "  end"
            end_match = re.match(r'^(\s*)end', line)
            if end_match:
                end_indent = len(end_match.group(1))
                if end_indent == current_indent:
                    # This is the end of the object we are removing
                    removing = False
                    extracting = False
                    current_indent = -1
        else:
            # Check for KlasorResimleri property references
            if "KlasorResimleri" in line and ("Properties.Images" in line or "Properties.LargeImages" in line):
                pass # Skip this line
            else:
                new_lines.append(line)
            
        i += 1

    # Write Utablo.dfm
    with open('c:/Entegra/Entegra/Utablo.dfm', 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
        
    print(f"Extracted {len(extracted_item)} lines for {extracting_target}")

    # 2. Update UStil.dfm
    if extracted_item:
        with open('c:/Entegra/Entegra/UStil.dfm', 'r', encoding='utf-8', errors='ignore') as f:
            stil_lines = f.readlines()
            
        # Insert before the last 'end'
        last_end_index = -1
        for idx in range(len(stil_lines)-1, -1, -1):
            if stil_lines[idx].strip() == 'end':
                last_end_index = idx
                break
        
        if last_end_index != -1:
            stil_lines.insert(last_end_index, "".join(extracted_item))
            
        with open('c:/Entegra/Entegra/UStil.dfm', 'w', encoding='utf-8') as f:
            f.writelines(stil_lines)

    # 3. Update Utablo.pas
    with open('c:/Entegra/Entegra/Utablo.pas', 'r', encoding='utf-8', errors='ignore') as f:
        pas_lines = f.readlines()
        
    new_pas_lines = []
    decl_pattern = re.compile(r'^\s+([a-zA-Z0-9_]+)\s*:\s*[a-zA-Z0-9_]+;')
    
    for line in pas_lines:
        match = decl_pattern.match(line)
        if match:
            name = match.group(1)
            if name in components_to_remove:
                continue
        new_pas_lines.append(line)
        
    with open('c:/Entegra/Entegra/Utablo.pas', 'w', encoding='utf-8') as f:
        f.writelines(new_pas_lines)

    # 4. Update UStil.pas
    with open('c:/Entegra/Entegra/UStil.pas', 'r', encoding='utf-8', errors='ignore') as f:
        stil_pas_lines = f.readlines()
        
    # Check if already declared
    already_declared = False
    for line in stil_pas_lines:
        if extracting_target in line:
            already_declared = True
            break
            
    if not already_declared:
        # Find where to insert declaration
        insert_idx = -1
        for idx, line in enumerate(stil_pas_lines):
            if "private" in line: # Insert before private
                insert_idx = idx
                break
                
        if insert_idx != -1:
            stil_pas_lines.insert(insert_idx, f"    {extracting_target}: TcxEditRepositoryImageComboBoxItem;\n")
            
        with open('c:/Entegra/Entegra/UStil.pas', 'w', encoding='utf-8') as f:
            f.writelines(stil_pas_lines)

fix_utablo()
