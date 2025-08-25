#!/usr/bin/env python3
import sys, os, json, tempfile, subprocess, re

if len(sys.argv) < 3:
    sys.exit('usage: run_test262.py <engine> <test>...')
engine = sys.argv[1]
tests = sys.argv[2:]
root = os.getcwd()
with open(os.path.join(root, 'harness', 'sta.js')) as f:
    sta = f.read()
with open(os.path.join(root, 'harness', 'assert.js')) as f:
    assert_js = f.read()
for t in tests:
    with open(t) as f:
        src = f.read()
    m = re.search(r'/\*---([\s\S]*?)---\*/', src)
    includes = []
    if m:
        fm = m.group(1)
        src = src[m.end():]
        collect = False
        for line in fm.splitlines():
            line = line.strip()
            if collect:
                if line.startswith('-'):
                    includes.append(line[1:].strip())
                else:
                    collect = False
            if line.startswith('includes:'):
                if '[' in line:
                    inner = line[line.find('[')+1:line.rfind(']')]
                    for item in inner.split(','):
                        item = item.strip()
                        if item:
                            includes.append(item.strip('\"\''))
                else:
                    collect = True
    extra = ''
    for inc in includes:
        try:
            with open(os.path.join('harness', inc)) as f:
                extra += f.read() + '\n'
        except IOError:
            pass
    script = sta + '\n' + assert_js + '\n' + extra + src
    tmp = tempfile.NamedTemporaryFile('w', suffix='.js', delete=False)
    tmp.write(script)
    tmp.close()
    proc = subprocess.run([engine, tmp.name], capture_output=True, text=True)
    passed = (proc.returncode == 0)
    result = {'file': t, 'result': {'pass': passed}}
    err = proc.stderr.strip()
    if not err:
        err = proc.stdout.strip()
    if not passed and err:
        result['result']['stderr'] = err
    print(json.dumps(result))
    os.unlink(tmp.name)
