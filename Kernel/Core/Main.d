module Core.Main;

import Core.Log;
import Core.DeviceManager;

import MemoryManager.Heap;
import MemoryManager.Memory;
import MemoryManager.PhysMem;
import MemoryManager.PageAllocator;

import Architectures.CPU;
import Architectures.Main;
import Architectures.Paging;
import Architectures.Multiprocessor;

import VFSManager.VFS;
import TaskManager.Task;
import SyscallManager.Res;
import SyscallManager.Syscall;

import Devices.Timer;
import Devices.Display.BGA;
import Devices.Mouse.PS2Mouse;
import Devices.Keyboard.PS2Keyboard;

/+
Pipe dead
paging - kopirovanie stranok pri vytvoreni noveho procesu
+/


extern(C) void StartSystem() {
	Log.Init();

	Log.Print("Initializing Architecture: x86_64");
	Architecture.Init();

	Log.Print("Initializing CPU");
	CPU.Init();

	Log.Print("Initializing Physical Memory & Paging");
	PhysMem.Init();

	Log.Print("Initializing kernel heap");

	//Memory.KernelHeap = new Heap();
	//Memory.KernelHeap.Create(cast(ulong)PageAllocator.AllocPage(), Heap.MIN_SIZE, 0x10000, Paging.KernelPaging);
	//PageAllocator.IsInit = true;
	Log.Result(false);

	Log.Print("Initializing Multiprocessor configuration");
	Log.Result(Multiprocessor.Init());

	Log.Print("Starting multiple cores");
	Log.Result(true);
	Multiprocessor.BootCores();

//==================== MANAGERS ====================
	Log.Print("Initializing system calls database");
	Log.Result(Res.Init());

	Log.Print("Initializing syscall handler");
	Log.Result(Syscall.Init());

	Log.Print("Initializing device manger");
	Log.Result(DeviceManager.Init());

	Log.Print("Initializing VFS manger");
	Log.Result(VFS.Init());

	Log.Print("Initializing multitasking");
	Log.Result(Task.Init());

//==================== DEVICES ====================
	Log.Print("Initializing timer ticks = 100Hz");
	new Timer(100);
	Log.Result(true);

	Log.Print("Initializing PS/2 keyboard driver");
	new PS2Keyboard();
	Log.Result(true);

	Log.Print("Initializing PS/2 mouse driver");
	//new PS2Mouse();
	Log.Result(true);

	Log.Print("Setup BGA driver 800x600");
	BGA.Init(800, 600);
	Log.Result(true);

	Log.Print("Booting complete, starting init process");
	Log.Result(false);


	Paging.KernelPaging.MapRegion(cast(PhysicalAddress)0xE0000000, cast(VirtualAddress)0xE0000000, 0xFFFFFFFF);
	uint* xx = cast(uint *)0xE0000000;

	for (int i = 0; i < 0xFFFFF; i++)
		xx[i] = 0xFFFF00;


	import FileSystem.PipeDev;
	import TaskManager.Process;

	PipeDev pajpa = new PipeDev(0x1000, "pajpa");
	DeviceManager.DevFS.AddNode(pajpa);

	import TaskManager.Signal;
	//Task.CurrentProcess.Signals[SigNum.SIGSEGV] = cast(void function())&pagefaultCallBack;

	//static import Userspace.Init;
	//static import Userspace.GUI.Terminal;
	//Process.CreateProcess(cast(void function())&Userspace.GUI.Terminal.construct, ["/System/Bin/Terminal", "--single", "--nothing"]);


	byte tmp[256];
	while (true) {
		long i = pajpa.Read(0, tmp);
		Log.Print(cast(string)tmp[0 .. i]);
	}

	while (true) {}
}

extern(C) void apEntry() {
	while (true) { }
}

extern(C) void pagefaultCallBack() {
	Log.Print("page fault");
	while (true) {}
	return;
}