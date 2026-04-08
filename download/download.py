import os
import requests
import re
from zipfile import ZipFile
import shutil
from pathlib import Path

# Data of pixelarticons owner and repo
OWNER = 'halfmage'
REPO = 'pixelarticons'
REPOSITORY = f'{OWNER}/{REPO}'
LATEST_RELEASE_ENDPOINT = f'https://api.github.com/repos/{REPOSITORY}/releases/latest'

# Data of pixelarticons dart wrapper lib owner and repo
LIB_OWNER = 'libsrcdev'
LIB_REPO = 'pixelarticons'
LIB_REPOSITORY = f'{LIB_OWNER}/{LIB_REPO}'

# Temporary file constants
PIXELARTICONS_ZIPBALL = 'pixelarticons.zip'
RELEASE_FOLDER = 'release'
EXTRACTED_FOLDER = 'extracted'
SVG_FOLDER = 'svg'

# Critical exception, we need to fix manually otherwise the library can't be updated
BREAKING_CHANGE_EXCEPTION = '''
This is breaking change, someway this tool is not being able to find the icons in the latest release of {REPOSITORY}

Please, if you think it's a error with the tool itself, fill a issue in {LIB_REPOSITORY}

If you think it's a error with the original pixelarticons repository,
please check the 'Breaking Change Exception' section of the README.md of this library to see how to fix it
'''

# Critical exception, we need to figure out why the zip folder changed him format
UNEXPECTED_ZIP = '''
Expected a zipball that looks like:
```
.
`-- pixelarticons-<version>/
    |-- svg/
    |   `-- ...iconfiles.svg
    `-- ...otherreleasefiles.json
```

But we got a zipball that looks like:
```
.
|-- ??????/
|   `-- ...??????
|-- ??????/
|   `-- ...??????
`-- ??????/
    `-- ...??????
```
'''

# Avoid creating icon names using Dart keywords, useful to prefix with `k` later
KEYWORDS = {'abstract', 'else', 'import', 'show', 'as', 'enum', 'in', 'static', 'assert', 'export', 'interface', 'super', 'async', 'extends', 'is', 'switch', 'await', 'extension', 'late', 'sync', 'break', 'external', 'library', 'this', 'case', 'factory', 'mixin', 'throw', 'catch', 'false', 'new',
            'true', 'class', 'final', 'null', 'try', 'const', 'finally', 'on', 'typedef', 'continue', 'for', 'operator', 'var', 'covariant', 'Function', 'part', 'void', 'default', 'get', 'required', 'while', 'deferred', 'hide', 'rethrow', 'with', 'do', 'if', 'return', 'yield', 'dynamic', 'implements', 'set'}

# Required call to verify source status
latest_release_response = requests.get(LATEST_RELEASE_ENDPOINT)


def download(url: str, filename: str, dest_folder: str):
  if not os.path.exists(dest_folder):
    os.makedirs(dest_folder)  # create folder if it does not exist

  file_path = os.path.join(dest_folder, filename)

  file_request = requests.get(url, stream=True)

  if file_request.ok:
    with open(file_path, 'wb') as f:
      for chunk in file_request.iter_content(chunk_size=1024 * 8):
        if chunk:
          f.write(chunk)
          f.flush()
          os.fsync(f.fileno())
  else:
    raise Exception(
        f'Download failed: Status Code {file_request.status_code} | {file_request.text} | {file_request.json()}')


def download_zipball(url: str):
  return download(url, PIXELARTICONS_ZIPBALL, RELEASE_FOLDER)


def is_available():
  return latest_release_response.status_code == 200


def breaking_change_exception():
  return Exception(f'{BREAKING_CHANGE_EXCEPTION}\nResponse: {latest_release_response.json()}')


def download_icons():
  download_zipball(latest_release_response.json()['zipball_url'])

  pixelarticons_zip = ZipFile(os.path.join(RELEASE_FOLDER, PIXELARTICONS_ZIPBALL))
  extracted_folder = os.path.join(RELEASE_FOLDER, EXTRACTED_FOLDER)
  pixelarticons_zip.extractall(extracted_folder)

  for root, _, files in os.walk(extracted_folder):
    if root.endswith('svg'):
      for file in files:
        filename = Path(file).stem

        if not re.match('[a-zA-Z]', file) or filename in KEYWORDS:
          source = os.path.join(root, file)
          dest = os.path.join(root, f'k{file}')
          if os.path.exists(dest):
            os.remove(dest)
          os.rename(source, dest)

        folder_source = os.path.join(root)
        folder_dest = os.path.join(RELEASE_FOLDER, SVG_FOLDER)

      if os.path.exists(folder_dest):
        shutil.rmtree(folder_dest)
      os.rename(folder_source, folder_dest)

      return True

  raise Exception(UNEXPECTED_ZIP)


if not is_available():
  raise breaking_change_exception()
elif download_icons():
  print('PixelArtIcons Successfully Downloaded to /release/svg folder')
