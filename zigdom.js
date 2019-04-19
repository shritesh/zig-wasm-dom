const getString = function(ptr, len) {
    const slice = zigdom.exports.memory.buffer.slice(ptr, ptr + len);
    const textDecoder = new TextDecoder();
    return textDecoder.decode(slice);
}

const pushObject = function(object) {
    return zigdom.objects.push(object);
}

const getObject = function(objId) {
    return zigdom.objects[objId - 1];
}

const documentQuerySelector = function(selector_ptr, selector_len) {
    selector = getString(selector_ptr, selector_len);
    return pushObject(document.querySelector(selector));
}

const documentCreateElement = function(tag_name_ptr, tag_name_len) {
    tag_name = getString(tag_name_ptr, tag_name_len);
    return pushObject(document.createElement(tag_name));
}

const documentCreateTextNode = function(data_ptr, data_len) {
    data = getString(data_ptr, data_len);
    return pushObject(document.createTextNode(data));
}

const nodeAppendChild = function(node_id, child_id) {
    const node = getObject(node_id);
    const child = getObject(child_id);

    if (node === undefined || child === undefined) {
        return 0;
    }

    return pushObject(node.appendChild(child));
}

const zigReleaseObject = function(object_id) {
    zigdom.objects[object_id] = undefined;
}

const launch = function(result) {
    zigdom.exports = result.instance.exports;   
    if (!zigdom.exports.launch_export()) {
        throw "Launch Error";
    }
}

var zigdom = {
    objects: [],
    imports: {
        document: {
            query_selector: documentQuerySelector,
            create_element: documentCreateElement,
            create_text_node: documentCreateTextNode,
        },
        node: {
            append_child: nodeAppendChild
        },
        zig: {
            release_object: zigReleaseObject
        }
    },
    launch: launch,
    exports: undefined
};
