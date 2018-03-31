cmake_minimum_required(VERSION 2.8.11)
set(CMAKE_CXX_STANDARD 14)
set(QT_MIN_VERSION "5.8.0")
set(GLOOX_MIN_VERSION "1.0.19")

project(kaidan)

set(APPLICATION_ID "im.kaidan.kaidan")

# CMake options
option(I18N "Enable i18n support" FALSE)
option(SAILFISH_OS "Build with Sailfish OS GUI, needs 3rdparty/kaidansf submodule" FALSE)
option(UBUNTU_TOUCH "Building a Ubuntu Touch click (internal use only!)" FALSE)
option(CLICK_ARCH "Architecture that will be used in the click's manifest")

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc, uic and rcc automatically when needed.
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# CMake modules include
include(FeatureSummary)
include(GNUInstallDirs)

#
# Dependecies
#

find_package(PkgConfig REQUIRED)

# Find packages
find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Qml Quick Sql QuickControls2)
find_package(KF5Kirigami2 REQUIRED)
find_package(Qt5Widgets)
pkg_check_modules(GLOOX REQUIRED gloox>=${GLOOX_MIN_VERSION})

set_package_properties(
	Qt5Widgets PROPERTIES DESCRIPTION "Integration with QWidget based desktop styles"
	TYPE OPTIONAL
)

include_directories("${CMAKE_PREFIX_PATH}/include")

#
# Load submodules
#

# Main kaidan sources
include("${CMAKE_SOURCE_DIR}/src/CMakeLists.txt")

# I18n support
if(I18N)
	include("${CMAKE_SOURCE_DIR}/i18n/CMakeLists.txt")
endif()

# Sailfish OS GUI
if(SAILFISH_OS)
	if(EXISTS "${CMAKE_SOURCE_DIR}/3rdparty/kaidansf/CMakeLists.txt")
		include("${CMAKE_SOURCE_DIR}/3rdparty/kaidansf/CMakeLists.txt")
	else()
		message(FATAL_ERROR "Could NOT find KaidanSF adaptions for Sailfish OS.")
	endif()
endif()


#
# Sources / Resources
#

# normal kirigami GUI, if no Sailfish OS build
if(NOT SAILFISH_OS)
	set(KAIDAN_QML_QRC kaidan_qml.qrc)
endif()

add_executable(${PROJECT_NAME}
	${KAIDAN_SOURCES}
	${KAIDAN_QML_QRC}
	${I18N_QRC_CPP}     # only set if enabled
	${KAIDANSF_SOURCES} #
)

#
# Global C++ variables
#

if(SAILFISH_OS)
	add_definitions(-DSAILFISH_OS)
elseif(UBUNTU_TOUCH)
	add_definitions(-DUBUNTU_TOUCH)
else()
	# on others than sailfish os and ubuntu touch, enable libnotify notifications
	add_definitions(-DNOTIFICATIONS_LIBNOTIFY)
endif()

if(Qt5Widgets_FOUND)
	set(HAVE_QWIDGETS 1)
	add_definitions(-DHAVE_QWIDGETS)
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE
	DEBUG_SOURCE_PATH="${CMAKE_SOURCE_DIR}"
	${KAIDAN_COMPILE_DEFINITIONS}
)


#
# Linker flags
#

target_link_libraries(${PROJECT_NAME}
	Qt5::Core
	Qt5::Sql
	Qt5::Qml
	Qt5::Widgets
	${GLOOX_LIBRARIES}
)


#
# Install Kaidan
#

if(UBUNTU_TOUCH AND CLICK_ARCH)
	# will replace ${CLICK_ARCH} with its value
	configure_file(${CMAKE_SOURCE_DIR}/misc/ubuntu-touch/manifest.json.in
	               ${CMAKE_SOURCE_DIR}/misc/ubuntu-touch/manifest.json)

	# install kaidan binary
	install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}
	        DESTINATION ${CMAKE_INSTALL_PREFIX}
	)
	# install kaidan media
	install(DIRECTORY "data/images"
	        DESTINATION "${CMAKE_INSTALL_FULL_DATADIR}/${APPLICATION_ID}"
	)
	# install icon
	install(FILES "misc/kaidan.svg" "misc/ubuntu-touch/apparmor.json"
	              "misc/ubuntu-touch/kaidan.desktop" "misc/ubuntu-touch/manifest.json"
	        DESTINATION "${CMAKE_INSTALL_PREFIX}"
	)
elseif(UNIX AND NOT APPLE)
	# install kaidan binary
	install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}
	        DESTINATION ${CMAKE_INSTALL_FULL_BINDIR}
	)

	# install kaidan media
	install(DIRECTORY "data/images"
	        DESTINATION "${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}"
	)

	# install icon (scalable + 128x)
	install(FILES "misc/kaidan.svg"
	        DESTINATION "${CMAKE_INSTALL_FULL_DATADIR}/icons/hicolor/scalable/apps"
	)
	install(FILES "misc/kaidan-128x128.png"
	        DESTINATION "${CMAKE_INSTALL_FULL_DATADIR}/icons/hicolor/128x128/apps"
	        RENAME "kaidan.png"
	)
	# install desktop file
	install(FILES "misc/kaidan.desktop"
	        DESTINATION "${CMAKE_INSTALL_FULL_DATADIR}/applications"
	)
endif()


feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
