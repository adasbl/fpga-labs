#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SystemC::systemc" for configuration "Debug"
set_property(TARGET SystemC::systemc APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(SystemC::systemc PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/systemc.lib"
  )

list(APPEND _cmake_import_check_targets SystemC::systemc )
list(APPEND _cmake_import_check_files_for_SystemC::systemc "${_IMPORT_PREFIX}/lib/systemc.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
