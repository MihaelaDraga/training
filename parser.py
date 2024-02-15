def get_last_words_between_timestamp(filename, timestamp_start, timestamp_stop):
    last_words =[]
    in_range_flag = False
    with open(filename, 'r') as file:
        for line in file:
            if timestamp_start in line:
                in_range_flag = True
            elif timestamp_stop in line:
                in_range_flag = False
            if in_range_flag:
                word = line.strip().split()
                if word:
                    last_words.append(word[-1])
    return last_words
filename = 'logcat_applications.txt'
timestamp_start = '17:56:07.996'
timestamp_stop = '17:56:08.357'
last_words = get_last_words_between_timestamp(filename, timestamp_start, timestamp_stop)
print(last_words)