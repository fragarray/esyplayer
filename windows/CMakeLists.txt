# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(esyplayer LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "esyplayer")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)

# The media_kit Windows package bundles mpv 0.36, which cannot adjust the
# secondary subtitle delay independently. Use a pinned x86-64 libmpv build.
set(ESY_LIBMPV_ARCHIVE "mpv-dev-x86_64-20261111-git-bcde6b93cc.7z")
set(ESY_LIBMPV_URL "https://github.com/shinchiro/mpv-winbuild-cmake/releases/download/20261111/${ESY_LIBMPV_ARCHIVE}")
set(ESY_LIBMPV_SHA256 "273c079b11ea5575822f972756f4c9a71149a5c10130353abeb8586738938452")
set(ESY_LIBMPV_DLL_SHA256 "88504ee5560942a955405e99dfb5971368e4cf851321f36565bf2a667271db1b")
set(ESY_LIBMPV_DIR "${CMAKE_BINARY_DIR}/esyplayer-libmpv-bcde6b93cc")
set(ESY_LIBMPV_FILE "${ESY_LIBMPV_DIR}/libmpv-2.dll")
set(ESY_LIBMPV_DOWNLOAD "${CMAKE_BINARY_DIR}/${ESY_LIBMPV_ARCHIVE}")

if(NOT EXISTS "${ESY_LIBMPV_FILE}")
  file(DOWNLOAD "${ESY_LIBMPV_URL}" "${ESY_LIBMPV_DOWNLOAD}"
    EXPECTED_HASH "SHA256=${ESY_LIBMPV_SHA256}"
    TLS_VERIFY ON
    STATUS ESY_LIBMPV_DOWNLOAD_STATUS)
  list(GET ESY_LIBMPV_DOWNLOAD_STATUS 0 ESY_LIBMPV_DOWNLOAD_CODE)
  if(NOT ESY_LIBMPV_DOWNLOAD_CODE EQUAL 0)
    message(FATAL_ERROR "Could not download libmpv: ${ESY_LIBMPV_DOWNLOAD_STATUS}")
  endif()
  file(MAKE_DIRECTORY "${ESY_LIBMPV_DIR}")
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar xf "${ESY_LIBMPV_DOWNLOAD}" libmpv-2.dll
    WORKING_DIRECTORY "${ESY_LIBMPV_DIR}"
    RESULT_VARIABLE ESY_LIBMPV_EXTRACT_RESULT)
  if(NOT ESY_LIBMPV_EXTRACT_RESULT EQUAL 0 OR NOT EXISTS "${ESY_LIBMPV_FILE}")
    message(FATAL_ERROR "Could not extract libmpv from ${ESY_LIBMPV_ARCHIVE}")
  endif()
endif()

file(SHA256 "${ESY_LIBMPV_FILE}" ESY_LIBMPV_ACTUAL_SHA256)
if(NOT ESY_LIBMPV_ACTUAL_SHA256 STREQUAL ESY_LIBMPV_DLL_SHA256)
  message(FATAL_ERROR "Unexpected libmpv DLL checksum: ${ESY_LIBMPV_ACTUAL_SHA256}")
endif()

set(ESY_LIBMPV_REPLACED FALSE)
foreach(LIBRARY IN LISTS PLUGIN_BUNDLED_LIBRARIES)
  get_filename_component(LIBRARY_NAME "${LIBRARY}" NAME)
  if(LIBRARY_NAME STREQUAL "libmpv-2.dll")
    list(REMOVE_ITEM PLUGIN_BUNDLED_LIBRARIES "${LIBRARY}")
    set(ESY_LIBMPV_REPLACED TRUE)
  endif()
endforeach()
if(NOT ESY_LIBMPV_REPLACED)
  message(FATAL_ERROR "media_kit did not provide the expected libmpv DLL")
endif()
list(APPEND PLUGIN_BUNDLED_LIBRARIES "${ESY_LIBMPV_FILE}")

# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)
