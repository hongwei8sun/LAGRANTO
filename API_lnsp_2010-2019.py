import cdsapi
import calendar

c = cdsapi.Client()

### data download specifications:
cls     = "ea"         	# do not change
expver  = "1"          	# do not change
levtype = "ml"         	# do not change
stream  = "oper"       	# do not change
date    = "2010-01-01/to/2010-12-31" 
		       	# date: Specify a single date as "2018-01-01" or a period as "2018-08-01/to/2018-01-31". For periods > 1 month see https://software.ecmwf.int/wiki/x/l7GqB
tp      = "an"         	# type: Use "an" (analysis) unless you have a particular reason to use "fc" (forecast).
time    = "00:00:00/03:00:00/06:00:00/09:00:00/12:00:00/15:00:00/18:00:00/21:00:00"
                       	# time: ERA5 data is hourly. Specify a single time as "00:00:00", or a range as "00:00:00/01:00:00/02:00:00" or "00:00:00/to/23:00:00/by/1".


### 2017
date    = "2017-01-01/to/2017-12-31"
c.retrieve('reanalysis-era5-complete', {
    'class'   : cls,
    'date'    : date,
    'expver'  : expver,
    'levelist': '1',
    'levtype' : 'ml',
    'param'   : '152',
    'stream'  : stream,
    'time'    : time,
    'type'    : tp,
    'grid'    : [1.0, 1.0], # Latitude/longitude grid: east-west (longitude) and north-south resolution (latitude). Default: 0.25 x 0.25
}, 'ERA5_lnsp_2017.grib')


### 2018
date    = "2018-01-01/to/2018-12-31"
c.retrieve('reanalysis-era5-complete', {
    'class'   : cls,
    'date'    : date,
    'expver'  : expver,
    'levelist': '1',
    'levtype' : 'ml',
    'param'   : '152',
    'stream'  : stream,
    'time'    : time,
    'type'    : tp,
    'grid'    : [1.0, 1.0], # Latitude/longitude grid: east-west (longitude) and north-south resolution (latitude). Default: 0.25 x 0.25
}, 'ERA5_lnsp_2018.grib')


### 2019
date    = "2019-01-01/to/2019-12-31"
c.retrieve('reanalysis-era5-complete', {
    'class'   : cls,
    'date'    : date,
    'expver'  : expver,
    'levelist': '1',
    'levtype' : 'ml',
    'param'   : '152',
    'stream'  : stream,
    'time'    : time,
    'type'    : tp,
    'grid'    : [1.0, 1.0], # Latitude/longitude grid: east-west (longitude) and north-south resolution (latitude). Default: 0.25 x 0.25
}, 'ERA5_lnsp_2019.grib')



