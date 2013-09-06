module FileSystem.HelloDev;

import VFSManager.CharNode;
import VFSManager.DirectoryNode;


class HelloDev : CharNode {
	const string hello = "hello world";

	this(string name = "hello") { 
		super(name);
		length = 12;
	}

	override long Read(ulong offset, byte[] data) {
		foreach (long i, ref x; data)
			x = hello[offset++ % 12];
			
		return data.length;
	}

	override long Write(ulong offset, byte[] data) {
		return data.length;
	}
}