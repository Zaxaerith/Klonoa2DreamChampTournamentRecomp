cmake_minimum_required(VERSION 3.20)
project(Klonoa2DreamChampTournamentRecomp C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()

set(GBARECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/gbarecomp" CACHE PATH "Pinned gbarecomp submodule")
set(RECOMP_UI_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/recomp-ui" CACHE PATH "Pinned recomp-ui submodule")
set(GBARECOMP_RUNTIME_UI_ROOT "${RECOMP_UI_ROOT}" CACHE PATH "In-game runtime UI root")
set(GBARECOMP_GENERATED_CART_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/gen/cart" CACHE PATH "Generated cartridge C++ output")
set(GBARECOMP_GENERATED_BIOS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/gen/bios" CACHE PATH "Generated BIOS C++ output")
set(GBARECOMP_SELFHEAL_RECOMPILE_DEFAULT OFF CACHE BOOL "Interpreter fallback without runtime compiler" FORCE)
set(GBARECOMP_COMPILER_CACHE OFF CACHE STRING "Keep compilation output inside this project")

if(NOT EXISTS "${GBARECOMP_ROOT}/CMakeLists.txt")
    message(FATAL_ERROR "Missing gbarecomp submodule at ${GBARECOMP_ROOT}. Run: git submodule update --init --recursive")
endif()
if(NOT EXISTS "${RECOMP_UI_ROOT}/recomp_ui.cmake")
    message(FATAL_ERROR "Missing recomp-ui submodule at ${RECOMP_UI_ROOT}. Run: git submodule update --init --recursive")
endif()

# SDL2 discovery for MinGW / MSYS2 / sibling _sdl2 SDK
set(_gba_sdl2_candidates
    "${GBARECOMP_MINGW_PREFIX_UNIX}"
    "$ENV{SDL2_ROOT}"
    "${CMAKE_CURRENT_SOURCE_DIR}/.deps/sdl2/x86_64-w64-mingw32"
    "${CMAKE_CURRENT_SOURCE_DIR}/../_sdl2/SDL2-2.32.8/x86_64-w64-mingw32"
    "C:/msys64/mingw64"
)
file(GLOB _gba_sdl2_siblings "${CMAKE_CURRENT_SOURCE_DIR}/../_sdl2/SDL2-*/x86_64-w64-mingw32")
list(APPEND _gba_sdl2_candidates ${_gba_sdl2_siblings})
foreach(_cand IN LISTS _gba_sdl2_candidates)
    if(_cand AND EXISTS "${_cand}/include/SDL2/SDL.h")
        set(_gba_sdl2_root "${_cand}")
        break()
    endif()
endforeach()
if(_gba_sdl2_root)
    if(NOT GBARECOMP_MINGW_PREFIX_UNIX)
        set(GBARECOMP_MINGW_PREFIX_UNIX "${_gba_sdl2_root}" CACHE PATH "SDL2 SDK root" FORCE)
    endif()
    if(NOT SDL2_INCLUDE_DIR)
        set(SDL2_INCLUDE_DIR "${_gba_sdl2_root}/include/SDL2")
    endif()
    if(NOT SDL2_LIBRARY)
        set(SDL2_LIBRARY "${_gba_sdl2_root}/lib/libSDL2.dll.a")
    endif()
    if(NOT SDL2_DLL AND EXISTS "${_gba_sdl2_root}/bin/SDL2.dll")
        set(SDL2_DLL "${_gba_sdl2_root}/bin/SDL2.dll" CACHE FILEPATH "SDL2 runtime DLL")
    endif()
endif()

if(NOT GBARECOMP_MINGW_RUNTIME_BIN AND MINGW)
    get_filename_component(_gba_mingw_bin "${CMAKE_CXX_COMPILER}" DIRECTORY)
    set(GBARECOMP_MINGW_RUNTIME_BIN "${_gba_mingw_bin}" CACHE PATH "Directory holding MinGW runtime DLLs")
endif()

add_subdirectory("${GBARECOMP_ROOT}" framework EXCLUDE_FROM_ALL)

get_target_property(RUNTIME_DEFINES gbarecomp_runtime COMPILE_DEFINITIONS)
if(RUNTIME_DEFINES)
    list(FILTER RUNTIME_DEFINES EXCLUDE REGEX "^GBARECOMP_SRC_DIR=")
    set_property(TARGET gbarecomp_runtime PROPERTY COMPILE_DEFINITIONS ${RUNTIME_DEFINES} GBARECOMP_SRC_DIR="gbarecomp")
endif()
if(NOT "GBARECOMP_HAVE_SDL2" IN_LIST RUNTIME_DEFINES)
    message(FATAL_ERROR "SDL2 backend required")
endif()

if(EXISTS "${GBARECOMP_GENERATED_BIOS_DIR}/codegen_tail_macros.h")
    if(MSVC)
        target_compile_options(gbarecomp_runtime PRIVATE
            "/FI${GBARECOMP_GENERATED_BIOS_DIR}/codegen_tail_macros.h")
    else()
        target_compile_options(gbarecomp_runtime PRIVATE
            "-include" "${GBARECOMP_GENERATED_BIOS_DIR}/codegen_tail_macros.h")
    endif()
endif()

include("${RECOMP_UI_ROOT}/recomp_ui.cmake")
add_library(game_launcher_ui STATIC src/game_launcher_boot.cpp)
target_include_directories(game_launcher_ui PRIVATE
    "${GBARECOMP_ROOT}/src/runtime"
    "${GBARECOMP_ROOT}/src/gba"
    ${SDL2_INCLUDE_DIR}
)
recomp_target_launcher_ui(game_launcher_ui CONSOLE gba)
target_link_libraries(game_launcher_ui PUBLIC ${SDL2_LIBRARY})

if(EXISTS "${GBARECOMP_GENERATED_CART_DIR}/dispatch_table.cpp")
    file(GLOB CART_SOURCES CONFIGURE_DEPENDS "${GBARECOMP_GENERATED_CART_DIR}/*.cpp")
    add_executable(Klonoa2DreamChampTournamentRecomp WIN32
        src/main.cpp
        ${CART_SOURCES}
    )
    set_target_properties(Klonoa2DreamChampTournamentRecomp PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
    target_include_directories(Klonoa2DreamChampTournamentRecomp PRIVATE
        "${GBARECOMP_ROOT}/src/runtime"
        "${GBARECOMP_ROOT}/src/armv4t"
        "${GBARECOMP_GENERATED_CART_DIR}"
    )
    target_link_gbarecomp_runtime_stack(Klonoa2DreamChampTournamentRecomp game_launcher_ui)
    target_link_libraries(Klonoa2DreamChampTournamentRecomp PRIVATE game_launcher_ui)

    if(MINGW)
        target_link_options(Klonoa2DreamChampTournamentRecomp PRIVATE "-Wl,--stack,67108864")
    endif()

    set(SHARDS ${CART_SOURCES})
    list(FILTER SHARDS INCLUDE REGEX "/recompiled_[0-9]+\\.cpp$")
    if(SHARDS)
        if(MSVC)
            set_source_files_properties(${SHARDS} PROPERTIES COMPILE_OPTIONS "/O2")
        else()
            set_source_files_properties(${SHARDS} PROPERTIES COMPILE_OPTIONS "-O2;-g0")
        endif()
    endif()

    recomp_stage_launcher_assets(Klonoa2DreamChampTournamentRecomp CONSOLE gba)
    add_custom_command(TARGET Klonoa2DreamChampTournamentRecomp POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/recomp/player.toml"
        "$<TARGET_FILE_DIR:Klonoa2DreamChampTournamentRecomp>/player.toml"
        VERBATIM)
    if(COMMAND gbarecomp_stage_mingw_runtime)
        gbarecomp_stage_mingw_runtime(Klonoa2DreamChampTournamentRecomp)
    endif()
    if(SDL2_DLL)
        add_custom_command(TARGET Klonoa2DreamChampTournamentRecomp POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${SDL2_DLL}"
            "$<TARGET_FILE_DIR:Klonoa2DreamChampTournamentRecomp>/SDL2.dll"
            VERBATIM)
    endif()
endif()
