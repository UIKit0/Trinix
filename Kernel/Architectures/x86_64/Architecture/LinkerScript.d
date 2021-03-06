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

module Architecture.LinkerScript;

import MemoryManager;


private extern(C) extern __gshared {
    ubyte __linker_kernel_start;
    ubyte __linker_kernel_end;
    ubyte __linker_symbols_start;
    ubyte __linker_symbols_end;
    ubyte __linker_modules_start;
    ubyte __linker_modules_end;
}

abstract final class LinkerScript {
    @property {
        static const(void *) KernelBase()       { return cast(void *)&__linker_kernel_start;  }
        static const(void *) KernelEnd()        { return cast(void *)&__linker_kernel_end;    }
        static const(void *) KernelSymbols()    { return cast(void *)&__linker_symbols_start; }
        static const(void *) KernelSymbolsEnd() { return cast(void *)&__linker_symbols_end;   }
        static const(void *) KernelModules()    { return cast(void *)&__linker_modules_start; }
        static const(void *) KernelModulesEnd() { return cast(void *)&__linker_modules_end;   }
    }
}
