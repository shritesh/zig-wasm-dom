extern "document" fn query_selector(selector_ptr: [*]u8, selector_len: usize) usize;
extern "document" fn create_element(tag_name_ptr: [*]u8, tag_name_len: usize) usize;
extern "document" fn create_text_node(data_ptr: [*]u8, data_len: usize) usize;
extern "node" fn append_child(node_id: usize, child_id: usize) usize;
extern "zig" fn release_object(object_id: usize) void;

fn launch() !void {
    const body_selector = "body";
    const body_node = query_selector(&body_selector, body_selector.len);
    defer release_object(body_node);

    if (body_node == 0) {
        return error.ElementNotFound;
    }

    const pre_tag_name = "pre";
    const pre_tag_node = create_element(&pre_tag_name, pre_tag_name.len);
    defer release_object(pre_tag_node);
    
    const text_msg = @embedFile("zigdom.zig");
    const text_node = create_text_node(&text_msg, text_msg.len);
    defer release_object(text_node);

    if (text_node == 0) {
        return error.ElementNotFound;
    }

    const attached_text_node = append_child(pre_tag_node, text_node);
    defer release_object(attached_text_node);

    const attached_pre_node = append_child(body_node, pre_tag_node);
    defer release_object(attached_pre_node);
}

export fn launch_export() bool {
    launch() catch |err| return false;
    return true;
}
