# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "sin: 1 messages, 1 services")

set(MSG_I_FLAGS "-Isin:/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg;-Istd_msgs:/opt/ros/indigo/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(genlisp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(sin_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv" NAME_WE)
add_custom_target(_sin_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "sin" "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv" ""
)

get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg" NAME_WE)
add_custom_target(_sin_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "sin" "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg" ""
)

#
#  langs = gencpp;genlisp;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(sin
  "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/sin
)

### Generating Services
_generate_srv_cpp(sin
  "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/sin
)

### Generating Module File
_generate_module_cpp(sin
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/sin
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(sin_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(sin_generate_messages sin_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv" NAME_WE)
add_dependencies(sin_generate_messages_cpp _sin_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg" NAME_WE)
add_dependencies(sin_generate_messages_cpp _sin_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(sin_gencpp)
add_dependencies(sin_gencpp sin_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS sin_generate_messages_cpp)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(sin
  "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/sin
)

### Generating Services
_generate_srv_lisp(sin
  "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/sin
)

### Generating Module File
_generate_module_lisp(sin
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/sin
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(sin_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(sin_generate_messages sin_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv" NAME_WE)
add_dependencies(sin_generate_messages_lisp _sin_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg" NAME_WE)
add_dependencies(sin_generate_messages_lisp _sin_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(sin_genlisp)
add_dependencies(sin_genlisp sin_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS sin_generate_messages_lisp)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(sin
  "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/sin
)

### Generating Services
_generate_srv_py(sin
  "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/sin
)

### Generating Module File
_generate_module_py(sin
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/sin
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(sin_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(sin_generate_messages sin_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/srv/AddTwoInts.srv" NAME_WE)
add_dependencies(sin_generate_messages_py _sin_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/arquivos/Documents/codes/bci_openbci_master/ros/sin_filter/catkin_ws/src/sin/msg/Num.msg" NAME_WE)
add_dependencies(sin_generate_messages_py _sin_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(sin_genpy)
add_dependencies(sin_genpy sin_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS sin_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/sin)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/sin
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(sin_generate_messages_cpp std_msgs_generate_messages_cpp)

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/sin)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/sin
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
add_dependencies(sin_generate_messages_lisp std_msgs_generate_messages_lisp)

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/sin)
  install(CODE "execute_process(COMMAND \"/usr/bin/python\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/sin\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/sin
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
add_dependencies(sin_generate_messages_py std_msgs_generate_messages_py)
