function select_click(d_o_name, select_value) {
XHR.post('/cgi-bin/luci/admin/services/digital_outs/select', { id: d_o_name, value: select_value }, function(x) { console.log(x); location.reload(); });
}

function add_click() {
XHR.post('/cgi-bin/luci/admin/services/digital_outs/add', { }, function(x) { console.log(x); location.reload(); });
}

function delete_click(delete_id) {
if (confirm (question_delete)) { XHR.post('/cgi-bin/luci/admin/services/digital_outs/delete', { id: delete_id }, function(x) { console.log(x); location.reload(); }); }
}

function settings_click(d_o_id) {
XHR.post('/cgi-bin/luci/admin/services/digital_outs/settings', { id : d_o_id }, function(x) {
var data_array = x.responseText.split("\n");
document.getElementById('d_o_edit_id').value = data_array[0];
document.getElementById('d_o_edit_memo').value = data_array[1];
document.getElementById('d_o_edit_state_alias_0').value = data_array[2];
document.getElementById('d_o_edit_state_alias_1').value = data_array[3];
document.getElementById('d_o_edit_address').value = data_array[4];
document.getElementById('d_o_edit_oid').value = data_array[5];
document.getElementById('d_o_edit_community').value = data_array[6];
document.getElementById('d_o_edit_port').value = data_array[7];
document.getElementById('d_o_edit_period').value = data_array[8];
document.getElementById('d_o_edit_timeout').value = data_array[9];
});
document.getElementById('div_gray_background').style.display="block";
}

function save_settings() {
d_o_id = document.getElementById('d_o_edit_id').value;
d_o_memo = document.getElementById('d_o_edit_memo').value;
d_o_state_alias_1 = document.getElementById('d_o_edit_state_alias_1').value;
d_o_state_alias_0 = document.getElementById('d_o_edit_state_alias_0').value;
d_o_address = document.getElementById('d_o_edit_address').value;
d_o_oid = document.getElementById('d_o_edit_oid').value;
d_o_community = document.getElementById('d_o_edit_community').value;
d_o_port = document.getElementById('d_o_edit_port').value;
d_o_period = document.getElementById('d_o_edit_period').value;
d_o_timeout = document.getElementById('d_o_edit_timeout').value;
XHR.post('/cgi-bin/luci/admin/services/digital_outs/settings-commit', { id : d_o_id, memo: d_o_memo, state_alias_1: d_o_state_alias_1, state_alias_0: d_o_state_alias_0, address: d_o_address, oid: d_o_oid, community: d_o_community, port: d_o_port, period: d_o_period, timeout: d_o_timeout }, function(x) { console.log(x); location.reload(); });
}

function status_view(status_text) {
var status_split = status_text.split("\n");
for (let i=0; i < (status_split.length-1); i=i+3) {
    id = status_split[i]; 
    document.getElementById(id + '_state').innerHTML = status_split[i+1]; 
switch (status_split[i+2]) {
case "0":
      current_status = "<font color='#4c4'>" + status_0 + "</font>"; break;
case "1":
      current_status = "<font color='#44c'>" + status_1 + "</font>"; break;
case "2":
      current_status = "<font color='#c44'>" + status_2 + "</font>"; break;
default:
      current_status = "--"; break; }
document.getElementById(id + '_status').innerHTML = current_status;
}}