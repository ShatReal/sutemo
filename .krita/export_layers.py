from krita import *
from pathlib import Path
import shutil

SAVE_FOLDER_PATH = 'C:/game_development/projects/sutemo/sprites/{}/{:02d}_{}/{:02d}_{}'
SAVE_FILE_PATH = 'C:/game_development/projects/sutemo/sprites/{}/{:02d}_{}/{:02d}_{}/{}.png'

path = Path('C:/game_development/projects/sutemo/sprites')
shutil.rmtree(path)

app = Krita.instance()
exportParams = InfoObject()
documentsOpen = app.documents()

hairFilters = [False, True, False, False, False]
skinFilters = [True, False, False, True, False]
eyeFilters = [False, False, True, False, True]
defaultFilters = [False, False, False, False, False]

for doc in documentsOpen:
    doc.setBatchmode(True)
    gender = doc.fileName().split('/')[-1].split('.')[0]
    filters = [doc.nodeByName('lighten_skin'), doc.nodeByName('lighten_hair'), doc.nodeByName('lighten_eyes'), doc.nodeByName('pink_tint'), doc.nodeByName('desaturate')]
    topLayers = doc.topLevelNodes()
    for layer in topLayers:
        layer.setVisible(False)
    i = 0
    for layer in topLayers:
        if layer.type() == 'grouplayer':
            layer.setVisible(True)
            for item in layer.childNodes():
                item.setVisible(False)
            j = 0
            for item in layer.childNodes():
                item.setVisible(True)
                for itemLayer in item.childNodes():
                    itemLayer.setVisible(False)
                for itemLayer in item.childNodes():
                    itemLayer.setVisible(True)
                    if 'hair' in layer.name() and itemLayer.name() == 'base':
                        curFilters = hairFilters
                    elif layer.name() == 'body' and itemLayer.name() == 'base' or itemLayer.name() == 'skin':
                        curFilters = skinFilters
                    elif layer.name() == 'eyes' and itemLayer.name() == 'base':
                        curFilters = eyeFilters
                    else:
                        curFilters = defaultFilters
                    for k in range(len(filters)):
                        filters[k].setVisible(curFilters[k])
                    Path(SAVE_FOLDER_PATH.format(gender, i, layer.name(), j, item.name())).mkdir(parents=True, exist_ok=True)
                    doc.refreshProjection()
                    if not doc.exportImage(SAVE_FILE_PATH.format(gender, i, layer.name(), j, item.name(), itemLayer.name()), exportParams):
                        print('Failed to export ' + SAVE_FILE_PATH.format(gender, i, layer.name(), j, item.name(), itemLayer.name()))
                    itemLayer.setVisible(False)
                item.setVisible(False)
                j += 1
            layer.setVisible(False)
            i += 1