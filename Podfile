source 'http://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '14.0'

# 定义共享依赖
def shared_pods
  pod 'SnapKit', '~> 5.6.0'
  pod 'SDWebImage', '~> 5.16.0'
end

target 'HBSCHomework' do
  use_frameworks!
  shared_pods
end

# 为测试target添加依赖
target 'HBSCHomeworkTests' do
  use_frameworks!
  shared_pods
end
