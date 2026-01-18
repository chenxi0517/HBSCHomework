# HBSCHomework iOS App

## 项目介绍

这是一个使用Swift和UIKit开发的iOS应用，包含登录页、首页、搜索页和个人主页等功能。

## 功能特性

- 登录页（支持用户名密码登录和生物识别登录）
- 首页（支持未登录状态查看）
- 搜索页（支持GitHub用户搜索）
- 个人主页（支持用户登出）
- 通用错误页面
- 图片小部件（AsyncImageView）
- 支持深色与浅色模式
- 适配iPhone和iPad
- 使用本地化文件实现中文支持
- 调用GitHub API获取数据
- 使用Keychain安全存储用户凭据
- 使用XCAssets管理资源

## 技术栈

- 开发语言：Swift
- 框架：UIKit
- 自动布局：SnapKit
- 依赖管理：Swift Package Manager

## 如何运行项目

1. 在Xcode中打开项目
2. 选择项目文件（蓝色图标）
3. 切换到"Signing & Capabilities"标签
4. 在"Team"下拉菜单中选择您的开发团队
5. 切换到"Package Dependencies"标签
6. 点击"+"按钮，添加SnapKit依赖：
   - 输入URL：https://github.com/SnapKit/SnapKit.git
   - 选择版本：从5.6.0开始
7. 点击"Add Package"
8. 选择SnapKit库，添加到HBSCHomework目标
9. 运行项目

## 项目结构

```
HBSCHomework/
├── Controllers/          # 视图控制器
├── Extensions/           # 扩展
├── Localization/         # 本地化文件
├── Models/               # 数据模型
├── Protocols/            # 协议
├── Services/             # 服务层
├── Utils/                # 工具类
├── Views/                # 自定义视图
└── Assets.xcassets/      # 资源文件
```

## 注意事项

- 最低支持iOS 14版本
- 无需支持多语言，仅需中文
- 无需支持无障碍功能与标签功能
