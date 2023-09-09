#!/usr/bin/env python3

import argparse
import ast
import os
import sys

import ipynb_util


def insert_pip_install_ita_header(cells):
    inserted = False
    for cell in cells:
        if cell['cell_type'] == 'code':
            src_ast = ast.parse(''.join(cell['source']).strip())
            for node in ast.walk(src_ast):
                if isinstance(node, ast.Import):
                    inserted = inserted or any(x.name == 'ita' for x in node.names)
                elif isinstance(node, ast.ImportFrom) and node.module is not None:
                    inserted = inserted or node.module == 'ita'
            if inserted:
                pass
    if inserted:
        header = ipynb_util.code_cell(f"""
###################################################
## import ita を行う際は事前にこのセルを実行せよ ##
###################################################
!pip install ita
""".strip()).to_ipynb()
        cells.insert(0, header)
    return inserted


if __name__ == '__main__':
    for path in sys.argv[1:]:
        cells, metadata = ipynb_util.load_cells(path)
        inserted = insert_pip_install_ita_header(cells)
        if inserted:
            ipynb_util.save_as_notebook(path, cells, metadata)
