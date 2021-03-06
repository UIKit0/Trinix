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

module Modules.FileSystem.Ext2.Ext2CharNode;

import VFSManager;
import Modules.FileSystem.Ext2;


final class Ext2CharNode : CharNode {
    private DiskNode m_node;
    private bool m_loadedAttribs;

    @property auto Node() { return m_node; }

    this(int inode, DirectoryNode parent, FileAttributes attributes) {
        m_node = DiskNode(parent, inode);
        super(parent, attributes);
    }
    
    @property override FileAttributes Attributes() {
      /*  if (!m_loadedAttribs && m_parent !is null && m_parent.FileSystem !is null) {
            auto attribs = (cast(Ext2FileSystem)m_parent.FileSystem).GetAttributes(Node.Inode);
            attribs.Name = m_attributes.Name;
            attribs.Type = m_attributes.Type;

            m_attributes    = attribs;
            m_loadedAttribs = true;
        }*/
        
        return m_attributes;
    }
    
    @property override void Attributes(FileAttributes value) {
        m_attributes = value;

        if (m_parent !is null && m_parent.FileSystem !is null)
            (cast(Ext2FileSystem)m_parent.FileSystem).SetAttributes(Node, m_attributes);
    }
    
    override ulong Read(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(Ext2FileSystem)m_parent.FileSystem).Read(Node.Node, offset, data);
    }
    
    override ulong Write(long offset, byte[] data) {
        if (m_parent is null || m_parent.FileSystem is null)
            return 0;
        
        return (cast(Ext2FileSystem)m_parent.FileSystem).Write(Node.Node, offset, data);
    }
}