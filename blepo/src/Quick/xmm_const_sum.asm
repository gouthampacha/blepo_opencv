; Copyright (c) 2004 Clemson University.
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or (at
; your option) any later version.
;  
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; General Public License for more details.
;  
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
;--------------------------------------------------------------------------------------
; void xmm_const_sum(unsigned char *src, const unsigned char val, unsigned char *dst, int num_doublequadwords);
;
; Saturated sum of a one-dimensional byte array and another byte, using XMM registers
;
; Notes:  * a doublequadwords is 16 bytes
;         * num_doublequadwords must be > 0
;         * This code assumes that SSE2 commands are available
;         * It is okay if src==dst
;         * No assumption is made about the doublequadword-alignment of the pointers
;--------------------------------------------------------------------------------------
;
; @author Manish Shiralkar
; @author Stan Birchfield

bits 32                         ;for 32 bit protected mode

section .data                   ;data segment
buffer dd 0x00000000
       dd 0x00000000
       dd 0x00000000
       dd 0x00000000

section .text code              ;code starts here 
global _xmm_const_sum           ;Add unsigned bytes with saturation, ie paddusb 

_xmm_const_sum:

  push ebp                      ;save stack pointer of caller function
  mov ebp, esp                  ;copy stack pointer to ebp
                                ;ebp+0:retAddr, ebp+4:caller fn ebp, ebp+8:1st param
  push esi
  push edi
  push ebx

  mov esi, [ebp+8]              ;pointer to first input image
  mov bx, [ebp+12]              ;const value
  mov edi, [ebp+16]             ;pointer to output image
  mov ecx, [ebp+20]             ;number of loops

  xor eax, eax                  ;set eax to 00000000H (zero)
  mov edx, 16
.label1:                        ;fill the buffer with 16 copies of the const val
  mov [buffer + eax], bx
  inc eax
  dec edx
  jnz .label1

  movdqu xmm1, [buffer]         ;fetch 16 bytes buffer
  xor eax, eax                  ;set eax to 00000000H (zero) 

.loop:                          ;Code to sum the image
  movdqu xmm0, [esi+eax]        ;fetch 16 bytes of 1st img
  paddusb xmm0, xmm1            ;'ADD' const val buffer to 1st img
  movdqu [edi+eax], xmm0        ;store the 'SUM' result in output img
  add eax, 16                   ;This will get next 16 bytes in next iteration
  loop .loop

  pop ebx
  pop edi
  pop esi
  pop ebp
ret
