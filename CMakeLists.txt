cmake_minimum_required(VERSION 3.15)
project(demo C)

find_package(libusb REQUIRED)

#target_include_directories(demo ${libusb_INCLUDE_DIR})
add_executable(demo main.c)
#target_include_directories(demo PRIVATE ${libusb_INCLUDE_DIR})
target_link_libraries(demo ${libusb_LIBRARIES})