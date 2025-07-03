以下是我想实现的文件目录结构：
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

其中 mockAPI 文件夹尚未创建
我们来重构一下相关文件，在这里我们不管后端如何实现，只需要定义好 API 请求和响应的数据模型即可
我们该如何操作呢