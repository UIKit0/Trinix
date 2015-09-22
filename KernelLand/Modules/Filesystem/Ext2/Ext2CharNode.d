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

module Modules.Filesystem.Ext2.Ext2CharNode;

import VFSManager;
import Modules.Filesystem.Ext2;


final class Ext2CharNode : CharNode {
    private int m_inode;
    private bool m_loadedAttribs;


    @property package auto Inode() {
        Ext2Filesystem.Inode ret;

        if (m_parent !is null && m_parent.FileSystem !is null)
            (cast(Ext2Filesystem)m_parent.FileSystem).ReadInode(ret, m_inode);

        return ret;
    }

    @property package void Inode(Ext2Filesystem.Inode node) {
        if (m_parent !is null && m_parent.FileSystem !is null)
            (cast(Ext2Filesystem)m_parent.FileSystem).WriteInode(node, m_inode);
    }
    
    this(int inode, DirectoryNode parent, FileAttributes attributes) {
        m_inode = inode;
        super(parent, attributes);
    }
    
    @property override FileAttributes Attributes() {
        if (!m_loadedAttribs && m_parent !is null && m_parent.FileSystem !is null) {
            auto attribs = (cast(Ext2Filesystem)m_parent.FileSystem).GetAttributes(Inode);
            attribs.Name = m_attributes.Name;
            attribs.Type = m_attributes.Type;

            m_attributes    = attribs;
            m_loadedAttribs = true;
        }
        
        return m_attributes;
    }
    
    @property override void Attributes(FileAttributes value) {
        m_attributes = value; //TODO
    }
    
    override ulong Read(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(Ext2Filesystem)m_parent.FileSystem).Read(Inode, offset, data);
    }
    
    override ulong Write(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(Ext2Filesystem)m_parent.FileSystem).Write(Inode, offset, data);
    }
}