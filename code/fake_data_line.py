# -*- coding: utf-8 -*-
"""
Created on Thu May  2 08:49:21 2019

@author: Quentin
"""

# Create a curve

import csv
import math
import random as rd
import matplotlib.pyplot as plt

# generate the first point
fp_lat = rd.uniform(-60,60)
fp_long = rd.uniform(-100,100)
# ft_alt = rd.uniform(0,100) to define later
fp_speed = 0

rang = input("Nombre de valeurs test : ")

r_lat = rd.choice([-1,1]) # generate a value to choose the latitude direction
r_long = rd.choice([-1,1]) # generate a value to choose the longitude direction

Lat = [fp_lat]
Long = [fp_long]

dist = 0

# create the csv file with false data
# in this case, the program only create a small turn
with open('names.csv', 'w', newline='') as csvfile:
    fieldnames = ['time','lat','lon','elevation','accuracy','bearing','speed','satellites','provider','hdop','vdop','pdop','geidheight','ageofdgpsdata','dgsid','activity']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    writer.writerow({'lat': fp_lat, 'lon': fp_long, 'speed' : fp_speed})
    
    lat, long, speed = fp_lat, fp_long, fp_speed
    
    for i in range(1,int(rang)):
            lat += r_lat*rd.uniform (0,0.001*i/int(rang))
            long += r_long*rd.uniform (0,0.001)
            Lat.append(lat)
            Long.append(long)
            dist += math.sqrt(((Lat[-1]-Lat[-2])*111)**2+((Long[-1]-Long[-2])*71)**2)
            speed = math.sqrt(((Lat[-1]-Lat[-2])*111)**2+((Long[-1]-Long[-2])*71)**2)*100
            writer.writerow({'lat': lat, 'lon': long, 'speed' : speed})
            
print(dist)
            
plt.plot(Long,Lat)
plt.xlabel("Longitude")
plt.ylabel("Latitude")
