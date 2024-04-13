from __future__ import annotations
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader


env = Environment(
    loader=FileSystemLoader('templates'),
    extensions=[
        'jinja2.ext.loopcontrols',
        'jinja2_markdown.MarkdownExtension',
    ],
)

public_dir = Path('public')
public_dir.mkdir(exist_ok=True)
template = env.get_template('index.html.j2')
data = yaml.safe_load(Path('data.yaml').read_text())
content = template.render(**data)
Path('public', 'index.html').write_text(content)
