from datetime import datetime
def get_last_words_between_timestamp(filename, timestamp_start, timestamp_stop):
    last_words =[]
    timestamp_start = datetime.strptime(timestamp_start, '%H:%M:%S.%f')
    timestamp_stop = datetime.strptime(timestamp_stop, '%H:%M:%S.%f')
    file = open(filename, 'r')
    file = file.readlines()
    for line in file:
        try:
            timestamp = line.strip().split()[1]
            time = datetime.strptime(timestamp, '%H:%M:%S.%f')
            if timestamp_start <= time < timestamp_stop:
                word = line.strip().split()
                last_words.append(word[-1])
        except:
            print("Error")
    return last_words
filename = 'logcat_applications.txt'
timestamp_start = '17:56:07.996'
timestamp_stop = '17:56:08.357'
last_words = get_last_words_between_timestamp(filename, timestamp_start, timestamp_stop)
print(last_words)