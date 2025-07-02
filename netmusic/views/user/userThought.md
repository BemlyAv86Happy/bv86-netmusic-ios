现在的结果已经明了了

让我们重新编写 userQrshow.swift 部分的代码，然让其满足以下功能

1. 调用后端的 generateQRCodeLogin, 生成二维码图像并显示在屏幕上
2. 调用后端的 pollingQrCodeLogin, 轮询二维码扫描结果
3. 如果登录成功，显示userMainView()，该文件暂为编写，主要是显示用户的个人信息
4. 如果登录失败，显示错误信息，并重新生成二维码
5. 存在一个默认二维码,该默认二维码将会在调用后端函数错误时出现
6. 该默认二维码指向的是 https://music.163.com/
7. 存在一个默认用户名，默认用户名为“蜂群987号”
8. 在页面左上角存在一个按钮，用于跳过二维码登录，直接显示userMainView()
重新编写 user.swift 部分的代码，然让其满足以下功能

1. 拥有以下全局变量：

    @Published var isLoggedIn: Bool = false

    @Published var qrCodeImage: Image?

    @Published var errorLoginMessage: AppError?

    @Published var userName: String?

    @Published var userInfo: String?

分别记录用户是否登录，二维码图像，登录错误信息，用户名，用户信息

2. 使用 if 函数来判断用户是否登录，以渲染不同的界面

if authManager.isLoggedIn {

    // 用户已登录，渲染其他界面（这里是占位符）

    userMainView() // 你需要创建这个视图

} else {

    // 用户尚未登录，显示二维码

    UserQRShowView()

}

3. 将Text("欢迎，用户已登录！")替换为Text("欢迎，\(userName)")

如果没有登录，则默认 userName 为‘蜂群987号’