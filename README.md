# RedNote

一个基于 IGListKit 的双列瀑布流 Feed 应用示例，包含动态高度计算、详情页分区展示、下拉刷新等功能。使用 SnapKit 管理约束，SDWebImage 加载图片，MJRefresh 提供下拉刷新。

## 功能特性

- 双列瀑布流布局，按内容动态计算高度
- 图片高度按真实宽高比计算，标题最多显示两行
- 详情页按 Header/Content/Author/Comments 分区展示
- 下拉刷新（MJRefresh）
- 简洁的约束和数据驱动（IGListKit）

## 效果预览

<p align="center">
  <img src="GithubImages/image1.jpg" alt="Feed 瀑布流" width="200" />
  <img src="GithubImages/image2.jpg" alt="详情页头图" width="200" />
</p>

## 技术栈

- `IGListKit`：数据驱动的列表架构
- `SnapKit`：约束布局
- `SDWebImage`：图片异步加载与缓存
- `MJRefresh`：下拉刷新
- 自定义 `WaterfallLayout`：双列瀑布流布局

## 运行环境

- iOS 15+
- Xcode 15+
- CocoaPods

## 快速开始

1. 安装依赖

   ```bash
   pod install
   ```
2. 使用 RedNote.xcworkspace 打开工程
3. 运行到模拟器或真机
