cmake_minimum_required(VERSION 3.15)
project(demo C CXX)

find_package(libusb REQUIRED)

add_executable(demo 
os_dep/linux/usb_intf.c
main.cpp)
#target_include_directories(demo PRIVATE ${libusb_INCLUDE_DIR})
target_link_libraries(demo ${libusb_LIBRARIES})
target_include_directories(demo PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>")