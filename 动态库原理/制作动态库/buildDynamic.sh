echo "编译test.m --- test.o"
clang -target x86_64-apple-macos10.15 \
-fobjc-arc \
-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
-I./dylib \
-c test.m -o test.o
#-I 指定头文件所处的位置


echo "编译 TestExample.m --- libTestExample.dylib"
# -dynamiclib：动态库
pushd ./dylib

clang -dynamiclib \
-target x86_64-apple-macos10.15 \
-fobjc-arc \
-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
-Xlinker -install_name -Xlinker @rpath/dylib/libTestExample.dylib \
TestExample.m -o libTestExample.dylib

# -Xlinker -install_name -Xlinker @rpath/libTestExample.dylib： 将 name 定义为 @rpath/libTestExample.dylib

echo "-------LC_ID_DYLIB---------"
otool -l libTestExample.dylib | grep 'LC_ID_DYLIB' -A 3

popd

#-L 库文件的位置
#-l 库文件的名称
echo "链接libTestExample.dylib -- test EXEC"
clang -target x86_64-apple-macos10.15 \
-fobjc-arc \
-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
-Xlinker -rpath -Xlinker @executable_path \
-L./dylib \
-lTestExample \
test.o -o test

echo "-------LC_RPATH---------"
otool -l test | grep 'LC_RPATH' -A 3

# -Xlinker -rpath -Xlinker @executable_path \ 将rpath定义为 @executable_path




