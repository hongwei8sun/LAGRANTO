#!/usr/bin/python

# =============================================================================
# Quick Viewer for meteorological fields from ECMWF
# Michael Sprenger, Sebastian Limbach [ based on IWAL], Winter 2012/13  
# =============================================================================

#  Imports
import os
import sys
from   optparse import OptionParser
import subprocess
import datetime

# The absolute path of the test-scripts
SCRIPT_PATH = os.getenv('DYN_TOOLS') + '/quickview/'

# ----------------------------------------------------------------------------
# Help page / show colorbar only
# ----------------------------------------------------------------------------

# Write the help page on demand
if ( sys.argv[1] == 'help' ):

    print ( '--------------------------------------------------------------------------------------------------------' )
    print ( 'Usage: [1] qv help                                                                                      ' ) 
    print ( '       [2] qv data field [options]       -> horizontal and vertical cross sections                      ' )
    print ( '       [3] qv data [options]             -> skew-T/log-P diagram and satellite imagery                  ' )
    print ( '       [4] qv colorbar                   -> show colorbar only                                          ' )
    print ( '                                                                                                        ' )
    print ( 'Arguments:                                                                                              ' )
    print ( '                                                                                                        ' )
    print ( '      data = P{date}           : explicit filename                                                      ' )
    print ( '      data = an.{date}         : operational ECMWF analysis                                             ' )
    print ( '      data = fc.{date}         : most recent operational ECMWF analysis for {date}                      ' )
    print ( '      data = fc.{date0}.{date} : operational ECMWF initialized at {date0} analysis for {date}           ' )
    print ( '      data = ir|wv.date        : IR and WV satellite imagery                                            ' )
    print ( '                                                                                                        ' )
    print ( '      field = Q@200hPa         : e.g. specific humidity (Q) at 200 hPa                                  ' )
    print ( '      field = PV@320K          : e.g. potential vorticity (PV) at 320 K                                 ' )
    print ( '      field = T@15             : e.g. temperature (T) at model level 15                                 ' )
    print ( '      field = SLP              : e.. reduced surface pressure                                           ' )
    print ( '                                                                                                        ' )
    print ( 'Options:                                                                                                ' )
    print ('                                                                                                         ' )
    print ('        -o  figname                              : name of output figure                                 ' )
    print ('        -d  lonmin,lonmax,latmin,latmax|region   : horizontal domain (region:europe,natlantic,nhem,shem) ' )
    print ('        -g  np|sp|latlon                         : geographic projection (np:north pole, sp:south pole, latlon (default)')      
    print ('        -v  lon1,lat1,lon2,lat2[,lev1,lev2,type] : vertical cross section (pype:gc,linear,ns,ew)         ' )
    print ('        -p  lon,lat[,lev1,lev2]                  : vertical profile (skew-T/log-P)                       ' )
    print ('        -c  cmin,cmax[,mode,#cols|colname]       : specification of colortable                           ' )
    print ('        -n  npixel                               : pixel size of figure (default=512)                    ' )
    print ('        -s                                       : show figure                                           ' )
    print ('        -r                                       : remove figure after showing it                        ' )
    print ('        -l                                       : show label/color bar                                  ' )
    print ( '--------------------------------------------------------------------------------------------------------' )

    quit()

elif ( sys.argv[1] == 'colorbar' ):

    figname = 'quickview.color'
    figpath = os.getcwd() + '/'

    print figname, figpath

    wsname  = 'testws'
    npixel  = 512
    os.system('python ' + SCRIPT_PATH + '/ext_scripts/colorbar.py ' +
          ' '.join([str(npixel), wsname, figpath, figname])) 
    
    cmd = 'xv ' + figpath + '/quickview.color.png;'
    subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)

    quit()
    
# ----------------------------------------------------------------------------
# Set ERA-Interim dictionary
# ----------------------------------------------------------------------------
 
erai = { 'T'       : [ 'P', 'dansgaard'],
         'OMEGA'   : [ 'P', 'dansgaard'],
         'U'       : [ 'P', 'dansgaard'],
         'V'       : [ 'P', 'dansgaard'],
         'SLP'     : [ 'P', 'dansgaard'],
         'PS'      : [ 'P', 'dansgaard'],
         'Q'       : [ 'P', 'dansgaard'],
         'LWC'     : [ 'P', 'dansgaard'],
         'IWC'     : [ 'P', 'dansgaard'],
         'U10M'    : [ 'B', 'dansgaard'],
         'V10M'    : [ 'B', 'dansgaard'],
         'TD2M'    : [ 'P', 'dansgaard'],
         'T2M'     : [ 'P', 'dansgaard'],
         'SKT'     : [ 'B', 'dansgaard'],
         'G10M'    : [ 'G', 'dansgaard'],
         'T2MAX'   : [ 'G', 'dansgaard'],
         'T2MIN'   : [ 'G', 'dansgaard'],
         'RTOT'    : [ 'R', 'dansgaard'],
         'LSP'     : [ 'R', 'dansgaard'],
         'CP'      : [ 'R', 'dansgaard'],
         'SF'      : [ 'R', 'dansgaard'],
         'SSHF'    : [ 'R', 'dansgaard'],
         'O3'      : [ 'O', 'litho'    ],
         'TROPO'   : [ 'L', 'litho'    ],
         'LABEL'   : [ 'L', 'litho'    ],
         'CAPE_MU' : [ 'C', 'litho'    ],
         'CIN_MU'  : [ 'C', 'litho'    ],
         'CAPE_ML' : [ 'C', 'litho'    ],
         'CIN_ML'  : [ 'C', 'litho'    ],
         'Z'       : [ 'Z', 'dansgaard'],
         'TH'      : [ 'S', 'thermo'   ],
         'PV'      : [ 'S', 'thermo'   ],
         'RH'      : [ 'S', 'thermo'   ],
         'THE'     : [ 'S', 'thermo'   ]
       }    

# ----------------------------------------------------------------------------
# Get the arguments
# ----------------------------------------------------------------------------

# Parse optional parameters
parser = OptionParser()
parser.add_option("-o",  "--outfile",    type='string',       dest="outfile",    default = 'NONE'  )
parser.add_option("-d",  "--domain",     type='string',       dest="domain",     default = 'NONE'  )
parser.add_option("-p",  "--profile",    type='string',       dest="profile",    default = 'NONE'  )
parser.add_option("-v",  "--vertical",   type='string',       dest="vertical",   default = 'NONE'  )
parser.add_option("-c",  "--color",      type='string',       dest="color",      default = 'NONE'  )
parser.add_option("-n",  "--npixel",     type='int',          dest="npixel",     default = 512     )
parser.add_option("-s",  "--show",       action="store_true", dest="show",       default = False   )
parser.add_option("-r",  "--showremove", action="store_true", dest="showremove", default = False   )
parser.add_option("-l",  "--labelbar",   action="store_true", dest="labelbar",   default = False   ) 
parser.add_option("-g",  "--geoproj",    type='string',       dest="projection", default = 'latlon')

(options, args) = parser.parse_args()

# Get mandatory arguments (inpfile / field) 
inpfile = args[0]
if ( len(args) == 2 ) :
    field   = args[1]
else:
    field = 'T'

# Adjusts defaults
if options.outfile   == 'NONE' :
    outfile = inpfile
else:
    outfile = options.outfile

# Set some internal parameters 
wsname     = 'testws'

# Set name of output figures
figname = outfile
figpath = os.getcwd()+'/'
    
# Decide about the plotting mode
if any( elem == '-d' for elem in sys.argv ):
    print "Mode : horizontal cross scection"
    mode = 'horizontal'

elif any( elem == '-v' for elem in sys.argv ):
    print "Mode : vertical cross scection"
    mode = 'vertical'

elif any( elem == '-p' for elem in sys.argv ):
    print "Mode : vertical profile"
    mode = 'profile'

else:
    print "Mode : horizontal cross section (default)"
    mode = 'horizontal'

# Check that the number of pixel is reasonable
if ( options.npixel > 2000 ):
    sys.exit('number of pixels too large');

# ----------------------------------------------------------------------------
# Set the meteorological field 
# ----------------------------------------------------------------------------

field_split = field.split('@')

if len(field_split) == 1 :
    field_fieldname = field_split[0]
    field_level     = 0
    field_unit      = 'nil'

elif len(field_split) == 2 :
    field_fieldname = field_split[0]
    field_level     = field_split[1]
    i0 = field_level.find('hPa')
    i1 = field_level.find('K'  )
    if ( i0 != -1 ):
        field_unit  = 'hPa'
        field_level = field_level[0:i0]
    elif ( i1 != -1 ):
        field_unit = 'K'
        field_level = field_level[0:i1]
    else:
        field_unit = 'ML'
        field_level = field_level

print field_unit

# ----------------------------------------------------------------------------
# Set the data source + check whether field is available
# ----------------------------------------------------------------------------

inpfile_split = inpfile.split('.')

if len(inpfile_split) == 1 :
    inpfile_filename = os.path.split(inpfile_split[0])[1]
    inpfile_folder   = os.path.split(inpfile_split[0])[0]
    if inpfile_folder == '':
        inpfile_folder = os.getcwd()
    inpfile_folder = inpfile_folder + '/'

elif ( inpfile_split[0] == 'an' ) & ( len(inpfile_split) == 2 ):
    inpfile_filename = 'P'+inpfile_split[1]
    inpfile_folder   = '/net/litho/atmosdyn/ec.analysis/'

elif  ( inpfile_split[0] == 'fc' ) & ( len(inpfile_split) == 2 ):
    inpfile_filename = 'P'+inpfile_split[1]
    today            = datetime.date.today()
    weekday          = today.weekday()
    if ( weekday == 0 ):
        weekday = 6
    else:
        weekday = weekday -1
    daynames         = ( 'Mon','Tue','Wed','Thu','Fri','Sat','Sun' )
    inpfile_folder   = '/net/litho/atmosdyn/ec.forecast/' + daynames[weekday] + '/'

elif  ( inpfile_split[0] == 'fc' ) & ( len(inpfile_split) == 3 ):
    inpfile_filename = 'P'+inpfile_split[2]
    inpfile_folder   = '/net/litho/atmosdyn/ec.forecast/' + inpfile_split[1] + '/'

elif ( inpfile_split[0] == 'ei' ) & ( len(inpfile_split) == 2 ):
        
    inpfile_filename = erai[field_fieldname][0]+inpfile_split[1]
    yyyy             = inpfile_filename[1:5]
    mm               = inpfile_filename[5:7]
    inpfile_folder   = '/net/'+erai[field_fieldname][1]+'/atmosdyn/erainterim/cdf/'+yyyy+'/'+mm+'/'

else:
    sys.exit('Unsupported input file ' + inpfile);

# Check whether the input file is available
if os.path.exists(inpfile_folder+inpfile_filename):
    print 'input file found: ' + inpfile_folder + inpfile_filename
else:
    sys.exit( 'input file is missing : ' + inpfile_folder + inpfile_filename )
    
# Check whether field is available on input file
cmd        = 'getvars ' + inpfile_folder + '/' + inpfile_filename
proc       = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
(out, err) = proc.communicate()  
ok         = any( (elem.strip() == field_fieldname) for elem in out.split('\n') ) 

# If not available, try to calculate it with p2s
if ( ok == False ):
    print 'Try to calculate '+field_fieldname+' with p2s'
    cmd = 'p2s ' + inpfile_folder + '/' + inpfile_filename
    print 'NOT YET IMPLEMTED'

if ok == False:
    sys.exit('variable '+field_fieldname+' missing on '+inpfile_filename);

# ----------------------------------------------------------------------------
# Set the color table
# ----------------------------------------------------------------------------

color_split = options.color.split(',')

if len(color_split) == 5:
    color_cmin = color_split[0]
    color_cmax = color_split[1]
    color_mode = color_split[2]
    color_ncol = color_split[3]
    color_name = color_split[4]

elif len(color_split) == 4:
    color_cmin = color_split[0]
    color_cmax = color_split[1]
    color_mode = color_split[2]
    color_ncol = color_split[3]
    color_name = 'adjust'

elif len(color_split) == 3:
    color_cmin = color_split[0]
    color_cmax = color_split[1]
    color_mode = color_split[2]
    color_ncol = 18
    color_name = 'hotcold_18lev'

elif len(color_split) == 2:
    color_cmin = color_split[0]
    color_cmax = color_split[1]
    color_mode = 'fill'
    color_ncol = '18'
    color_name = 'hotcold_18lev'

elif (color_split[0] == 'PV.default') | ( color_split[0] == 'NONE' ) & ( field_fieldname == 'PV' ):
    color_cmin = '-0.5'
    color_cmax = '10.'
    color_mode = 'fill'
    color_ncol = 'adjust'
    color_name = 'PV.default'

elif color_split[0] == 'NONE':
    color_cmin = 'p95'
    color_cmax = 'p05'
    color_mode = 'fill'
    color_ncol = '18'
    color_name = 'hotcold_18lev'

# ----------------------------------------------------------------------------
# Set the horizontal domain
# ----------------------------------------------------------------------------

# Set the geographical projection 
projection = options.projection
print projection      

domain_split = options.domain.split(',')

print domain_split

if len(domain_split) == 4:
    domain_xmin = domain_split[0]
    domain_xmax = domain_split[1]
    domain_ymin = domain_split[2]
    domain_ymax = domain_split[3]

elif ( len(domain_split) == 1 ) & (options.domain == 'europe' ):
    domain_xmin = -20
    domain_xmax = 40
    domain_ymin = 30
    domain_ymax = 75

elif ( len(domain_split) == 1 ) & (options.domain == 'natlantic' ):
    domain_xmin = -100
    domain_xmax = 10
    domain_ymin = 10
    domain_ymax = 75

elif ( len(domain_split) == 1 ) & (options.domain == 'global' ):
    domain_xmin = -180
    domain_xmax = 180
    domain_ymin = -90
    domain_ymax = 90

elif ( len(domain_split) == 1 ) & (options.domain == 'nhem' ):
    domain_xmin = -180
    domain_xmax = 180
    domain_ymin = 0
    domain_ymax = 90

elif ( len(domain_split) == 1 ) & (options.domain == 'shem' ):
    domain_xmin = -180
    domain_xmax = 180
    domain_ymin = -90
    domain_ymax = 0
    
elif ( len(domain_split) == 2 ):
    domain_xmin = -180
    domain_xmax = 180
    domain_ymin = domain_split[0]
    domain_ymax = domain_split[1]

elif ( projection == 'np' ):
    domain_xmin = -180
    domain_xmax = 180
    domain_ymin = 30
    domain_ymax = 90

elif ( projection == 'sp' ):
    domain_xmin = -180
    domain_xmax = 180
    domain_ymin = -90
    domain_ymax = -30
    
else:
    domain_xmin = 'adjust'
    domain_xmax = 'adjust'
    domain_ymin = 'adjust'
    domain_ymax = 'adjust'

# Check that the geographical domain is reasonable
if ( domain_xmin != 'adjust' ):
    if (domain_xmin >= domain_xmax) | (domain_ymin >= domain_ymax):
        sys.exit('domain problem:')

# ----------------------------------------------------------------------------
# Set the settings for vertical cross section
# ----------------------------------------------------------------------------

vertical_split = options.vertical.split(',')

if len(vertical_split) == 7:
    vertical_lon1 = vertical_split[0]
    vertical_lat1 = vertical_split[1]
    vertical_lon2 = vertical_split[2]
    vertical_lat2 = vertical_split[3]
    vertical_lev1 = vertical_split[4]
    vertical_lev2 = vertical_split[5]
    vertical_type = vertical_split[6]

if len(vertical_split) == 6:
    vertical_lon1 = vertical_split[0]
    vertical_lat1 = vertical_split[1]
    vertical_lon2 = vertical_split[2]
    vertical_lat2 = vertical_split[3]
    vertical_lev1 = vertical_split[4]
    vertical_lev2 = vertical_split[5]
    vertical_type = 'linear'

if len(vertical_split) == 4:
    vertical_lon1 = vertical_split[0]
    vertical_lat1 = vertical_split[1]
    vertical_lon2 = vertical_split[2]
    vertical_lat2 = vertical_split[3]
    vertical_lev1 = 1030
    vertical_lev2 = 100
    vertical_type = 'linear'

elif ( len(vertical_split) == 1 ) & (options.vertical == 'zurich.ns' ):
    vertical_lon1 = 8.538
    vertical_lat1 = 47.3690 - 7.5
    vertical_lon2 = 8.538
    vertical_lat2 = 47.3690 + 7.5
    vertical_lev1 = 1030
    vertical_lev2 = 100
    vertical_type = 'linear'

# ----------------------------------------------------------------------------
# Set the profile settings
# ----------------------------------------------------------------------------

profile_split = options.profile.split(',')

if len(profile_split) == 4:
    profile_lon  = profile_split[0]
    profile_lat  = profile_split[1]
    profile_lev1 = profile_split[2]
    profile_lev2 = profile_split[3]

elif len(profile_split) == 2:
    profile_lon  = profile_split[0]
    profile_lat  = profile_split[1]
    profile_lev1 = 1030
    profile_lev2 = 100

# ----------------------------------------------------------------------------
# Horizontal cross section 
# ----------------------------------------------------------------------------

if ( mode == 'horizontal' ):

    os.system('python ' + SCRIPT_PATH + '/ext_scripts/horizontal.py ' + 
        ' '.join([inpfile_filename, 
                  inpfile_folder, 
                  field_fieldname, 
                  str(field_level),
                  str(domain_xmin),str(domain_xmax),str(domain_ymin),str(domain_ymax), 
                  str(options.npixel), 
                  wsname, 
                  figpath,figname, 
                  str(color_cmin), str(color_ncol), str(color_cmax), color_name, 
                  field_unit,projection,color_mode]))



# ----------------------------------------------------------------------------
# Vertical cross section 
# ----------------------------------------------------------------------------

if ( mode == 'vertical' ) :

    os.system('python ' + SCRIPT_PATH + '/ext_scripts/vertical.py ' +
          ' '.join([inpfile_filename, 
                    inpfile_folder, 
                    field_fieldname,
                    str(vertical_lon1), str(vertical_lon2), 
                    str(vertical_lat1), str(vertical_lat2), 
                    str(vertical_lev1), str(vertical_lev2),
                    vertical_type, 
                    str(options.npixel), 
                    wsname, 
                    figpath, figname,
                    str(color_cmin), str(color_ncol), str(color_cmax), 
                    color_name,color_mode ]))

# ----------------------------------------------------------------------------
# Skew-T/log-P (skewtlogp)
# ----------------------------------------------------------------------------

if ( mode == 'profile' ):

    os.system('python ' + SCRIPT_PATH + '/ext_scripts/skewtlogp.py ' +
          ' '.join([inpfile_filename,inpfile_folder,
          str(profile_lon), str(profile_lat), str(profile_lev1), str(profile_lev2),
          str(options.npixel), wsname, figpath, figname ]))


# ----------------------------------------------------------------------------
# Show the figure if requested
# ----------------------------------------------------------------------------

if options.show:
    cmd = 'xv ' + figpath + '/' + figname + '.png'
    subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)

if options.showremove:
    cmd = 'xv ' + figpath + '/' + figname + '.png; rm ' + figpath + '/' + figname + '.png'
    subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)

if options.labelbar | ( mode == 'colorbar' ):

    figname = 'quickview.color'
    os.system('python ' + SCRIPT_PATH + '/ext_scripts/colorbar.py ' +
          ' '.join([str(options.npixel), wsname, figpath, figname])) 

    if options.showremove:
        cmd = 'xv ' + figpath + '/quickview.color.png;' + 'rm ' + figpath + '/quickview.color.png'
        subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
    else:
        cmd = 'xv ' + figpath + '/quickview.color.png;'
        subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
