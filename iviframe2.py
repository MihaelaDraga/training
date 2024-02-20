import math
def hex_to_binary(hex_number):
    hex_bytes = hex_number.split()
    binary_number = ''.join(bin(int(byte, 16))[2:].zfill((len(hex_number)*4)) for byte in hex_bytes)
    return binary_number
def parse_binary_frame(hex_frame):
    hex_bytes = hex_frame.split()
    print(hex_bytes)
    parsed_binary_numbers = []
    for byte in hex_bytes:
        binary_byte =bin(int(byte, 16))[2:].zfill(8)
        parsed_binary_numbers.extend(list(binary_byte))
    return parsed_binary_numbers
def get_signal_value(binary_frame,byte_position,bit_pos,lengh):
    if byte_position < 0 or byte_position>= len(binary_frame):
        raise IndexError("Byte position out of range")
    start_index= byte_position * 8
    end_index = start_index + 8
    byte = binary_frame[start_index:end_index]
    print("Byte sequence is:",byte)
    a = 7 - bit_pos
    subsir = byte[a:a + lengh]
    print("Bits sequence:", subsir)
    decimal_value = int(subsir, 2)
    bool_value = False
    if byte_position == 0 and bit_pos == 7 and lengh ==3:
        print ("PassengerSetMemoRequest is:",decimal_value)
        bool_value =True
    elif byte_position == 5 and bit_pos == 7 and lengh==4:
        print("ClimFPrightBlowingRequest is:",decimal_value)
        bool_value = True
    elif byte_position == 5 and bit_pos ==3 and lengh ==1:
        print("TimeFormatDisplay is:",decimal_value)
        bool_value = True
    return bool_value

hex_number = "60 20 45 6C FE 3D 4B AA"
binary = parse_binary_frame(hex_number)
print("Binary list=" ,binary)
binary_string = ''.join(binary)
print("Final value is ",get_signal_value(binary_string,5,7,4) )
