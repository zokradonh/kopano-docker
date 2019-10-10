#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4


try:
    import kopano
except ImportError:
    import zarafa as kopano
from MAPI.Util import *
import binascii

def opt_args():
    parser = kopano.parser('skpcf')
    parser.add_option("--user", dest="user", action="store", help="Username")
    parser.add_option("--public", dest="public", action="store_true", help="Show public folders")
    parser.add_option("--delete", dest="delete", action="store", help="Delete folder based on entryid")
    parser.add_option("--extend", dest="extend", action="store_true", help="show more values")

    return parser.parse_args()
def printprop(typename, item):
    if typename == 'PT_MV_BINARY':
        listItem = []
        for i in item:
            listItem.append(str(binascii.hexlify(i)).upper())
        return listItem
    if typename == 'PT_OBJECT':
        return None
    if typename == 'PT_BINARY':
        return str(binascii.hexlify(item)).upper()
    if typename == 'PT_UNICODE':
        try:
            return item.encode('utf-8').decode()
        except:
            return item
    else:
        return item

def printmapiprops(folder):
    props = []
    for prop in folder.props():
        if hex(prop.proptag) == "0x10130102L":
            props.append([prop.id_, prop.idname, hex(prop.proptag), prop.typename, printprop(prop.typename, prop.value), prop.value])
        else:
            props.append([prop.id_, prop.idname, hex(prop.proptag), prop.typename, printprop(prop.typename, prop.value)])

    return props
def main():
    options, args = opt_args()

    if not  options.user and not options.public:
        print('Please use\n' \
            '%s --user <username>  or\n' \
            '%s --public' % (sys.argv[0], sys.argv[0]))
        sys.exit(1)
    if options.user:
        user = kopano.server(options).user(options.user)
        store = user.store
        name = user.name
    if options.public:
        name = 'Public'
        store = kopano.server(options).public_store
    if not options.delete:
        print('Store:', name.encode('utf-8').decode())
        print('{:50} {:50} {:50}'.format('Folder name', 'Parent folder', 'Entryid'))

        for folder in store.root.folders():
            print('{:50} {:50} {:50}'.format(folder.name.encode('utf8').decode(), folder.parent.name.encode('utf8').decode(), folder.entryid))
            if options.extend:
                props = printmapiprops(folder)
                f = open('%s-%s.prop' % (folder.name, folder.entryid), 'w')
                for prop in props:
                    f.write('{0:5}  {1:37}  {2:8}  {3:10}  {4:1}\n'.format(prop[0], prop[1], prop[2], prop[3], prop[4]))
                f.close()

    else:
        print('Not in yet')




if __name__ == "__main__":
    main()
