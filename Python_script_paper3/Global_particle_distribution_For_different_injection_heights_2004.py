#!/usr/bin/env python
# coding: utf-8

# In[7]:


import numpy as np
import math

import xarray as xr

import matplotlib.pyplot as plt
import matplotlib.colors as colors
from matplotlib.cm import get_cmap
from matplotlib import ticker
import matplotlib.gridspec as gridspec

from IPython.display import Image

from tqdm import tqdm
import os 
from datetime import date

g = 9.8


# In[8]:


Year = "2004"

Months = []
for imon in range(1,13): ### shw
    Months.append(str(imon).zfill(2))
    
Days = []
for iday in range(1,30,3):
    Days.append(str(iday).zfill(2))
    
print(Year)
print(Months)
print(Days)


# In[9]:


# directory = '/n/home12/hongwei/HONGWEI/lagranto_era5_0.2um/Simulation_0.2um/'+Year+'/'
# directory = '/n/home12/hongwei/Hongwei_holyscratch01/Simulation_0.2um/'+Year+'/'
directory = '/n/home12/hongwei/HONGWEI/lagranto_era5_0.2um/Simulation_0.2um_Publication/6_altitudes/'+Year+'/'


N_head = 5 # first 5 lines are head lines, not include data
N_column = 4

# Nx = 36
# Ny = 21
# Nz = 5
# N_parcel = 3780

Nx = 24
Ny = 21
Nz = 6
N_parcel = Nx*Ny*Nz

if Nx*Ny*Nz!=N_parcel: print('ERROR: parcel number is wrong!')
    
    
# filename = "traj_"+Year+Months[0]+Days[0]+"_trace.1"
# file1 = open(directory+filename, 'r')
# Lines = file1.readlines()
# print(Nt,"days")


# In[10]:


Lats_edge = np.arange(-90,91,6)
Lons_edge = np.arange(-180,181,10)

Lats_mid = np.arange(-87,90,6)
Lons_mid = np.arange(-175,180,10)
Levs = [100, 75, 65, 55, 40, 30]


N_lat = len(Lats_mid)
N_lon = len(Lons_mid)
N_lev = len(Levs) # 16, 18, 20, 22, 24 km

Lats_edge, Lons_edge, Lats_mid, Lons_mid, N_lat, N_lon, Lons_edge[-1]


# In[11]:



def find_i_LON(lon):
    if lon<Lons_edge[0]:  lon = lon+360
    if lon>=Lons_edge[-1]: lon = lon-360
    return int( np.floor( (lon - Lons_edge[0]) / (Lons_edge[1]-Lons_edge[0]) ) )


def find_i_LAT(lat):
    return int( np.floor( (lat - Lats_edge[0]) / (Lats_edge[1]-Lats_edge[0]) ) )


def find_i_LEV(lev):
    if lev==Levs[0]: ii=0
    if lev==Levs[1]: ii=1
    if lev==Levs[2]: ii=2
    if lev==Levs[3]: ii=3
    if lev==Levs[4]: ii=4
    if lev==Levs[5]: ii=5
    return ii


# In[ ]:





# In[12]:


# loop for all traj files

# count the particle (injected at different height) number in each grid cell
N_day = 20*366
Num_2D = np.zeros((N_lon, N_lat, N_lev, N_day)) 
        
for month in Months:
    
    # read tropopause height
    TROP_folder = "/n/home12/hongwei/HONGWEI/lagranto_era5_0.2um/Plot_python/Tropopause_height/"
    TROP_ds  = xr.open_dataset(TROP_folder+'ERA5_monmean_'+month+'.nc')
    TROP_wmo   = TROP_ds["wmo_1st_p"][:,:,:] # [time: 1, lat: 601, lon: 1200]
    TROP_dyn   = TROP_ds["dyn_p"][:,:,:]
    TROP_lon = TROP_ds["lon"].values
    TROP_lat = TROP_ds["lat"].values
    
    
    for day in tqdm(Days):
        
        
        f_date = date(2000, 1, 1)
        l_date = date(int(Year), int(month), int(day))
        Delta  = l_date - f_date
        i_day = Delta.days

        
        # (1) read original data from traj files
        filename = "traj_"+Year+month+day+".1"
        file1 = open(directory+filename, 'r')
        Lines = file1.readlines()

        Nt = int( (len(Lines)-4)/N_parcel - 1 )   
        data = np.zeros((N_parcel, Nt, N_column))
        
        
        count = 0
        # Strips the newline character
        for line in Lines:
            count += 1
    
            if count>=5:
                i = count-5
                i_parcel = math.floor( i / (Nt+1) ) # Nt time lines plue 1 empty line
                i_t = i%(Nt+1)
        
                if i_t!=0:
                    a = line.split()

                    if i_t==1:
                        if float(a[0])!=0.0: print('ERROR: first time is not 0 !!!')
                
                    data[i_parcel,i_t-1,0] = float(a[0]) # t [h]
                    data[i_parcel,i_t-1,1] = float(a[1]) # lon
                    data[i_parcel,i_t-1,2] = float(a[2]) # lat
                    data[i_parcel,i_t-1,3] = float(a[3]) # lev

                
                
        # (2) calculate injected tracer lifetime in the stratosphere
        
        for i_parcel in range(N_parcel):
            In_strat = 1
            
            # select 20 km------------------------------------------
            if abs(data[i_parcel,0,3]-55.0) > 1e-5:
                continue
            
            for it in range(Nt-4):
                
                # check whether touch the tropopause
                LON_1 = data[i_parcel,it,1]
                LAT_1 = data[i_parcel,it,2]
                P_1   = data[i_parcel,it,3]
                P_2   = data[i_parcel,it+1,3]
                P_3   = data[i_parcel,it+2,3]
                
                if P_1>340.0: # directly identified as tropopause
                    In_strat = 0
                    break 
                    
                # once lower than 90 hPa, begin to check whether touch tropopause
                if P_1>90.0 and P_1<P_2 and P_2<P_3: 
                    
                    # match location
                    
                    # make sure LON_1 is alway in the same range of TROP_lon (i.e., -180 to 180)
                    if LON_1<np.min(TROP_lon): LON_1 = LON_1+360
                    if LON_1>np.max(TROP_lon): LON_1 = LON_1-360
                    ilon   = (np.abs(TROP_lon - LON_1)).argmin() 
                    
                    ilat   = (np.abs(TROP_lat - LAT_1)).argmin()

#                     P_trop = TROP_p[0, ilat, ilon] 
                    P_trop = max(TROP_wmo[0, ilat, ilon], TROP_dyn[0, ilat, ilon])
                        
                    # compare particle pressure with tropopause pressure
                    if P_1>P_trop: 
                        In_strat = 0       
                        break    
                    
                    
                # count number of particle in the stratosphere in each grid cell
                if In_strat ==1:
                    LON = data[i_parcel,it,1]
                    LAT = data[i_parcel,it,2]
                    LEV = data[i_parcel,0,3] # consider the initial injection height
                        
                    i_LON = find_i_LON(LON)
                    i_LAT = find_i_LAT(LAT)
                    i_LEV = find_i_LEV(LEV)
                          
#                     print(LON, LAT, LEV, i_LON, i_LAT, i_LEV, it)
                    Num_2D[i_LON, i_LAT, i_LEV, i_day+it] = Num_2D[i_LON, i_LAT, i_LEV, i_day+it] + 1
#                     if data[i_parcel,it,3]>50.0:
#                         Num_2D_lower[i_LON, i_LAT, i_LEV, i_day+it]=Num_2D_lower[i_LON, i_LAT, i_LEV, i_day+it]+1
#                     if data[i_parcel,it,3]<=50.0:
#                         Num_2D_upper[i_LON, i_LAT, i_LEV, i_day+it]=Num_2D_upper[i_LON, i_LAT, i_LEV, i_day+it]+1

        file1.close()
        


# In[ ]:


with open('./Num_Concnt_2000_'+Year+'.txt', 'w') as f:
    for it in range(N_day):
        for ix in range(N_lon):
            for iy in range(N_lat):
                f.write(  str(it) + ',' + str(Lons_mid[ix]) + ',' + str(Lats_mid[iy]) + ',' \
                    + str(Num_2D[ix, iy, 0, it])  + ',' \
                    + str(Num_2D[ix, iy, 1, it])  + ',' \
                    + str(Num_2D[ix, iy, 2, it])  + ',' \
                    + str(Num_2D[ix, iy, 3, it])  + ',' \
                    + str(Num_2D[ix, iy, 4, it])  + ',' \
                    + str(Num_2D[ix, iy, 5, it])   )

                f.write('\n')
f.close()


# with open('./Num_Concnt_data/Num_Concnt_upper_2000_'+Year+'.txt', 'w') as f:
#     for it in range(N_day):
#             for ix in range(N_lon):
#                 for iy in range(N_lat):
#                     f.write(  str(it) + ',' \
#                             + str(Lons_mid[ix]) + ',' \
#                             + str(Lats_mid[iy]) + ',' \
                
#                             + str(Num_2D_upper[ix, iy, 0, it])  + ',' \
#                             + str(Num_2D_upper[ix, iy, 1, it])  + ',' \
#                             + str(Num_2D_upper[ix, iy, 2, it])  + ',' \
#                             + str(Num_2D_upper[ix, iy, 3, it])  + ',' \
#                             + str(Num_2D_upper[ix, iy, 4, it])  + ',' \
#                             + str(Num_2D_upper[ix, iy, 5, it])   )
                
#                     f.write('\n')
# f.close()


# with open('./Num_Concnt_data/Num_Concnt_lower_2000_'+Year+'.txt', 'w') as f:
#     for it in range(N_day):
#             for ix in range(N_lon):
#                 for iy in range(N_lat):
#                     f.write(  str(it) + ',' \
#                             + str(Lons_mid[ix]) + ',' \
#                             + str(Lats_mid[iy]) + ',' \
                
#                             + str(Num_2D_lower[ix, iy, 0, it])  + ',' \
#                             + str(Num_2D_lower[ix, iy, 1, it])  + ',' \
#                             + str(Num_2D_lower[ix, iy, 2, it])  + ',' \
#                             + str(Num_2D_lower[ix, iy, 3, it])  + ',' \
#                             + str(Num_2D_lower[ix, iy, 4, it])  + ',' \
#                             + str(Num_2D_lower[ix, iy, 5, it])   )
                
#                     f.write('\n')
# f.close()


# In[ ]:


Nt


# In[ ]:





# In[ ]:




