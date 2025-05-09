if(ENABLE_LLVM_SHARED)
set(llvm_libs "LLVM")
else()
set(llvm_raw_libs bitwriter bpfcodegen debuginfodwarf irreader linker
  mcjit objcarcopts option passes lto bpfasmparser bpfdisassembler)
if(ENABLE_LLVM_NATIVECODEGEN)
set(llvm_raw_libs ${llvm_raw_libs} nativecodegen)
endif()
list(FIND LLVM_AVAILABLE_LIBS "LLVMCoverage" _llvm_coverage)
if (${_llvm_coverage} GREATER -1)
  list(APPEND llvm_raw_libs coverage)
endif()
list(FIND LLVM_AVAILABLE_LIBS "LLVMCoroutines" _llvm_coroutines)
if (${_llvm_coroutines} GREATER -1)
  list(APPEND llvm_raw_libs coroutines)
endif()
list(FIND LLVM_AVAILABLE_LIBS "LLVMFrontendOpenMP" _llvm_frontendOpenMP)
if (${_llvm_frontendOpenMP} GREATER -1)
  list(APPEND llvm_raw_libs frontendopenmp)
endif()
if (${LLVM_PACKAGE_VERSION} VERSION_EQUAL 15 OR ${LLVM_PACKAGE_VERSION} VERSION_GREATER 15)
  list(APPEND llvm_raw_libs windowsdriver)
endif()
if (${LLVM_PACKAGE_VERSION} VERSION_EQUAL 16 OR ${LLVM_PACKAGE_VERSION} VERSION_GREATER 16)
  list(APPEND llvm_raw_libs frontendhlsl)
endif()
if (${LLVM_PACKAGE_VERSION} VERSION_EQUAL 18 OR ${LLVM_PACKAGE_VERSION} VERSION_GREATER 18)
  list(APPEND llvm_raw_libs frontenddriver)
endif()

llvm_map_components_to_libnames(_llvm_libs ${llvm_raw_libs})
llvm_expand_dependencies(llvm_libs ${_llvm_libs})
endif()

if(ENABLE_LLVM_SHARED AND NOT libclang-shared STREQUAL "libclang-shared-NOTFOUND")
set(clang_libs ${libclang-shared})
else()
# order is important
set(clang_libs
  ${libclangFrontend}
  ${libclangSerialization}
  ${libclangDriver}
  ${libclangASTMatchers})

list(APPEND clang_libs
  ${libclangParse}
  ${libclangSema}
  ${libclangCodeGen}
  ${libclangAnalysis}
  ${libclangRewrite}
  ${libclangEdit}
  ${libclangAST}
  ${libclangLex})

# if (${LLVM_PACKAGE_VERSION} VERSION_EQUAL 15 OR ${LLVM_PACKAGE_VERSION} VERSION_GREATER 15)
  list(APPEND clang_libs ${libclangSupport})
# endif()

if (${LLVM_PACKAGE_VERSION} VERSION_EQUAL 18 OR ${LLVM_PACKAGE_VERSION} VERSION_GREATER 18)
  list(APPEND clang_libs ${libclangAPINotes})
endif()

list(APPEND clang_libs
  ${libclangBasic})
endif()

# prune unused llvm static library stuff when linking into the new .so
set(_exclude_flags)
foreach(_lib ${clang_libs})
  get_filename_component(_lib ${_lib} NAME)
  set(_exclude_flags "${_exclude_flags} -Wl,--exclude-libs=${_lib}")
endforeach(_lib)
set(clang_lib_exclude_flags "${_exclude_flags}")

set(_exclude_flags)
foreach(_lib ${llvm_libs})
  get_filename_component(_lib ${_lib} NAME)
  set(_exclude_flags "${_exclude_flags} -Wl,--exclude-libs=lib${_lib}.a")
endforeach(_lib)
set(llvm_lib_exclude_flags "${_exclude_flags}")
