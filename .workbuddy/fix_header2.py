import re, os

def fix_file(fpath):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. 去掉头部横线：把开头的 -- ===...=== 改成 -- ，同时保留中间的内容行
    # 匹配开头4行的横线注释
    lines = content.split('\n')
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # 跳过第1行横线
        if i == 0 and re.match(r'^-- =+$', line):
            i += 1
            continue
        # 跳过第3行横线（内容行之后的那行）
        if i == 2 and re.match(r'^-- =+$', line):
            i += 1
            continue
        new_lines.append(line)
        i += 1
    content = '\n'.join(new_lines)

    # 2. 在装载语句前加上 -- 数据装载
    # 匹配 insert overwrite / load data 开头的行（前面可能有多余空行）
    # 需要确保前面没有 -- 数据装载 注释（避免重复）
    
    # 用正则替换：找到 insert overwrite 或 load data 前面不是 -- 数据装载 的行
    # 匹配规则：如果一行的前导空白+insert overwrite 或 load data，且前一行不是 -- 数据装载
    lines = content.split('\n')
    result = []
    for i, line in enumerate(lines):
        stripped = line.strip()
        # 判断是否是装载语句开头
        is_load_stmt = (stripped.startswith('insert overwrite') or 
                        stripped.startswith('load data'))
        if is_load_stmt:
            # 检查前一行是否已经是 -- 数据装载
            prev_is_marker = False
            j = len(result) - 1
            while j >= 0 and result[j].strip() == '':
                j -= 1
            if j >= 0 and result[j].strip() == '-- 数据装载':
                prev_is_marker = True
            
            if not prev_is_marker:
                # 去除前面的空行，插入 -- 数据装载
                # 回溯删除前面的空行
                while result and result[-1].strip() == '':
                    result.pop()
                result.append('-- 数据装载')
                # 保留一个空行在注释和SQL之间
                result.append('')
        
        result.append(line)
    
    content = '\n'.join(result)
    
    # 清理多余空行（注释和SQL之间只留一个空行）
    # 确保 -- 数据装载 后面跟一个空行再跟SQL
    content = re.sub(r'-- 数据装载\n\n+', '-- 数据装载\n\n', content)
    
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return True

count = 0
for root, dirs, files in os.walk('sql'):
    for f in files:
        if f.endswith('.sql'):
            fpath = os.path.join(root, f)
            if fix_file(fpath):
                count += 1
                print(f'  ✓ {fpath}')

print(f'\n共处理 {count} 个文件')
