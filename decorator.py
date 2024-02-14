def format(cnp):
    if not cnp.isdigit() or len(cnp) !=13:
        return "Invalid cnp because is not a 13 digit numeric number"
    if not 1<= int(cnp[0]) <= 9:
        return "Invalid cnp  because first digit should be between 1 and 9"
    month = int(cnp[3:5])
    if not 1<= month <= 12:
        return "Month incorect, shoul be between 1 and 12"
    day = int(cnp[5:7])
    if not 1<= day <= 31:
        return "Day incorrect, should be between 1 and 31"
    if not cnp[1:].isdigit():
        return "Invalid cnp because it must be numeric"
    return "Valid cnp"
cnp = input("Give your cnp:")
print(format(cnp))

