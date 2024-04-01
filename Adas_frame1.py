import json
import io
import sys
def find_head(element):
    with open('headers.json', 'r') as file:
        dict_data = json.load(file)
    hex_list = hex_frame.split()
    payload =[]
    for i in range(len(hex_list) - 1):
        if hex_list[i] == dict_data[element]['byte_header1'] and hex_list[i + 1] == dict_data[element]['byte_header2'] and hex_list[i + 2] == dict_data[element]['dlc']:
            if i != -1:
                print(
                    f"Header {dict_data[element]['byte_header1'] + dict_data[element]['byte_header2']} + DLC: {dict_data[element]['dlc']} found at position '{i}'")
                header_pos = i
                payload_start = header_pos + 3
                payload_stop = payload_start + int(dict_data[element]['dlc'])
                payload = hex_list[payload_start:payload_stop]
    return payload

def find_payload(hex_frame,sig_list):
    payload =[]
    for element in sig_list:
        if element == "LDW_head1":
            payload1=find_head(element)
        elif element == "DW_head2":
            payload2 = find_head(element)
        elif element == "LCA_head3":
            payload3 = find_head(element)
    return payload1,payload2,payload3
def convert_frame_to_binary(payload):
    parsed_binary_numbers = []
    for byte in payload:
        binary_byte =bin(int(byte, 16))[2:].zfill(8)
        parsed_binary_numbers.extend(list(binary_byte))
    return parsed_binary_numbers
def get_and_set_signal_value(hex_frame,sig_name):
    with open('ADAS_signals.json', 'r') as file:
        dict_data = json.load(file)
    start_index = dict_data[sig_name]['BytePos'] * 8
    end_index = start_index + 8
    byte = hex_frame[start_index:end_index]
    a = 7 - dict_data[sig_name]['BitPos']
    subsir = byte[a:a + dict_data[sig_name]['Size']]
    decimal_value = int(subsir[0], 2)
    bit_signal = decimal_value
    if bit_signal == dict_data[sig_name]['Value']:
        print(f"{sig_name} already set to {dict_data[sig_name]['Value']}")
        bit_signal == dict_data[sig_name]['Value']
    else:
        bit_signal = dict_data[sig_name]['Value']
    bin_representation = bin(bit_signal)[2:]
    start_pos = a
    stop_pos = a + len(bin_representation)
    bin_representation = bin_representation.zfill(stop_pos - start_pos)
    byte[start_pos:stop_pos] = bin_representation
    start_pos = dict_data[sig_name]['BytePos'] * 8
    stop_pos = start_index + 8
    hex_frame[start_pos:stop_pos] = byte
    binary_frame_string = ''.join(hex_frame)
    hex_str = hex(int(binary_frame_string, 2))[2:]
    return hex_str
def get_payload_hex_list(pay_bin_list,sig_list):
    for element in pay_bin_list:
        if sig_list1[0] == 'LDW_AlertStatus' and element == pay_bin_list[0]:
            hex_value0 = get_and_set_signal_value(element, sig_list1[0])
            print("Hex value of paylod after signal LDW_AlertStatus set is :", get_and_set_signal_value(element, sig_list1[0]))
        elif sig_list1[1] == 'DW_FollowUpTimeDisplay' and element == pay_bin_list[1]:
            hex_value1 = get_and_set_signal_value(element, sig_list1[1])
            print("Hex value of paylod after signal  DW_FollowUpTimeDisplay set is :", get_and_set_signal_value(element, sig_list1[1]))
        elif sig_list1[2] == 'LCA_OverrideDisplay' and element == pay_bin_list[2]:
            hex_value2 = get_and_set_signal_value(element, sig_list1[2])
            print("Hex value of paylod after signal LCA_OverrideDisplay  set is :", get_and_set_signal_value(element, sig_list1[2]))
        else:
            print("Something  is not OK!")
    return hex_value0,hex_value1,hex_value2
def set_frame(hex_frame,signals_set_hex_list,element):
    with open('headers.json', 'r') as file:
        dict_data = json.load(file)
    hex_list = hex_frame.split()
    hex_payload = [signals_set_hex_list[i:i+2].upper() for i in range(0, len(signals_set_hex_list),2)]
    payload = []
    for i in range(len(hex_list) - 1):
        if element == 'LDW_head1' and hex_list[i] == dict_data[element]['byte_header1'] and hex_list[i + 1] == dict_data[element]['byte_header2'] and hex_list[i + 2] == dict_data[element]['dlc']:
                header_pos = i
                payload_start = header_pos + 3
                payload_stop = payload_start + int(dict_data[element]['dlc'])
                payload = hex_list[payload_start:payload_stop]
                new_hex_list = hex_list[:payload_start] + hex_payload + hex_list[payload_stop:]
                final_hex_frame1 = ' '.join(new_hex_list)
                return final_hex_frame1
        elif element == sig_list[1] and hex_list[i] == dict_data[element]['byte_header1'] and hex_list[i + 1] == dict_data[element]['byte_header2'] and hex_list[i + 2] == dict_data[element]['dlc']:
                header_pos = i
                payload_start = header_pos + 3
                payload_stop = payload_start + int(dict_data[element]['dlc'])
                payload = hex_list[payload_start:payload_stop]
                new_hex_list = hex_list[:payload_start] + hex_payload + hex_list[payload_stop:]
                final_hex_frame2 = ' '.join(new_hex_list)
                return final_hex_frame2
        elif element == sig_list[2] and hex_list[i] == dict_data[element]['byte_header1'] and hex_list[i + 1] == dict_data[element]['byte_header2'] and hex_list[i + 2] == dict_data[element]['dlc']:
                header_pos = i
                payload_start = header_pos + 3
                payload_stop = payload_start + int(dict_data[element]['dlc'])
                payload = hex_list[payload_start:payload_stop]
                new_hex_list = hex_list[:payload_start] + hex_payload + hex_list[payload_stop:]
                final_hex_frame3 = ' '.join(new_hex_list)
                return final_hex_frame3
def replace_frame(hex_frame,frames):
    hexupper=hex_frame.upper()
    initial_list = hexupper.split()
    replaced_frame = initial_list.copy()
    for frame in frames:
        frame_list=frame.split()
        for i in range(len(initial_list)):
            if initial_list[i] != frame_list[i]:
                replaced_frame[i] = frame_list[i]
    return ' '.join(replaced_frame)
hex_frame = "00 06 02 08 80 00 00 00 00 00 00 00 00 05 D0 08 FF 60 00 00 02 00 00 00 00 06 01 08 80 00 00 00 00 00 00 00 00 00 10 C7 77 8A 70 AB AF 88 2A 8C"
sig_list = ["LDW_head1", "DW_head2", "LCA_head3"]
sig_list1 = ["LDW_AlertStatus", "DW_FollowUpTimeDisplay", "LCA_OverrideDisplay"]
payload1, payload2, payload3 = find_payload(hex_frame,sig_list)
print(f"Payload1 is:{payload1}\nPayload2 is:{payload2}\nPayload3 is:{payload3}")
pay1_bin = convert_frame_to_binary(payload1)
pay2_bin = convert_frame_to_binary(payload2)
pay3_bin = convert_frame_to_binary(payload3)
pay_bin_list = [pay1_bin,pay2_bin,pay3_bin]
print("Bin list of all three  payloads is",pay_bin_list)
signals_set_hex_list = get_payload_hex_list(pay_bin_list,sig_list1)
print("Signals hex list after set ",signals_set_hex_list)
c=set_frame(hex_frame,signals_set_hex_list[2],sig_list[2])
b=set_frame(hex_frame,signals_set_hex_list[1],sig_list[1])
a=set_frame(hex_frame,signals_set_hex_list[0],sig_list[0])
replaced_frame = replace_frame(hex_frame,[a,b,c])
print("Final frame after replacing the signals sets is:",replaced_frame)