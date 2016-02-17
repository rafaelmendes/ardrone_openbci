# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "plot_linear: 1 messages, 1 services")

set(MSG_I_FLAGS "-Iplot_linear:/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg;-Istd_msgs:/opt/ros/indigo/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(genlisp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(plot_linear_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv" NAME_WE)
add_custom_target(_plot_linear_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "plot_linear" "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv" ""
)

get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg" NAME_WE)
add_custom_target(_plot_linear_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "plot_linear" "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg" ""
)

#
#  langs = gencpp;genlisp;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(plot_linear
  "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/plot_linear
)

### Generating Services
_generate_srv_cpp(plot_linear
  "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/plot_linear
)

### Generating Module File
_generate_module_cpp(plot_linear
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/plot_linear
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(plot_linear_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(plot_linear_generate_messages plot_linear_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv" NAME_WE)
add_dependencies(plot_linear_generate_messages_cpp _plot_linear_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg" NAME_WE)
add_dependencies(plot_linear_generate_messages_cpp _plot_linear_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(plot_linear_gencpp)
add_dependencies(plot_linear_gencpp plot_linear_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS plot_linear_generate_messages_cpp)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(plot_linear
  "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/plot_linear
)

### Generating Services
_generate_srv_lisp(plot_linear
  "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/plot_linear
)

### Generating Module File
_generate_module_lisp(plot_linear
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/plot_linear
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(plot_linear_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(plot_linear_generate_messages plot_linear_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv" NAME_WE)
add_dependencies(plot_linear_generate_messages_lisp _plot_linear_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg" NAME_WE)
add_dependencies(plot_linear_generate_messages_lisp _plot_linear_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(plot_linear_genlisp)
add_dependencies(plot_linear_genlisp plot_linear_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS plot_linear_generate_messages_lisp)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(plot_linear
  "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/plot_linear
)

### Generating Services
_generate_srv_py(plot_linear
  "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/plot_linear
)

### Generating Module File
_generate_module_py(plot_linear
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/plot_linear
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(plot_linear_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(plot_linear_generate_messages plot_linear_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/srv/AddTwoInts.srv" NAME_WE)
add_dependencies(plot_linear_generate_messages_py _plot_linear_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/files/Documents/bci_openbci_master/ros/tutorials/catkin_ws/src/plot_linear/msg/Num.msg" NAME_WE)
add_dependencies(plot_linear_generate_messages_py _plot_linear_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(plot_linear_genpy)
add_dependencies(plot_linear_genpy plot_linear_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS plot_linear_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/plot_linear)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/plot_linear
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(plot_linear_generate_messages_cpp std_msgs_generate_messages_cpp)

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/plot_linear)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/plot_linear
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
add_dependencies(plot_linear_generate_messages_lisp std_msgs_generate_messages_lisp)

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/plot_linear)
  install(CODE "execute_process(COMMAND \"/usr/bin/python\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/plot_linear\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/plot_linear
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
add_dependencies(plot_linear_generate_messages_py std_msgs_generate_messages_py)
