#!/bin/csh

# -----------------------------------------------------------------------------
# Set some general parameters
# -----------------------------------------------------------------------------

# Usage
if ( $#argv == 0 ) then
  echo "install.sh [import|lib|core|goodies|links|all|docu|clean|tag] "
  exit 0
endif

# Set the mode
set mode = $1

# Set path to SVN repository
set svnpath=https://svn.iac.ethz.ch/pub/lagranto_era5_0.2um/

# Set paths for development and for synchronisation (operational)
set path_devel  = "${DYN_TOOLS}//lagranto_era5_0.2um/"
set path_sync   = "${DYN_TOOLS}/lagranto_era5_0.2um/"
#set path_import = "/net/bio/dyn_soft/usrlocal/lagranto.ecmwf/"

# Set Fortran compiler
setenv FORTRAN gfortran 
#setenv FORTRAN gfortran

# Set netcdf format (ive, cdo, mch) 
set ncdf = cdo 

# Init netCDF library depending on the Fortran compiler
if ( "${FORTRAN}" == "pgf90" ) then
  module load netcdf/4.2.1-pgf90
  module list

else if ( "${FORTRAN}" == "gfortran" ) then

#module load gcc/13.2.0-fasrc01
#module load openmpi/4.1.5-fasrc03
#module load hdf5/1.14.2-fasrc01
#module load netcdf-fortran/4.6.1-fasrc01
#module load netcdf-c/4.9.2-fasrc03

module load gcc/10.2.0-fasrc01
module load openmpi/4.1.0-fasrc01
module load zlib/1.2.11-fasrc01
module load szip/2.1.1-fasrc01
module load hdf5/1.10.7-fasrc01
module load netcdf-fortran/4.5.3-fasrc01
module load netcdf-c/4.8.0-fasrc01

#  module load netcdf/4.5.0-fasrc01 
#  module load netcdf-fortran/4.4.4-fasrc06
#  module load gfortran
#  module load netcdf/4.6.1

else if ( "${FORTRAN}" == "ifort" ) then
  module load intel
  module load netcdf/4.3.2-intel

else
  echo "Fortran Compiler ${FORTRAN} not supported... Exit"
  exit 1

endif

# -----------------------------------------------------------------------------
# Import Lagranto code from <lagranto.ecmwf>
# -----------------------------------------------------------------------------

#if ( ("${mode}" == "import") | ("${mode}" == "all" ) ) then
#  rsync -avz --delete ${path_import}/caltra        ${path_devel}
#  rsync -avz --delete ${path_import}/create_startf ${path_devel}
#  rsync -avz --delete ${path_import}/density       ${path_devel}
#  rsync -avz --delete ${path_import}/docu          ${path_devel}
#  rsync -avz --delete ${path_import}/figure        ${path_devel}
#  rsync -avz --delete ${path_import}/goodies       ${path_devel}
#  rsync -avz --delete ${path_import}/lib           ${path_devel}
#  rsync -avz --delete ${path_import}/lidar         ${path_devel}
#  rsync -avz --delete ${path_import}/select        ${path_devel}
#  rsync -avz --delete ${path_import}/tools         ${path_devel}
#  rsync -avz --delete ${path_import}/trace         ${path_devel}
#endif

# -----------------------------------------------------------------------------
# Create a new tag in SVN repository
# -----------------------------------------------------------------------------

if ( "${mode}" == "tag" ) then
   svn info
   if ( "${#argv}" != 2 ) then
     echo "Usage: install.csh tag id <id=tag number>"
   else
     set tagnr = $2
   endif
   svn copy ${svnpath}/trunk ${svnpath}/tags/${tagnr} -m "Release ${tagnr}"
   exit 0
endif

# -----------------------------------------------------------------------------
# Set internal parameters and detailed installation mode
# -----------------------------------------------------------------------------

# Set LAGRANTO environment variable
setenv LAGRANTO ${path_devel}

# Set netCDF paths
# setenv NETCDF_LIB `nc-config --flibs`
# setenv NETCDF_INC `nc-config --fflags`
setenv NETCDF_LIB `nf-config --flibs`
setenv NETCDF_INC `nf-config --fflags`

# Set list of core programs
# set core  = "create_startf caltra trace select density lidar"
set core  = "caltra"

# Set list of goodies
set goodies = "lsl2rdf changet extract getmima gettidiff getvars list2lsl lsl2list mergetra newtime reformat timeres trainfo difference datelist" 
#set goodies = "lsl2rdf changet extract gettidiff getvars list2lsl lsl2list mergetra newtime reformat timeres trainfo difference datelist" 

# Set list of tools
# set tools = "traj2num tracal footprint" 
set tools = "traj2num footprint" ### shw

# Set list of libraries
set libs  = "iotra ioinp inter times libcdfio libcdfplus"

# Core programs
foreach prog ( $core )
   if ( "${prog}" == "${mode}" ) then
      set core  = ${prog}
      set mode  = "core"
   endif
end

# Goodies
foreach tool ( $goodies )
   if ( "${tool}" == "${mode}" ) then
      set goodies = ${tool}
      set mode    = "goodies"
   endif
end

# Tools
foreach tool ( $tools )
   if ( "${tool}" == "${mode}" ) then
      set tools = ${tool}
      set mode  = "tools"
   endif
end

# Libraries
foreach lib ( $libs )
   if ( "${lib}" == "${mode}" ) then
      set libs  = ${lib}
      set mode  = "lib"
   endif
end

# Check that the mode is ok 
if ( "${mode}" == "all"     ) goto modeok
if ( "${mode}" == "lib"     ) goto modeok
if ( "${mode}" == "core"    ) goto modeok
if ( "${mode}" == "goodies" ) goto modeok
if ( "${mode}" == "tools"   ) goto modeok
if ( "${mode}" == "links"   ) goto modeok
if ( "${mode}" == "clean"   ) goto modeok
if ( "${mode}" == "docu"    ) goto modeok
if ( "${mode}" == "sync"    ) goto modeok
echo "Unsupported mode ${mode} ... Stop"
exit 1

modeok:

# -----------------------------------------------------------------------------
# Make clean 
# -----------------------------------------------------------------------------

if ( "${mode}" == "clean" ) then

cd ${LAGRANTO}/

foreach prog ( $core )
   \rm -f ${prog}/${prog} ${prog}/${prog}.o
end
\rm -f trace/calvar.o select/special.o

foreach tool ( $tools )
  \rm -f goodies/${tool} goodies/${tool}.o 
end
\rm -f goodies/*.mod goodies/*.o

\rm lib/*.a lib/*.o

foreach prog ( $core )
   \rm -f bin/${prog} bin/${prog}.sh  bin/${prog}.era5
end
\rm -f bin/seltra bin/seltra.sh bin/seltra.era5
foreach tool ( $tools )
  \rm -f bin/${tool} bin/${tool}.sh bin/${tool}.era5
end
\rm -f bin/lagrantohelp.sh bin/lagrantohelp.era5
\rm -f bin/startf bin/startf.sh bin/startf.era5
\rm -f bin/lagranto.sh bin/lagranto.era5

\rm ${LAGRANTO}/startf

exit 0

endif


# -----------------------------------------------------------------------------
# Install reference 
# -----------------------------------------------------------------------------

#if ( ("${mode}" == "docu") | ("${mode}" == "all" ) ) then
#
#echo "Installing documentation"
#echo "-----------------------------------------------------------------"
#echo
#
#cd ${LAGRANTO}/docu/reference/
#
#\rm -f reference.ps
#\rm -f reference2.ps
#groff -man ../man/*.0 > reference2.ps
#ps2pdf reference2.ps
#
#latex title
#dvips title
#ps2pdf title.ps
#
#gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=reference.pdf title.pdf reference2.pdf
#
#\rm -f *.aux *.log *.dvi
#\rm -f title.ps  reference2.ps
#\rm -f title.pdf reference2.pdf
#
#endif
#
#if ( "${mode}" == "docu" ) exit 0



# -----------------------------------------------------------------------------
# Install libraries 
# -----------------------------------------------------------------------------

if ( ("${mode}" == "lib") | ("${mode}" == "all" ) ) then

echo "-----------------------------------------------------------------"
echo "Installing libraries"
echo "-----------------------------------------------------------------"
echo

# Change to library directory
cd ${LAGRANTO}/lib

# Set the correct netCDF interface
echo
if ( "${ncdf}" == "ive" ) then
   echo " ioinp_ive.f -> ioinp.f"
   \cp ioinp_ive.f ioinp.f
endif
if  ( "${ncdf}" == "nc" ) then
   echo " ioinp_cdf.f -> ioinp.f"
   \cp ioinp_nc.f ioinp.f
endif
if  ( "${ncdf}" == "cdo" ) then
   echo " ioinp_cdo.f -> ioinp.f"
   \cp ioinp_cdo.f ioinp.f
endif
if  ( "${ncdf}" == "mch" ) then
   echo " ioinp_mch.f -> ioinp.f"
   \cp ioinp_mch.f ioinp.f
endif
echo

# Loop over all libraries - compile and make library
foreach lib ( $libs )

\rm -f ${lib}.a
\rm -f ${lib}.o
echo ${FORTRAN} -c -O ${lib}.f
${FORTRAN} -fallow-argument-mismatch  -c -O ${NETCDF_INC} ${lib}.f

ar r ${lib}.a ${lib}.o
\rm -f ${lib}.l ${lib}.o

ranlib ${lib}.a
if ( ! -f ${lib}.a ) then
  echo "Problem in compiling ${lib} ... Stop"
  exit 1
endif

end

endif

if ( "${mode}" == "lib" ) exit 0

# -----------------------------------------------------------------------------
# Check that libraries are ok
# -----------------------------------------------------------------------------

echo
echo "-----------------------------------------------------------------"
echo "Check that all libraries are available"
echo "-----------------------------------------------------------------"
echo

# Change to library directory
cd ${LAGRANTO}/lib

# Check whether all libraries are available
foreach lib ( $libs )

if ( ! -f ${lib}.a ) then
  echo "Library ${lib} missing... Stop"
  exit 1
else
  ls -l ${lib}.a    
endif

end

# Exit if only libraries shoudl be installed
if ( "${mode}" == "lib" ) exit 0

# -----------------------------------------------------------------------------
# Compile Lagrango core programs
# -----------------------------------------------------------------------------

if ( ("${mode}" == "all" ) | ("${mode}" == "core" ) ) then

echo
echo "-----------------------------------------------------------------"
echo "Installing Lagranto core programs"
echo "-----------------------------------------------------------------"

foreach prog ( $core )

echo
echo "----- $prog"
echo
cd ${LAGRANTO}/${prog}
\rm -f ${prog}.o 
\rm -f ${prog}
if ( "${prog}" == "trace"  ) \rm calvar.o
if ( "${prog}" == "select" ) \rm special.o
\rm -f ${prog}
make -i -k -f ${prog}.make
if ( ! -f ${prog} ) then
  echo "Problem in compiling ${prog} ... Stop"
  exit 1
endif

end

endif

if ( "${mode}" == "core" ) exit 0

# -----------------------------------------------------------------------------
# Check that all Lagranto core programs are available
# -----------------------------------------------------------------------------

echo
echo "-----------------------------------------------------------------"
echo "Check that all Lagranto core programs are available"
echo "-----------------------------------------------------------------"
echo

foreach prog ( $core )

  cd ${LAGRANTO}/${prog}
  if ( ! -f ${prog} ) then
    echo "${prog} is missing... Stop"
    exit 1
  else
    ls -l ${prog}    
  endif

end

# Exit if only core programs shoudl be installed
if ( "${mode}" == "core" ) exit 0

# -----------------------------------------------------------------------------
# Compile Lagrango goodies
# -----------------------------------------------------------------------------

if ( ("${mode}" == "all" ) | ("${mode}" == "goodies" ) ) then

echo
echo "-----------------------------------------------------------------"
echo "Installing Lagranto goodies"
echo "-----------------------------------------------------------------"

cd ${LAGRANTO}/goodies

foreach tool ( $goodies )

echo
echo "----- ${tool}"
echo
\rm -f ${tool}.o
\rm -f ${tool}
if ( -f ${tool}.make ) then
   make -f ${tool}.make
else if ( -f ${tool}.install ) then
   ./${tool}.install
endif

if ( ! -f ${tool} ) then
  echo "Problem in compiling ${tool} ... Stop"
  exit 1
endif

end

endif

if ( "${mode}" == "goodies" ) exit 0

# -----------------------------------------------------------------------------
# Check that all Lagranto goodies are available
# -----------------------------------------------------------------------------

echo
echo "-----------------------------------------------------------------"
echo "Check that all Lagranto goodies are available"
echo "-----------------------------------------------------------------"
echo

cd ${LAGRANTO}/goodies

foreach tool ( $goodies )

if ( ! -f ${tool} ) then
  echo "${tool} is missing... Stop"
  exit 1
else
  ls -l ${tool} 
endif

end

endif

# Exit if only goodies should be installed
if ( "${mode}" == "goodies" ) exit 0

# -----------------------------------------------------------------------------
# Compile Lagrango tools
# -----------------------------------------------------------------------------

if ( ("${mode}" == "all" ) | ("${mode}" == "tools" ) ) then

echo
echo "-----------------------------------------------------------------"
echo "Installing Lagranto tools"
echo "-----------------------------------------------------------------"

cd ${LAGRANTO}/tools

foreach tool ( $tools )

echo
echo "----- ${tool}"
echo
\rm -f ${tool}.o
\rm -f ${tool}
if ( -f ${tool}.make ) then
   make -f ${tool}.make
else if ( -f ${tool}.install ) then
   ./${tool}.install
endif

if ( ! -f ${tool} ) then
  echo "Problem in compiling ${tool} ... Stop"
  exit 1
endif

end

endif

#if ( "${mode}" == "tools" ) exit 0
#
# -----------------------------------------------------------------------------
# Check that all Lagranto tools are available
# -----------------------------------------------------------------------------
#
#echo
#echo "-----------------------------------------------------------------"
#echo "Check that all Lagranto tools are available"
#echo "-----------------------------------------------------------------"
#echo
#
#cd ${LAGRANTO}/tools
#
#foreach tool ( $tools )
#
#if ( ! -f ${tool} ) then
#  echo "${tool} is missing... Stop"
#  exit 1
#else
#  ls -l ${tool} 
#endif
#
#end
#
#endif
#
## Exit if only goodies should be installed
#if ( "${mode}" == "tools" ) exit 0
#
# -----------------------------------------------------------------------------
# Create links to programs
# -----------------------------------------------------------------------------

if ( ("${mode}" == "all" ) | ("${mode}" == "links" )  ) then

echo
echo "-----------------------------------------------------------------"
echo "Create links in ${LAGRANTO}/bin/"
echo "-----------------------------------------------------------------"
echo

if ( ! -d ${LAGRANTO}/bin ) mkdir ${LAGRANTO}/bin
cd ${LAGRANTO}/bin

ln -svf ${LAGRANTO}/bin/lagranto            lagranto.sh
ln -svf ${LAGRANTO}/bin/lagranto            lagranto.era5 
ln -svf ${LAGRANTO}/bin/lagrantohelp        lagrantohelp.sh
ln -svf ${LAGRANTO}/bin/lagrantohelp        lagrantohelp.era5

ln -svf ${LAGRANTO}/caltra/caltra.sh        caltra.sh
ln -svf ${LAGRANTO}/startf/create_startf.sh create_startf.sh
ln -svf ${LAGRANTO}/select/select.sh        select.sh
ln -svf ${LAGRANTO}/select/select.sh        seltra.sh
ln -svf ${LAGRANTO}/trace/trace.sh          trace.sh
ln -svf ${LAGRANTO}/density/density.sh      density.sh
ln -svf ${LAGRANTO}/startf/create_startf.sh startf.sh
ln -svf ${LAGRANTO}/lidar/lidar.sh          lidar.sh

ln -svf ${LAGRANTO}/caltra/caltra.sh        caltra.era5
ln -svf ${LAGRANTO}/startf/create_startf.sh create_startf.era5
ln -svf ${LAGRANTO}/select/select.sh        select.era5
ln -svf ${LAGRANTO}/select/select.sh        seltra.era5
ln -svf ${LAGRANTO}/trace/trace.sh          trace.era5
ln -svf ${LAGRANTO}/density/density.sh      density.era5
ln -svf ${LAGRANTO}/startf/create_startf.sh startf.era5
ln -svf ${LAGRANTO}/lidar/lidar.sh          lidar.era5

ln -svf ${LAGRANTO}/caltra/caltra.sh        caltra
ln -svf ${LAGRANTO}/startf/create_startf.sh create_startf
ln -svf ${LAGRANTO}/select/select.sh        select
ln -svf ${LAGRANTO}/select/select.sh        seltra
ln -svf ${LAGRANTO}/trace/trace.sh          trace
ln -svf ${LAGRANTO}/density/density.sh      density
ln -svf ${LAGRANTO}/startf/create_startf.sh startf
ln -svf ${LAGRANTO}/lidar/lidar.sh          lidar

foreach tool ( $goodies )
  ln -svf ${LAGRANTO}/goodies/${tool}.sh     ${tool}.sh 
  ln -svf ${LAGRANTO}/goodies/${tool}.sh     ${tool}.era5
  ln -svf ${LAGRANTO}/goodies/${tool}.sh     ${tool} 
end

foreach tool ( $tools )
  ln -svf ${LAGRANTO}/tools/${tool}.sh     ${tool}.sh 
  ln -svf ${LAGRANTO}/tools/${tool}.sh     ${tool}.era5
  ln -svf ${LAGRANTO}/tools/${tool}.sh     ${tool} 
end

# Set link for create_startf / startf
\rm -f ${LAGRANTO}/startf
ln -svf ${LAGRANTO}/create_startf ${LAGRANTO}/startf

# Set extra name for <select> to avoid conflict in BASH
ln -svf ${LAGRANTO}/select/select.sh        seltra
ln -svf ${LAGRANTO}/select/select.sh        seltra.sh
ln -svf ${LAGRANTO}/select/select.sh        seltra.era5

endif


# -----------------------------------------------------------------------------
# Synchronise ( development -> operational ) 
# -----------------------------------------------------------------------------

if ( ("${mode}" == "all" ) | ("${mode}" == "sync" )  ) then

echo
echo "-----------------------------------------------------------------"
echo "Sync ( lagranto.era5 -> lagranto )"
echo "-----------------------------------------------------------------"
echo

cd ${path_sync}/bin/

ln -svf ${path_devel}/bin/lagranto.sh            lagranto.era5
ln -svf ${path_devel}/bin/lagrantohelp.sh        lagrantohelp.era5

ln -svf ${path_devel}/caltra/caltra.sh           caltra.era5
ln -svf ${path_devel}/startf/create_startf.sh    create_startf.era5
ln -svf ${path_devel}/select/select.sh           select.era5
ln -svf ${path_devel}/trace/trace.sh             trace.era5
ln -svf ${path_devel}/density/density.sh         density.era5
ln -svf ${path_devel}/startf/create_startf.sh    startf.era5
ln -svf ${path_devel}/lidar/lidar.sh             lidar.era5
ln -svf ${path_devel}/lidar/seltra.sh            seltra.era5

foreach tool ( $goodies )
  ln -svf ${path_devel}/goodies/${tool}.sh         ${tool}.era5
end
foreach tool ( $tools )
  ln -svf ${path_devel}/tools/${tool}.sh           ${tool}.era5
end
 
# Set all permissions
chmod -R og+rx ${path_sync}/bin/

endif

# -----------------------------------------------------------------------------
# Final tasks
# -----------------------------------------------------------------------------

echo
echo "-----------------------------------------------------------------"
echo "Installation complete"
echo "-----------------------------------------------------------------"
echo
echo "Please set the environmental variable LAGRANTO"
echo
echo "    setenv LAGRANTO ${LAGRANTO}"
echo
 




