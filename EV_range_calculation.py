def calc_autonomy(battery_level):
    total_battery_capacity = 62
    energy_consumption = 15.6
    estimated_range = (battery_level/100)*total_battery_capacity / (energy_consumption/100)
    return estimated_range
battery_level = float(input("Enter battery level in percentage:",))
autonomy = calc_autonomy((battery_level))
print (f"Estimated autonomy of {battery_level} is {autonomy} .%2f km")