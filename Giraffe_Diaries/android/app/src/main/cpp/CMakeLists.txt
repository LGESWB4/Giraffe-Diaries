cmake_minimum_required(VERSION 3.10)
project(llama)

# NDK 환경 설정
set(CMAKE_CXX_STANDARD 17)

# `llama.cpp` 폴더 추가
if(TARGET llama)
    message(STATUS "Target 'llama' already defined. Skipping add_library.")
else()
    # 라이브러리 빌드
    add_library(llama SHARED IMPORTED)
    set_target_properties(llama PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libllama.so)
endif()