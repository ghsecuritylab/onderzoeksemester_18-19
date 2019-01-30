cmake_minimum_required(VERSION 3.5)

#set(INCLUDE_DIRS "include")
#set(SOURCES "")
#foreach(dir ${INCLUDE_DIRS})
#	set(abs_dir ${CMAKE_BINARY_DIR}/${dir})
#	file(GLOB matches "${abs_dir}/*.c" "${abs_dir}/*.cpp" "${abs_dir}/*.h" "${abs_dir}/*.hpp" "${abs_dir}/*.asm")
#	list(APPEND SOURCES ${matches})
#endforeach()
#set(MAIN_SRCS ${matches} )



include(${IDF_PATH}/tools/cmake/project.cmake)
project(hello-world)




#add_executable(${PROJECT_NAME} hello_world_main.c ${SOURCES})