import json
import io
import sys
def convert_frame_to_binary(payload):
    parsed_binary_numbers = []
    for byte in payload:
        binary_byte =bin(int(byte, 16))[2:].zfill(8)
        parsed_binary_numbers.extend(list(binary_byte))
    return parsed_binary_numbers
def find_payload(hex_frame, header_byte1,header_byte2, dlc_hex):
    hex_list = hex_frame.split()
    payload =[]
    header_found =False
    for i in range(len(hex_list) - 1):
        if hex_list[i] == header_byte1 and hex_list[i+1] == header_byte2 and hex_list[i+2]==dlc_hex:
            if i != -1:
                print(f"Header {header_byte1+header_byte2} + DLC: {dlc_hex} found at position '{i}'")
                header_pos =i
                payload_start = header_pos + 3
                payload_stop = payload_start + int(dlc_hex)
                payload = hex_list[payload_start:payload_stop]
            else:
                print(f"Header not found")
            return payload
    print ("Not found one or more start components")
    return payload
def find_header(hex_frame, header_byte1,header_byte2):
    hex_bytes = hex_frame.split()
    header_complet = header_byte1+header_byte2
    for i in range(len(hex_bytes)-1):
        if hex_bytes[i] == header_byte1 and hex_bytes[i+1] ==header_byte2:
            if i != -1:
                print(f"Header '{header_complet}' found at position '{i}'")
            else:
                print(f"Header '{header_complet}' not found")
            return i
    return header_complet
def find_pos_DLC(hex_number, data_lengh):
    hex_bytes = hex_number.split()
    poz = []
    for i,hex_value in enumerate(hex_bytes):
        if hex_value == data_lengh:
            poz.append(i)
    return poz
def get_signal_value(binary_frame,byte_position,bit_pos,lengh,val_to_set):
    if byte_position < 0 or byte_position>= len(binary_frame):
        raise IndexError("Byte position out of range")
    start_index= byte_position * 8
    end_index = start_index + 8
    byte = binary_frame[start_index:end_index]
    a = 7 - bit_pos
    subsir = byte[a:a + lengh]
    decimal_value = int(subsir[0],2)
    #decimal_value = int(subsir, 2)
    bool_value = False
    if byte_position == 2 and bit_pos == 5 and lengh == 2:
        bit_signal= decimal_value
        print ("LDW_AlertStatus is:",bit_signal)
        if bit_signal == val_to_set :
            print (f"LDW_AlertStatus already set to {val_to_set}")
        else:
            bit_signal = val_to_set
            bin_representation = bin(bit_signal)[2:]
            print("bin",bin_representation)
            start_pos = a
            stop_pos = a+len(bin_representation)
            bin_representation=bin_representation.zfill(stop_pos-start_pos)
            byte[start_pos:stop_pos]=bin_representation
            print("New byte list",byte)

    elif byte_position == 5 and bit_pos == 2 and lengh== 1:
        bit_signal = decimal_value
        print("LCA_OverrideDisplay is:",decimal_value)
        if bit_signal==val_to_set:
            print (f"LCA_OverrideDisplay already set to {val_to_set}")
        else:
            bit_signal = val_to_set
            bin_representation = bin(bit_signal)[2:]
            print("bin", bin_representation)
            start_pos = a
            stop_pos = a + len(bin_representation)
            bin_representation = bin_representation.zfill(stop_pos - start_pos)
            byte[start_pos:stop_pos] = bin_representation
            print("New byte list", byte)
    elif byte_position == 4 and bit_pos == 7 and lengh == 6:
        bit_signal = decimal_value
        print("DW_FollowUpTimeDisplay is:",decimal_value)
        if bit_signal==val_to_set:
            print (f"DW_FollowUpTimeDisplay already set to {val_to_set}")
        else:
            bit_signal = val_to_set
            bin_representation = bin(bit_signal)[2:]
            print("bin", bin_representation)
            start_pos = a
            stop_pos = a + len(bin_representation)
            bin_representation = bin_representation.zfill(stop_pos - start_pos)
            byte[start_pos:stop_pos] = bin_representation
    start_pos = byte_position * 8
    stop_pos = start_index + 8
    binary_frame[start_pos:stop_pos] = byte
    binary_frame_string = ''.join(binary_frame)
    hex_str = hex(int(binary_frame_string, 2))[2:]
    print(f"The signal is set to {bit_signal}")
    return hex_str
def set_frame(hex_frame,payload_set,header_byte1,header_byte2,dlc_hex):
    hex_list = hex_frame.split()
    print("hex_lisr is:",hex_list)
    hex_payload = [payload_set[i:i+2] for i in range(0, len(payload_set),2)]
    print("pay_set",hex_payload)
    payload = []
    header_found = False
    for i in range(len(hex_list) - 1):
        if hex_list[i] == header_byte1 and hex_list[i + 1] == header_byte2 and hex_list[i + 2] == dlc_hex:
            if i != -1:
                print(f"Header {header_byte1 + header_byte2} + DLC: {dlc_hex} found at position '{i}'")
                header_pos = i
                payload_start = header_pos + 3
                payload_stop = payload_start + int(dlc_hex)
                payload = hex_list[payload_start:payload_stop]
                print("payload is",payload)
            else:
                print(f"Header not found")
   # print("Hex_list_payload is :" , payload)
    print(hex_list[:payload_start])
    print(hex_payload)
    print(hex_list[payload_stop:])
    new_hex_list=hex_list[:payload_start] + hex_payload + hex_list[payload_stop:]
    print("Hex_list_payload is", new_hex_list)
    final_hex_frame =' '.join(new_hex_list)
    return final_hex_frame
hex_frame = "00 06 02 08 80 00 00 00 00 00 00 00 00 05 D0 08 FF 60 00 00 02 00 00 00 00 06 01 08 80 00 00 00 00 00 00 00 00 00 10 C7 77 8A 70 AB AF 88 2A 8C"
header_byte1 = '06'
header_byte2 = '02'
dlc_byte_lengh = '08'
with open('ADAS_signals.json', 'r') as file:
    dict_data=json.load(file)
byte_pos_dw = dict_data.get("DW_FollowUpTimeDisplay",{}).get("BytePos",None)
bit_pos_dw = dict_data.get("LCA_OverrideDisplay",{}).get("BitPos",None)
print(f"Byte from DW is {byte_pos_dw} and bit from LCA is {bit_pos_dw}")
lengh_data_pos = find_pos_DLC(hex_frame,dlc_byte_lengh)
print(f"DLC was found at positions:{lengh_data_pos} and has payload lengh {int(dlc_byte_lengh)} bytes")
payload_itself= find_payload(hex_frame,header_byte1,header_byte2,dlc_byte_lengh)
print("Payload is:",payload_itself)
payload_bin = convert_frame_to_binary(payload_itself)
print("Payload binary list",payload_bin)
signal_value = get_signal_value(payload_bin,2,5,2,2)
print("The frame in hex is :", signal_value)
final_frame = set_frame(hex_frame,signal_value,header_byte1,header_byte2,dlc_byte_lengh)
print("Final frame is:",final_frame)
