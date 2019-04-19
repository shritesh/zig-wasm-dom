const getString = function(ptr, len) {
  const slice = zigdom.exports.memory.buffer.slice(ptr, ptr + len);
  const textDecoder = new TextDecoder();
  return textDecoder.decode(slice);
};

const pushObject = function(object) {
  return zigdom.objects.push(object);
};

const getObject = function(objId) {
  return zigdom.objects[objId - 1];
};

const dispatch = function(eventId) {
  return function() {
    zigdom.exports.dispatchEvent(eventId);
  };
};

const elementSetAttribute = function(
  node_id,
  name_ptr,
  name_len,
  value_ptr,
  value_len
) {
  const node = getObject(node_id);
  const attribute_name = getString(name_ptr, name_len);
  const value = getString(value_ptr, value_len);
  node[attribute_name] = value;
};

const elementGetAttribute = function(
  node_id,
  name_ptr,
  name_len,
  result_address_ptr,
  result_address_len_ptr
) {
  const node = getObject(node_id);
  const attribute_name = getString(name_ptr, name_len);
  const result = node[attribute_name];
  // convert result into Uint8Array
  const textEncoder = new TextEncoder();
  const resultArray = textEncoder.encode(result);
  var len = resultArray.length;

  if (len === 0) {
    return false;
  }

  // allocate required number of bytes
  const ptr = zigdom.exports._wasm_alloc(len);
  if (ptr === 0) {
    throw "Cannot allocate memory";
  }

  // write the array to the memory
  const mem_result = new DataView(zigdom.exports.memory.buffer, ptr, len);
  for (let i = 0; i < len; ++i) {
    mem_result.setUint8(i, resultArray[i], true);
  }

  // write the address of the result array to result_address_ptr
  const mem_result_address = new DataView(
    zigdom.exports.memory.buffer,
    result_address_ptr,
    32 / 8
  );
  mem_result_address.setUint32(0, ptr, true);

  //write the size of the result array to result_address_ptr_len_ptr
  const mem_result_address_len = new DataView(
    zigdom.exports.memory.buffer,
    result_address_len_ptr,
    32 / 8
  );
  mem_result_address_len.setUint32(0, len, true);

  // return if success? (optional)
  return true;
};
const eventTargetAddEventListener = function(
  objId,
  event_ptr,
  event_len,
  eventId
) {
  const node = getObject(objId);
  const ev = getString(event_ptr, event_len);
  node.addEventListener(ev, dispatch(eventId));
};

const documentQuerySelector = function(selector_ptr, selector_len) {
  const selector = getString(selector_ptr, selector_len);
  return pushObject(document.querySelector(selector));
};

const documentCreateElement = function(tag_name_ptr, tag_name_len) {
  const tag_name = getString(tag_name_ptr, tag_name_len);
  return pushObject(document.createElement(tag_name));
};

const documentCreateTextNode = function(data_ptr, data_len) {
  data = getString(data_ptr, data_len);
  return pushObject(document.createTextNode(data));
};

const nodeAppendChild = function(node_id, child_id) {
  const node = getObject(node_id);
  const child = getObject(child_id);

  if (node === undefined || child === undefined) {
    return 0;
  }

  return pushObject(node.appendChild(child));
};

const windowAlert = function(msg_ptr, msg_len) {
  const msg = getString(msg_ptr, msg_len);
  alert(msg);
};

const zigReleaseObject = function(object_id) {
  zigdom.objects[object_id - 1] = undefined;
};

const launch = function(result) {
  zigdom.exports = result.instance.exports;
  if (!zigdom.exports.launch_export()) {
    throw "Launch Error";
  }
};

var zigdom = {
  objects: [],
  imports: {
    document: {
      query_selector: documentQuerySelector,
      create_element: documentCreateElement,
      create_text_node: documentCreateTextNode
    },
    element: {
      set_attribute: elementSetAttribute,
      get_attribute: elementGetAttribute
    },
    event_target: {
      add_event_listener: eventTargetAddEventListener
    },
    node: {
      append_child: nodeAppendChild
    },
    window: {
      alert: windowAlert
    },
    zig: {
      release_object: zigReleaseObject
    }
  },
  launch: launch,
  exports: undefined
};
