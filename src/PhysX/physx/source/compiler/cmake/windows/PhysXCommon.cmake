##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##  * Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
##  * Neither the name of NVIDIA CORPORATION nor the names of its
##    contributors may be used to endorse or promote products derived
##    from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
## EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
## CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
## EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
## PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
## OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## Copyright (c) 2018 NVIDIA Corporation. All rights reserved.

#
# Build PhysXCommon
#

SET(PHYSXCOMMON_WINDOWS_HEADERS
	${PHYSX_SOURCE_DIR}/common/include/windows/CmWindowsLoadLibrary.h
	${PHYSX_SOURCE_DIR}/common/include/windows/CmWindowsModuleUpdateLoader.h
)
SOURCE_GROUP(common\\include\\windows FILES ${PHYSXCOMMON_WINDOWS_HEADERS})

SET(PHYSXCOMMON_WINDOWS_SOURCE
	${COMMON_SRC_DIR}/windows/CmWindowsModuleUpdateLoader.cpp
	${COMMON_SRC_DIR}/windows/CmWindowsDelayLoadHook.cpp
)
SOURCE_GROUP(common\\src\\windows FILES ${PHYSXCOMMON_WINDOWS_SOURCE})

SET(PHYSXCOMMON_RESOURCE
	${PHYSX_SOURCE_DIR}/compiler/resource_${RESOURCE_LIBPATH_SUFFIX}/PhysXCommon.rc)
SOURCE_GROUP(resource FILES ${PHYSXCOMMON_RESOURCE})

SET(PXCOMMON_PLATFORM_SRC_FILES 
	${PHYSXCOMMON_WINDOWS_HEADERS}
	${PHYSXCOMMON_WINDOWS_SOURCE}
	
	${PHYSXCOMMON_RESOURCE}
)

SET(PXCOMMON_PLATFORM_INCLUDES
	${PHYSX_SOURCE_DIR}/common/src/windows
)

IF(NOT PX_GENERATE_STATIC_LIBRARIES)
	SET(PXCOMMON_LIBTYPE_DEFS
		PX_FOUNDATION_DLL=1;PX_PHYSX_COMMON_EXPORTS;
	)
ENDIF()

SET(PXCOMMON_COMPILE_DEFS
	# Common to all configurations
	${PHYSX_WINDOWS_COMPILE_DEFS};${PXCOMMON_LIBTYPE_DEFS};${PHYSX_LIBTYPE_DEFS};${PHYSXGPU_LIBTYPE_DEFS}

	# Switch platforms here?
	$<$<CONFIG:debug>:${PHYSX_WINDOWS_DEBUG_COMPILE_DEFS};>
	$<$<CONFIG:checked>:${PHYSX_WINDOWS_CHECKED_COMPILE_DEFS};>
	$<$<CONFIG:profile>:${PHYSX_WINDOWS_PROFILE_COMPILE_DEFS};>
	$<$<CONFIG:release>:${PHYSX_WINDOWS_RELEASE_COMPILE_DEFS}>
)

SET(PXCOMMON_PLATFORM_LINK_FLAGS "/MAP")

IF(PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSXCOMMON_LIBTYPE STATIC)
ELSE()
	SET(PHYSXCOMMON_LIBTYPE SHARED)
ENDIF()

IF(NV_USE_GAMEWORKS_OUTPUT_DIRS AND PHYSXCOMMON_LIBTYPE STREQUAL "STATIC")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_DEBUG "PhysXCommon_static${CMAKE_DEBUG_POSTFIX}")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_CHECKED "PhysXCommon_static${CMAKE_CHECKED_POSTFIX}")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_PROFILE "PhysXCommon_static${CMAKE_PROFILE_POSTFIX}")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_RELEASE "PhysXCommon_static${CMAKE_RELEASE_POSTFIX}")
ELSE()
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_DEBUG "PhysXCommon${CMAKE_DEBUG_POSTFIX}")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_CHECKED "PhysXCommon${CMAKE_CHECKED_POSTFIX}")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_PROFILE "PhysXCommon${CMAKE_PROFILE_POSTFIX}")
	SET(PHYSXCOMMON_COMPILE_PDB_NAME_RELEASE "PhysXCommon${CMAKE_RELEASE_POSTFIX}")
ENDIF()

IF(PHYSXCOMMON_LIBTYPE STREQUAL "SHARED")
	INSTALL(FILES $<TARGET_PDB_FILE:PhysXCommon> 
		DESTINATION $<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile> OPTIONAL)
		
	SET(PXCOMMON_PLATFORM_LINK_FLAGS_DEBUG "/DELAYLOAD:PhysXFoundation${CMAKE_DEBUG_POSTFIX}.dll")
	SET(PXCOMMON_PLATFORM_LINK_FLAGS_CHECKED "/DELAYLOAD:PhysXFoundation${CMAKE_CHECKED_POSTFIX}.dll")
	SET(PXCOMMON_PLATFORM_LINK_FLAGS_PROFILE "/DELAYLOAD:PhysXFoundation${CMAKE_PROFILE_POSTFIX}.dll")
	SET(PXCOMMON_PLATFORM_LINK_FLAGS_RELEASE "/DELAYLOAD:PhysXFoundation${CMAKE_RELEASE_POSTFIX}.dll")
ELSE()
	INSTALL(FILES ${PHYSX_ROOT_DIR}/$<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile>/$<$<CONFIG:debug>:${PHYSXCOMMON_COMPILE_PDB_NAME_DEBUG}>$<$<CONFIG:checked>:${PHYSXCOMMON_COMPILE_PDB_NAME_CHECKED}>$<$<CONFIG:profile>:${PHYSXCOMMON_COMPILE_PDB_NAME_PROFILE}>$<$<CONFIG:release>:${PHYSXCOMMON_COMPILE_PDB_NAME_RELEASE}>.pdb
		DESTINATION $<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile> OPTIONAL)	
ENDIF()