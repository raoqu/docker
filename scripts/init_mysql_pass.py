import re
import subprocess

def extract_content(file_path):
    # 定义正则表达式模式
    pattern = r'root@localhost:\s*([^\s]+)\s*$'
    
    # 打开文件并读取内容
    with open(file_path, 'r') as file:
        content = file.read()
        
    # 使用正则表达式查找匹配项
    match = re.search(pattern, content, re.MULTILINE)
    
    # 如果找到匹配项，则返回匹配的组（即小括号内的内容）
    if match:
        return match.group(1)
    else:
        return None  # 如果没有找到匹配项，返回None或其他默认值

def write_string_to_file(file_path, content):
    with open(file_path, 'w') as file:
        file.write(content)

file_path = 'mysql_pass.txt'

mysql_pass = extract_content(file_path)
command = ['mysql', '-u', 'root', '-p"{}"'.format(mysql_pass)]

with open('change_pass.sql', 'r') as sql_file:
    subprocess.run(command, stdin=sql_file, capture_output=False, text=True)
write_string_to_file('mysql_newpass.txt', mysql_pass + ' -> mysql')