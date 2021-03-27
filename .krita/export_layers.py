from krita import *

SAVE_PATH = 'C:/game_development/projects/sutemo/sprites/{}/{}/{:02d}_{}/{}.png'

app = Krita.instance()
exportParams = InfoObject()
documentsOpen = app.documents()

hairFilters = [False, True, False, False]
skinFilters = [True, False, False, True]
eyeFilters = [False, False, True, False]
defaultFilters = [False, False, False, False]

for doc in documentsOpen:
    doc.setBatchmode(True)
    gender = doc.fileName().split('/')[-1].split('.')[0]
    filters = [doc.nodeByName('lighten_skin'), doc.nodeByName('lighten_hair'), doc.nodeByName('lighten_eyes'), doc.nodeByName('pink_tint')]
    topLayers = doc.topLevelNodes()
    for layer in topLayers:
        layer.setVisible(False)
    for layer in topLayers:
        if layer.type() == 'grouplayer':
            layer.setVisible(True)
            for item in layer.childNodes():
                item.setVisible(False)
            i = 0
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
                    for j in range(len(filters)):
                        filters[j].setVisible(curFilters[j])
                    doc.refreshProjection()
                    if not doc.exportImage(SAVE_PATH.format(gender, layer.name(), i, item.name(), itemLayer.name()), exportParams):
                        print('Failed to export ' + SAVE_PATH.format(gender, layer.name(), i, item.name(), itemLayer.name()))
                    itemLayer.setVisible(False)
                item.setVisible(False)
                i += 1
            layer.setVisible(False)