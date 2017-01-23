#!/usr/bin/env python
# -*- coding: utf-8 -*-

import csv
import fnmatch
import os
import sys
from xml.etree import ElementTree
from xml.etree.ElementTree import ParseError

groups = {}
views = []


def process_file(path):
    try:
        root = ElementTree.parse(path).getroot()
        for data in root:
            for record in data:
                model, id_ = record.get('model'), record.get('id')
                if not id_ or not model:
                    return
                if model == 'res.groups' and id_ not in groups:
                    process_group(record)
                elif model == 'ir.ui.view':
                    process_view(record, path)
    except ParseError:
        return


def process_group(node):
    group = {
        'name': ''
    }
    for field in node.findall('field'):
        if field.get('name') == 'name':
            group['name'] = field.text
    groups[node.get('id')] = group


def process_view(node, path):
    view = {
        'path': path,
        'id': node.get('id'),
        'model': '',
        'name': '',
    }
    for field in node.findall('field'):
        name = field.get('name')
        if name == 'name':
            view['name'] = field.text
        elif name == 'model':
            view['model'] = field.text
    views.append(view)


def process_addons_dir(dir_path):
    groups_file_path = os.path.join(dir_path, '.groups')
    views_file_path = os.path.join(dir_path, '.views')
    for root, dirnames, filenames in os.walk(dir_path):
        for filename in fnmatch.filter(filenames, '*.xml'):
            process_file(os.path.join(root, filename))

    if groups:
        with open(groups_file_path, 'wb') as csv_file:
            writer = csv.writer(csv_file, delimiter=';')
            for group_id, values in groups.items():
                writer.writerow(
                    (values['name'], group_id)
                )

    if views:
        with open(views_file_path, 'wb') as csv_file:
            writer = csv.writer(csv_file, delimiter=';')
            for view in views:
                writer.writerow(
                    (view['path'], view['id'], view['model'], view['name'])
                )


if __name__ == '__main__':
    if len(sys.argv) == 2:
        process_addons_dir(sys.argv[1])
