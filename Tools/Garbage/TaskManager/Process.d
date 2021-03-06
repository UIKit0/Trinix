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
 * 
 * TODO:
 *      o Signal handler
 *      o Syscalls: sbrk, get(id, uid, gid, resources, childs, cwd)
 */

module TaskManager.Process;

import Core;
import Library;
import VFSManager;
import TaskManager;
import Architecture;
import MemoryManager;
import ObjectManager;


final class Process : Resource {
    private enum IDENTIFIER = "com.trinix.TaskManager.Process";
    private v_addr m_userStack = 0xFFFFFFFF_80000000;

    private ulong m_id;
    private ulong m_uid;
    private ulong m_gid;
    private bool m_isKernel;

    package Paging m_paging;
    private DirectoryNode m_cwd;

    private LinkedList!Thread m_threads;
    private List!Resource m_resources; //TODO: look on this

    @property {
        static auto Current()   { return Task.m_currentThread.ParentProcess; }
        ulong ID()              { return m_id;       }
        ulong UID()             { return m_uid;      }
        ulong GID()             { return m_gid;      }
        bool IsKernel()         { return m_isKernel; }
        Paging PageTable()      { return m_paging;   }
        package auto Threads()  { return m_threads;  }
        auto WorkingDirectory() { return m_cwd;      }
    }
    
    package static Process Initialize() {
        if (Task.ThreadCount)
            return null;

        Process process    = new Process();
        process.m_paging   = VirtualMemory.KernelPaging;
        process.m_cwd      = VFS.Root;
        process.m_isKernel = true;

        /* Kernel thread */
        Thread t           = new Thread(process);
        with (t) {
            Name           = "Kernel";
            State          = ThreadState.Running;
            SetKernelStack();
        }
    
        return process;
    }

    private this() {
        CallTable[] callTable = [

        ];

        m_id        = Task.NextPID;
        m_threads   = new LinkedList!Thread();
        m_resources = new List!Resource();

        if (Thread.Current !is null) {
            m_uid       = Process.Current.m_uid;
            m_gid       = Process.Current.m_gid;
            m_isKernel  = Process.Current.m_isKernel;
            m_paging    = Process.Current.m_paging;
            m_cwd       = Process.Current.m_cwd;
        }

        Task.Processes.Add(this);
        super(DeviceType.Task, IDENTIFIER, 0x01, callTable);
    }

    this(void delegate() ProcessStart) {
        this();
        
        CopyResources();
        new Thread(this, ProcessStart);
    }

    this(void function() ProcessStart) {
        this();

        CopyResources();
        new Thread(this, ProcessStart);
    }

    this(string fileName, string[] arguments) {
        this();
        //TODO: load binary file and exec it
        //Dont copy resources
        //Copy paging from VirtualMemory.KernelPaging
    }

    ~this() {
        foreach (x; m_resources) {
            if (x.DetachProcess(this))
                delete x;
        }

        foreach (x; m_threads)
            delete x;

        delete m_paging;
        delete m_threads;
        delete m_resources;
    }

    void Start() {
        m_threads.First.Value.Start();
    }

    bool AttachResource(Resource resource) {
        if (m_resources.Contains(resource))
            return false;

        if (!resource.AttachProcess(this))
            return false;

        m_resources.Add(resource);
        return true;
    }

    bool DetachResource(Resource resource) {
        if (!m_resources.Remove(resource))
            return false;

        if (resource.DetachProcess(this))
            delete resource;

        return true;
    }

    package ulong[] AllocUserStack(ulong size = Thread.USER_STACK_SIZE) {
        for (ulong i = 0; i < size; i += Paging.PAGE_SIZE) {
            m_userStack -= Paging.PAGE_SIZE;
            m_paging.AllocFrame(m_userStack, AccessMode.DefaultUser); //TODO: Nejako nefunguje :/
        }

        return (cast(ulong *)m_userStack)[0 .. size];
    }

    private void CopyResources() {
        foreach (x; Current.m_resources) {
            if (x.AttachProcess(this))
                m_resources.Add(x);
        }
    }
}