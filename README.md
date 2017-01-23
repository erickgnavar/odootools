# Odootools

Set of tools for Odoo development

This package inspect Odoo source code to build a db of features for easy search.

## Dependencies

- `f.el`
- `helm`
- Python 2

## Installation

Clone this repo somewhere

```elisp
(add-to-list 'load-path "path where the repo was cloned")

(setq odootools-addons-path "path to odoo addons folder")

(require 'odootools)
```

## Usage

- For search and insert security group id `odootools-find-group-id`
- For search and insert view id `odootools-find-group-id`
- For search and open view file `odootools-find-view-file`
- For rebuild the db db use `odootools-rebuild-db`


## TODO

- [ ] Go to view line after open buffer
- [ ] Add snippets for python and xml modes
- [ ] Find Odoo models by model ID
