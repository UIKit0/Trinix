﻿/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Architectures.x86_64.Core.SyscallHandler;

import Architecture;
import MemoryManager;


struct SyscallStack {
align(1):
    ulong R15, R14, R13, R12, R11, R10, R9, R8;
    ulong RBP, RDI, RSI, RDX;
    private ulong _RCX;
    ulong RBX, RAX;
}


abstract final class SyscallHandler {
    private enum Registers : ulong {
        IA32_STAR    = 0xC000_0081,
        IA32_LSTAR   = 0xC000_0082,
        IA32_CSTAR   = 0xC000_0083,
        IA32_FMASK   = 0xC000_0084,
        IA32_FS_BASE = 0xC000_0100,
        IA32_GS_BASE = 0xC000_0101,

        STAR         = 0x0013_0008_0000_0000
    }

    static void Initialize() {
        Port.WriteMSR(Registers.IA32_LSTAR, cast(ulong)&SyscallCommon);
        Port.WriteMSR(Registers.IA32_STAR, Registers.STAR);
        Port.WriteMSR(Registers.IA32_FMASK, 0x200);
    }

    static void SyscallDispatcher(SyscallStack* stack) {
        Thread.Current.SavedState.SSESyscall.Save();
        VirtualMemory.KernelPaging.Install();

        with (stack)
            RAX = ResourceManager.CallResource(R9, R8, RDI, RSI, RDX, RBX, RAX);

        Process.Current.PageTable.Install();
        Thread.Current.SavedState.SSESyscall.Load();
    }

    extern(C) private static void SyscallCommon() {
        asm {
            naked;
            swapgs;
            mov [GS:0], RSP;
            mov RSP, [GS:8];
            swapgs;
            sti;
            
            // Save context
            push RAX;
            push RBX;
            push RCX;
            push RDX;
            push RSI;
            push RDI;
            push RBP;
            push R8;
            push R9;
            push R10;
            push R11;
            push R12;
            push R13;
            push R14;
            push R15;
            
            // Run dispatcher
            mov RDI, RSP;
            call SyscallDispatcher;
            
            // Restore context
            pop R15;
            pop R14;
            pop R13;
            pop R12;
            pop R11;
            pop R10;
            pop R9;
            pop R8;
            pop RBP;
            pop RDI;
            pop RSI;
            pop RDX;
            pop RCX;
            pop RBX;
            pop RAX;
            
            cli;
            swapgs;
            mov RSP, [GS:0];
            swapgs;
            sysretq;
        }
    }
}