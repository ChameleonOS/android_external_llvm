; RUN: llc -mcpu=pwr7 -O0 -filetype=obj %s -o - | \
; RUN: llvm-readobj -r | FileCheck %s

; Test correct relocation generation for thread-local storage
; using the initial-exec model and integrated assembly.

target datalayout = "E-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v128:128:128-n32:64"
target triple = "powerpc64-unknown-linux-gnu"

@a = external thread_local global i32

define signext i32 @main() nounwind {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval
  %0 = load i32* @a, align 4
  ret i32 %0
}

; Verify generation of R_PPC64_GOT_TPREL16_DS and R_PPC64_TLS for
; accessing external variable a.
;
; CHECK: Relocations [
; CHECK:   Section (2) .rela.text {
; CHECK:     0x{{[0-9,A-F]+}} R_PPC64_GOT_TPREL16_HA    a
; CHECK:     0x{{[0-9,A-F]+}} R_PPC64_GOT_TPREL16_LO_DS a
; CHECK:     0x{{[0-9,A-F]+}} R_PPC64_TLS               a
; CHECK:   }
; CHECK: ]
