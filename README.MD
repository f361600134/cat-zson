# Cat Framework

一个功能强大的 Flutter 脚手架框架，基于从 yueji_client 工程提炼出的最佳实践。

## 🎯 核心特性

### 响应式导航系统
- ✅ **智能断点判断** - 自动识别移动端、平板、桌面端
- ✅ **多模式导航** - 抽屉式(移动端) / 可收缩侧边栏(平板) / 固定侧边栏(桌面端)
- ✅ **SidebarX 深度集成** - 丰富的自定义配置选项
- ✅ **完整路由管理** - 路由跳转、历史记录、状态管理

### 框架能力
- 🏗️ **模块化架构** - 清晰的项目结构和依赖注入
- 🌐 **网络层封装** - 基于 Dio 的协议适配器
- 💾 **存储管理** - 类型安全的本地存储方案
- 🎨 **主题系统** - 支持亮色/暗色主题切换
- 🌍 **国际化支持** - 多语言切换机制
- 📢 **事件总线** - 模块间解耦通信
- ⚡ **异步任务** - 轮询服务和任务管理
- 🔔 **通知系统** - 优雅的消息提示

## 🚀 快速开始

### 1. 环境要求

```yaml
environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.2
  responsive_framework: ^1.5.1
  sidebarx: ^0.17.1
  # ... 其他依赖见 pubspec.yaml
```

### 2. 初始化框架

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Cat Framework
  await CatFramework.instance.initialize(
    config: const CatFrameworkConfig(),
    networkPlugins: [
      LoggingPlugin(enableDetailLog: true),
      CachePlugin(),
      RetryPlugin(maxRetries: 2),
    ],
  );

  runApp(const MyApp());
}
```

### 3. 使用响应式导航

```dart
class MainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints(
      breakpoints: const [
        Breakpoint(start: 0, end: 450, name: MOBILE),
        Breakpoint(start: 451, end: 800, name: TABLET),
        Breakpoint(start: 801, end: 1920, name: DESKTOP),
      ],
      child: GetBuilder<CatNavigationController>(
        init: CatNavigationController(),
        builder: (controller) {
          return CatResponsiveScaffold(
            navigationItems: navigationItems,
            config: navigationConfig,
            title: 'Cat Framework',
            body: bodyWidget,
            onRouteChanged: (route) {
              // 处理路由变化
            },
          );
        },
      ),
    );
  }
}
```

## 📱 响应式行为

| 设备类型 | 屏幕宽度 | 导航模式 | 特性 |
|---------|---------|---------|------|
| 移动端 | ≤ 450px | 抽屉式 | 点击菜单打开，选择后自动关闭 |
| 平板端 | 451-800px | 可收缩侧边栏 | 支持展开/收缩，动画过渡 |
| 桌面端 | > 800px | 固定侧边栏 | 默认展开，提供更多操作空间 |

## 🎨 主题系统

框架内置多种预设主题：

```dart
// Material Design 3 风格
NavigationThemes.material3Theme(context)

// 紧凑风格  
NavigationThemes.compactTheme(context)

// 现代风格
NavigationThemes.modernTheme(context)

// 深色主题
NavigationThemes.darkTheme(context)
```

## 🔧 配置选项

### 导航配置
```dart
NavigationConfig(
  extendedWidth: 280,           // 展开宽度
  collapsedWidth: 80,           // 收缩宽度  
  drawerWidth: 300,             // 抽屉宽度
  animationDuration: Duration(milliseconds: 300),
  showToggleButton: true,       // 显示切换按钮
  appName: 'Your App',          // 应用名称
  logo: yourLogoWidget,         // 应用Logo
  theme: customTheme,           // 自定义主题
  headerBuilder: headerBuilder, // 自定义头部
  footerBuilder: footerBuilder, // 自定义底部
)
```

### 框架配置
```dart
CatFrameworkConfig(
  appName: 'Cat Framework App',
  supportedLocales: [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ],
  fallbackLocale: Locale('en', 'US'),
  defaultStorageContainer: 'cat_framework',
)
```

## 📂 项目结构

```
lib/
├── app/
│   ├── core/                    # 核心功能
│   │   ├── framework/           # 框架核心
│   │   ├── navigation/          # 导航系统 ⭐
│   │   ├── network/            # 网络层
│   │   ├── storage/            # 存储管理
│   │   ├── theme/              # 主题系统
│   │   ├── i18n/               # 国际化
│   │   └── event/              # 事件总线
│   ├── modules/                # 业务模块
│   │   ├── main/               # 主布局 ⭐
│   │   ├── home/               # 首页
│   │   ├── settings/           # 设置页
│   │   └── profile/            # 个人资料
│   ├── routes/                 # 路由配置
│   ├── utils/                  # 工具类
│   └── demo/                   # 演示页面 ⭐
└── main.dart                   # 应用入口
```

## 🎯 核心 API

### 导航控制器
```dart
final controller = Get.find<CatNavigationController>();

// 导航控制
controller.navigateTo('/target-route');
controller.goBack();
controller.refreshCurrentPage();

// 侧边栏控制
controller.toggleSidebar();
controller.expandSidebar(); 
controller.collapseSidebar();

// 状态查询
bool canGoBack = controller.canGoBack;
String currentRoute = controller.currentRoute.value;
NavigationItem? currentItem = controller.currentItem;
```

### 框架服务
```dart
// 存储管理
Cat.storage.write('key', value);
Cat.storage.read<T>('key');

// 配置管理  
Cat.config.getString('key', defaultValue);
Cat.config.getBool('key', defaultValue);

// 事件总线
Cat.events.fire(CustomEvent());
Cat.events.listen<CustomEvent>((event) {});

// 通知服务
Cat.notify.showSuccess(message: 'Success!');
Cat.notify.showError(message: 'Error!');

// 主题服务
Cat.theme?.enableDarkMode();
Cat.theme?.enableLightMode();
Cat.theme?.followSystem();
```

## 🎮 演示应用

运行项目查看完整的演示：

```bash
flutter run
```

访问 `/main` 路由体验完整的响应式导航系统。

## 🔍 主要特性演示

1. **响应式断点** - 调整浏览器窗口大小观察导航模式变化
2. **主题切换** - 在设置页面切换亮色/暗色主题
3. **路由管理** - 点击导航项观察页面切换和历史记录
4. **自定义配置** - 查看各种配置选项的效果

## 📖 详细文档

查看完整的使用指南和 API 文档。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**Cat Framework** - 让 Flutter 应用开发更简单、更高效！ 🐱
