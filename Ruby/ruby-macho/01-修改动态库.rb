require 'macho'

#ruby-macho
macho_path_dylib = './bin/libAFNetworking.dylib'
macho_path_copy_dylib = './bin/libAFNetworking_copy.dylib'

# copy macho_path_dylib => macho_path_copy_dylib
FileUtils.cp macho_path_dylib, macho_path_copy_dylib

# 动态库 /exec 所有关于动态库的信息, 该动态库所依赖的动态库
file_dylibs = MachO::Tools.dylibs(macho_path_dylib)

file_dylibs.each do |dylib|
  puts dylib
end


copy = MachO::MachOFile.new(macho_path_copy_dylib)
origin = MachO::MachOFile.new(macho_path_dylib)
puts "查看 rpath : -- copy ----  #{copy.rpaths} ----- origin ------: #{origin.rpaths}"

# 修改 rpath
MachO::Tools.change_rpath(macho_path_copy_dylib, '@loader_path/Frameworks', '@loader_path/Frameworks/LY')
copy = MachO::MachOFile.new(macho_path_copy_dylib)
origin = MachO::MachOFile.new(macho_path_dylib)
puts "modify rpath >>>>>>: #{copy.rpaths} ----- origin ------: #{origin.rpaths}"

# 添加 rpath
MachO::Tools.add_rpath(macho_path_copy_dylib, '@loader_path/Frameworks/LY1/LY2')

copy = MachO::MachOFile.new(macho_path_copy_dylib)
origin = MachO::MachOFile.new(macho_path_dylib)
puts "add rpath >>>>>: #{copy.rpaths} ----- origin ------: #{origin.rpaths}"

# 删除 rpath
MachO::Tools.delete_rpath(macho_path_copy_dylib, '@loader_path/Frameworks/LY1/LY2')
copy = MachO::MachOFile.new(macho_path_copy_dylib)

puts "delete rpath >>>>: #{copy.rpaths} ------origin-----: #{origin.rpaths}"


# github 地址 ： https://github.com/Homebrew/ruby-macho





# dylib id
# 原理 = shell no 命令 install_name_tool  二进制 -》修改
# merge libtool 二进制 + 规则 + fat
# MachO::Tools.change_dylib_id(macho_path_copy_dylib, 'test_cat')

# copy = MachO::MachOFile.new(macho_path_copy_dylib)

# origin = MachO::MachOFile.new(macho_path_dylib)

# # hmap -》vip -》原理 -》hmap -》
# puts "copy dylib_id: #{copy.dylib_id}    ---origin---: #{origin.dylib_id}"

# MachO::Tools.change_rpath(macho_path_copy_dylib, '@loader_path/Frameworks', '@loader_path/Frameworks/cat')

# copy = MachO::MachOFile.new(macho_path_copy_dylib)

# puts "copy rpath: #{copy.rpaths}    ---origin---: #{origin.rpaths}"

# MachO::Tools.add_rpath(macho_path_copy_dylib, '@loader_path/Frameworks/cat/cat')

# copy = MachO::MachOFile.new(macho_path_copy_dylib)

# puts "copy rpath: #{copy.rpaths}    ---origin---: #{origin.rpaths}"

# MachO::Tools.delete_rpath(macho_path_copy_dylib, '@loader_path/Frameworks/cat/cat')

# copy = MachO::MachOFile.new(macho_path_copy_dylib)

# puts "copy rpath: #{copy.rpaths}    ---origin---: #{origin.rpaths}"
