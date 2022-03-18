const path = require("path");
const webpack = require("webpack");

function resolve(dir) {
    return path.join(__dirname, dir);
}

function getProductName(){
    let name = ''
    switch(process.env.CURRENT_PRO){
        case 'pluginScpmock':
            name = '环境配置';
            break
        case 'pluginH5':
            name = "环境配置_客户端";
            break
        case 'pluginIos':
            name = "环境配置_客户端插件_Ios";
            break
        case 'pluginAndroid':
            name = "环境配置_客户端插件_Android";
            break
        default :
            name = "环境配置_客户端";
    }
    return name;
}

module.exports = {
    configureWebpack: {
        plugins: [
            new webpack.DefinePlugin({
                "process.env": {
                    CURRENT_PRO: JSON.stringify(process.env.CURRENT_PRO),
                },
            }),
        ],
    },
    publicPath: "./",
    devServer: {
        // can be overwritten by process.env.HOST
        host: "0.0.0.0",
        port: 8080,
        proxy: {
            "/sinosun-ui": {
                target: "C:/D/project/Electron/electron-vue-test",
                changeOrigin: true,
                ws: true,
            },
        },
    },
    chainWebpack: (config) => {
        config.resolve.alias
            .set("@", resolve("src"))
            .set("src", resolve("src"))
            .set("common", resolve("src/common"))
            .set("components", resolve("src/components"));

        // config.module
        //     .rule('shebang')
        //     // .test(/\.js$/)
        //     .use('shebang-loader')
        //     .loader('shebang-loader')
        //     .end()

        // config.module
        //     .rule('shebang')
        //     .test(/node_modules\/_ecstatic@3.3.2@ecstatic\/lib\/ecstatic\.js$/)
        //     .use('shebang-loader')
        //     .loader('shebang-loader')
        //     .end()
    },
    pluginOptions: {
        electronBuilder: {
            builderOptions: {
                appId: "com.example.app",
                productName: getProductName(), //项目名，也是生成的安装文件名，即aDemo.exe
                copyright: "Copyright © 2019", //版权信息
                // "directories": {
                //     "output": "./dist"//输出文件路径
                // },
                asar: false, // asar打包
                win: {
                    //win相关配置
                    icon: "./public/app.ico", //图标，当前图标在根目录下，注意这里有两个坑
                    target: [
                        {
                            target: "nsis", //利用nsis制作安装程序
                            arch: [
                                "x64", //64位
                                "ia32", //32位
                            ],
                        },
                    ],
                },
                mac: {
                    icon: "./public/app.ico", //图标，当前图标在根目录下，注意这里有两个坑,
                    target: ["dmg"],
                },
                // "files": [
                //     "build/**/*",
                //     "main.js",
                //     "public/preload.js"
                // ]
            },
            nodeModulesPath: ['./public/scpmock/node_modules', './node_modules']
        },
    },
};
