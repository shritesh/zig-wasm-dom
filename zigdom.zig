// https://github.com/shritesh/zig-wasm-dom
extern "document" fn query_selector(selector_ptr: [*]const u8, selector_len: usize) usize;
extern "document" fn create_element(tag_name_ptr: [*]const u8, tag_name_len: usize) usize;
extern "document" fn create_text_node(data_ptr: [*]const u8, data_len: usize) usize;
extern "element" fn set_attribute(element_id: usize, name_ptr: [*]const u8, name_len: usize, value_ptr: [*]const u8, value_len: usize) void;
extern "element" fn get_attribute(element_id: usize, name_ptr: [*]const u8, name_len: usize, value_ptr: *[*]u8, value_len: *usize) bool;
extern "event_target" fn add_event_listener(event_target_id: usize, event_ptr: [*]const u8, event_len: usize, event_id: usize) void;
extern "window" fn alert(msg_ptr: [*]const u8, msg_len: usize) void;
extern "node" fn append_child(node_id: usize, child_id: usize) usize;
extern "zig" fn release_object(object_id: usize) void;

const std = @import("std");

const eventId = enum(usize) {
    Submit,
    Clear,
};

var input_tag_node: u32 = undefined;

fn launch() !void {
    const body_selector = "body";
    const body_node = query_selector(body_selector, body_selector.len);
    defer release_object(body_node);

    if (body_node == 0) {
        return error.QuerySelectorError;
    }
    const input_tag_name = "input";
    input_tag_node = create_element(input_tag_name, input_tag_name.len);
    // We don't release as we'll be referencing it later

    if (input_tag_node == 0) {
        return error.CreateElementError;
    }

    const input_tag_attribute_name = "value";
    const input_tag_attribute_value = "Hello from Zig!";
    set_attribute(input_tag_node, input_tag_attribute_name, input_tag_attribute_name.len, input_tag_attribute_value, input_tag_attribute_value.len);

    const button_tag_name = "button";

    const submit_button_node = create_element(button_tag_name, button_tag_name.len);
    defer release_object(submit_button_node);

    if (submit_button_node == 0) {
        return error.CreateElementError;
    }

    const event_name = "click";
    attach_listener(submit_button_node, event_name, eventId.Submit);

    const submit_text_msg = "submit";
    const submit_text_node = create_text_node(submit_text_msg, submit_text_msg.len);
    defer release_object(submit_text_node);

    if (submit_text_node == 0) {
        return error.CreateTextNodeError;
    }

    const attached_submit_text_node = append_child(submit_button_node, submit_text_node);
    defer release_object(attached_submit_text_node);

    if (attached_submit_text_node == 0) {
        return error.AppendChildError;
    }

    const clear_button_node = create_element(button_tag_name, button_tag_name.len);
    defer release_object(clear_button_node);

    if (clear_button_node == 0) {
        return error.CreateElementError;
    }

    attach_listener(clear_button_node, event_name, eventId.Clear);

    const clear_text_msg = "clear";
    const clear_text_node = create_text_node(clear_text_msg, clear_text_msg.len);
    defer release_object(clear_text_node);

    if (clear_text_node == 0) {
        return error.CreateTextNodeError;
    }

    const attached_clear_text_node = append_child(clear_button_node, clear_text_node);
    defer release_object(attached_clear_text_node);

    if (attached_clear_text_node == 0) {
        return error.AppendChildError;
    }

    const attached_input_node = append_child(body_node, input_tag_node);
    defer release_object(attached_input_node);

    if (attached_input_node == 0) {
        return error.AppendChildError;
    }

    const attached_submit_button_node = append_child(body_node, submit_button_node);
    defer release_object(attached_submit_button_node);

    if (attached_submit_button_node == 0) {
        return error.AppendChildError;
    }

    const attached_clear_button_node = append_child(body_node, clear_button_node);
    defer release_object(attached_clear_button_node);

    if (attached_clear_button_node == 0) {
        return error.AppendChildError;
    }
}

fn attach_listener(node: usize, event_name: []const u8, event_id: eventId) void {
    add_event_listener(node, event_name.ptr, event_name.len, @enumToInt(event_id));
}

export fn dispatchEvent(id: u32) void {
    switch (@intToEnum(eventId, id)) {
        eventId.Submit => on_submit_event(),
        eventId.Clear => on_clear_event(),
    }
}

fn on_clear_event() void {
    const input_tag_attribute_name = "value";
    const input_tag_attribute_value = "";
    set_attribute(input_tag_node, input_tag_attribute_name, input_tag_attribute_name.len, input_tag_attribute_value, input_tag_attribute_value.len);
}

fn on_submit_event() void {
    var attribute_ptr: [*]u8 = undefined;
    var attribute_len: usize = undefined;

    const input_tag_attribute_name = "value";
    const success = get_attribute(input_tag_node, input_tag_attribute_name, input_tag_attribute_name.len, &attribute_ptr, &attribute_len);

    if (success) {
        const result = attribute_ptr[0..attribute_len];
        defer std.heap.page_allocator.free(result);

        alert(result.ptr, result.len);
    }
}

export fn launch_export() bool {
    launch() catch |err| return false;
    return true;
}

export fn _wasm_alloc(len: usize) u32 {
    var buf = std.heap.page_allocator.alloc(u8, len) catch |err| return 0;
    return @ptrToInt(buf.ptr);
}
