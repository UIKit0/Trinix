/**
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

 module Architecture.Arch;

import Core;
import MemoryManager;


class Arch : IArch {
    IPaging InitialzePaging() {
        return null;
    }

    void InitializeTimer(int freqency) {
        PIT.Initialize(freqency);
    }
}

extern(C) void ArchMain(uint magic, void* info) {
	/* Initialize SSE for vararg used in Logger */
    //TODO: this is not needed now
	Port.InitializeSSE();
	Port.EnableSSE();

    Logger.Initialize();
    Log("Cau amigo!");

    Log("multiboot2");
    Multiboot.ParseHeader(magic, info);

    Log("Initialize CPU");
    CPU.Initialize();

    __gshared Arch arch;
    arch = Arch.init;

    Log("Jumping to [KernelMain]");
    KernelMain();
}
