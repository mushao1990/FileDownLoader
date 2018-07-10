## MSNetwork框架搭建思路（主要还是参考AFNetworking）

###框架需要类如下：

- 一个对NSURLSession进行管理的类（对应MSURLSessionManager）

-  一个网络请求请求解析类（MSURLRequestSerializaiton）

- 一个网络请求响应解析类（MSURLResponseSerialization）

- 一个网络加密证书相关类（MSSecurityPolicy）

### 相关关系图如下：
![图片](/Users/apple/Documents/Downloader/屏幕快照 2018-07-10 上午8.25.47.png)

#### 关于MSURLSessionManager的构建思路：

