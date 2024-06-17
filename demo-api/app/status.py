import random
from datetime import datetime, timedelta

# Global state variable
state = "On Earth"
distance_from_earth = 0
distance_to_moon = 0
speed = 0
nearest_crater = "N/A"
landing_time = "N/A"
call_count = 0

def get_rocket_status():
    global state, distance_from_earth, distance_to_moon, speed, nearest_crater, landing_time, call_count

    call_count += 1

    if call_count == 1:
        return [state, f"Distance from Earth: {distance_from_earth} km", f"Distance to Moon: {distance_to_moon} km", f"Speed: {speed} km/h", f"Nearest Crater: {nearest_crater}", f"Landing Time: {landing_time}"]
    elif call_count == 2:
        state = "In transit"
        distance_from_earth = random.randint(10000, 200000)
        distance_to_moon = random.randint(10000, 200000)
        speed = random.randint(1000, 30000)
        return [state, f"Distance from Earth: {distance_from_earth} km", f"Distance to Moon: {distance_to_moon} km", f"Speed: {speed} km/h", f"Nearest Crater: {nearest_crater}", f"Landing Time: {landing_time}"]
    elif call_count == 3:
        state = "On the moon"
        nearest_crater = random.choice(['Tycho', 'Copernicus', 'Kepler'])
        landing_time = (datetime.utcnow() + timedelta(hours=12)).strftime('%Y-%m-%d %H:%M:%S')
        return [state, f"Distance from Earth: {distance_from_earth} km", f"Distance to Moon: {distance_to_moon} km", f"Speed: {speed} km/h", f"Nearest Crater: {nearest_crater}", f"Landing Time: {landing_time}"]
    else:
        call_count = 1
        state = "On Earth"
        distance_from_earth = 0
        distance_to_moon = 0
        speed = 0
        nearest_crater = "N/A"
        landing_time = "N/A"
        return [state, f"Distance from Earth: {distance_from_earth} km", f"Distance to Moon: {distance_to_moon} km", f"Speed: {speed} km/h", f"Nearest Crater: {nearest_crater}", f"Landing Time: {landing_time}"]