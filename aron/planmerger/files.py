def WriteFile(path, content):
    with open(path, 'w') as f:
        f.write(content)

def ReadFile(path):
    with open(path, 'r') as f:
        content = f.read()
        return content
    return None