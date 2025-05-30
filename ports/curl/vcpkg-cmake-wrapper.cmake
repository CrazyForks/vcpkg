list(REMOVE_ITEM ARGS "NO_MODULE" "CONFIG" "MODULE")
_find_package(${ARGS} CONFIG)

if(CURL_FOUND)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0012 NEW)
    cmake_policy(SET CMP0054 NEW)
    cmake_policy(SET CMP0057 NEW)

    include("${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake")

    set(_curl_target CURL::libcurl_shared)
    if(TARGET CURL::libcurl_static)
        set(_curl_target CURL::libcurl_static)
    endif()
    get_target_property(_curl_include_dirs ${_curl_target} INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(_curl_link_libraries ${_curl_target} INTERFACE_LINK_LIBRARIES)
    if(NOT _curl_link_libraries)
        set(_curl_link_libraries "")
    endif()
    if(_curl_link_libraries MATCHES "ZLIB::ZLIB")
        string(REGEX REPLACE "([\$]<[^;]*)?ZLIB::ZLIB([^;]*>)?" "${ZLIB_LIBRARIES}" _curl_link_libraries "${_curl_link_libraries}")
    endif()
    if(_curl_link_libraries MATCHES "OpenSSL::")
        string(REGEX REPLACE "([\$]<[^;]*)?OpenSSL::(SSL|Crypto)([^;]*>)?" "${OPENSSL_LIBRARIES}" _curl_link_libraries "${_curl_link_libraries}")
    endif()
    if(_curl_link_libraries MATCHES "::")
        message(WARNING "CURL_LIBRARIES list at least one target. This will not work for use cases where targets are not resolved.")
    endif()

    if(WIN32)
        get_target_property(_curl_location_debug ${_curl_target} IMPORTED_IMPLIB_DEBUG)
        get_target_property(_curl_location_release ${_curl_target} IMPORTED_IMPLIB_RELEASE)
    endif()

    if(NOT _curl_location_debug AND NOT _curl_location_release)
        get_target_property(_curl_location_debug ${_curl_target} IMPORTED_LOCATION_DEBUG)
        get_target_property(_curl_location_release ${_curl_target} IMPORTED_LOCATION_RELEASE)
    endif()

    set(CURL_INCLUDE_DIRS "${_curl_include_dirs}")
    set(CURL_LIBRARY_DEBUG "${_curl_location_debug}" CACHE INTERNAL "vcpkg")
    set(CURL_LIBRARY_RELEASE "${_curl_location_release}" CACHE INTERNAL "vcpkg")
    select_library_configurations(CURL)
    set(CURL_LIBRARIES ${CURL_LIBRARY} ${_curl_link_libraries})
    set(CURL_VERSION_STRING "${CURL_VERSION}")

    unset(_curl_include_dirs)
    unset(_curl_link_libraries)
    unset(_curl_location_debug)
    unset(_curl_location_release)
    unset(_curl_target)
    cmake_policy(POP)
endif()
