以下是我想实现的文件目录结构：
```
├── mockAPI/
├──────user/ 
│      ├── loginAPI.swift    // 包含登录相关的函数或类
│      ├── userAPI.swift     // 包含用户相关的函数或类
│      └── apiModels.swift      // 包含所有 API 请求和响应的数据模型
├── views/
├──────user/ 
│       ├── userView.swift
│       ├── userQRShowView.swift
│       └── AuthenticationManager.swift
```

现在已经编写好了基本的视图模块，该增加新的 api 来模仿用户数据了

需要模仿的属于有：用户头像、用户粉丝数、用户关注、用户等级、用户听歌时长、创建的歌单<br>
其中创建的歌单包括歌单封面、歌单名称、歌单歌曲数量、歌单播放次数<br>
单个歌单以列表的形式呈现，包括歌曲名称、歌曲作者、是否喜欢、播放按钮<br>
https://github.com/algerkong/AlgerMusicPlayer/blob/main/src/renderer/views/user/detail.vue
